import 'package:flutter/material.dart';
import 'login_page.dart';
import 'main/main_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(), // MainPage를 첫 화면으로 설정
    );
  }
}
