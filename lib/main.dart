import 'package:flutter/material.dart';
import 'api/bond_api_client.dart';
import 'screens/main_screen.dart';

void main() {
  const bondApiMode = String.fromEnvironment('BOND_API_MODE', defaultValue: 'api');
  const bondApiBaseUrl = String.fromEnvironment('BOND_API_BASE_URL', defaultValue: 'http://localhost:8888');

  configureBondApi(
    modeText: bondApiMode,
    baseUrl: bondApiBaseUrl,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financial Platform',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
