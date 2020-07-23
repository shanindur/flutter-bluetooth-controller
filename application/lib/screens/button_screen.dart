import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ButtonScreen extends StatefulWidget {
  final BluetoothDevice device;
  final BluetoothConnection connection;

  const ButtonScreen({Key key, this.device, this.connection}) : super(key: key);

  @override
  _ButtonScreenState createState() => _ButtonScreenState();
}

class _ButtonScreenState extends State<ButtonScreen> {
  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool isDisconnecting = false;
  bool _isConnected = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(widget.device != null){
      _isConnected = true;
    }
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
        backgroundColor: Color(0xFF00979d),
        title: Text("Buttons"
        ),
        centerTitle: true,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: <Widget>[
          Padding(
          padding: const EdgeInsets.all(40.0),
          child: InkWell(
            onTap: (){
              _sendMessageToBluetooth("1");
            },
            borderRadius: BorderRadius.circular(50.0),
            child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 6.0,
                ),
              ],
              ),
              child: Center(child: Text("1",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30.0
              ),)),
            ),
          ),
        ),
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: InkWell(
              onTap: (){
                _sendMessageToBluetooth("2");
              },
              borderRadius: BorderRadius.circular(50.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: Center(child: Text("2",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0
                  ),)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: InkWell(
              onTap: (){
                _sendMessageToBluetooth("3");
              },
              borderRadius: BorderRadius.circular(50.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: Center(child: Text("3",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0
                  ),)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: InkWell(
              onTap: (){
                _sendMessageToBluetooth("4");
              },
              borderRadius: BorderRadius.circular(50.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: Center(child: Text("4",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0
                  ),)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: InkWell(
              onTap: (){
                _sendMessageToBluetooth("5");
              },
              borderRadius: BorderRadius.circular(50.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: Center(child: Text("5",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0
                  ),)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: InkWell(
              onTap: (){
                _sendMessageToBluetooth("6");
              },
              borderRadius: BorderRadius.circular(50.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: Center(child: Text("6",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0
                  ),)),
              ),
            ),
          ),
        ],
      )
    );
  }

  // Method to send message,
  // for turning the Bluetooth device on
  void _sendMessageToBluetooth(String value) async {

      widget.connection.output.add(utf8.encode(value.toString()));
      show('Press button ' + value.toString());
      await widget.connection.output.allSent;

  }


  // Method to show a Snackbar,
  // taking message as the text
  Future show(
      String message, {
        Duration duration: const Duration(seconds: 1),
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
