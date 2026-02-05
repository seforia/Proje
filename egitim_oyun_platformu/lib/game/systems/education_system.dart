import '../../models/simulation_spec.dart';

/// Educational feedback and tutorial system
/// Provides step-by-step guidance, hints, and rule validation
class EducationSystem {
  final SimulationPedagogy pedagogy;
  int _currentStepIndex = 0;
  int _hintLevel = 0;
  final List<String> _feedbackMessages = [];

  EducationSystem(this.pedagogy);

  /// Get current tutorial step
  String? get currentStep {
    if (_currentStepIndex >= (pedagogy.tutorialSteps?.length ?? 0)) return null;
    return pedagogy.tutorialSteps?[_currentStepIndex];
  }

  /// Advance to next tutorial step
  void nextStep() {
    if (_currentStepIndex < (pedagogy.tutorialSteps?.length ?? 0)) {
      _currentStepIndex++;
    }
  }

  /// Check if tutorial is complete
  bool get isTutorialComplete =>
      _currentStepIndex >= (pedagogy.tutorialSteps?.length ?? 0);

  /// Get progressive hint (reveals more detail each time)
  String getHint() {
    final List<String> hintLevels = [
      pedagogy.concept, // Level 0: Concept only
      pedagogy.hint, // Level 1: Basic hint
      pedagogy.explain, // Level 2: Full explanation
      'Tüm ipuçları gösterildi. Denemeye devam et!', // Level 3+
    ];

    final String hint =
        hintLevels[_hintLevel.clamp(0, hintLevels.length - 1)];
    _hintLevel++;
    return hint;
  }

  /// Reset hint level
  void resetHints() {
    _hintLevel = 0;
  }

  /// Validate physics rule (e.g., reflection law)
  RuleValidationResult validateReflection({
    required double incidentAngle,
    required double reflectedAngle,
    double tolerance = 2.0, // degrees
  }) {
    final double error = (incidentAngle - reflectedAngle).abs();
    final bool isValid = error <= tolerance;

    String feedback;
    if (isValid) {
      feedback = '✅ Doğru! Gelme açısı (${incidentAngle.toStringAsFixed(1)}°) = '
          'Yansıma açısı (${reflectedAngle.toStringAsFixed(1)}°)';
    } else {
      feedback = '❌ Dikkat! Gelme açısı (${incidentAngle.toStringAsFixed(1)}°) ≠ '
          'Yansıma açısı (${reflectedAngle.toStringAsFixed(1)}°). '
          'Fark: ${error.toStringAsFixed(1)}°';
    }

    _feedbackMessages.add(feedback);
    return RuleValidationResult(isValid: isValid, feedback: feedback);
  }

  /// Check goal achievement (e.g., ray hit target)
  GoalResult checkGoal({
    required bool targetHit,
    required double precision, // px
    required int moveCount,
    required double timeSpent, // seconds
  }) {
    if (!targetHit) {
      _feedbackMessages.add('🎯 Hedefi vur! Işığı veya aynayı ayarla.');
      return GoalResult(
        achieved: false,
        feedback: 'Hedef henüz vurulmadı',
      );
    }

    String feedback = '🎉 Hedef vuruldu!\n';
    feedback += '⏱️ Süre: ${timeSpent.toInt()} saniye\n';
    feedback += '🔄 Hamle: $moveCount\n';
    feedback += '🎯 Hassasiyet: ${precision.toStringAsFixed(1)} px\n';

    if (precision < 10) {
      feedback += '⭐ Mükemmel hassasiyet!';
    } else if (precision < 20) {
      feedback += '👍 İyi hassasiyet!';
    }

    _feedbackMessages.add(feedback);
    return GoalResult(achieved: true, feedback: feedback);
  }

  /// Get all feedback messages
  List<String> get feedbackHistory => List.unmodifiable(_feedbackMessages);

  /// Clear feedback history
  void clearFeedback() {
    _feedbackMessages.clear();
  }

  /// Get success screen data
  SuccessScreenData getSuccessData({
    required int score,
    required double timeSpent,
    required int moveCount,
    required double precision,
  }) {
    String rating;
    if (score >= 150 && moveCount <= 3 && timeSpent <= 30) {
      rating = '⭐⭐⭐ Mükemmel!';
    } else if (score >= 120 && moveCount <= 4) {
      rating = '⭐⭐ Çok iyi!';
    } else if (score >= 100) {
      rating = '⭐ Tamamlandı!';
    } else {
      rating = '✅ Başarılı';
    }

    return SuccessScreenData(
      rating: rating,
      score: score,
      timeSpent: timeSpent.toInt(),
      moveCount: moveCount,
      precision: precision,
      explanation: pedagogy.explain,
      concept: pedagogy.concept,
    );
  }
}

/// Rule validation result
class RuleValidationResult {
  final bool isValid;
  final String feedback;

  RuleValidationResult({required this.isValid, required this.feedback});
}

/// Goal achievement result
class GoalResult {
  final bool achieved;
  final String feedback;

  GoalResult({required this.achieved, required this.feedback});
}

/// Success screen data
class SuccessScreenData {
  final String rating;
  final int score;
  final int timeSpent;
  final int moveCount;
  final double precision;
  final String explanation;
  final String concept;

  SuccessScreenData({
    required this.rating,
    required this.score,
    required this.timeSpent,
    required this.moveCount,
    required this.precision,
    required this.explanation,
    required this.concept,
  });
}
