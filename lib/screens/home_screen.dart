import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main_provider.dart';
import '../models/investment.dart';
import '../services/calculation_service.dart';
import '../services/google_sheets_service.dart';
import '../services/investment_service.dart';
import '../utils/helpers.dart';
import '../widgets/investment_card.dart';
import '../widgets/profit_loss_indicator.dart';
import 'add_investment_screen.dart';
import 'analytics_screen.dart';
import 'portfolio_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInvestments();
    });
  }

  Future<void> _loadInvestments() async {
    final provider = context.read<InvestmentProvider>();
    final sheetsService = context.read<GoogleSheetsService>();

    // ถ้ามี spreadsheet ID และเข้าสู่ระบบแล้ว
    if (provider.spreadsheetId != null) {
      provider.setLoading(true);

      if (!sheetsService.isSignedIn) {
        await sheetsService.signIn();
      }

      if (sheetsService.isSignedIn) {
        try {
          final investments = await sheetsService.getInvestments(provider.spreadsheetId!);
          if (investments.isNotEmpty) {
            provider.setInvestments(investments);
          }
        } catch (e) {
          print('Error loading from Google Sheets: $e');
        }
      }

      provider.setLoading(false);
    }

    // ถ้าไม่มีข้อมูล ให้ใช้ข้อมูลตัวอย่าง
    if (provider.investments.isEmpty) {
      _loadSampleData();
    }
  }

  void _loadSampleData() {
    final provider = context.read<InvestmentProvider>();
    final sampleInvestments = [
      Investment(
        id: '1',
        symbol: 'AAPL',
        name: 'Apple Inc.',
        type: InvestmentType.stock,
        quantity: Decimal.fromInt(10),
        buyPrice: Decimal.fromInt(150),
        currentPrice: Decimal.fromInt(155),
        purchaseDate: DateTime.now().subtract(Duration(days: 30)),
      ),
      Investment(
        id: '2',
        symbol: 'BTC',
        name: 'Bitcoin',
        type: InvestmentType.crypto,
        quantity: Decimal.parse('0.5'),
        buyPrice: Decimal.fromInt(40000),
        currentPrice: Decimal.fromInt(42000),
        purchaseDate: DateTime.now().subtract(Duration(days: 15)),
      ),
    ];

    provider.setInvestments(sampleInvestments);
  }

  Future<void> _refreshPrices() async {
    final provider = context.read<InvestmentProvider>();
    final investmentService = context.read<InvestmentService>();
    final sheetsService = context.read<GoogleSheetsService>();

    if (provider.investments.isEmpty) return;

    provider.setLoading(true);

    final updatedInvestments = await investmentService.updateAllPrices(provider.investments);
    provider.updateAllPrices(updatedInvestments);

    if (provider.spreadsheetId != null) {
      await sheetsService.updateCurrentPrices(provider.spreadsheetId!, updatedInvestments);
    }

    provider.setLoading(false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ราคาอัพเดทเรียบร้อยแล้ว')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Investment Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshPrices,
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'signin':
                  await _signInToGoogle();
                  break;
                case 'signout':
                  await _signOutFromGoogle();
                  break;
                case 'create_sheet':
                  await _createNewSpreadsheet();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'signin',
                child: Text('เข้าสู่ระบบ Google'),
              ),
              PopupMenuItem(
                value: 'signout',
                child: Text('ออกจากระบบ'),
              ),
              PopupMenuItem(
                value: 'create_sheet',
                child: Text('สร้างสเปรดชีตใหม่'),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          PortfolioScreen(),
          AnalyticsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'หน้าหลัก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'พอร์ตโฟลิโอ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'วิเคราะห์',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddInvestmentScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildHomeTab() {
    return Consumer<InvestmentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (provider.investments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'ยังไม่มีการลงทุน',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'กดปุ่ม + เพื่อเพิ่มการลงทุนแรก',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final totalValue = CalculationService.calculateTotalValue(provider.investments);
        final totalInitialValue = CalculationService.calculateTotalInitialValue(provider.investments);
        final totalProfitLoss = CalculationService.calculateTotalProfitLoss(provider.investments);
        final totalProfitLossPercentage = CalculationService.calculateTotalProfitLossPercentage(provider.investments);

        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'มูลค่าพอร์ตโฟลิโอ',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${formatCurrency(totalValue)}',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ทุนเริ่มต้น: ${formatCurrency(totalInitialValue)}'),
                      ProfitLossIndicator(
                        profitLoss: totalProfitLoss,
                        percentage: totalProfitLossPercentage,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: provider.investments.length,
                itemBuilder: (context, index) {
                  final investment = provider.investments[index];
                  return InvestmentCard(
                    investment: investment,
                    onTap: () => _showInvestmentDetails(investment),
                    onDelete: () => _deleteInvestment(investment.id),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signInToGoogle() async {
    final sheetsService = context.read<GoogleSheetsService>();
    final success = await sheetsService.signIn();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เข้าสู่ระบบ Google สำเร็จ')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถเข้าสู่ระบบได้')),
      );
    }
  }

  Future<void> _signOutFromGoogle() async {
    final sheetsService = context.read<GoogleSheetsService>();
    await sheetsService.signOut();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ออกจากระบบแล้ว')),
    );
  }

  Future<void> _createNewSpreadsheet() async {
    final sheetsService = context.read<GoogleSheetsService>();
    final provider = context.read<InvestmentProvider>();

    if (!sheetsService.isSignedIn) {
      await sheetsService.signIn();
    }

    final spreadsheetId = await sheetsService.createSpreadsheet('Investment Tracker');

    if (spreadsheetId != null) {
      provider.setSpreadsheetId(spreadsheetId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('สร้างสเปรดชีตใหม่สำเร็จ')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถสร้างสเปรดชีตได้')),
      );
    }
  }

  void _showInvestmentDetails(Investment investment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(investment.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Symbol: ${investment.symbol}'),
            Text('Type: ${investment.type.toString().split('.').last}'),
            Text('Quantity: ${investment.quantity}'),
            Text('Buy Price: ${formatCurrency(investment.buyPrice)}'),
            Text('Current Price: ${formatCurrency(investment.currentPrice)}'),
            Text('Purchase Date: ${formatDate(investment.purchaseDate)}'),
            if (investment.notes != null && investment.notes!.isNotEmpty)
              Text('Notes: ${investment.notes}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('ปิด'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteInvestment(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ยืนยันการลบ'),
        content: Text('คุณแน่ใจหรือไม่ที่จะลบการลงทุนนี้?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final provider = context.read<InvestmentProvider>();
      final sheetsService = context.read<GoogleSheetsService>();

      provider.removeInvestment(id);

      if (provider.spreadsheetId != null) {
        await sheetsService.deleteInvestment(provider.spreadsheetId!, id);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ลบการลงทุนเรียบร้อยแล้ว')),
      );
    }
  }
}