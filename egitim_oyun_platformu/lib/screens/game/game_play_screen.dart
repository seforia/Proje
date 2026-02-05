import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:provider/provider.dart';
import '../../models/game_template.dart';
import '../../providers/game_provider.dart';
import '../../providers/auth_provider.dart';
import '../../game/templates/quiz_runner_game.dart';

class GamePlayScreen extends StatefulWidget {
  final GameTemplate gameTemplate;

  const GamePlayScreen({
    super.key,
    required this.gameTemplate,
  });

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  late QuizRunnerGame game;
  bool gameEnded = false;
  int finalScore = 0;
  bool gameCompleted = false;
  final DateTime startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    game = QuizRunnerGame(
      gameTemplate: widget.gameTemplate,
      onGameEnd: _onGameEnd,
    );
  }

  void _onGameEnd(int score, bool completed) {
    if (gameEnded) return;
    
    setState(() {
      gameEnded = true;
      finalScore = score;
      gameCompleted = completed;
    });

    // Record game play
    final authProvider = context.read<AuthProvider>();
    final gameProvider = context.read<GameProvider>();
    final duration = DateTime.now().difference(startTime).inSeconds;

    if (authProvider.userProfile != null) {
      gameProvider.recordGamePlay(
        userId: authProvider.userProfile!.id,
        gameId: 'local_game_${DateTime.now().millisecondsSinceEpoch}',
        score: score,
        completed: completed,
        duration: duration,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Game widget
          GameWidget(game: game),
          
          // HUD overlay
          if (!gameEnded)
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: _buildHUD(),
            ),
          
          // Game over overlay
          if (gameEnded)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: _buildGameOverDialog(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHUD() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${game.score}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Lives
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                for (int i = 0; i < game.lives; i++)
                  const Icon(Icons.favorite, color: Colors.red, size: 20),
                for (int i = game.lives; i < 3; i++)
                  const Icon(Icons.favorite_border, color: Colors.red, size: 20),
              ],
            ),
          ),
          
          // Timer
          if (widget.gameTemplate.config.timeLimit)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.gameTemplate.config.duration - game.gameTime.toInt()}s',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGameOverDialog() {
    return Card(
      margin: const EdgeInsets.all(40),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              gameCompleted ? Icons.emoji_events : Icons.refresh,
              size: 80,
              color: gameCompleted ? Colors.amber : Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              gameCompleted ? 'Tebrikler!' : 'Oyun Bitti',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Skor: $finalScore',
              style: const TextStyle(
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              gameCompleted
                  ? 'Tüm soruları tamamladın!'
                  : 'Tekrar dene!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Ana Sayfa'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      game = QuizRunnerGame(
                        gameTemplate: widget.gameTemplate,
                        onGameEnd: _onGameEnd,
                      );
                      gameEnded = false;
                      finalScore = 0;
                      gameCompleted = false;
                    });
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('Tekrar Oyna'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
