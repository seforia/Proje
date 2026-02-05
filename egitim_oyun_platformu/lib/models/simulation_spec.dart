// JSON-driven Simulation Specification
// AI yalnızca bu formatı üretir, motor kodu yazmaz

class SimulationSpec {
  final SimulationMeta meta;
  final SimulationScene scene;
  final List<SimulationEntity> entities;
  final SimulationRules rules;
  final List<SimulationGoal> goals;
  final SimulationConstraints constraints;
  final SimulationScoring scoring;
  final SimulationPedagogy pedagogy;

  SimulationSpec({
    required this.meta,
    required this.scene,
    required this.entities,
    required this.rules,
    required this.goals,
    required this.constraints,
    required this.scoring,
    required this.pedagogy,
  });

  factory SimulationSpec.fromJson(Map<String, dynamic> json) {
    return SimulationSpec(
      meta: SimulationMeta.fromJson(json['meta']),
      scene: SimulationScene.fromJson(json['simulation']['scene']),
      entities: (json['simulation']['entities'] as List)
          .map((e) => SimulationEntity.fromJson(e))
          .toList(),
      rules: SimulationRules.fromJson(json['simulation']['rules']),
      goals: (json['goals'] as List)
          .map((g) => SimulationGoal.fromJson(g))
          .toList(),
      constraints: SimulationConstraints.fromJson(json['constraints']),
      scoring: SimulationScoring.fromJson(json['scoring']),
      pedagogy: SimulationPedagogy.fromJson(json['pedagogy']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meta': meta.toJson(),
      'simulation': {
        'scene': scene.toJson(),
        'entities': entities.map((e) => e.toJson()).toList(),
        'rules': rules.toJson(),
      },
      'goals': goals.map((g) => g.toJson()).toList(),
      'constraints': constraints.toJson(),
      'scoring': scoring.toJson(),
      'pedagogy': pedagogy.toJson(),
    };
  }
}

class SimulationMeta {
  final String id;
  final String title;
  final String subject;
  final String topic;
  final String gradeBand;
  final String difficulty;
  final String language;

  SimulationMeta({
    required this.id,
    required this.title,
    required this.subject,
    required this.topic,
    required this.gradeBand,
    required this.difficulty,
    this.language = 'tr',
  });

  factory SimulationMeta.fromJson(Map<String, dynamic> json) {
    return SimulationMeta(
      id: json['id'],
      title: json['title'],
      subject: json['subject'],
      topic: json['topic'],
      gradeBand: json['gradeBand'],
      difficulty: json['difficulty'],
      language: json['language'] ?? 'tr',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'topic': topic,
      'gradeBand': gradeBand,
      'difficulty': difficulty,
      'language': language,
    };
  }
}

class SimulationScene {
  final double width;
  final double height;
  final String background;
  final GridConfig? grid;

  SimulationScene({
    required this.width,
    required this.height,
    required this.background,
    this.grid,
  });

  factory SimulationScene.fromJson(Map<String, dynamic> json) {
    return SimulationScene(
      width: json['width'].toDouble(),
      height: json['height'].toDouble(),
      background: json['background'],
      grid: json['grid'] != null ? GridConfig.fromJson(json['grid']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'background': background,
      if (grid != null) 'grid': grid!.toJson(),
    };
  }
}

class GridConfig {
  final bool enabled;
  final int size;

  GridConfig({required this.enabled, required this.size});

  factory GridConfig.fromJson(Map<String, dynamic> json) {
    return GridConfig(
      enabled: json['enabled'],
      size: json['size'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'enabled': enabled, 'size': size};
  }
}

class SimulationEntity {
  final String id;
  final String type;
  final Position position;
  final double angleDeg;
  final bool draggable;
  final bool rotatable;
  final Map<String, dynamic> properties;

  SimulationEntity({
    required this.id,
    required this.type,
    required this.position,
    this.angleDeg = 0,
    this.draggable = false,
    this.rotatable = false,
    this.properties = const {},
  });

  factory SimulationEntity.fromJson(Map<String, dynamic> json) {
    return SimulationEntity(
      id: json['id'],
      type: json['type'],
      position: Position.fromJson(json['position']),
      angleDeg: json['angleDeg']?.toDouble() ?? 0,
      draggable: json['draggable'] ?? false,
      rotatable: json['rotatable'] ?? false,
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'position': position.toJson(),
      'angleDeg': angleDeg,
      'draggable': draggable,
      'rotatable': rotatable,
      if (properties.isNotEmpty) 'properties': properties,
    };
  }

  SimulationEntity copyWith({
    String? id,
    String? type,
    Position? position,
    double? angleDeg,
    bool? draggable,
    bool? rotatable,
    Map<String, dynamic>? properties,
  }) {
    return SimulationEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      angleDeg: angleDeg ?? this.angleDeg,
      draggable: draggable ?? this.draggable,
      rotatable: rotatable ?? this.rotatable,
      properties: properties ?? this.properties,
    );
  }
}

class Position {
  final double x;
  final double y;

  Position({required this.x, required this.y});

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'x': x, 'y': y};
  }
}

// Type alias for clarity
typedef SimulationPosition = Position;

class SimulationRules {
  final ReflectionRule? reflection;
  final RayConfig? ray;

  SimulationRules({this.reflection, this.ray});

  factory SimulationRules.fromJson(Map<String, dynamic> json) {
    return SimulationRules(
      reflection: json['reflection'] != null
          ? ReflectionRule.fromJson(json['reflection'])
          : null,
      ray: json['ray'] != null ? RayConfig.fromJson(json['ray']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (reflection != null) 'reflection': reflection!.toJson(),
      if (ray != null) 'ray': ray!.toJson(),
    };
  }
}

class ReflectionRule {
  final bool enabled;
  final String law;

  ReflectionRule({required this.enabled, required this.law});

  factory ReflectionRule.fromJson(Map<String, dynamic> json) {
    return ReflectionRule(
      enabled: json['enabled'],
      law: json['law'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'enabled': enabled, 'law': law};
  }
}

class RayConfig {
  final int maxBounces;
  final double maxLength;

  RayConfig({required this.maxBounces, required this.maxLength});

  factory RayConfig.fromJson(Map<String, dynamic> json) {
    return RayConfig(
      maxBounces: json['maxBounces'],
      maxLength: json['maxLength'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'maxBounces': maxBounces, 'maxLength': maxLength};
  }
}

class SimulationGoal {
  final String id;
  final String type;
  final String? targetId;

  SimulationGoal({
    required this.id,
    required this.type,
    this.targetId,
  });

  factory SimulationGoal.fromJson(Map<String, dynamic> json) {
    return SimulationGoal(
      id: json['id'],
      type: json['type'],
      targetId: json['targetId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      if (targetId != null) 'targetId': targetId,
    };
  }
}

class SimulationConstraints {
  final int maxMoves;
  final int timeLimitSec;

  SimulationConstraints({
    required this.maxMoves,
    required this.timeLimitSec,
  });

  factory SimulationConstraints.fromJson(Map<String, dynamic> json) {
    return SimulationConstraints(
      maxMoves: json['maxMoves'],
      timeLimitSec: json['timeLimitSec'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxMoves': maxMoves,
      'timeLimitSec': timeLimitSec,
    };
  }
}

class SimulationScoring {
  final int base;
  final int timeBonusPerSec;
  final int movePenalty;
  final PrecisionBonus? precisionBonus;

  SimulationScoring({
    required this.base,
    required this.timeBonusPerSec,
    required this.movePenalty,
    this.precisionBonus,
  });

  factory SimulationScoring.fromJson(Map<String, dynamic> json) {
    return SimulationScoring(
      base: json['base'],
      timeBonusPerSec: json['timeBonusPerSec'],
      movePenalty: json['movePenalty'],
      precisionBonus: json['precisionBonus'] != null
          ? PrecisionBonus.fromJson(json['precisionBonus'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base': base,
      'timeBonusPerSec': timeBonusPerSec,
      'movePenalty': movePenalty,
      if (precisionBonus != null) 'precisionBonus': precisionBonus!.toJson(),
    };
  }
}

class PrecisionBonus {
  final bool enabled;
  final double thresholdPx;
  final int bonus;

  PrecisionBonus({
    required this.enabled,
    required this.thresholdPx,
    required this.bonus,
  });

  factory PrecisionBonus.fromJson(Map<String, dynamic> json) {
    return PrecisionBonus(
      enabled: json['enabled'],
      thresholdPx: json['thresholdPx'].toDouble(),
      bonus: json['bonus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'thresholdPx': thresholdPx,
      'bonus': bonus,
    };
  }
}

class SimulationPedagogy {
  final String concept;
  final String hint;
  final String explain;
  final List<String>? tutorialSteps;

  SimulationPedagogy({
    required this.concept,
    required this.hint,
    required this.explain,
    this.tutorialSteps,
  });

  factory SimulationPedagogy.fromJson(Map<String, dynamic> json) {
    return SimulationPedagogy(
      concept: json['concept'],
      hint: json['hint'],
      explain: json['explain'],
      tutorialSteps: json['tutorialSteps'] != null
          ? List<String>.from(json['tutorialSteps'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'concept': concept,
      'hint': hint,
      'explain': explain,
      if (tutorialSteps != null) 'tutorialSteps': tutorialSteps,
    };
  }
}
