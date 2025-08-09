import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';

class ProfitLossIndicator extends StatelessWidget {
  final Decimal profitLoss;
  final Decimal percentage;
  final bool showIcon;
  final double fontSize;

  const ProfitLossIndicator({
    super.key,
    required this.profitLoss,
    required this.percentage,
    this.showIcon = false,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = profitLoss >= Decimal.zero;
    final color = isPositive ? Color(AppConstants.profitColor) : Color(AppConstants.lossColor);
    final icon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon) ...[
          Icon(
            icon,
            color: color,
            size: fontSize,
          ),
          SizedBox(width: 4),
        ],
        Text(
          '${formatCurrency(profitLoss)} (${formatPercentage(percentage)})',
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}