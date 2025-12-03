import 'package:flutter/material.dart';
import 'routes/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Tema agar tidak muncul layar biru di awal
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B5E86)),
      ),

      // Routing
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerate,

      // Halaman pertama → LoginPage
      initialRoute: AppRoutes.login,
    );
  }
}
