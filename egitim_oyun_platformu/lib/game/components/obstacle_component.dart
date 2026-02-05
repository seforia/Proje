import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

class ObstacleComponent extends PositionComponent with CollisionCallbacks {
  final String spriteName;
  final double speed;
  final int damage;

  ObstacleComponent({
    required this.spriteName,
    required Vector2 position,
    this.speed = 200,
    this.damage = 10,
  }) : super(
          size: Vector2(40, 40),
          position: position,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add collision hitbox
    add(RectangleHitbox()..debugMode = false);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move obstacle left
    position.x -= speed * dt;

    // Remove if off screen
    if (position.x < -size.x) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Simple colored shape for MVP (replace with sprite later)
    final paint = Paint()
      ..color = _getSpriteColor(spriteName)
      ..style = PaintingStyle.fill;
    
    if (spriteName.contains('meteor') || spriteName.contains('rock')) {
      // Draw diamond shape for rocks/meteors
      final path = Path()
        ..moveTo(size.x / 2, 0)
        ..lineTo(size.x, size.y / 2)
        ..lineTo(size.x / 2, size.y)
        ..lineTo(0, size.y / 2)
        ..close();
      canvas.drawPath(path, paint);
    } else if (spriteName.contains('tree')) {
      // Draw triangle for trees
      final path = Path()
        ..moveTo(size.x / 2, 0)
        ..lineTo(size.x, size.y)
        ..lineTo(0, size.y)
        ..close();
      canvas.drawPath(path, paint);
    } else {
      // Draw circle for other obstacles
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x / 2,
        paint,
      );
    }
    
    // Add border
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      borderPaint,
    );
  }

  Color _getSpriteColor(String name) {
    if (name.contains('red')) return Colors.red.shade700;
    if (name.contains('green')) return Colors.green.shade700;
    if (name.contains('brown')) return Colors.brown.shade700;
    if (name.contains('gray') || name.contains('rock')) return Colors.grey.shade700;
    return Colors.red.shade900;
  }
}
