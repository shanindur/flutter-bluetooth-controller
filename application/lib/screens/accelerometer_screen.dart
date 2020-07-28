import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:sensors/sensors.dart';

class AccelerometerScreen extends StatefulWidget {
  final BluetoothConnection connection;
  final BluetoothDevice device;

  const AccelerometerScreen({Key key, this.connection, this.device}) : super(key: key);


  @override
  _AccelerometerScreenState createState() => _AccelerometerScreenState();
}

class _AccelerometerScreenState extends State<AccelerometerScreen> {

  List<double> _accelerometerValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
  <StreamSubscription<dynamic>>[];

  String _side = "";
  int _arrowSide = 0 ;

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  setLandscapeOrientation()  {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft]);
  }

  @override
  void initState() {
    super.initState();
    _streamSubscriptions.add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
        if(_accelerometerValues[0] > 0 &&  _accelerometerValues[1] < 2 && _accelerometerValues[1] > -2 ){
          _side = "down";
          _arrowSide = 2;
          _sendMessageToBluetooth("2");
        }

        if(_accelerometerValues[0] < 0 &&  _accelerometerValues[1] < 2 && _accelerometerValues[1] > -2 ){
          _side = "up";
          _arrowSide = 1;
          _sendMessageToBluetooth("1");
        }

        if(_accelerometerValues[1] < 0 &&  _accelerometerValues[0] < 2 && _accelerometerValues[0] > -2 ){
          _side = "left";
          _arrowSide = 4;
          _sendMessageToBluetooth("4");
        }

        if(_accelerometerValues[1] > 0 &&  _accelerometerValues[0] < 2 && _accelerometerValues[0] > -2 ){
          _side = "right";
          _arrowSide = 3;
          _sendMessageToBluetooth("3");
        }
      });
    }));
  }


  @override
  Widget build(BuildContext context) {
    final List<String> accelerometer = _accelerometerValues?.map((double v) => v.toStringAsFixed(1))?.toList();
    if (MediaQuery.of(context).orientation != null) {
      setLandscapeOrientation();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Accelerometer",
          style: TextStyle(
            fontFamily: 'Lato',
          ),),
        centerTitle: true,
        backgroundColor: Color(0xFF00979d),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 100.0,
                  width: 100.0,
                  child: Container(
                    width: 100.0,
                    height: 100.0,
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      color: _side == "up" ? Colors.green : Colors.grey,
                      size: 70,
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 50.0),
                        height: 100.0,
                        width: 100.0,
                        child: Container(
                          width: 100.0,
                          height: 100.0,
                          child: Icon(
                            Icons.keyboard_arrow_left,
                            color: _side == "left" ? Colors.green : Colors.grey,
                            size: 70,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 50.0),
                        height: 100.0,
                        width: 100.0,
                        child: Container(
                          width: 100.0,
                          height: 100.0,
                          child: Icon(
                            Icons.keyboard_arrow_right,
                            color: _side == "right" ? Colors.green : Colors.grey,
                            size: 70,
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
                    width: 100.0,
                    height: 100.0,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: _side == "down" ? Colors.green : Colors.grey,
                      size: 70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method to send message,
  // for turning the Bluetooth device on
  void _sendMessageToBluetooth(String value) async {
    widget.connection.output.add(utf8.encode(value));
    await widget.connection.output.allSent;
  }
}
