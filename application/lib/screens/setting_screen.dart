import 'package:application/redux/actions.dart';
import 'package:application/screens/vocal_command_config.dart';
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
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text('General',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold
                      ),),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                  child: Row(
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
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text('Terminal',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold
                      ),),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Enable time display",
                            style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: 'Lato'
                            ),),
                          Text("Display time reference for exchanged data",
                            style: TextStyle(
                                fontSize: 14.0,
                                fontFamily: 'Lato'
                            ),),
                        ],
                      ),
                      Switch(
                          value: state.isEnableTime,
                          activeColor: Color(0xFF00979d),
                          onChanged: (bool value) {
                            StoreProvider.of<AppState>(context).dispatch(ChangeEnableTime(value));
                          }
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text('Voice Control',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold
                      ),),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Vocal commands configuration",
                            style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: 'Lato'
                            ),),
                          Text("Configure data to send",
                            style: TextStyle(
                                fontSize: 14.0,
                                fontFamily: 'Lato'
                            ),),
                        ],
                      ),
                      IconButton(
                        onPressed: (){
                          Navigator.of(context).push(   MaterialPageRoute(
                            builder: (context) {
                              return VocalCommandConfig();
                            },
                          ),);
                        },
                        icon: Icon(Icons.record_voice_over),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
