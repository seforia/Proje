class AppConstants {
  static const String appName = 'Eğitim Oyun Platformu';
  static const String appVersion = '1.0.0';

  // Age groups
  static const List<String> ageGroups = [
    '6-8',
    '9-11',
    '12-14',
    '15+',
  ];

  // Default values
  static const int feedPageSize = 20;
  static const int maxCommentLength = 500;
  static const int maxGameTitleLength = 50;
  static const int maxGameDescriptionLength = 200;

  // Error messages
  static const String networkError = 'İnternet bağlantısı yok';
  static const String unknownError = 'Bir hata oluştu';
  static const String authError = 'Giriş yapmanız gerekiyor';
}
