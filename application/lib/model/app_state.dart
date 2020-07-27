import 'package:flutter/material.dart';

class  AppState{
  bool isAutoConnect;

  AppState(
      {@required this.isAutoConnect = false}
      );

  AppState.fromAppState(AppState state){
    isAutoConnect = state.isAutoConnect;
  }
}