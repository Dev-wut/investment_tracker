import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/config/route_config.dart';
import 'core/constants/api_constants.dart';
import 'core/constants/app_constants.dart';
import 'core/services/networks/app_script_api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/authentication/domain/repositories/auth_persistence.dart';
import 'features/authentication/domain/repositories/google_auth_repository.dart';
import 'features/authentication/domain/repositories/secure_token_storage.dart';
import 'features/authentication/presentation/blocs/google_auth/google_auth_bloc.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final authRepo = GoogleAuthRepository(
    AuthPersistenceImpl(),
    SecureTokenStorageImpl(),
  );
  runApp(MyApp(authRepo: authRepo));
}

class MyApp extends StatelessWidget {
  final GoogleAuthRepository authRepo;
  const MyApp({super.key, required this.authRepo});

  @override
  Widget build(BuildContext context) {

    final appScript = AppScriptApiClient(
      authRepo: authRepo,
      baseExecUrl: Uri.parse(ApiConstants.appScriptBaseUrl),
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepo),
        RepositoryProvider.value(value: appScript),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) =>
            GoogleAuthBloc(authRepo)..add(const GoogleAuthStarted(
              clientId: AppConstants.iosClientId,
              serverClientId: AppConstants.webClientId,
            ))),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Investment Tracker',
          theme: AppTheme.mainTheme,
          routerConfig: RouteConfig.router,
        ),
      ),
    );
  }
}