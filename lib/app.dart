import 'package:flutter/material.dart';
import 'main_layout.dart';
import 'routes/app_routes.dart';

class UkilApp extends StatelessWidget {
  const UkilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ✅ IMPORTANT
      onGenerateRoute: AppRoutes.generateRoute,

      // optional fallback route
      initialRoute: '/',
      home: const MainLayout(),
    );
  }
}
