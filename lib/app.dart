import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/design_preview/presentation/design_preview_page.dart';

class VonteApp extends StatelessWidget {
  const VonteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vonte PoS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // TEMP: Set initialRoute to design preview for UI foundation verification
      initialRoute: DesignPreviewPage.routeName,
      routes: {
        // TEMP: Preview route
        DesignPreviewPage.routeName: (context) => const DesignPreviewPage(),
      },
    );
  }
}

