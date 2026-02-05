/// Deterministic scoring system with bonuses and penalties
class ScoringSystem {
  final ScoringConfig config;
  int _currentScore = 0;
  int _moveCount = 0;
  double _elapsedTime = 0;

  ScoringSystem(this.config) {
    _currentScore = config.baseScore;
  }

  /// Get current score
  int get score => _currentScore;

  /// Get current move count
  int get moveCount => _moveCount;

  /// Get elapsed time
  double get elapsedTime => _elapsedTime;

  /// Update elapsed time
  void updateTime(double deltaTime) {
    _elapsedTime += deltaTime;
  }

  /// Record a move (dragging or rotating entity)
  void recordMove() {
    _moveCount++;
    _currentScore -= config.movePenalty;
  }

  /// Calculate final score with all bonuses
  int calculateFinalScore({
    required bool goalAchieved,
    required double precisionPx,
  }) {
    if (!goalAchieved) return 0;

    int finalScore = config.baseScore;

    // Time bonus (faster = more points)
    final int timeBonus = (config.timeLimitSec - _elapsedTime).toInt() *
        config.timeBonusPerSec;
    if (timeBonus > 0) {
      finalScore += timeBonus;
    }

    // Move penalty (fewer moves = more points)
    finalScore -= _moveCount * config.movePenalty;

    // Precision bonus (hit close to center = bonus)
    if (precisionPx <= config.precisionThresholdPx) {
      finalScore += config.precisionBonus;
    }

    return finalScore.clamp(0, 999); // Max 999 points
  }

  /// Reset scoring
  void reset() {
    _currentScore = config.baseScore;
    _moveCount = 0;
    _elapsedTime = 0;
  }

  /// Get detailed score breakdown
  ScoreBreakdown getBreakdown({
    required bool goalAchieved,
    required double precisionPx,
  }) {
    final int timeBonus = (config.timeLimitSec - _elapsedTime).toInt() *
        config.timeBonusPerSec;
    final int movePenalty = _moveCount * config.movePenalty;
    final int precisionBonus =
        precisionPx <= config.precisionThresholdPx ? config.precisionBonus : 0;

    return ScoreBreakdown(
      baseScore: config.baseScore,
      timeBonus: timeBonus > 0 ? timeBonus : 0,
      movePenalty: movePenalty,
      precisionBonus: precisionBonus,
      finalScore: calculateFinalScore(
        goalAchieved: goalAchieved,
        precisionPx: precisionPx,
      ),
    );
  }
}

/// Scoring configuration (from SimulationSpec)
class ScoringConfig {
  final int baseScore;
  final int timeBonusPerSec;
  final int movePenalty;
  final int precisionBonus;
  final double precisionThresholdPx;
  final double timeLimitSec;

  ScoringConfig({
    required this.baseScore,
    required this.timeBonusPerSec,
    required this.movePenalty,
    required this.precisionBonus,
    required this.precisionThresholdPx,
    required this.timeLimitSec,
  });
}

/// Detailed score breakdown
class ScoreBreakdown {
  final int baseScore;
  final int timeBonus;
  final int movePenalty;
  final int precisionBonus;
  final int finalScore;

  ScoreBreakdown({
    required this.baseScore,
    required this.timeBonus,
    required this.movePenalty,
    required this.precisionBonus,
    required this.finalScore,
  });

  @override
  String toString() {
    return '''
🏆 Puan Detayları:
📊 Baz Puan: $baseScore
⏱️ Zaman Bonusu: +$timeBonus
🔄 Hamle Cezası: -$movePenalty
🎯 Hassasiyet Bonusu: +$precisionBonus
━━━━━━━━━━━━━━━━
💯 Toplam: $finalScore
''';
  }
}
