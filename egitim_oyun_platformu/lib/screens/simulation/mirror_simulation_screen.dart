import 'package:flutter/material.dart';
import 'dart:math';
import '../../game/systems/reflection_system.dart';
import '../../game/systems/education_system.dart';
import '../../game/systems/scoring_system.dart';
import '../../models/simulation_spec.dart';

/// Mirror reflection simulation screen (canvas-based)
class MirrorSimulationScreen extends StatefulWidget {
  final SimulationSpec spec;

  const MirrorSimulationScreen({Key? key, required this.spec})
      : super(key: key);

  @override
  State<MirrorSimulationScreen> createState() => _MirrorSimulationScreenState();
}

class _MirrorSimulationScreenState extends State<MirrorSimulationScreen>
    with TickerProviderStateMixin {
  late EducationSystem _educationSystem;
  late ScoringSystem _scoringSystem;
  late List<SimulationEntity> _entities;

  String? _selectedEntityId;
  bool _isRotating = false;
  bool _showTutorial = true;
  bool _goalAchieved = false;

  @override
  void initState() {
    super.initState();

    // Initialize systems
    _educationSystem = EducationSystem(widget.spec.pedagogy);

    _scoringSystem = ScoringSystem(ScoringConfig(
      baseScore: widget.spec.scoring.base,
      timeBonusPerSec: widget.spec.scoring.timeBonusPerSec,
      movePenalty: widget.spec.scoring.movePenalty,
      precisionBonus: widget.spec.scoring.precisionBonus?.bonus ?? 25,
      precisionThresholdPx: widget.spec.scoring.precisionBonus?.thresholdPx ?? 6,
      timeLimitSec: widget.spec.constraints.timeLimitSec.toDouble(),
    ));

    _entities = List.from(widget.spec.entities);

    // Start timer
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && !_goalAchieved) {
        setState(() {
          _scoringSystem.updateTime(0.1);
        });
        _startTimer();
      }
    });
  }

  void _onEntityDrag(String entityId, Offset delta) {
    setState(() {
      final index = _entities.indexWhere((e) => e.id == entityId);
      if (index != -1 && _entities[index].draggable) {
        _entities[index] = _entities[index].copyWith(
          position: SimulationPosition(
            x: _entities[index].position.x + delta.dx,
            y: _entities[index].position.y + delta.dy,
          ),
        );
        _scoringSystem.recordMove();
        _checkGoal();
      }
    });
  }

  void _onEntityRotate(String entityId, double deltaAngle) {
    setState(() {
      final index = _entities.indexWhere((e) => e.id == entityId);
      if (index != -1 && _entities[index].rotatable) {
        _entities[index] = _entities[index].copyWith(
          angleDeg: (_entities[index].angleDeg + deltaAngle) % 360,
        );
        _scoringSystem.recordMove();
        _checkGoal();
      }
    });
  }

  void _checkGoal() {
    final lightSource =
        _entities.firstWhere((e) => e.type == 'light_source');
    final mirrors = _entities.where((e) => e.type == 'mirror').toList();
    final target = _entities.firstWhere((e) => e.type == 'target');

    // Trace ray
    final reflectionSystem = ReflectionSystem();
    final segments = reflectionSystem.traceRay(
      origin: Offset(lightSource.position.x, lightSource.position.y),
      angleDeg: lightSource.angleDeg,
      mirrors: mirrors.map((m) {
        return MirrorEntity(
          id: m.id,
          position: Offset(m.position.x, m.position.y),
          angleDeg: m.angleDeg,
          length: m.properties['length'] as double? ?? 150,
        );
      }).toList(),
      maxBounces: widget.spec.rules.ray?.maxBounces ?? 3,
      maxSegmentLength: widget.spec.rules.ray?.maxLength.toDouble() ?? 1000,
    );

    // Check if ray hits target
    final targetRadius = target.properties['radius'] as double? ?? 20;
    final hitTarget = ReflectionSystem.hitsTarget(
      rayPath: segments,
      targetPosition: Offset(target.position.x, target.position.y),
      targetRadius: targetRadius,
    );

    if (hitTarget && !_goalAchieved) {
      setState(() {
        _goalAchieved = true;
      });
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    final breakdown = _scoringSystem.getBreakdown(
      goalAchieved: true,
      precisionPx: 5.0, // TODO: Calculate actual precision
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Başarılı!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.spec.pedagogy.explain,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(breakdown.toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Ana Menü'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetSimulation();
            },
            child: const Text('Tekrar Oyna'),
          ),
        ],
      ),
    );
  }

  void _resetSimulation() {
    setState(() {
      _entities = List.from(widget.spec.entities);
      _goalAchieved = false;
      _scoringSystem.reset();
      _educationSystem.resetHints();
    });
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final lightSource =
        _entities.firstWhere((e) => e.type == 'light_source');
    final mirrors = _entities.where((e) => e.type == 'mirror').toList();

    // Trace ray for visualization
    final reflectionSystem = ReflectionSystem();
    final segments = reflectionSystem.traceRay(
      origin: Offset(lightSource.position.x, lightSource.position.y),
      angleDeg: lightSource.angleDeg,
      mirrors: mirrors.map((m) {
        return MirrorEntity(
          id: m.id,
          position: Offset(m.position.x, m.position.y),
          angleDeg: m.angleDeg,
          length: m.properties['length'] as double? ?? 150,
        );
      }).toList(),
      maxBounces: widget.spec.rules.ray?.maxBounces ?? 3,
      maxSegmentLength: widget.spec.rules.ray?.maxLength.toDouble() ?? 1000,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.spec.meta.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () {
              final hint = _educationSystem.getHint();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(hint)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetSimulation,
          ),
        ],
      ),
      body: Column(
        children: [
          // HUD
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  '⏱️ ${_scoringSystem.elapsedTime.toInt()}s',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  '🔄 ${_scoringSystem.moveCount} hamle',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  '💯 ${_scoringSystem.score}',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),

          // Tutorial panel
          if (_showTutorial && _educationSystem.currentStep != null)
            Container(
              color: Colors.blue.shade50,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.school, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _educationSystem.currentStep!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      setState(() {
                        _showTutorial = false;
                      });
                    },
                  ),
                ],
              ),
            ),

          // Canvas
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                if (_selectedEntityId != null) {
                  if (_isRotating) {
                    _onEntityRotate(_selectedEntityId!, 2.0);
                  } else {
                    _onEntityDrag(_selectedEntityId!, details.delta);
                  }
                }
              },
              onPanEnd: (_) {
                setState(() {
                  _selectedEntityId = null;
                  _isRotating = false;
                });
              },
              child: CustomPaint(
                painter: SimulationPainter(
                  entities: _entities,
                  raySegments: segments,
                  selectedEntityId: _selectedEntityId,
                  sceneConfig: widget.spec.scene,
                ),
                size: Size.infinite,
              ),
            ),
          ),

          // Control buttons
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isRotating = false;
                      _selectedEntityId = lightSource.id;
                    });
                  },
                  icon: const Icon(Icons.light_mode),
                  label: const Text('Işık'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isRotating = true;
                      _selectedEntityId = mirrors.first.id;
                    });
                  },
                  icon: const Icon(Icons.rotate_right),
                  label: const Text('Ayna'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for simulation rendering
class SimulationPainter extends CustomPainter {
  final List<SimulationEntity> entities;
  final List<RaySegment> raySegments;
  final String? selectedEntityId;
  final SimulationScene sceneConfig;

  SimulationPainter({
    required this.entities,
    required this.raySegments,
    required this.selectedEntityId,
    required this.sceneConfig,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final bgColor = Color(int.parse(sceneConfig.background.replaceFirst('#', '0xFF')));
    canvas.drawRect(Offset.zero & size, Paint()..color = bgColor);

    // Grid
    if (sceneConfig.grid?.enabled ?? false) {
      _drawGrid(canvas, size, sceneConfig.grid?.size ?? 20);
    }

    // Ray segments
    for (final segment in raySegments) {
      final paint = Paint()
        ..color = Colors.yellow.withOpacity(0.8)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(segment.start, segment.end, paint);
    }

    // Entities
    for (final entity in entities) {
      final position = Offset(entity.position.x, entity.position.y);
      final isSelected = entity.id == selectedEntityId;

      switch (entity.type) {
        case 'light_source':
          _drawLightSource(canvas, position, entity.angleDeg, isSelected);
          break;
        case 'mirror':
          final length = entity.properties['length'] as double? ?? 150;
          _drawMirror(canvas, position, entity.angleDeg, length, isSelected);
          break;
        case 'target':
          final radius = entity.properties['radius'] as double? ?? 20;
          _drawTarget(canvas, position, radius, isSelected);
          break;
      }
    }
  }

  void _drawGrid(Canvas canvas, Size size, int gridSize) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawLightSource(
      Canvas canvas, Offset position, double angleDeg, bool isSelected) {
    final paint = Paint()
      ..color = isSelected ? Colors.orangeAccent : Colors.orange
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, 12, paint);

    // Direction arrow
    final angleRad = angleDeg * pi / 180;
    final arrowEnd = position + Offset(cos(angleRad) * 25, sin(angleRad) * 25);
    canvas.drawLine(
      position,
      arrowEnd,
      Paint()
        ..color = Colors.yellow
        ..strokeWidth = 2,
    );
  }

  void _drawMirror(Canvas canvas, Offset position, double angleDeg,
      double length, bool isSelected) {
    final angleRad = angleDeg * pi / 180;
    final dir = Offset(cos(angleRad), sin(angleRad));
    final start = position - dir * length / 2;
    final end = position + dir * length / 2;

    canvas.drawLine(
      start,
      end,
      Paint()
        ..color = isSelected ? Colors.cyanAccent : Colors.cyan
        ..strokeWidth = 4,
    );

    // Normal indicator
    final normal = Offset(-sin(angleRad), cos(angleRad));
    canvas.drawLine(
      position,
      position + normal * 20,
      Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..strokeWidth = 1,
    );
  }

  void _drawTarget(
      Canvas canvas, Offset position, double radius, bool isSelected) {
    canvas.drawCircle(
      position,
      radius,
      Paint()
        ..color = isSelected ? Colors.greenAccent : Colors.green
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      position,
      radius * 0.5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant SimulationPainter oldDelegate) => true;
}
