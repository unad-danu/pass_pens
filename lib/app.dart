import 'package:flutter/material.dart';
import 'presentation/themes.dart';
import 'routes/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Tema aplikasi (light mode)
      theme: AppTheme.lightTheme,

      // Routing
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerate,

      // Halaman pertama yang dibuka
      initialRoute: AppRoutes.login,
    );
  }
}
