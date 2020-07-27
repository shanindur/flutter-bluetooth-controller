import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';


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

  final SpeechToText speech = SpeechToText();
  String _text = '';
  bool _hasSpeech;
  String _currentLocaleId = "en_US";
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initSpeechState();
    _hasSpeech = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Voice",
          style: TextStyle(
            fontFamily: 'Lato',
          ),),
        centerTitle: true,
        backgroundColor: Color(0xFF00979d),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(_text.isEmpty ? "..." : _text,
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 25.0
            ),),
            Container(
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 0.26,
                        spreadRadius: level * 1.5,
                        color: Colors.black.withOpacity(0.1)
                    )
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(50))
              ),
              child: FloatingActionButton(
                onPressed: (){
                  !_hasSpeech || speech.isListening ? null : startListening();
                },
                child: Icon(Icons.mic,
                color: speech.isListening ? Colors.redAccent : Colors.white)
              ),
            ),

          ],
        ),
      ),
    );
  }

  void _initSpeechState() async {
    bool hasSpeech = await speech.initialize(
      onError: errorListener, onStatus: statusListener);
    if(!mounted){
      return;
    }
    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  void statusListener(String status){
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
    if(result.finalResult){
      if(result.recognizedWords == "switch off"){
        _sendMessageToBluetooth("0");
      }
      if(result.recognizedWords == "switch on"){
        _sendMessageToBluetooth("1");
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
