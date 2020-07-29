import 'package:flutter/material.dart';

class  AppState{
  bool isAutoConnect, isEnableTime;

  AppState({@required this.isAutoConnect = false, this.isEnableTime = true});

  AppState.fromAppState(AppState state){
    isAutoConnect = state.isAutoConnect;
    isEnableTime = state.isEnableTime;
  }
}