import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_screen.dart';

class GameGenerationScreen extends StatefulWidget {
  final String subject;
  final String topic;
  final String age;
  final String difficulty;

  const GameGenerationScreen({
    super.key,
    required this.subject,
    required this.topic,
    required this.age,
    required this.difficulty,
  });

  @override
  State<GameGenerationScreen> createState() => _GameGenerationScreenState();
}

class _GameGenerationScreenState extends State<GameGenerationScreen> {
  @override
  void initState() {
    super.initState();
    _generateGame();
  }

  Future<void> _generateGame() async {
    final gameProvider = context.read<GameProvider>();

    // For MVP, use sample game instead of real AI
    // Change to real AI when Gemini API key is configured
    gameProvider.useSampleGame();

    // Uncomment for real AI generation:
    // await gameProvider.generateGame(
    //   subject: widget.subject,
    //   topic: widget.topic,
    //   age: widget.age,
    //   difficulty: widget.difficulty,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oyun Oluşturuluyor'),
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, _) {
          if (gameProvider.isGenerating) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: AppTheme.paddingLarge),
                  Text(
                    'AI oyununu hazırlıyor...',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppTheme.paddingSmall),
                  Text(
                    '${widget.subject} - ${widget.topic}',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            );
          }

          if (gameProvider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: AppTheme.errorColor,
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    Text(
                      'Oyun Oluşturulamadı',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppTheme.paddingSmall),
                    Text(
                      gameProvider.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),
                    ElevatedButton.icon(
                      onPressed: () {
                        gameProvider.clearError();
                        _generateGame();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Tekrar Dene'),
                    ),
                    const SizedBox(height: AppTheme.paddingSmall),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Geri Dön'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (gameProvider.currentGame != null) {
            return _GamePreview(
              onSave: _handleSave,
              onCancel: _handleCancel,
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Future<void> _handleSave() async {
    final gameProvider = context.read<GameProvider>();
    final authProvider = context.read<AuthProvider>();

    if (authProvider.user == null || authProvider.userProfile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kullanıcı bilgisi bulunamadı'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    final gameId = await gameProvider.saveGame(
      authProvider.user!.uid,
      authProvider.userProfile!.name,
    );

    if (gameId != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oyun başarıyla kaydedildi!'),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );

      // Navigate to home and clear game
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
      gameProvider.clearGame();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(gameProvider.error ?? 'Oyun kaydedilemedi'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _handleCancel() {
    final gameProvider = context.read<GameProvider>();
    gameProvider.clearGame();
    Navigator.of(context).pop();
  }
}

class _GamePreview extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _GamePreview({
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>().currentGame!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 50,
                color: AppTheme.secondaryColor,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),

          // Title
          Center(
            child: Text(
              'Oyun Hazır!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: AppTheme.paddingLarge),

          // Game info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppTheme.paddingSmall),
                  Text(
                    game.description,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(game.subject),
                        avatar: const Icon(Icons.school_rounded, size: 16),
                      ),
                      Chip(
                        label: Text(game.topic),
                        avatar: const Icon(Icons.topic_rounded, size: 16),
                      ),
                      Chip(
                        label: Text(game.difficulty),
                        avatar: const Icon(Icons.speed_rounded, size: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),

          // Game details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    icon: Icons.extension_rounded,
                    label: 'Oyun Tipi',
                    value: _getGameTypeLabel(game.gameType),
                  ),
                  const Divider(),
                  _InfoRow(
                    icon: Icons.question_answer_rounded,
                    label: 'Soru Sayısı',
                    value: '${game.questions.length} soru',
                  ),
                  const Divider(),
                  _InfoRow(
                    icon: Icons.timer_rounded,
                    label: 'Süre',
                    value: '${game.config.duration} saniye',
                  ),
                  const Divider(),
                  _InfoRow(
                    icon: Icons.stars_rounded,
                    label: 'Hedef Puan',
                    value: '${game.config.targetScore} puan',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.paddingXLarge),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  child: const Text('İptal'),
                ),
              ),
              const SizedBox(width: AppTheme.paddingMedium),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Kaydet ve Paylaş'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getGameTypeLabel(String gameType) {
    switch (gameType) {
      case 'quiz_runner':
        return 'Koşarak Soru Cevaplama';
      case 'collector':
        return 'Toplama Oyunu';
      case 'puzzle':
        return 'Bulmaca';
      default:
        return gameType;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: AppTheme.paddingSmall),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
