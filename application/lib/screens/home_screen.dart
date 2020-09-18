import 'package:application/screens/menu_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

//For firebase
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';

// For performing some operations asynchronously
import 'dart:async';
import 'dart:convert';

// For using PlatformException
import 'package:flutter/services.dart';

import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:launch_review/launch_review.dart';

class HomeApp extends StatefulWidget {
  @override
  _HomeAppState createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {
  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _dropDownKey = new GlobalKey<ScaffoldState>();

  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  // Track the Bluetooth connection with the remote device
  BluetoothConnection connection;

  //Firebase
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  int _deviceState;

  bool isDisconnecting = false;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

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
    readData();

    //get package information
    _initPackageInfo();
    //Firebase Cloud Messaging
    _initFCM();
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

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Future<void> _initFCM() async {
    //Firebase
    var token = await _firebaseMessaging.getToken();
    print("Instance ID: " + token);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // Avoid memory leak and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  setPortraitOrientation() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
    if (MediaQuery.of(context).orientation != null) {
      setPortraitOrientation();
    }
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
                if (isConnected) {
                  _disconnect();
                }
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
                    backgroundColor: Colors.pink[200],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "General",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Lato',
                            fontSize: 18.0),
                      )),
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
                        child: Text(
                          "Settings",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Lato',
                          ),
                        ),
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
                      child: Text(
                        "Paired Devices",
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "Note: If you can't find the device in the list, please pair the device by going to the settings.",
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Lato',
                        color: Colors.grey),
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
                              DropdownButtonHideUnderline(
                                key: _dropDownKey,
                                child: DropdownButton(
                                  hint: Text(
                                    "Select a paired device",
                                    style: TextStyle(
                                      fontFamily: 'Lato',
                                    ),
                                  ),
                                  items: _getDeviceItems(),
                                  onChanged: (value) =>
                                      setState(() => _device = value),
                                  value:
                                      _devicesList.isNotEmpty ? _device : null,
                                ),
                              ),
                              RaisedButton(
                                color:
                                    _connected ? Colors.red : Color(0xFF00979d),
                                onPressed: _isButtonUnavailable
                                    ? null
                                    : _connected ? _disconnect : _connect,
                                child: Text(
                                  _connected ? 'Disconnect' : 'Connect',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Lato',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Container(
                          margin: EdgeInsets.only(top: 10.0),
                          height: 200.0,
                          width: 200.0,
                          child: Padding(
                              padding: const EdgeInsets.all(40.0),
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
                                    onPressed: () async {
                                      if (isConnected) {
                                        print('Connect -> selected ' +
                                            _device.address);
                                        _startNextScreen(context, _device);
                                      } else {
                                        show('No device selected');
                                      }
                                    },
                                    color: isConnected
                                        ? Colors.green
                                        : Colors.grey,
                                    child: Text(
                                      "Begin",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 25.0),
                                    ),
                                  ),
                                ),
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 30.0, bottom: 10.0),
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    "Version " +
                        _packageInfo.version +
                        "\n\nPowered by Shanindu Rajapaksha",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey, fontFamily: 'Lato', fontSize: 14.0),
                  ),
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
    if (_device == null) {
      show('No device selected');
    } else {
      setState(() {
        _isButtonUnavailable = true;
      });
      if (!isConnected) {
        await BluetoothConnection.toAddress(_device.address)
            .then((_connection) {
          print('Connected to the device');
          connection = _connection;
          setState(() {
            _connected = true;
          });
          show('Device connected');

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
          show('Device could not connect');
        });

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

  void _startNextScreen(BuildContext context, BluetoothDevice device) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return MenuScreen(device: device, connection: connection);
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

  Future<String> readData() async {
    String result = (await FirebaseDatabase.instance
            .reference()
            .child("app_data/version")
            .once())
        .value
        .toString();
    if (_packageInfo.version != result) {
      _onAlertButtonPressed(context);
    }
    return result;
  }

  // Alert with single button.
  _onAlertButtonPressed(context) {
    Alert(
      context: context,
      type: AlertType.info,
      title: "Update  ",
      desc: "A new update is available.",
      buttons: [
        DialogButton(
          child: Text(
            "Update",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            LaunchReview.launch(
                androidAppId: 'com.spacebar.flutterapp.bluetooth.application');
            Navigator.pop(context);
          },
          width: 120,
        )
      ],
    ).show();
  }
}
