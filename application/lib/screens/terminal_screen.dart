import 'dart:convert';

import 'package:application/model/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';

class TerminalScreen extends StatefulWidget {
  final BluetoothDevice device;
  final BluetoothConnection connection;

  const TerminalScreen({Key key, this.device, this.connection}) : super(key: key);

  @override
  _TerminalScreenState createState() => _TerminalScreenState();
}

class _Message {
  int whom;
  String text;
  String time;

  _Message(this.whom, this.text, this.time);
}

class _TerminalScreenState extends State<TerminalScreen> {
  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static final clientID = 0;
  List<_Message> messages = List<_Message>();
  String _messageBuffer = '';

  final TextEditingController textEditingController =
  new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => widget.connection != null && widget.connection.isConnected;
  bool isDisconnecting = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Row> list = messages.map((_message) {
      return Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            child: Column(
              children: [
                Container(
                  child: Text((text) {
                        return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                      }(_message.text.trim()),
                      style: TextStyle(color: Colors.white)),
                  padding: EdgeInsets.all(12.0),
                  width: 222.0,
                  decoration: BoxDecoration(
                      color:
                      _message.whom == clientID ? Colors.blueAccent : Colors.grey,
                      borderRadius: BorderRadius.circular(7.0)),
                ),
                Container(
                  width: MediaQuery.of(context).size.width - 190,
                  child: StoreConnector<AppState, AppState>(
                    converter: (store) => store.state,
                    builder: (context, state){
                      return Visibility(
                        visible: state.isEnableTime,
                        child: Text(_message.time.toString(),
                          style: TextStyle(
                              color: Colors.grey
                          ),
                          textAlign: TextAlign.right,),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
        mainAxisAlignment: _message.whom == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00979d),
          centerTitle: true,
          title: (Text('Terminal',
          style: TextStyle(
            fontFamily: 'Lato',
          ),)
            )),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Flexible(
              child: ListView(
                  padding: const EdgeInsets.all(12.0),
                  controller: listScrollController,
                  children: list),
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(0.0, 1.0), //(x,y)
                    blurRadius: 6.0,
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(left: 16.0),
                      child: TextField(
                        style: const TextStyle(fontSize: 15.0),
                        controller: textEditingController,
                        decoration: InputDecoration.collapsed(
                          hintText: 'Type your data to send...',
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                        enabled: isConnected,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(8.0),
                    child: IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Colors.blue),
                        onPressed: isConnected
                            ? () => _sendMessage(textEditingController.text)
                            : null),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }


  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0) {
      try {
//        widget.connection.output.add(utf8.encode(text + "\r\n"));
        widget.connection.output.add(utf8.encode(text));
        await widget.connection.output.allSent;

        setState(() {
          DateTime now = DateTime.now();
          String formattedTime = DateFormat('kk:mm').format(now);
          messages.add(_Message(clientID, text, formattedTime));
        });

        Future.delayed(Duration(milliseconds: 333)).then((_) {
          listScrollController.animateTo(
              listScrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 333),
              curve: Curves.easeOut);
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
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
