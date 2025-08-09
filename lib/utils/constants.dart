class AppConstants {
  // Google Sheets
  static const String defaultSpreadsheetName = 'Investment Tracker';

  // API Keys (ใส่ API Key จริงของคุณที่นี่)
  static const String alphaVantageApiKey = 'YOUR_ALPHA_VANTAGE_API_KEY';
  static const String coinGeckoApiKey = 'YOUR_COINGECKO_API_KEY'; // ไม่บังคับ

  // Colors
  static const int primaryColor = 0xFF2196F3;
  static const int profitColor = 0xFF4CAF50;
  static const int lossColor = 0xFFF44336;

  // Format
  static const String currencySymbol = '฿';
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  // Validation
  static const double minInvestmentAmount = 0.01;
  static const double maxInvestmentAmount = 999999999.99;
}