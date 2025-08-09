import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main_provider.dart';
import '../models/investment.dart';
import '../services/calculation_service.dart';
import '../utils/helpers.dart';
import '../widgets/chart_widget.dart';
import '../widgets/profit_loss_indicator.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  String _selectedChartType = 'pie';

  @override
  Widget build(BuildContext context) {
    return Consumer<InvestmentProvider>(
      builder: (context, provider, child) {
        if (provider.investments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pie_chart, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'ไม่มีข้อมูลพอร์ตโฟลิโอ',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final totalValue = CalculationService.calculateTotalValue(provider.investments);
        final totalInitialValue = CalculationService.calculateTotalInitialValue(provider.investments);
        final totalProfitLoss = CalculationService.calculateTotalProfitLoss(provider.investments);
        final totalProfitLossPercentage = CalculationService.calculateTotalProfitLossPercentage(provider.investments);
        final distribution = CalculationService.calculatePortfolioDistribution(provider.investments);

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // สรุปพอร์ตโฟลิโอ
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'สรุปพอร์ตโฟลิโอ',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('มูลค่าปัจจุบัน', style: TextStyle(color: Colors.grey[600])),
                              Text(
                                formatCurrency(totalValue),
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('กำไร/ขาดทุน', style: TextStyle(color: Colors.grey[600])),
                              ProfitLossIndicator(
                                profitLoss: totalProfitLoss,
                                percentage: totalProfitLossPercentage,
                                showIcon: true,
                                fontSize: 16,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'ทุนเริ่มต้น: ${formatCurrency(totalInitialValue)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // กราฟพอร์ตโฟลิโอ
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'กราฟพอร์ตโฟลิโอ',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          DropdownButton<String>(
                            value: _selectedChartType,
                            onChanged: (value) {
                              setState(() => _selectedChartType = value!);
                            },
                            items: [
                              DropdownMenuItem(value: 'pie', child: Text('Pie Chart')),
                              DropdownMenuItem(value: 'bar', child: Text('Bar Chart')),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      PortfolioChart(
                        investments: provider.investments,
                        chartType: _selectedChartType,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // การกระจายตัวของพอร์ต
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'การกระจายตัวตามประเภท',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      ...distribution.entries.map((entry) {
                        final type = entry.key;
                        final percentage = entry.value;
                        final typeName = type == InvestmentType.stock ? 'หุ้น' : 'คริปโต';
                        final color = type == InvestmentType.stock ? Colors.blue : Colors.orange;

                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(typeName),
                              Spacer(),
                              Text(
                                formatPercentage(percentage),
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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
}