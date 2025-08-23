import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF1E88E5);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF1565C0);

  static const Color secondary = Color(0xFF43A047);
  static const Color secondaryLight = Color(0xFF66BB6A);
  static const Color secondaryDark = Color(0xFF2E7D32);

  // Background Colors
  static const Color bgPrimary = Color(0xFF0A0A0A);
  static const Color bgSecondary = Color(0xFF1A1A1A);
  static const Color bgTertiary = Color(0xFF262626);
  static const Color bgQuaternary = Color(0xFF2A2A2A);
  static const Color bgCard = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF888888);
  static const Color textMuted = Color(0xFF666666);
  static const Color textDisabled = Color(0xFF555555);
  static const Color textInverse = Color(0xFF000000);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF66BB6A);
  static const Color successDark = Color(0xFF388E3C);

  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorDark = Color(0xFFD32F2F);

  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);

  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF42A5F5);
  static const Color infoDark = Color(0xFF1976D2);

  // Financial Colors
  static const Color profit = Color(0xFF4CAF50);
  static const Color loss = Color(0xFFF44336);
  static const Color neutral = Color(0xFF9E9E9E);
  static const Color pending = Color(0xFFFF9800);

  // Border & Divider Colors
  static const Color border = Color(0xFF333333);
  static const Color borderLight = Color(0xFF444444);
  static const Color borderDark = Color(0xFF222222);
  static const Color divider = Color(0xFF2E2E2E);

  // Surface Colors
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFF262626);
  static const Color overlay = Color(0x80000000);

  // Cryptocurrency Colors
  static const Color bitcoin = Color(0xFFF7931A);
  static const Color ethereum = Color(0xFF627EEA);
  static const Color binanceCoin = Color(0xFFF3BA2F);
  static const Color xrp = Color(0xFF23292F);
  static const Color cardano = Color(0xFF1652F0);
  static const Color solana = Color(0xFF9945FF);
  static const Color polkadot = Color(0xFFE6007A);
  static const Color chainlink = Color(0xFF375BD2);
  static const Color dogecoin = Color(0xFFC2A633);
  static const Color litecoin = Color(0xFFBFBFBF);
  static const Color polygon = Color(0xFF8247E5);
  static const Color avalanche = Color(0xFFE84142);
  static const Color uniswap = Color(0xFFFF007A);
  static const Color shibaInu = Color(0xFFFFA409);

  // DeFi Protocol Colors
  static const Color aave = Color(0xFFB6509E);
  static const Color compound = Color(0xFF00D395);
  static const Color pancakeSwap = Color(0xFFD1884F);
  static const Color sushiSwap = Color(0xFFFA52A0);
  static const Color curve = Color(0xFFFFD429);

  // Traditional Asset Colors
  static const Color stockThai = Color(0xFF1E88E5);
  static const Color stockUS = Color(0xFF4285F4);
  static const Color stockGlobal = Color(0xFF9C27B0);
  static const Color etf = Color(0xFF673AB7);
  static const Color mutualFund = Color(0xFF009688);
  static const Color bond = Color(0xFF795548);
  static const Color commodity = Color(0xFFFF5722);
  static const Color forex = Color(0xFF607D8B);
  static const Color cash = Color(0xFF4CAF50);

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF1E88E5), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFFEB3B), // Yellow
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
    Color(0xFFF44336), // Red
  ];

  // Pie Chart Colors for Asset Allocation
  static const List<Color> pieChartColors = [
    Color(0xFF1E88E5), // Crypto
    Color(0xFF4CAF50), // Stocks
    Color(0xFFFF9800), // ETF
    Color(0xFFE91E63), // Mutual Funds
    Color(0xFF9C27B0), // Bonds
    Color(0xFF00BCD4), // Cash
    Color(0xFFFFEB3B), // Commodities
    Color(0xFF795548), // Others
  ];

  // Transaction Type Colors
  static const Color transactionBuy = Color(0xFF4CAF50);
  static const Color transactionSell = Color(0xFFF44336);
  static const Color transactionDividend = Color(0xFFFF9800);
  static const Color transactionTransfer = Color(0xFF2196F3);
  static const Color transactionFee = Color(0xFF9E9E9E);
  static const Color transactionSplit = Color(0xFF673AB7);

  // Risk Level Colors
  static const Color riskLow = Color(0xFF4CAF50);
  static const Color riskMedium = Color(0xFFFF9800);
  static const Color riskHigh = Color(0xFFF44336);
  static const Color riskVeryHigh = Color(0xFF9C27B0);

  // Goal Progress Colors
  static const Color goalAchieved = Color(0xFF4CAF50);
  static const Color goalOnTrack = Color(0xFF2196F3);
  static const Color goalBehind = Color(0xFFFF9800);
  static const Color goalOffTrack = Color(0xFFF44336);

  // Interactive Element Colors
  static const Color fabBackground = Color(0xFF1E88E5);
  static const Color fabForeground = Color(0xFFFFFFFF);

  static const Color buttonPrimary = Color(0xFF4CAF50);
  static const Color buttonPrimaryPressed = Color(0xFF45A049);
  static const Color buttonSecondary = Color(0x00FFFFFF);
  static const Color buttonSecondaryPressed = Color(0xFF2A2A2A);

  static const Color inputBackground = Color(0xFF1A1A1A);
  static const Color inputBorder = Color(0xFF333333);
  static const Color inputFocused = Color(0xFF1E88E5);
  static const Color inputError = Color(0xFFF44336);

  // Gradient Colors
  static const LinearGradient profitGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lossGradient = LinearGradient(
    colors: [Color(0xFFF44336), Color(0xFFE91E63)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E88E5), Color(0xFF3F51B5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient aiGradient = LinearGradient(
    colors: [Color(0xFF1E88E5), Color(0xFF3F51B5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient riskGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFFFF9800), Color(0xFFF44336)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Opacity Variants
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha:opacity);
  }

  // Chart Fill Colors with Opacity
  static final Color chartFillProfit = profit.withValues(alpha: 0.1);
  static final Color chartFillLoss = error.withValues(alpha:0.1);
  static final Color chartFillNeutral = neutral.withValues(alpha:0.1);

  // Market Status Colors
  static const Color marketOpen = Color(0xFF4CAF50);
  static const Color marketClosed = Color(0xFFF44336);
  static const Color marketPremarket = Color(0xFFFF9800);
  static const Color marketAfterHours = Color(0xFF2196F3);

  // News & Sentiment Colors
  static const Color newsBullish = Color(0xFF4CAF50);
  static const Color newsBearish = Color(0xFFF44336);
  static const Color newsNeutral = Color(0xFF9E9E9E);

  // Theme-specific Color Schemes
  static const ColorScheme darkColorScheme = ColorScheme.dark(
    primary: primary,
    secondary: secondary,
    surface: bgSecondary,
    error: error,
    onPrimary: textPrimary,
    onSecondary: textPrimary,
    onSurface: textPrimary,
    onError: textPrimary,
  );

  // Material 3 Color Roles
  static const Color primaryContainer = Color(0xFF1565C0);
  static const Color onPrimaryContainer = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF2E7D32);
  static const Color onSecondaryContainer = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFF57C00);
  static const Color onTertiaryContainer = Color(0xFFFFFFFF);

  // Utility Methods
  static Color getAssetColor(String assetType) {
    switch (assetType.toUpperCase()) {
      case 'BTC':
      case 'BITCOIN':
        return bitcoin;
      case 'ETH':
      case 'ETHEREUM':
        return ethereum;
      case 'BNB':
      case 'BINANCE':
        return binanceCoin;
      case 'XRP':
        return xrp;
      case 'ADA':
      case 'CARDANO':
        return cardano;
      case 'SOL':
      case 'SOLANA':
        return solana;
      case 'STOCK_TH':
        return stockThai;
      case 'STOCK_US':
        return stockUS;
      case 'ETF':
        return etf;
      case 'MUTUAL_FUND':
        return mutualFund;
      default:
        return neutral;
    }
  }

  static Color getTransactionColor(String transactionType) {
    switch (transactionType.toUpperCase()) {
      case 'BUY':
        return transactionBuy;
      case 'SELL':
        return transactionSell;
      case 'DIVIDEND':
        return transactionDividend;
      case 'TRANSFER':
        return transactionTransfer;
      case 'FEE':
        return transactionFee;
      default:
        return neutral;
    }
  }

  static Color getRiskColor(double riskScore) {
    if (riskScore <= 3.0) {
      return riskLow;
    } else if (riskScore <= 6.0) {
      return riskMedium;
    } else if (riskScore <= 8.0) {
      return riskHigh;
    } else {
      return riskVeryHigh;
    }
  }

  static Color getProfitLossColor(double value) {
    if (value > 0) {
      return profit;
    } else if (value < 0) {
      return loss;
    } else {
      return neutral;
    }
  }
}