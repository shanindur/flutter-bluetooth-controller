import 'package:application/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Arduino Bluetooth',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomeApp(),
    );
  }
}
