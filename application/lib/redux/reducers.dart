import '../model/app_state.dart';
import 'actions.dart';

AppState reducer(AppState prevState, dynamic action){
  AppState newState = AppState.fromAppState(prevState);

  if(action is ChangeAutoConnect){
    newState.isAutoConnect = action.payload;
  }

  if(action is ChangeEnableTime){
    newState.isEnableTime = action.payload;
  }

  return newState;
}