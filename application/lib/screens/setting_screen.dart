import 'package:application/redux/actions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../model/app_state.dart';
import '../redux/reducers.dart';

class SettingScreen extends StatefulWidget {
  final BluetoothConnection connection;
  final BluetoothDevice device;

  const SettingScreen({Key key, this.connection, this.device}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings",
          style: TextStyle(
            fontFamily: 'Lato',
          ),),
        centerTitle: true,
        backgroundColor: Color(0xFF00979d),
      ),
      body: StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state){
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Device auto connect",
                      style: TextStyle(
                          fontSize: 18.0,
                          fontFamily: 'Lato'
                      ),),
                    Switch(
                        value: state.isAutoConnect,
                        activeColor: Color(0xFF00979d),
                        onChanged: (bool value) {
                         StoreProvider.of<AppState>(context).dispatch(ChangeAutoConnect(value));
                        }
                    )
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
