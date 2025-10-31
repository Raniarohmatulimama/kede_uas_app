import 'package:flutter/material.dart';
import 'HomePage.dart';

void main() {
  runApp(const KedeGroceryApp());
}

class KedeGroceryApp extends StatelessWidget {
  const KedeGroceryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kede - Grocery App',
      theme: ThemeData(
        primaryColor: const Color(0xFF4CB32B),
        scaffoldBackgroundColor: const Color(0xFFFAFEFC),
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CB32B)),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
