import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:connectivity/connectivity.dart';

class VoiceScreen extends StatefulWidget {
  final BluetoothConnection connection;
  final BluetoothDevice device;

  const VoiceScreen({Key key, this.connection, this.device}) : super(key: key);

  @override
  _VoiceScreenState createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  final SpeechToText speech = SpeechToText();
  String _text = '';
  bool _hasSpeech;
  String _currentLocaleId = "en_US";
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;

  @override
  void initState() {
    _initSpeechState();
    _hasSpeech = false;
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    super.initState();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Voice Control",
          style: TextStyle(
            fontFamily: 'Lato',
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF00979d),
      ),
      body: Column(
        children: [
          _connectionStatus == 'ConnectivityResult.none'
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: 25.0,
                  color: _connectionStatus == 'ConnectivityResult.none'
                      ? Colors.red
                      : Colors.green,
                  child: Center(
                    child: Text(
                      _connectionStatus == 'ConnectivityResult.none'
                          ? 'Offline'
                          : 'Online',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              : Container(),
          Container(
            height: MediaQuery.of(context).size.height - 150,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    _text.isEmpty ? "..." : _text,
                    style: TextStyle(fontFamily: 'Lato', fontSize: 25.0),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 0.26,
                              spreadRadius: level * 1.5,
                              color: Colors.black.withOpacity(0.1))
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    child: FloatingActionButton(
                        onPressed: () {
                          !_hasSpeech || speech.isListening
                              ? null
                              : startListening();
                        },
                        child: Icon(Icons.mic,
                            color: speech.isListening
                                ? Colors.redAccent
                                : Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          Text(
            'Say "go forward / come backward"',
            style: TextStyle(color: Colors.grey),
          )
        ],
      ),
    );
  }

  void _initSpeechState() async {
    bool hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener);
    if (!mounted) {
      return;
    }
    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  void statusListener(String status) {
    print(status);
  }

  void errorListener(SpeechRecognitionError error) {
    print("Received error status: $error");
  }

  startListening() {
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 10),
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        partialResults: true,
        onDevice: true,
        listenMode: ListenMode.confirmation);
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    setState(() {
      this.level = level;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    if (result.finalResult) {
      if (result.recognizedWords == "go forward") {
        _sendMessageToBluetooth("1");
      }
      if (result.recognizedWords == "come") {
        _sendMessageToBluetooth("2");
      }
      if (result.recognizedWords == "turn left") {
        _sendMessageToBluetooth("4");
      }
      if (result.recognizedWords == "turn right") {
        _sendMessageToBluetooth("3");
      }
      if (result.recognizedWords == "stop") {
        _sendMessageToBluetooth("5");
      }
      if (result.recognizedWords == "enjoy yourself") {
        _sendMessageToBluetooth("6");
      }

      setState(() {
        _text = result.recognizedWords;
      });
    }
  }

  // Method to send message,
  // for turning the Bluetooth device on
  void _sendMessageToBluetooth(String value) async {
    widget.connection.output.add(utf8.encode(value));
    await widget.connection.output.allSent;
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        String wifiName, wifiBSSID, wifiIP;

        try {
          if (!kIsWeb && Platform.isIOS) {
            LocationAuthorizationStatus status =
                await _connectivity.getLocationServiceAuthorization();
            if (status == LocationAuthorizationStatus.notDetermined) {
              status =
                  await _connectivity.requestLocationServiceAuthorization();
            }
            if (status == LocationAuthorizationStatus.authorizedAlways ||
                status == LocationAuthorizationStatus.authorizedWhenInUse) {
              wifiName = await _connectivity.getWifiName();
            } else {
              wifiName = await _connectivity.getWifiName();
            }
          } else {
            wifiName = await _connectivity.getWifiName();
          }
        } on PlatformException catch (e) {
          print(e.toString());
          wifiName = "Failed to get Wifi Name";
        }

        try {
          if (!kIsWeb && Platform.isIOS) {
            LocationAuthorizationStatus status =
                await _connectivity.getLocationServiceAuthorization();
            if (status == LocationAuthorizationStatus.notDetermined) {
              status =
                  await _connectivity.requestLocationServiceAuthorization();
            }
            if (status == LocationAuthorizationStatus.authorizedAlways ||
                status == LocationAuthorizationStatus.authorizedWhenInUse) {
              wifiBSSID = await _connectivity.getWifiBSSID();
            } else {
              wifiBSSID = await _connectivity.getWifiBSSID();
            }
          } else {
            wifiBSSID = await _connectivity.getWifiBSSID();
          }
        } on PlatformException catch (e) {
          print(e.toString());
          wifiBSSID = "Failed to get Wifi BSSID";
        }

        try {
          wifiIP = await _connectivity.getWifiIP();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiIP = "Failed to get Wifi IP";
        }

        setState(() {
          _connectionStatus = '$result\n'
              'Wifi Name: $wifiName\n'
              'Wifi BSSID: $wifiBSSID\n'
              'Wifi IP: $wifiIP\n';
        });
        break;
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        setState(() => _connectionStatus = result.toString());
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
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
