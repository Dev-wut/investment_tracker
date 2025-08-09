import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';

enum AppRoutes {
  initial(name: 'initial', path: '/initial'),
  loginPage(name: 'loginPage', path: '/loginPage'),
  dashboard(name: 'dashboard', path: '/dashboard');

  final String name;
  final String path;

  const AppRoutes({required this.name, required this.path});
}

final class RouteConfig {
  static GoRouter get router => _routes;

  static final _routes = GoRouter(
    initialLocation: AppRoutes.initial.path,
    routes: [
      GoRoute(
        name: AppRoutes.initial.name,
        path: AppRoutes.initial.path,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        name: AppRoutes.loginPage.name,
        path: AppRoutes.loginPage.path,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        name: AppRoutes.dashboard.name,
        path: AppRoutes.dashboard.path,
        builder: (context, state) => const DashboardPage(),
      ),
    ],
  );
}
