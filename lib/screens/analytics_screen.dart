import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main_provider.dart';
import '../services/calculation_service.dart';
import '../utils/helpers.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InvestmentProvider>(
      builder: (context, provider, child) {
        if (provider.investments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'ไม่มีข้อมูลสำหรับวิเคราะห์',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final metrics = CalculationService.calculateRiskReturnMetrics(provider.investments);
        final bestInvestment = CalculationService.getBestPerformingInvestment(provider.investments);
        final worstInvestment = CalculationService.getWorstPerformingInvestment(provider.investments);

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // เมตริกความเสี่ยงและผลตอบแทน
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'เมตริกความเสี่ยงและผลตอบแทน',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      _buildMetricRow('ผลตอบแทนรวม', formatPercentage(metrics['totalReturn']!)),
                      _buildMetricRow('Sharpe Ratio', metrics['sharpeRatio']!.toStringAsFixed(2)),
                      _buildMetricRow('Value at Risk (95%)', formatPercentage(metrics['var95']!)),
                      _buildMetricRow('Maximum Drawdown', formatPercentage(metrics['maxDrawdown']!)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // การลงทุนที่ดีที่สุดและแย่ที่สุด
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.trending_up, color: Colors.green),
                                SizedBox(width: 8),
                                Text(
                                  'ดีที่สุด',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            if (bestInvestment != null) ...[
                              Text(
                                bestInvestment.symbol,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                formatPercentage(bestInvestment.profitLossPercentage),
                                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.trending_down, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'แย่ที่สุด',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            if (worstInvestment != null) ...[
                              Text(
                                worstInvestment.symbol,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                formatPercentage(worstInvestment.profitLossPercentage),
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // สถิติพอร์ตโฟลิโอ
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'สถิติพอร์ตโฟลิโอ',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      _buildStatisticTile(
                        'จำนวนการลงทุน',
                        provider.investments.length.toString(),
                        Icons.account_balance_wallet,
                      ),
                      _buildStatisticTile(
                        'การลงทุนที่มีกำไร',
                        provider.investments.where((inv) => inv.profitLoss > Decimal.zero).length.toString(),
                        Icons.trending_up,
                        Colors.green,
                      ),
                      _buildStatisticTile(
                        'การลงทุนที่ขาดทุน',
                        provider.investments.where((inv) => inv.profitLoss < Decimal.zero).length.toString(),
                        Icons.trending_down,
                        Colors.red,
                      ),
                      _buildStatisticTile(
                        'มูลค่าการลงทุนเฉลี่ย',
                        formatCurrency((CalculationService.calculateTotalValue(provider.investments) / Decimal.fromInt(provider.investments.length)).toDecimal(scaleOnInfinitePrecision: 10)),
                        Icons.calculate,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticTile(String title, String value, IconData icon, [Color? color]) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}