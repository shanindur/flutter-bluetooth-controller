import 'package:application/screens/button_screen.dart';
import 'package:application/screens/switch_screen.dart';
import 'package:application/screens/terminal_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/material.dart';
// For performing some operations asynchronously
import 'dart:async';
import 'dart:convert';

// For using PlatformException
import 'package:flutter/services.dart';

class HomeApp extends StatefulWidget {
  @override
  _HomeAppState createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {
  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  // Track the Bluetooth connection with the remote device
  BluetoothConnection connection;

  int _deviceState;

  bool isDisconnecting = false;

  Map<String, Color> colors = {
    'onBorderColor': Colors.green,
    'offBorderColor': Colors.red,
    'neutralBorderColor': Colors.transparent,
    'onTextColor': Colors.green,
    'offTextColor': Colors.red[700],
    'neutralTextColor': Colors.blue,
  };

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection.isConnected;

  // Define some variables, which will be required later
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _deviceState = 0; // neutral

    // If the bluetooth of the device is not enabled,
    // then request permission to turn on bluetooth
    // as the app starts up
    enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  // Request Bluetooth permission from the user
  Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  // For retrieving and storing the paired devices
  // in a list.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  // Now, its time to build the UI
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: Image(
            image: AssetImage('assets/images/logo.png'),
          ),
          backgroundColor: Color(0xFF00979d),
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              label: Text(
                "Refresh",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Lato',
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              splashColor: Color(0xFF00979d),
              onPressed: () async {
                // So, that when new devices are paired
                // while the app is running, user can refresh
                // the paired devices list.
                await getPairedDevices().then((_) {
                  show('Device list refreshed');
                });
              },
            ),
          ],
        ),
        body: ListView(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: _isButtonUnavailable &&
                      _bluetoothState == BluetoothState.STATE_ON,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.red[200],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text("General",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Lato',
                            fontSize: 18.0
                        ),)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Enable Bluetooth',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Lato',
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                      Switch(
                        value: _bluetoothState.isEnabled,
                        onChanged: (bool value) {
                          future() async {
                            if (value) {
                              await FlutterBluetoothSerial.instance
                                  .requestEnable();
                            } else {
                              await FlutterBluetoothSerial.instance
                                  .requestDisable();
                            }

                            await getPairedDevices();
                            _isButtonUnavailable = false;

                            if (_connected) {
                              _disconnect();
                            }
                          }

                          future().then((_) {
                            setState(() {});
                          });
                        },
                        activeColor: Color(0xFF00979d),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bluetooth Status',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Lato',
                                fontSize: 14.0,
                              ),
                            ),
                            Text(
                              _bluetoothState.toString(),
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'Lato',
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RaisedButton(
                        elevation: 2,
                        child: Text("Settings",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Lato',
                          ),),
                        onPressed: () {
                          FlutterBluetoothSerial.instance.openSettings();
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text("Paired Devices",
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0
                        ),)),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child:  Text("Note: If you can't find the device in the list, please pair the device by going to the settings.",
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Lato',
                        color: Colors.grey
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
                Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              DropdownButton(
                                hint: Text("Select a paired device",
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                ),),
                                items: _getDeviceItems(),
                                onChanged: (value) =>
                                    setState(() => _device = value),
                                value: _devicesList.isNotEmpty ? _device : null,
                              ),
                              RaisedButton(
                                color: _connected ? Colors.red : Color(0xFF00979d),
                                onPressed: _isButtonUnavailable
                                    ? null
                                    : _connected ? _disconnect : _connect,
                                child:
                                Text(_connected ? 'Disconnect' : 'Connect',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Lato',
                                  ),),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Text("Controller",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0
                                ),)),
                        ),
//                      Padding(
//                        padding: const EdgeInsets.all(10.0),
//                        child: Card(
//                          shape: RoundedRectangleBorder(
//                            side: new BorderSide(
//                              color: _deviceState == 0
//                                  ? colors['neutralBorderColor']
//                                  : _deviceState == 1
//                                  ? colors['onBorderColor']
//                                  : colors['offBorderColor'],
//                              width: 3,
//                            ),
//                            borderRadius: BorderRadius.circular(4.0),
//                          ),
//                          elevation: _deviceState == 0 ? 4 : 0,
//                          child: Padding(
//                            padding: const EdgeInsets.all(8.0),
//                            child: Row(
//                              children: <Widget>[
//                                Expanded(
//                                  child: Text(
//                                    "DEVICE",
//                                    style: TextStyle(
//                                      fontSize: 16,
//                                      color: _deviceState == 0
//                                          ? colors['neutralTextColor']
//                                          : _deviceState == 1
//                                          ? colors['onTextColor']
//                                          : colors['offTextColor'],
//                                    ),
//                                  ),
//                                ),
//                                FlatButton(
//                                  onPressed: _connected
//                                      ? _sendOnMessageToBluetooth
//                                      : null,
//                                  child: Text("ON"),
//                                ),
//                                FlatButton(
//                                  onPressed: _connected
//                                      ? _sendOffMessageToBluetooth
//                                      : null,
//                                  child: Text("OFF"),
//                                ),
//                              ],
//                            ),
//                          ),
//                        ),
//                      ),
                        Container(
                          margin: EdgeInsets.only(top: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  if (isConnected) {
                                    print('Connect -> selected ' + _device.address);
                                    _startSwitchScreen(context, _device);
                                  } else {
                                    show('No device selected');
                                  }
                                },
                                child: Container(
                                  height: 100.0, // height of the button
                                  width: 100.0, // width of the button
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF00979d),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black,
                                        offset: Offset(0.0, 1.0), //(x,y)
                                        blurRadius: 6.0,
                                      ),
                                    ],
                                  ),
                                  child: Center(child: Text('Switch',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Lato',
                                    ),)),
                                ),),
                              GestureDetector(
                                onTap: () async {
                                  if (isConnected) {
                                    print('Connect -> selected ' + _device.address);
                                    _startTerminalScreen(context, _device);
                                  } else {
                                    show('No device selected');
                                  }
                                },
                                child: Container(
                                  height: 100.0, // height of the button
                                  width: 100.0, // width of the button
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF00979d),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black,
                                        offset: Offset(0.0, 1.0), //(x,y)
                                        blurRadius: 6.0,
                                      ),
                                    ],
                                  ),
                                  child: Center(child: Text('Terminal',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Lato',
                                    ),)),
                                ),),
                              GestureDetector(
                                onTap: () async {
                                  if (isConnected) {
                                    print('Connect -> selected ' + _device.address);
                                    _startButtonScreen(context, _device);
                                  } else {
                                    show('No device selected');
                                  }
                                },
                                child: Container(
                                  height: 100.0, // height of the button
                                  width: 100.0, // width of the button
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF00979d),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black,
                                        offset: Offset(0.0, 1.0), //(x,y)
                                        blurRadius: 6.0,
                                      ),
                                    ],
                                  ),
                                  child: Center(child: Text('Buttons',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Lato',
                                    ),)),
                                ),),
                            ],
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
                Container(
                  height: MediaQuery.of(context).size.height - 600.0,
                  margin: EdgeInsets.only(bottom: 10.0),
                  alignment: Alignment.bottomCenter,
                  child: Text("Powered by Shanindu Rajapaksha",
                    style: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Lato',
                        fontSize: 14.0
                    ),),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Create the List of devices to be shown in Dropdown Menu
  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  // Method to connect to bluetooth
  void _connect() async {
    setState(() {
      _isButtonUnavailable = true;
    });
    if (_device == null) {
      show('No device selected');
    } else {
      if (!isConnected) {
        await BluetoothConnection.toAddress(_device.address)
            .then((_connection) {
          print('Connected to the device');
          connection = _connection;
          setState(() {
            _connected = true;
          });

          connection.input.listen(null).onDone(() {
            if (isDisconnecting) {
              print('Disconnecting locally!');
            } else {
              print('Disconnected remotely!');
            }
            if (this.mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          print('Cannot connect, exception occurred');
          print(error);
        });
        show('Device connected');

        setState(() => _isButtonUnavailable = false);
      }
    }
  }

  // void _onDataReceived(Uint8List data) {
  //   // Allocate buffer for parsed data
  //   int backspacesCounter = 0;
  //   data.forEach((byte) {
  //     if (byte == 8 || byte == 127) {
  //       backspacesCounter++;
  //     }
  //   });
  //   Uint8List buffer = Uint8List(data.length - backspacesCounter);
  //   int bufferIndex = buffer.length;

  //   // Apply backspace control character
  //   backspacesCounter = 0;
  //   for (int i = data.length - 1; i >= 0; i--) {
  //     if (data[i] == 8 || data[i] == 127) {
  //       backspacesCounter++;
  //     } else {
  //       if (backspacesCounter > 0) {
  //         backspacesCounter--;
  //       } else {
  //         buffer[--bufferIndex] = data[i];
  //       }
  //     }
  //   }
  // }

  // Method to disconnect bluetooth
  void _disconnect() async {
    setState(() {
      _isButtonUnavailable = true;
      _deviceState = 0;
    });

    await connection.close();
    show('Device disconnected');
    if (!connection.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }

  // Method to send message,
  // for turning the Bluetooth device on
  void _sendOnMessageToBluetooth() async {
//    connection.output.add(utf8.encode("1" + "\r\n"));
    connection.output.add(utf8.encode("1"));
    await connection.output.allSent;
    show('Device Turned On');
    setState(() {
      _deviceState = 1; // device on
    });
  }

  // Method to send message,
  // for turning the Bluetooth device off
  void _sendOffMessageToBluetooth() async {
//    connection.output.add(utf8.encode("0" + "\r\n"));
    connection.output.add(utf8.encode("0"));
    await connection.output.allSent;
    show('Device Turned Off');
    setState(() {
      _deviceState = -1; // device off
    });
  }

  void _startSwitchScreen(BuildContext context, BluetoothDevice device) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return SwitchScreen(device: device, connection: connection);
        },
      ),
    );
  }

  void _startTerminalScreen(BuildContext context, BluetoothDevice device) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return TerminalScreen(device: device, connection: connection,);
        },
      ),
    );
  }

  void _startButtonScreen(BuildContext context, BluetoothDevice device) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ButtonScreen(device: device, connection: connection);
        },
      ),
    );
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
