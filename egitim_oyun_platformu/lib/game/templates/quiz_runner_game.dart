import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../models/game_template.dart';
import '../components/player_component.dart';
import '../components/obstacle_component.dart';
import 'dart:math';

class QuizRunnerGame extends FlameGame with TapCallbacks {
  final GameTemplate gameTemplate;
  final Function(int score, bool completed) onGameEnd;

  late PlayerComponent player;

  int currentQuestionIndex = 0;
  int score = 0;
  int lives = 3;
  double obstacleSpawnTimer = 0;
  double obstacleSpawnInterval = 2.0;
  bool isGameOver = false;
  double gameTime = 0;

  final Random random = Random();

  QuizRunnerGame({
    required this.gameTemplate,
    required this.onGameEnd,
  });

  @override
  Color backgroundColor() {
    try {
      final colorStr = gameTemplate.aesthetics.backgroundColor;
      return Color(int.parse(colorStr.replaceAll('#', '0xff')));
    } catch (e) {
      return const Color(0xFF0a0a2e);
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final playerEntity = gameTemplate.entities.firstWhere(
      (e) => e.type == 'player',
      orElse: () => gameTemplate.entities.first,
    );

    final playerProps = playerEntity.properties ?? {};
    player = PlayerComponent(
      spriteName: playerEntity.sprite,
      jumpHeight: (playerProps['jumpHeight'] as num?)?.toDouble() ?? 150,
    );

    add(player);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isGameOver) return;

    gameTime += dt;

    if (gameTemplate.config.timeLimit && 
        gameTime >= gameTemplate.config.duration) {
      _endGame(false);
      return;
    }

    obstacleSpawnTimer += dt;
    if (obstacleSpawnTimer >= obstacleSpawnInterval) {
      _spawnObstacle();
      obstacleSpawnTimer = 0;
      obstacleSpawnInterval = max(0.8, obstacleSpawnInterval - 0.05);
    }

    // Auto-answer questions for MVP
    if (currentQuestionIndex < gameTemplate.questions.length &&
        gameTime.toInt() % 5 == 0 && gameTime - gameTime.toInt() < dt) {
      _autoAnswerQuestion();
    }
  }

  void _spawnObstacle() {
    final obstacleEntities = gameTemplate.entities
        .where((e) => e.type == 'obstacle')
        .toList();
    
    if (obstacleEntities.isEmpty) return;

    final obstacleEntity = obstacleEntities[random.nextInt(obstacleEntities.length)];
    final obstacleProps = obstacleEntity.properties ?? {};
    
    final obstacle = ObstacleComponent(
      spriteName: obstacleEntity.sprite,
      position: Vector2(size.x, PlayerComponent.groundLevel),
      speed: 200 + (gameTime * 10),
      damage: (obstacleProps['damage'] as num?)?.toInt() ?? 1,
    );

    add(obstacle);
  }

  void _autoAnswerQuestion() {
    if (currentQuestionIndex >= gameTemplate.questions.length) {
      _endGame(true);
      return;
    }

    final question = gameTemplate.questions[currentQuestionIndex];
    final isCorrect = random.nextBool();

    if (isCorrect) {
      score += question.points;
    } else {
      lives--;
      if (lives <= 0) {
        _endGame(false);
        return;
      }
    }

    currentQuestionIndex++;
  }

  void _endGame(bool completed) {
    if (isGameOver) return;
    isGameOver = true;
    onGameEnd(score, completed);
  }

  @override
  void onTapDown(TapDownEvent event) {
    player.jump();
  }
}
