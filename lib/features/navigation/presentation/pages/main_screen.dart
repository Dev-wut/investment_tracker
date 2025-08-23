import 'package:flutter/material.dart';
import 'package:investment_tracker/features/dashboard/presentation/pages/dashboard_page.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MainScreenMainSection();
  }
}

class _MainScreenMainSection extends StatelessWidget {
  const _MainScreenMainSection();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Color(0xFFf7f7f7)],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          left: false,
          right: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                DashboardPage(),
              ],
            ),
          )
        ),
      ),
      bottomNavigationBar: const _BottomNavigationWidget(),
    );
  }
}

class _BottomNavigationWidget extends StatelessWidget {
  const _BottomNavigationWidget();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      currentIndex: 1,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home,color: Colors.black,), label: 'dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.swap_horiz_sharp), label: 'transactions'),
        BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'holdings'),
        BottomNavigationBarItem(icon: Icon(Icons.pie_chart_outline), label: 'reports'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'settings'),
      ],
      onTap: (index) {},
    );
  }
}


