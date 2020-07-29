import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:vibration/vibration.dart';

class ArrowScreen extends StatefulWidget {
  final BluetoothConnection connection;
  final BluetoothDevice device;

  const ArrowScreen({Key key, this.connection, this.device}) : super(key: key);


  @override
  _ArrowScreenState createState() => _ArrowScreenState();
}

class _ArrowScreenState extends State<ArrowScreen> {

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
      appBar: AppBar(
        title: Text("Arrows",
        style: TextStyle(
          fontFamily: 'Lato',
        ),),
        centerTitle: true,
        backgroundColor: Color(0xFF00979d),
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10.0),
                  height: 100.0,
                  width: 100.0,
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
                    child: ClipOval(
                      child: RaisedButton(
                          onPressed: (){
                            _sendMessageToBluetooth("1");
                            Vibration.vibrate(duration: 100);
                          },
                          color: Colors.green,
                          child: Container(
                            width: 100.0,
                            height: 100.0,
                            child: Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.white,
                              size: 70,
                            ),
                          )
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 40.0, bottom: 40.0, left: 20.0, right: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 100.0,
                        width: 100.0,
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
                          child: ClipOval(
                            child: RaisedButton(
                                onPressed: (){
                                  _sendMessageToBluetooth("4");
                                  Vibration.vibrate(duration: 100);
                                },
                                color: Colors.green,
                                child: Container(
                                  width: 100.0,
                                  height: 100.0,
                                  child: Icon(
                                    Icons.keyboard_arrow_left,
                                    color: Colors.white,
                                    size: 70,
                                  ),
                                )
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 100.0,
                        width: 100.0,
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
                          child: ClipOval(
                            child: RaisedButton(
                                onPressed: (){
                                  _sendMessageToBluetooth("3");
                                  Vibration.vibrate(duration: 100);
                                },
                                color: Colors.green,
                                child: Container(
                                  width: 100.0,
                                  height: 100.0,
                                  child: Icon(
                                  Icons.keyboard_arrow_right,
                                  color: Colors.white,
                                  size: 70,
                                ),
                                )
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 100.0,
                  width: 100.0,
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
                    child: ClipOval(
                      child: RaisedButton(
                        onPressed: (){
                          _sendMessageToBluetooth("2");
                          Vibration.vibrate(duration: 100);
                        },
                        color: Colors.green,
                        child: Container(
                          width: 100.0,
                          height: 100.0,
                          child: Icon(
                           Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 70,
                          ),
                        )
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // Method to send message,
  // for turning the Bluetooth device on
  void _sendMessageToBluetooth(String value) async {

    widget.connection.output.add(utf8.encode(value.toString()));
    await widget.connection.output.allSent;

  }
}
