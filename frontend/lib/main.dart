import 'package:flutter/material.dart';
import './screens/main_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Check AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2196F3), // Blue
          secondary: Color(0xFF03A9F4), // Light Blue
        ),
        useMaterial3: true,
      ),
      home: const MainLayout(),
    );
  }
}

