import '../model/app_state.dart';
import 'actions.dart';

AppState reducer(AppState prevState, dynamic action){
  AppState newState = AppState.fromAppState(prevState);

  if(action is ChangeAutoConnect){
    newState.isAutoConnect = action.payload;
  }

  return newState;
}