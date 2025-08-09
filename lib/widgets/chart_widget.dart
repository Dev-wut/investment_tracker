import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:decimal/decimal.dart';
import '../models/investment.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';

class PortfolioChart extends StatelessWidget {
  final List<Investment> investments;
  final String chartType;

  const PortfolioChart({
    super.key,
    required this.investments,
    this.chartType = 'pie',
  });

  @override
  Widget build(BuildContext context) {
    if (investments.isEmpty) {
      return Center(
        child: Text(
          'ไม่มีข้อมูลสำหรับแสดงกราฟ',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return chartType == 'pie' ? _buildPieChart() : _buildBarChart();
  }

  Widget _buildPieChart() {
    final sections = _getPieChartSections();

    return Column(
      children: [
        Container(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              startDegreeOffset: -90,
            ),
          ),
        ),
        SizedBox(height: 16),
        _buildLegend(),
      ],
    );
  }

  Widget _buildBarChart() {
    return Container(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxValue(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              // tooltipBgColor: Colors.grey[800]!,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final investment = investments[groupIndex];
                return BarTooltipItem(
                  '${investment.symbol}\n${formatCurrency(investment.currentValue)}',
                  TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value.toInt() < investments.length) {
                    return Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        investments[value.toInt()].symbol,
                        style: TextStyle(fontSize: 12),
                      ),
                    );
                  }
                  return Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    formatShortNumber(Decimal.fromInt(value.toInt())),
                    style: TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
          barGroups: _getBarGroups(),
        ),
      ),
    );
  }

  List<PieChartSectionData> _getPieChartSections() {
    final totalValue = investments.fold(
      Decimal.zero,
          (sum, investment) => sum + investment.currentValue,
    );

    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.pink,
    ];

    return investments.asMap().entries.map((entry) {
      final index = entry.key;
      final investment = entry.value;
      final percentage = (investment.currentValue / totalValue).toDecimal(scaleOnInfinitePrecision: 10) * Decimal.fromInt(100);

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: investment.currentValue.toDouble(),
        title: formatPercentage(percentage),
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _getBarGroups() {
    return investments.asMap().entries.map((entry) {
      final index = entry.key;
      final investment = entry.value;
      final isProfit = investment.profitLoss >= Decimal.zero;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: investment.currentValue.toDouble(),
            color: isProfit ? Color(AppConstants.profitColor) : Color(AppConstants.lossColor),
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  // double _getMaxValue() {
  //   return investments
  //       .map((inv) => inv.currentValue.toDouble())
  //       .fold(0, (max, value) => value > max ? value : max) * 1.1;
  // }
  double _getMaxValue() {
    if (investments.isEmpty) return 0.0;

    final maxValue = investments
        .map((inv) => inv.currentValue.toDouble())
        .reduce((a, b) => a > b ? a : b);

    return maxValue * 1.1;
  }

  Widget _buildLegend() {
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.pink,
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: investments.asMap().entries.map((entry) {
        final index = entry.key;
        final investment = entry.value;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8),
            Text(
              investment.symbol,
              style: TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class ProfitLossChart extends StatelessWidget {
  final List<Investment> investments;

  const ProfitLossChart({
    super.key,
    required this.investments,
  });

  @override
  Widget build(BuildContext context) {
    if (investments.isEmpty) {
      return Center(
        child: Text(
          'ไม่มีข้อมูลสำหรับแสดงกราฟ',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxValue(),
          minY: _getMinValue(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              // tooltipBgColor: Colors.grey[800]!,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final investment = investments[groupIndex];
                return BarTooltipItem(
                  '${investment.symbol}\n${formatCurrency(investment.profitLoss)}',
                  TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value.toInt() < investments.length) {
                    return Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        investments[value.toInt()].symbol,
                        style: TextStyle(fontSize: 12),
                      ),
                    );
                  }
                  return Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    formatShortNumber(Decimal.fromInt(value.toInt())),
                    style: TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
          barGroups: _getBarGroups(),
        ),
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    return investments.asMap().entries.map((entry) {
      final index = entry.key;
      final investment = entry.value;
      final isProfit = investment.profitLoss >= Decimal.zero;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: investment.profitLoss.toDouble(),
            color: isProfit ? Color(AppConstants.profitColor) : Color(AppConstants.lossColor),
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  // double _getMaxValue() {
  //   return investments
  //       .map((inv) => inv.profitLoss.toDouble())
  //       .fold(0, (max, value) => value > max ? value : max) * 1.1;
  // }
  // double _getMinValue() {
  //   return investments
  //       .map((inv) => inv.profitLoss.toDouble())
  //       .fold(0, (min, value) => value < min ? value : min) * 1.1;
  // }

  double _getMaxValue() {
    if (investments.isEmpty) return 0.0;
    final maxValue = investments
        .map((inv) => inv.profitLoss.toDouble())
        .reduce((a, b) => a > b ? a : b);

    return maxValue * 1.1;
  }
  double _getMinValue() {
    if (investments.isEmpty) return 0.0;

    final minValue = investments
        .map((inv) => inv.profitLoss.toDouble())
        .reduce((a, b) => a < b ? a : b);

    return minValue * 1.1;
  }
}