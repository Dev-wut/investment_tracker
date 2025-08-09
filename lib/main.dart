import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/config/route_config.dart';
import 'core/theme/app_theme.dart';
import 'features/authentication/presentation/blocs/auth/auth_bloc.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc()..add(CheckAuthStatus()),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Investment Tracker',
        theme: AppTheme.mainTheme,
        routerConfig: RouteConfig.router,
      ),
    );
  }
}