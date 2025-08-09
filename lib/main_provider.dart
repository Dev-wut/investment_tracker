import 'package:flutter/material.dart';
import 'package:investment_tracker/services/google_sheets_service.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/investment_service.dart';
import 'models/investment.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<GoogleSheetsService>(
          create: (_) => GoogleSheetsService(),
        ),
        ChangeNotifierProvider(create: (_) => InvestmentProvider()),
        Provider(create: (_) => InvestmentService()),
      ],
      child: MaterialApp(
        title: 'Investment Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: HomeScreen(),
      ),
    );
  }
}

class InvestmentProvider extends ChangeNotifier {
  List<Investment> _investments = [];
  bool _isLoading = false;
  String? _spreadsheetId;

  List<Investment> get investments => _investments;
  bool get isLoading => _isLoading;
  String? get spreadsheetId => _spreadsheetId;

  void setSpreadsheetId(String id) {
    _spreadsheetId = id;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setInvestments(List<Investment> investments) {
    _investments = investments;
    notifyListeners();
  }

  void addInvestment(Investment investment) {
    _investments.add(investment);
    notifyListeners();
  }

  void updateInvestment(Investment updatedInvestment) {
    final index = _investments.indexWhere((inv) => inv.id == updatedInvestment.id);
    if (index != -1) {
      _investments[index] = updatedInvestment;
      notifyListeners();
    }
  }

  void removeInvestment(String id) {
    _investments.removeWhere((inv) => inv.id == id);
    notifyListeners();
  }

  void updateAllPrices(List<Investment> updatedInvestments) {
    _investments = updatedInvestments;
    notifyListeners();
  }
}