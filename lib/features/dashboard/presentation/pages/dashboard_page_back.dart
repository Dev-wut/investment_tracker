// import 'dart:developer';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:investment_tracker/core/config/route_config.dart';
//
// import '../../../../core/constants/app_constants.dart';
// import '../../../authentication/presentation/blocs/google_auth/google_auth_bloc.dart';
//
// // === Style tokens (centralize repeated colors) ===
// const kPrimary = Color(0xFF667eea);
// const kBgLight = Color(0xFFf7f7f7);
// const kTextPrimary = Color(0xFF2d3436);
// const kTextSecondary = Color(0xFF636e72);
//
// // Avoid magic strings in popup menu
// enum _MenuAction { profile, logout }
//
// class DashboardPage extends StatelessWidget {
//   const DashboardPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<GoogleAuthBloc, GoogleAuthState>(
//       listenWhen: (prev, curr) => prev.status != curr.status,
//       listener: (ctx, state) {
//         final status = state.status;
//         if (status == AuthStatus.unauthenticated) {
//           if (!ctx.mounted) return;
//           // Navigate to login *after* sign-out completes, from a safe context.
//           log('AuthUnauthenticated');
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (ctx.mounted) {
//               ctx.replaceNamed(AppRoutes.loginPage.name);
//             }
//           });
//         } else if (status == AuthStatus.failure) {
//           final msg = state.error ?? 'Authentication failed';
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (ctx.mounted) {
//               ScaffoldMessenger.of(ctx).showSnackBar(
//                 SnackBar(content: Text(msg)),
//               );
//             }
//           });
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(AppConstants.appName),
//           backgroundColor: kPrimary,
//           foregroundColor: Colors.white,
//           elevation: 0,
//           actions: const [
//             // _UserMenu(),
//             _AccountButton(),
//           ],
//         ),
//         body: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [kPrimary, kBgLight],
//               stops: [0.0, 0.3],
//             ),
//           ),
//           child: const SafeArea(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _WelcomeSection(),
//                   SizedBox(height: 24),
//                   _PortfolioOverview(),
//                   SizedBox(height: 24),
//                   _QuickActions(),
//                   SizedBox(height: 24),
//                   _RecentTransactions(),
//                   SizedBox(height: 24),
//                   _MarketSummary(),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Add Investment - Coming Soon!')),
//             );
//           },
//           backgroundColor: kPrimary,
//           child: const Icon(Icons.add, color: Colors.white),
//         ),
//         bottomNavigationBar: const _BottomNavigationWidget(),
//       ),
//     );
//   }
// }
//
// class _WelcomeSection extends StatelessWidget {
//   const _WelcomeSection();
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<GoogleAuthBloc, GoogleAuthState>(
//       buildWhen: (p, c) => p.status != c.status || p.user?.name != c.user?.name,
//       builder: (context, state) {
//         final userName = state.status == AuthStatus.authenticated
//             ? (state.user?.name?.split(' ').first ?? 'Investor')
//             : 'Investor';
//
//         return _SectionCard(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Welcome back\n$userName! 👋',
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: kTextPrimary,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 "Here's your investment summary for today",
//                 style: TextStyle(fontSize: 16, color: kTextSecondary),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// class _PortfolioOverview extends StatelessWidget {
//   const _PortfolioOverview();
//
//   @override
//   Widget build(BuildContext context) {
//     return _SectionCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Row(
//             children: [
//               Icon(Icons.account_balance_wallet, color: kPrimary),
//               SizedBox(width: 8),
//               Text(
//                 'Portfolio Overview',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: kTextPrimary,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: const [
//               Expanded(
//                 child: _PortfolioCard(
//                   title: 'Total Value',
//                   value: '฿1,245,680',
//                   change: '+12.5%',
//                   isPositive: true,
//                   icon: Icons.trending_up,
//                 ),
//               ),
//               SizedBox(width: 12),
//               Expanded(
//                 child: _PortfolioCard(
//                   title: "Today's P&L",
//                   value: '฿+15,420',
//                   change: '+1.25%',
//                   isPositive: true,
//                   icon: Icons.show_chart,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _SectionCard extends StatelessWidget {
//   final Widget child;
//   const _SectionCard({required this.child});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.95),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 12,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }
// }
//
// class _PortfolioCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final String change;
//   final bool isPositive;
//   final IconData icon;
//
//   const _PortfolioCard({
//     required this.title,
//     required this.value,
//     required this.change,
//     required this.isPositive,
//     required this.icon,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final Color accent = isPositive ? const Color(0xFF4CAF50) : const Color(0xFFf44336);
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 250),
//       curve: Curves.easeOut,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: isPositive ? const Color(0xFFe8f5e8) : const Color(0xFFffeaea),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: accent, width: 1),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, size: 20, color: accent),
//               const Spacer(),
//               Text(
//                 change,
//                 style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: accent),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(title, style: const TextStyle(fontSize: 12, color: kTextSecondary)),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextPrimary),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _QuickActions extends StatelessWidget {
//   const _QuickActions();
//
//   @override
//   Widget build(BuildContext context) {
//     return _SectionCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Quick Actions',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextPrimary),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: _ActionButton(
//                   icon: Icons.add_circle,
//                   label: 'Buy',
//                   color: const Color(0xFF4CAF50),
//                   onTap: () => _showComingSoon(context),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _ActionButton(
//                   icon: Icons.remove_circle,
//                   label: 'Sell',
//                   color: const Color(0xFFf44336),
//                   onTap: () => _showComingSoon(context),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _ActionButton(
//                   icon: Icons.analytics,
//                   label: 'Analyze',
//                   color: kPrimary,
//                   onTap: () => _showComingSoon(context),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showComingSoon(BuildContext context) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Feature coming soon!')),
//     );
//   }
// }
//
// class _ActionButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final VoidCallback onTap;
//
//   const _ActionButton({
//     required this.icon,
//     required this.label,
//     required this.color,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: color.withOpacity(0.08),
//       borderRadius: BorderRadius.circular(12),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               Icon(icon, color: color, size: 32),
//               const SizedBox(height: 8),
//               Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _RecentTransactions extends StatelessWidget {
//   const _RecentTransactions();
//
//   @override
//   Widget build(BuildContext context) {
//     final transactions = const [
//       _TransactionItem('AAPL', 'Apple Inc.', '+10 shares', '฿+15,420', true),
//       _TransactionItem('TSLA', 'Tesla Inc.', '-5 shares', '฿-8,750', false),
//       _TransactionItem('GOOGL', 'Alphabet Inc.', '+3 shares', '฿+9,230', true),
//     ];
//
//     return _SectionCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Recent Transactions',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextPrimary),
//               ),
//               TextButton(
//                 onPressed: () => _showComingSoon(context),
//                 child: const Text('View All'),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           ...transactions.map((t) => Padding(padding: EdgeInsets.only(bottom: 12), child: t)),
//         ],
//       ),
//     );
//   }
//
//   void _showComingSoon(BuildContext context) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Feature coming soon!')),
//     );
//   }
// }
//
// class _TransactionItem extends StatelessWidget {
//   final String symbol;
//   final String name;
//   final String quantity;
//   final String amount;
//   final bool isPositive;
//
//   const _TransactionItem(this.symbol, this.name, this.quantity, this.amount, this.isPositive);
//
//   String _chipText(String s) => s.length >= 2 ? s.substring(0, 2) : s;
//
//   @override
//   Widget build(BuildContext context) {
//     final Color accent = isPositive ? const Color(0xFF4CAF50) : const Color(0xFFf44336);
//     return Row(
//       children: [
//         Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: kPrimary.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Center(
//             child: Text(
//               _chipText(symbol),
//               style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimary),
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: kTextPrimary)),
//               Text(quantity, style: const TextStyle(color: kTextSecondary, fontSize: 12)),
//             ],
//           ),
//         ),
//         Text(
//           amount,
//           style: TextStyle(fontWeight: FontWeight.bold, color: accent),
//         ),
//       ],
//     );
//   }
// }
//
// class _MarketSummary extends StatelessWidget {
//   const _MarketSummary();
//
//   @override
//   Widget build(BuildContext context) {
//     return _SectionCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Market Summary',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextPrimary),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: const [
//               Expanded(child: _MarketIndex('SET', '1,647.25', '+1.2%', true)),
//               SizedBox(width: 12),
//               Expanded(child: _MarketIndex('S&P 500', '4,521.63', '+0.8%', true)),
//               SizedBox(width: 12),
//               Expanded(child: _MarketIndex('NASDAQ', '14,039.68', '-0.3%', false)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _MarketIndex extends StatelessWidget {
//   final String name;
//   final String value;
//   final String change;
//   final bool isPositive;
//
//   const _MarketIndex(this.name, this.value, this.change, this.isPositive);
//
//   @override
//   Widget build(BuildContext context) {
//     final Color accent = isPositive ? const Color(0xFF4CAF50) : const Color(0xFFf44336);
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(name, style: const TextStyle(fontSize: 12, color: kTextSecondary)),
//         const SizedBox(height: 4),
//         const SizedBox(height: 2),
//         Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kTextPrimary)),
//         Text(change, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: accent)),
//       ],
//     );
//   }
// }
//
// class _BottomNavigationWidget extends StatelessWidget {
//   const _BottomNavigationWidget();
//
//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       type: BottomNavigationBarType.fixed,
//       selectedItemColor: kPrimary,
//       unselectedItemColor: Colors.grey,
//       currentIndex: 0,
//       items: const [
//         BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
//         BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Portfolio'),
//         BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Discover'),
//         BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
//       ],
//       onTap: (index) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Tab $index - Coming Soon!')),
//         );
//       },
//     );
//   }
// }
//
//
// class _AccountButton extends StatelessWidget {
//   const _AccountButton();
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<GoogleAuthBloc, GoogleAuthState>(
//       buildWhen: (p, c) => p.status != c.status || p.user != c.user,
//       builder: (context, state) {
//         if (state.status != AuthStatus.authenticated) {
//           return const SizedBox.shrink();
//         }
//         final user = state.user;
//         final hasPhoto = (user?.photoUrl?.isNotEmpty ?? false);
//         return IconButton(
//           tooltip: 'Account',
//           onPressed: () => _openAccountSheet(context, user?.name, user?.photoUrl),
//           icon: CircleAvatar(
//             backgroundImage: hasPhoto ? NetworkImage(user!.photoUrl!) : null,
//             backgroundColor: Colors.white24,
//             child: !hasPhoto
//                 ? Text(
//               (user?.name?.trim().isNotEmpty ?? false)
//                   ? user!.name!.trim().characters.first.toUpperCase()
//                   : 'U',
//               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//             )
//                 : null,
//           ),
//         );
//       },
//     );
//   }
//
//   void _openAccountSheet(BuildContext parentCtx, String? name, String? photoUrl) {
//     showModalBottomSheet<void>(
//       context: parentCtx,
//       useSafeArea: true,
//       showDragHandle: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (sheetCtx) {
//         return _AccountSheet(
//           name: name,
//           photoUrl: photoUrl,
//           onProfile: () {
//             Navigator.of(sheetCtx).pop(); // ปิดให้เรียบร้อยก่อน
//             ScaffoldMessenger.of(parentCtx).showSnackBar(
//               const SnackBar(content: Text('Profile - Coming Soon!')),
//             );
//           },
//           onLogout: () {
//             // 1) ปิดแผ่นเมนูให้จบวงจร overlay
//             Navigator.of(sheetCtx).pop();
//             // 2) ค่อย ๆ ยิง event logout หลังเฟรมถัดไป
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               if (!parentCtx.mounted) return;
//               parentCtx.read<GoogleAuthBloc>().add(const GoogleAuthSignOutRequested());
//             });
//           },
//         );
//       },
//     );
//   }
// }
//
// class _AccountSheet extends StatelessWidget {
//   final String? name;
//   final String? photoUrl;
//   final VoidCallback onProfile;
//   final VoidCallback onLogout;
//
//   const _AccountSheet({
//     required this.name,
//     required this.photoUrl,
//     required this.onProfile,
//     required this.onLogout,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final hasPhoto = (photoUrl?.isNotEmpty ?? false);
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ListTile(
//             leading: CircleAvatar(
//               backgroundImage: hasPhoto ? NetworkImage(photoUrl!) : null,
//               child: !hasPhoto
//                   ? const Icon(Icons.person_outline)
//                   : null,
//             ),
//             title: Text(name ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold)),
//             subtitle: const Text('Signed in'),
//           ),
//           const Divider(),
//           ListTile(
//             leading: const Icon(Icons.person),
//             title: const Text('Profile'),
//             onTap: onProfile,
//           ),
//           ListTile(
//             leading: const Icon(Icons.logout, color: Colors.red),
//             title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
//             onTap: onLogout,
//           ),
//         ],
//       ),
//     );
//   }
// }
