import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/subject_topic.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/game_constants.dart';
import '../../providers/game_provider.dart';
import '../../providers/auth_provider.dart';
import 'game_generation_screen.dart';

class TopicInputScreen extends StatefulWidget {
  final SubjectTopic subject;

  const TopicInputScreen({
    super.key,
    required this.subject,
  });

  @override
  State<TopicInputScreen> createState() => _TopicInputScreenState();
}

class _TopicInputScreenState extends State<TopicInputScreen> {
  String? _selectedTopic;
  String _selectedAge = AppConstants.ageGroups[1]; // Default: 9-11
  String _selectedDifficulty = GameConstants.easy; // Default: kolay

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject info
            Container(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Row(
                children: [
                  Text(
                    widget.subject.icon,
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(width: AppTheme.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.subject.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Bir konu seçin veya kendiniz yazın',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.paddingLarge),

            // Topic selection
            Text(
              'Konu',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.subject.topics.map((topic) {
                final isSelected = _selectedTopic == topic;
                return ChoiceChip(
                  label: Text(topic),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedTopic = selected ? topic : null;
                    });
                  },
                  selectedColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppTheme.paddingLarge),

            // Age group
            Text(
              'Yaş Grubu',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.ageGroups.map((age) {
                final isSelected = _selectedAge == age;
                return ChoiceChip(
                  label: Text('$age yaş'),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedAge = age;
                    });
                  },
                  selectedColor: AppTheme.secondaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppTheme.paddingLarge),

            // Difficulty
            Text(
              'Zorluk',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Row(
              children: [
                Expanded(
                  child: _DifficultyCard(
                    label: 'Kolay',
                    icon: Icons.sentiment_satisfied_rounded,
                    color: AppTheme.secondaryColor,
                    isSelected: _selectedDifficulty == GameConstants.easy,
                    onTap: () {
                      setState(() {
                        _selectedDifficulty = GameConstants.easy;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DifficultyCard(
                    label: 'Orta',
                    icon: Icons.sentiment_neutral_rounded,
                    color: Colors.orange,
                    isSelected: _selectedDifficulty == GameConstants.medium,
                    onTap: () {
                      setState(() {
                        _selectedDifficulty = GameConstants.medium;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DifficultyCard(
                    label: 'Zor',
                    icon: Icons.sentiment_very_dissatisfied_rounded,
                    color: AppTheme.errorColor,
                    isSelected: _selectedDifficulty == GameConstants.hard,
                    onTap: () {
                      setState(() {
                        _selectedDifficulty = GameConstants.hard;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingXLarge),

            // Generate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectedTopic != null ? _handleGenerate : null,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('AI ile Oyun Oluştur'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.secondaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleGenerate() {
    if (_selectedTopic == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameGenerationScreen(
          subject: widget.subject.name,
          topic: _selectedTopic!,
          age: _selectedAge,
          difficulty: _selectedDifficulty,
        ),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.grey.shade100,
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppTheme.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
