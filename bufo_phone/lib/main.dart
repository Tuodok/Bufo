import 'package:flutter/material.dart';
import 'screens/connect_to_server_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bufo',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 85, 0, 231)
      ),
      home: ConnectToServerScreen(),
    );
  }
}
