import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/route_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../authentication/presentation/blocs/google_auth/google_auth_bloc.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<GoogleAuthBloc, GoogleAuthState>(
      listener: (context, state) async {
        final AuthStatus status = state.status;
        if (status == AuthStatus.authenticated) {
          await Future.delayed(Duration(seconds: 3));
          if(context.mounted)context.go(AppRoutes.dashboard.path);
        } else if (status == AuthStatus.unauthenticated) {
          context.go(AppRoutes.loginPage.path);
        } else if (status == AuthStatus.failure) {
          final msg = state.error ?? 'Authentication failed';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
          context.go(AppRoutes.loginPage.path);
        }
      },
      child: Scaffold(
        body: Container(
          decoration: AppTheme.loginBackgroundDecoration,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.trending_up,
                  size: 100,
                  color: Colors.white,
                ),
                SizedBox(height: 20),
                Text(
                  'Investment Tracker',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 40),
                CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
