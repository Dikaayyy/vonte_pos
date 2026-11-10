import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_routes.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/design_preview/presentation/design_preview_page.dart';
import 'features/home/presentation/pages/home_placeholder_page.dart';

class VonteApp extends StatelessWidget {
  const VonteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (context) => getIt<AuthCubit>(),
      child: MaterialApp(
        title: 'Vonte PoS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (context) => const SplashPage(),
          AppRoutes.login: (context) => const LoginPage(),
          AppRoutes.register: (context) => const RegisterPage(),
          AppRoutes.home: (context) => const HomePlaceholderPage(),
          // Kept for design token and widget preview tests
          DesignPreviewPage.routeName: (context) => const DesignPreviewPage(),
        },
      ),
    );
  }
}
