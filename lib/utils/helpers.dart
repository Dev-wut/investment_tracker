import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'constants.dart';

// จัดรูปแบบเงิน
String formatCurrency(Decimal amount) {
  final formatter = NumberFormat('#,##0.00');
  return '${AppConstants.currencySymbol}${formatter.format(amount.toDouble())}';
}

// จัดรูปแบบเปอร์เซ็นต์
String formatPercentage(Decimal percentage) {
  final formatter = NumberFormat('#,##0.00');
  return '${formatter.format(percentage.toDouble())}%';
}

// จัดรูปแบบวันที่
String formatDate(DateTime date) {
  final formatter = DateFormat(AppConstants.dateFormat);
  return formatter.format(date);
}

// จัดรูปแบบวันที่และเวลา
String formatDateTime(DateTime dateTime) {
  final formatter = DateFormat(AppConstants.dateTimeFormat);
  return formatter.format(dateTime);
}

// สร้าง ID สำหรับการลงทุน
String generateId() {
  return DateTime.now().millisecondsSinceEpoch.toString();
}

// ตรวจสอบว่าเป็นกำไรหรือขาดทุน
bool isProfit(Decimal amount) {
  return amount >= Decimal.zero;
}

// แปลงสตริงเป็น Decimal อย่างปลอดภัย
Decimal? parseDecimal(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    return Decimal.parse(value);
  } catch (e) {
    return null;
  }
}

// คำนวณการเปลี่ยนแปลงเปอร์เซ็นต์
Decimal calculatePercentageChange(Decimal oldValue, Decimal newValue) {
  if (oldValue == Decimal.zero) return Decimal.zero;

  final change = (newValue - oldValue) / oldValue;
  final changeDecimal = Decimal.parse(change.toString());
  return changeDecimal * Decimal.fromInt(100);
}

// จัดรูปแบบตัวเลขแบบสั้น
String formatShortNumber(Decimal number) {
  final value = number.toDouble();
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  } else if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}K';
  } else {
    return value.toStringAsFixed(2);
  }
}