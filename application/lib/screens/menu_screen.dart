import 'package:application/screens/about_screen.dart';
import 'package:application/screens/accelerometer_screen.dart';
import 'package:application/screens/arrow_screen.dart';
import 'package:application/screens/button_screen.dart';
import 'package:application/screens/setting_screen.dart';
import 'package:application/screens/switch_screen.dart';
import 'package:application/screens/terminal_screen.dart';
import 'package:application/screens/voice_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class MenuScreen extends StatefulWidget {
  final BluetoothDevice device;
  final BluetoothConnection connection;

  const MenuScreen({Key key, this.device, this.connection}) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // Avoid memory leak and disconnect
    if (!_isConnected) {
      isDisconnecting = true;
      widget.connection.dispose();
    }
  }

  setPortraitOrientation()  {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation != null) {
      setPortraitOrientation();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00979d),
        centerTitle: true,
        title: Text("Menu",
          style: TextStyle(
            fontFamily: 'Lato'
          ),
        ),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 2.0,
        mainAxisSpacing: 2.0,
        children: [
          RaisedButton(
            onPressed: () {
              _startSwitchScreen(context);
            },
            color: Colors.purple,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  width: 50.0,
                  height: 50.0,
                  color: Colors.white,
                  image: AssetImage('assets/images/switch.png'),
                ),
                SizedBox(height: 10.0,),
                Text("Switch",
                style: TextStyle(
                  fontSize: 18.0,
                  fontFamily: 'Lato',
                  color: Colors.white
                ),)
              ],
            ),
          ),
          RaisedButton(
            onPressed: (){
              _startTerminalScreen(context);
            },
            color: Colors.purple,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  width: 50.0,
                  height: 50.0,
                  color: Colors.white,
                  image: AssetImage('assets/images/code.png'),
                ),
                SizedBox(height: 10.0,),
                Text("Terminal",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'Lato',
                      color: Colors.white
                  ),)
              ],
            ),
          ),
          RaisedButton(
            onPressed: (){
              _startButtonScreen(context);
            },
            color: Colors.purple,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  width: 50.0,
                  height: 50.0,
                  color: Colors.white,
                  image: AssetImage('assets/images/menu.png'),
                ),
                SizedBox(height: 10.0,),
                Text("Buttons",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'Lato',
                      color: Colors.white
                  ),)
              ],
            ),
          ),
          RaisedButton(
            onPressed: (){
              _startArrowScreen(context);
            },
            color: Colors.purple,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  width: 50.0,
                  height: 50.0,
                  color: Colors.white,
                  image: AssetImage('assets/images/arrows.png'),
                ),
                SizedBox(height: 10.0,),
                Text("Arrows",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'Lato',
                      color: Colors.white
                  ),)
              ],
            ),
          ),
          RaisedButton(
            onPressed: (){
              _startAccelerometerScreen(context);
            },
            color: Colors.purple,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  width: 50.0,
                  height: 50.0,
                  color: Colors.white,
                  image: AssetImage('assets/images/compass.png'),
                ),
                SizedBox(height: 10.0,),
                Text("Accelerometer",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'Lato',
                      color: Colors.white
                  ),)
              ],
            ),
          ),
          RaisedButton(
            onPressed: (){
              _startVoiceScreen(context);
            },
            color: Colors.purple,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  width: 50.0,
                  height: 50.0,
                  color: Colors.white,
                  image: AssetImage('assets/images/microphone.png'),
                ),
                SizedBox(height: 10.0,),
                Text("Voice",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'Lato',
                      color: Colors.white
                  ),)
              ],
            ),
          ),
          RaisedButton(
            onPressed: (){
              _startSettingScreen(context);
            },
            color: Colors.purple,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  width: 50.0,
                  height: 50.0,
                  color: Colors.white,
                  image: AssetImage('assets/images/setting.png'),
                ),
                SizedBox(height: 10.0,),
                Text("Settings",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'Lato',
                      color: Colors.white
                  ),)
              ],
            ),
          ),
          RaisedButton(
            onPressed: (){
              _startAboutScreen();
            },
            color: Colors.purple,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  width: 50.0,
                  height: 50.0,
                  color: Colors.white,
                  image: AssetImage('assets/images/info.png'),
                ),
                SizedBox(height: 10.0,),
                Text("About",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'Lato',
                      color: Colors.white
                  ),)
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startSwitchScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return SwitchScreen(device: widget.device, connection: widget.connection);
        },
      ),
    );
  }

  void _startTerminalScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return TerminalScreen(device: widget.device, connection: widget.connection);
        },
      ),
    );
  }

  void _startButtonScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ButtonScreen(device: widget.device, connection: widget.connection);
        },
      ),
    );
  }

  void _startArrowScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ArrowScreen(device: widget.device, connection: widget.connection);
        },
      ),
    );
  }

  void _startAccelerometerScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return AccelerometerScreen(device: widget.device, connection: widget.connection);
        },
      ),
    );
  }

  void _startVoiceScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return VoiceScreen(device: widget.device, connection: widget.connection);
        },
      ),
    );
  }

  void _startSettingScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return SettingScreen(device: widget.device, connection: widget.connection);
        },
      ),
    );
  }

  void _startAboutScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return AboutScreen();
        },
      ),
    );
  }
}
