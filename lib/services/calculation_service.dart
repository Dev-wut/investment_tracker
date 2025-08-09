import 'package:decimal/decimal.dart';

import '../models/investment.dart';

class CalculationService {
  // คำนวณมูลค่าพอร์ตโฟลิโอรวม
  static Decimal calculateTotalValue(List<Investment> investments) {
    return investments.fold(
      Decimal.zero,
          (total, investment) => total + investment.currentValue,
    );
  }

  // คำนวณมูลค่าเริ่มต้นรวม
  static Decimal calculateTotalInitialValue(List<Investment> investments) {
    return investments.fold(
      Decimal.zero,
          (total, investment) => total + investment.initialValue,
    );
  }

  // คำนวณกำไร/ขาดทุนรวม
  static Decimal calculateTotalProfitLoss(List<Investment> investments) {
    return investments.fold(
      Decimal.zero,
          (total, investment) => total + investment.profitLoss,
    );
  }

  // คำนวณเปอร์เซ็นต์กำไร/ขาดทุนรวม
  static Decimal calculateTotalProfitLossPercentage(List<Investment> investments) {
    final totalInitial = calculateTotalInitialValue(investments);
    final totalProfitLoss = calculateTotalProfitLoss(investments);

    if (totalInitial == Decimal.zero) return Decimal.zero;
    final result = totalProfitLoss / totalInitial;
    Decimal decimalResult = result.toDecimal(scaleOnInfinitePrecision: 10);
    return Decimal.parse(decimalResult.toString()) * Decimal.fromInt(100);
  }

  // คำนวณการกระจายตัวของพอร์ต
  static Map<InvestmentType, Decimal> calculatePortfolioDistribution(List<Investment> investments) {
    final totalValue = calculateTotalValue(investments);
    final distribution = <InvestmentType, Decimal>{};

    for (final type in InvestmentType.values) {
      final typeValue = investments
          .where((investment) => investment.type == type)
          .fold(Decimal.zero, (sum, investment) => sum + investment.currentValue);

      final percentage = typeValue / totalValue;
      final percentageDecimal = percentage.toDecimal(scaleOnInfinitePrecision: 10);
      distribution[type] = totalValue == Decimal.zero ? Decimal.zero : percentageDecimal * Decimal.fromInt(100);
    }

    return distribution;
  }

  // คำนวณการลงทุนที่ดีที่สุด
  static Investment? getBestPerformingInvestment(List<Investment> investments) {
    if (investments.isEmpty) return null;

    return investments.reduce((best, current) =>
    current.profitLossPercentage > best.profitLossPercentage ? current : best);
  }

  // คำนวณการลงทุนที่แย่ที่สุด
  static Investment? getWorstPerformingInvestment(List<Investment> investments) {
    if (investments.isEmpty) return null;

    return investments.reduce((worst, current) =>
    current.profitLossPercentage < worst.profitLossPercentage ? current : worst);
  }

  // คำนวณ Sharpe Ratio (แบบง่าย)
  static Decimal calculateSharpeRatio(List<Investment> investments) {
    if (investments.isEmpty) return Decimal.zero;

    final returns = investments.map((i) => i.profitLossPercentage).toList();
    final avgReturnRational = returns.fold(Decimal.zero, (sum, ret) => sum + ret) / Decimal.fromInt(returns.length);
    final avgReturn = avgReturnRational.toDecimal(scaleOnInfinitePrecision: 10);

    // คำนวณ standard deviation
    final varianceRational = returns.fold(Decimal.zero, (sum, ret) => sum + (ret - avgReturn) * (ret - avgReturn)) / Decimal.fromInt(returns.length);
    final variance = varianceRational.toDecimal(scaleOnInfinitePrecision: 10);
    final varianceDouble = variance.toDouble();
    final standardDeviation = Decimal.parse(varianceDouble.toString());

    return standardDeviation == Decimal.zero ? Decimal.zero : (avgReturn / standardDeviation).toDecimal(scaleOnInfinitePrecision: 10) ;
  }

  // คำนวณ Value at Risk (VaR) แบบง่าย
  static Decimal calculateVaR(List<Investment> investments, double confidenceLevel) {
    if (investments.isEmpty) return Decimal.zero;

    final returns = investments.map((i) => i.profitLossPercentage).toList();
    returns.sort((a, b) => a.compareTo(b));

    final index = ((1 - confidenceLevel) * returns.length).round();
    return index < returns.length ? returns[index] : Decimal.zero;
  }

  // คำนวณ Maximum Drawdown
  static Decimal calculateMaxDrawdown(List<Investment> investments) {
    if (investments.isEmpty) return Decimal.zero;

    var maxDrawdown = Decimal.zero;
    var peak = investments.first.currentValue;

    for (final investment in investments) {
      if (investment.currentValue > peak) {
        peak = investment.currentValue;
      }
      final drawdown = ((peak - investment.currentValue) / peak).toDecimal(scaleOnInfinitePrecision: 10) * Decimal.fromInt(100);
      if (drawdown > maxDrawdown) {
        maxDrawdown = drawdown;
      }
    }

    return maxDrawdown;
  }

  // คำนวณ Risk-Return Ratio
  static Map<String, Decimal> calculateRiskReturnMetrics(List<Investment> investments) {
    final totalReturn = calculateTotalProfitLossPercentage(investments);
    final sharpeRatio = calculateSharpeRatio(investments);
    final var95 = calculateVaR(investments, 0.95);
    final maxDrawdown = calculateMaxDrawdown(investments);

    return {
      'totalReturn': totalReturn,
      'sharpeRatio': sharpeRatio,
      'var95': var95,
      'maxDrawdown': maxDrawdown,
    };
  }
}