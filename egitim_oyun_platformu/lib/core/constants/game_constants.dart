class GameConstants {
  // Game types
  static const String quizRunner = 'quiz_runner';
  static const String collector = 'collector';
  static const String puzzle = 'puzzle';

  // Difficulty levels
  static const String easy = 'kolay';
  static const String medium = 'orta';
  static const String hard = 'zor';

  // Themes
  static const String spaceTheme = 'space';
  static const String forestTheme = 'forest';
  static const String underwaterTheme = 'underwater';
  static const String desertTheme = 'desert';
  static const String cityTheme = 'city';

  // Entity types
  static const String player = 'player';
  static const String npc = 'npc';
  static const String item = 'item';
  static const String obstacle = 'obstacle';

  // Default game config
  static const int defaultDuration = 60;
  static const int defaultTargetScore = 100;
  static const double defaultSpeed = 1.0;
  static const bool defaultTimeLimit = true;

  // Points
  static const int correctAnswerPoints = 10;
  static const int wrongAnswerPenalty = -5;
}
