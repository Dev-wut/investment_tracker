import 'package:decimal/decimal.dart';

enum InvestmentType { stock, crypto }

class Investment {
  final String id;
  final String symbol;
  final String name;
  final InvestmentType type;
  final Decimal quantity;
  final Decimal buyPrice;
  final Decimal currentPrice;
  final DateTime purchaseDate;
  final String? notes;

  Investment({
    required this.id,
    required this.symbol,
    required this.name,
    required this.type,
    required this.quantity,
    required this.buyPrice,
    required this.currentPrice,
    required this.purchaseDate,
    this.notes,
  });

  // คำนวณมูลค่าเริ่มต้น
  Decimal get initialValue => quantity * buyPrice;

  // คำนวณมูลค่าปัจจุบัน
  Decimal get currentValue => quantity * currentPrice;

  // คำนวณกำไร/ขาดทุน
  Decimal get profitLoss => currentValue - initialValue;

  // คำนวณเปอร์เซ็นต์กำไร/ขาดทุน
  Decimal get profitLossPercentage => (profitLoss / initialValue).toDecimal(scaleOnInfinitePrecision: 10) * Decimal.fromInt(100);

  // แปลงเป็น Map สำหรับส่งไป Google Sheets
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'type': type.toString().split('.').last,
      'quantity': quantity.toString(),
      'buy_price': buyPrice.toString(),
      'current_price': currentPrice.toString(),
      'purchase_date': purchaseDate.toIso8601String(),
      'initial_value': initialValue.toString(),
      'current_value': currentValue.toString(),
      'profit_loss': profitLoss.toString(),
      'profit_loss_percentage': profitLossPercentage.toString(),
      'notes': notes ?? '',
    };
  }

  // สร้าง Investment จาก Map
  factory Investment.fromMap(Map<String, dynamic> map) {
    return Investment(
      id: map['id'] ?? '',
      symbol: map['symbol'] ?? '',
      name: map['name'] ?? '',
      type: InvestmentType.values.firstWhere(
            (e) => e.toString().split('.').last == map['type'],
        orElse: () => InvestmentType.stock,
      ),
      quantity: Decimal.parse(map['quantity'] ?? '0'),
      buyPrice: Decimal.parse(map['buy_price'] ?? '0'),
      currentPrice: Decimal.parse(map['current_price'] ?? '0'),
      purchaseDate: DateTime.parse(map['purchase_date'] ?? DateTime.now().toIso8601String()),
      notes: map['notes'],
    );
  }

  // สร้างสำเนาที่แก้ไขราคาปัจจุบัน
  Investment copyWith({
    String? id,
    String? symbol,
    String? name,
    InvestmentType? type,
    Decimal? quantity,
    Decimal? buyPrice,
    Decimal? currentPrice,
    DateTime? purchaseDate,
    String? notes,
  }) {
    return Investment(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      buyPrice: buyPrice ?? this.buyPrice,
      currentPrice: currentPrice ?? this.currentPrice,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      notes: notes ?? this.notes,
    );
  }
}