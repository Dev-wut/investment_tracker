import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextTheme {
  // ฟอนต์หลัก
  static const String fontFamily = 'Roboto';
  static const String numberFontFamily = 'Roboto Mono'; // สำหรับตัวเลข

  static TextTheme get defaultTextTheme => const TextTheme(
    // หัวข้อใหญ่ - มูลค่า Portfolio หลัก
    displayLarge: TextStyle(
      fontFamily: numberFontFamily,
      fontSize: 32.0,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -0.5,
      height: 1.2,
    ),
    // หัวข้อรอง - มูลค่าใหญ่
    displayMedium: TextStyle(
      fontFamily: numberFontFamily,
      fontSize: 28.0,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: -0.5,
      height: 1.2,
    ),
    // หัวข้อย่อย - ราคาสินทรัพย์
    displaySmall: TextStyle(
      fontFamily: numberFontFamily,
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.3,
    ),
    // หัวข้อหลักในหน้า - ชื่อหน้า
    headlineLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.3,
    ),
    // หัวข้อส่วนใหญ่ - ชื่อส่วน
    headlineMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.3,
    ),
    // หัวข้อย่อยในส่วน - ชื่อสินทรัพย์
    headlineSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.4,
    ),
    // เนื้อหาที่เน้น - รายละเอียดสำคัญ
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      height: 1.5,
    ),
    // เนื้อหาหลัก - ข้อความทั่วไป
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      height: 1.4,
    ),
    // เนื้อหาเล็ก - คำอธิบาย
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12.0,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      height: 1.4,
    ),
    // ข้อความในปุ่ม
    labelLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: 0.5,
    ),
    // คำอธิบายเล็ก - แท็บ, หมวดหมู่
    labelMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12.0,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
      letterSpacing: 0.3,
    ),
    // คำอธิบายเล็กมาก - วันที่, เวลา
    labelSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 10.0,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
      letterSpacing: 0.2,
    ),
  );

  // Text Styles เฉพาะสำหรับ Investment App

  // สำหรับแสดงราคาหลัก
  static const TextStyle priceText = TextStyle(
    fontFamily: numberFontFamily,
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // สำหรับแสดงเปอร์เซ็นต์เปลี่ยนแปลง
  static const TextStyle percentageText = TextStyle(
    fontFamily: numberFontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.2,
  );

  // สำหรับแสดงจำนวนหุ้น/เหรียญ
  static const TextStyle quantityText = TextStyle(
    fontFamily: numberFontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  // สำหรับชื่อสินทรัพย์
  static const TextStyle assetNameText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // สำหรับสัญลักษณ์สินทรัพย์ (BTC, ETH, etc.)
  static const TextStyle symbolText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  // สำหรับข้อความในกราฟ
  static const TextStyle chartLabelText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // สำหรับแสดงวันที่เวลา
  static const TextStyle dateTimeText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.3,
  );

  // สำหรับข้อความสถานะ
  static const TextStyle statusText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  // สำหรับหัวข้อในการ์ด
  static const TextStyle cardTitleText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // สำหรับข้อความใน Tab
  static const TextStyle tabText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.2,
  );

  // สำหรับข้อความ Hint ใน Input
  static const TextStyle hintText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.4,
  );

  // สำหรับข้อความ Error
  static const TextStyle errorText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: AppColors.error,
    height: 1.3,
  );

  // Utility Methods สำหรับสี Dynamic

  // ข้อความกำไร/ขาดทุน
  static TextStyle profitLossText(double value, {double fontSize = 14.0}) {
    return TextStyle(
      fontFamily: numberFontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: AppColors.getProfitLossColor(value),
      height: 1.2,
    );
  }

  // ข้อความเปอร์เซ็นต์พร้อมสี
  static TextStyle percentageWithColor(double percentage, {double fontSize = 12.0}) {
    return TextStyle(
      fontFamily: numberFontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: AppColors.getProfitLossColor(percentage),
      height: 1.2,
      letterSpacing: 0.2,
    );
  }

  // ข้อความราคาพร้อมสี
  static TextStyle priceWithColor(double price, {double fontSize = 16.0}) {
    return TextStyle(
      fontFamily: numberFontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: AppColors.getProfitLossColor(price),
      height: 1.2,
    );
  }

  // ข้อความสำหรับประเภท Transaction
  static TextStyle transactionTypeText(String type, {double fontSize = 12.0}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: AppColors.getTransactionColor(type),
      height: 1.2,
    );
  }

  // ข้อความสำหรับ Risk Level
  static TextStyle riskLevelText(double riskScore, {double fontSize = 14.0}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: AppColors.getRiskColor(riskScore),
      height: 1.2,
    );
  }

  // Text Styles สำหรับ Dark/Light Theme
  static TextTheme darkTextTheme = defaultTextTheme;

  // อาจจะเพิ่ม Light Theme ในอนาคต
  static TextTheme lightTextTheme = defaultTextTheme.copyWith(
    displayLarge: defaultTextTheme.displayLarge?.copyWith(color: Colors.black87),
    displayMedium: defaultTextTheme.displayMedium?.copyWith(color: Colors.black87),
    displaySmall: defaultTextTheme.displaySmall?.copyWith(color: Colors.black87),
    headlineLarge: defaultTextTheme.headlineLarge?.copyWith(color: Colors.black87),
    headlineMedium: defaultTextTheme.headlineMedium?.copyWith(color: Colors.black87),
    headlineSmall: defaultTextTheme.headlineSmall?.copyWith(color: Colors.black87),
    bodyLarge: defaultTextTheme.bodyLarge?.copyWith(color: Colors.black87),
    bodyMedium: defaultTextTheme.bodyMedium?.copyWith(color: Colors.black87),
    bodySmall: defaultTextTheme.bodySmall?.copyWith(color: Colors.black54),
    labelLarge: defaultTextTheme.labelLarge?.copyWith(color: Colors.black87),
    labelMedium: defaultTextTheme.labelMedium?.copyWith(color: Colors.black54),
    labelSmall: defaultTextTheme.labelSmall?.copyWith(color: Colors.black54),
  );

  // Typography Scale สำหรับ Responsive Design
  static const Map<String, double> fontSizes = {
    'xs': 10.0,
    'sm': 12.0,
    'base': 14.0,
    'lg': 16.0,
    'xl': 18.0,
    '2xl': 20.0,
    '3xl': 24.0,
    '4xl': 28.0,
    '5xl': 32.0,
  };

  // Font Weights
  static const Map<String, FontWeight> fontWeights = {
    'light': FontWeight.w300,
    'normal': FontWeight.w400,
    'medium': FontWeight.w500,
    'semibold': FontWeight.w600,
    'bold': FontWeight.w700,
    'extrabold': FontWeight.w800,
  };
}

// // ใช้งานได้เลย
// Text(
// '+15.67%',
// style: AppTextTheme.profitLossText(15.67),
// );
//
// Text(
// '฿25,994.00',
// style: AppTextTheme.priceWithColor(25994.00),
// );
//
// Text(
// 'ซื้อ',
// style: AppTextTheme.transactionTypeText('BUY'),
// );

// // ใน Theme
// MaterialApp(
// theme: ThemeData(
// textTheme: AppTextTheme.darkTextTheme,
// fontFamily: AppTextTheme.fontFamily,
// ),
// );
//
// // ใน Widget
// Text(
// '฿39,019.69',
// style: AppTextTheme.priceText,
// );