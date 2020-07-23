import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class SwitchScreen extends StatefulWidget {
  final BluetoothDevice device;
  final BluetoothConnection connection;

  const SwitchScreen({Key key, this.device, this.connection}) : super(key: key);


  @override
  _SwitchScreenState createState() => _SwitchScreenState();
}

class _SwitchScreenState extends State<SwitchScreen> {

  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _switchState;

  bool isDisconnecting = false;
  bool _isConnected = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(widget.device != null){
      _isConnected = true;
    }
    _switchState = false;

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // Avoid memory leak and disconnect
    if (!_isConnected) {
      isDisconnecting = true;
      widget.connection.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Switch"
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF00979d),
      ),
      body: Center(
        child: Switch(
              value: _switchState,
              onChanged: (bool value) {
                _sendMessageToBluetooth(value);
              },
              activeColor: Color(0xFF00979d),
        ),
      ),
    );
  }

  // Method to send message,
  // for turning the Bluetooth device on
  void _sendMessageToBluetooth(bool value) async {
    if(value){
      widget.connection.output.add(utf8.encode("1"));
      show('Device Turned On');
      setState(() {
        _switchState = true; // switch on
      });
    }else{
      widget.connection.output.add(utf8.encode("0"));
      show('Device Turned Off');
      setState(() {
        _switchState = false; // switch off
      });
    }
    await widget.connection.output.allSent;
  }

  // Method to show a Snackbar,
  // taking message as the text
  Future show(
      String message, {
        Duration duration: const Duration(seconds: 3),
      }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(
          message,
        ),
        duration: duration,
      ),
    );
  }
}