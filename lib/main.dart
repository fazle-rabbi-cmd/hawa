import 'package:flutter/material.dart';
import 'package:hawa/screens/HomeScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hawa',
      theme: ThemeData.light(), // Using the light theme
      home: const HomeScreen(),
    );
  }
}
