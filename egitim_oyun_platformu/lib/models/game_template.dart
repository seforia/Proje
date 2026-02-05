import 'dart:convert';

class GameTemplate {
  final String gameType;
  final String subject;
  final String topic;
  final String title;
  final String description;
  final String difficulty;
  final GameConfig config;
  final List<GameEntity> entities;
  final List<Question> questions;
  final Aesthetics aesthetics;

  GameTemplate({
    required this.gameType,
    required this.subject,
    required this.topic,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.config,
    required this.entities,
    required this.questions,
    required this.aesthetics,
  });

  factory GameTemplate.fromJson(Map<String, dynamic> json) {
    return GameTemplate(
      gameType: json['gameType'] as String,
      subject: json['subject'] as String,
      topic: json['topic'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      difficulty: json['difficulty'] as String,
      config: GameConfig.fromJson(json['config'] as Map<String, dynamic>),
      entities: (json['entities'] as List)
          .map((e) => GameEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList(),
      aesthetics: Aesthetics.fromJson(json['aesthetics'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gameType': gameType,
      'subject': subject,
      'topic': topic,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'config': config.toJson(),
      'entities': entities.map((e) => e.toJson()).toList(),
      'questions': questions.map((q) => q.toJson()).toList(),
      'aesthetics': aesthetics.toJson(),
    };
  }
}

class GameConfig {
  final int duration;
  final int targetScore;
  final double speed;
  final bool timeLimit;

  GameConfig({
    required this.duration,
    required this.targetScore,
    required this.speed,
    required this.timeLimit,
  });

  factory GameConfig.fromJson(Map<String, dynamic> json) {
    return GameConfig(
      duration: json['duration'] as int,
      targetScore: json['targetScore'] as int,
      speed: (json['speed'] as num).toDouble(),
      timeLimit: json['timeLimit'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'duration': duration,
      'targetScore': targetScore,
      'speed': speed,
      'timeLimit': timeLimit,
    };
  }
}

class GameEntity {
  final String id;
  final String type;
  final String name;
  final String sprite;
  final Map<String, dynamic>? properties;

  GameEntity({
    required this.id,
    required this.type,
    required this.name,
    required this.sprite,
    this.properties,
  });

  factory GameEntity.fromJson(Map<String, dynamic> json) {
    return GameEntity(
      id: json['id'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      sprite: json['sprite'] as String,
      properties: json['properties'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'sprite': sprite,
      if (properties != null) 'properties': properties,
    };
  }
}

class Question {
  final String id;
  final String text;
  final List<Answer> answers;
  final String correctAnswerId;
  final int points;

  Question({
    required this.id,
    required this.text,
    required this.answers,
    required this.correctAnswerId,
    required this.points,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      answers: (json['answers'] as List)
          .map((a) => Answer.fromJson(a as Map<String, dynamic>))
          .toList(),
      correctAnswerId: json['correctAnswerId'] as String,
      points: json['points'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'answers': answers.map((a) => a.toJson()).toList(),
      'correctAnswerId': correctAnswerId,
      'points': points,
    };
  }
}

class Answer {
  final String id;
  final String text;
  final String? sprite;

  Answer({
    required this.id,
    required this.text,
    this.sprite,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'] as String,
      text: json['text'] as String,
      sprite: json['sprite'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      if (sprite != null) 'sprite': sprite,
    };
  }
}

class Aesthetics {
  final String theme;
  final String backgroundColor;
  final String primaryColor;

  Aesthetics({
    required this.theme,
    required this.backgroundColor,
    required this.primaryColor,
  });

  factory Aesthetics.fromJson(Map<String, dynamic> json) {
    return Aesthetics(
      theme: json['theme'] as String,
      backgroundColor: json['backgroundColor'] as String,
      primaryColor: json['primaryColor'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'backgroundColor': backgroundColor,
      'primaryColor': primaryColor,
    };
  }
}
