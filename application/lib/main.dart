import 'package:application/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'model/app_state.dart';
import 'redux/reducers.dart';
import 'dart:io' show Platform;

Future<void> main() async {
  final _initState = AppState();
  final Store<AppState> _store = Store<AppState>(reducer, initialState: _initState);

  runApp(MyApp(store: _store));
}

class MyApp extends StatelessWidget {
  final Store<AppState> store;
  MyApp({this.store});

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Arduino Bluetooth',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: HomeApp(),
      ),
    );
  }
}
