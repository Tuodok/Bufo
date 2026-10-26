import 'package:bufo/src/screens/connect_to_server_screen.dart';
import 'package:flutter/material.dart';

class BufoApp extends StatelessWidget {
  const BufoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bufo',
      theme: ThemeData(
        appBarTheme: AppBarTheme(backgroundColor: Colors.black),
        scaffoldBackgroundColor: const Color.fromARGB(255, 85, 0, 231),
      ),
      home: ConnectToServerScreen(),
    );
  }
}
