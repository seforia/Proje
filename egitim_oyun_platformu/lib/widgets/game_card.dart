import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_metadata.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../core/theme/app_theme.dart';

class GameCard extends StatelessWidget {
  final GameMetadata game;

  const GameCard({
    super.key,
    required this.game,
  });

  Color _getDifficultyColor() {
    switch (game.difficulty.toLowerCase()) {
      case 'kolay':
        return AppTheme.secondaryColor;
      case 'orta':
        return Colors.orange;
      case 'zor':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getSubjectIcon() {
    switch (game.subject.toLowerCase()) {
      case 'matematik':
        return Icons.calculate_rounded;
      case 'fen bilgisi':
      case 'fen':
        return Icons.science_rounded;
      case 'türkçe':
        return Icons.book_rounded;
      case 'ingilizce':
        return Icons.language_rounded;
      case 'sosyal bilgiler':
      case 'sosyal':
        return Icons.public_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.user?.uid;

    return Card(
      child: InkWell(
        onTap: () {
          _showGameDetails(context);
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Icon(
                      _getSubjectIcon(),
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: AppTheme.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Oluşturan: ${game.creatorName}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.paddingMedium),

              // Tags
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(game.subject),
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    labelStyle: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  Chip(
                    label: Text(game.topic),
                    backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                    labelStyle: const TextStyle(
                      color: AppTheme.secondaryColor,
                      fontSize: 12,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  Chip(
                    label: Text(game.difficulty),
                    backgroundColor: _getDifficultyColor().withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: _getDifficultyColor(),
                      fontSize: 12,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.paddingMedium),

              // Stats
              Row(
                children: [
                  Icon(
                    Icons.play_arrow_rounded,
                    size: 20,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${game.plays} oynandı',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(width: AppTheme.paddingMedium),
                  Icon(
                    Icons.favorite_rounded,
                    size: 20,
                    color: AppTheme.accentColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${game.likes} beğeni',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.paddingMedium),

              // Play button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to game play screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Oyun oynatma özelliği yakında eklenecek!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Oyna'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGameDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLarge),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.paddingLarge),

              // Title
              Text(
                game.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppTheme.paddingSmall),

              // Creator
              Row(
                children: [
                  Icon(
                    Icons.person_rounded,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    game.creatorName,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.paddingLarge),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    icon: Icons.play_arrow_rounded,
                    label: 'Oynandı',
                    value: '${game.plays}',
                  ),
                  _StatItem(
                    icon: Icons.favorite_rounded,
                    label: 'Beğeni',
                    value: '${game.likes}',
                    iconColor: AppTheme.accentColor,
                  ),
                  _StatItem(
                    icon: Icons.school_rounded,
                    label: 'Zorluk',
                    value: game.difficulty,
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.paddingLarge),

              // Subject & Topic
              Text(
                'Konu',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppTheme.paddingSmall),
              Text('${game.subject} - ${game.topic}'),
              const SizedBox(height: AppTheme.paddingLarge),

              // Play button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Oyun oynatma özelliği yakında eklenecek!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Oyuna Başla'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: iconColor ?? AppTheme.primaryColor,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }
}
