class AppConstants {
  // Google Sign-In Configuration
  static const String serverClientId = '830462391740-a8793nia9nbpe8hhkshepc60htc5slge.apps.googleusercontent.com';

  // Optional: iOS Client ID (ถ้าต้องการ)
  static const String iosClientId = 'YOUR_IOS_CLIENT_ID_HERE.apps.googleusercontent.com';

  // Optional: Web Client ID (ถ้าต้องการ)
  static const String webClientId = '830462391740-a8793nia9nbpe8hhkshepc60htc5slge.apps.googleusercontent.com';

  // Google Sign-In Scopes
  static const List<String> googleSignInScopes = [
    'email',
    'profile',
    'https://www.googleapis.com/auth/drive.file',
  ];


  // ค่าคงที่ทั่วไปของแอพ
  static const String appName = 'Investment Tracker';
  static const String appVersion = '1.0.0';

  // ค่าคงที่สำหรับ Local Storage
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const String onboardingKey = 'has_completed_onboarding';
  static const String favoriteCoinsKey = 'favorite_coins';

  // ค่าคงที่สำหรับการตั้งค่า
  static const List<String> supportedLanguages = <String>['en', 'th'];
  static const List<String> defaultFiatCurrencies = <String>['USD', 'EUR', 'THB', 'JPY'];

  // ค่าคงที่สำหรับแผนภูมิ
  static const List<String> timeFrames = <String>['24h', '7d', '30d', '90d', '1y', 'all'];
  static const Map<String, String> timeFrameLabels = <String, String>{
    '24h': '24 ชั่วโมง',
    '7d': '7 วัน',
    '30d': '30 วัน',
    '90d': '90 วัน',
    '1y': '1 ปี',
    'all': 'ทั้งหมด',
  };

  // ค่าคงที่สำหรับการแจ้งเตือน
  static const int maxAlerts = 10;
  static const double defaultAlertThreshold = 5.0; // 5%
}