import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:package_info/package_info.dart';

class AboutScreen extends StatefulWidget {

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //get package information
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About",
          style: TextStyle(
            fontFamily: 'Lato',
          ),),
        centerTitle: true,
        backgroundColor: Color(0xFF00979d),
      ),
      body:  Container(
        alignment: Alignment.center,
        child: Text("Version "+_packageInfo.version + "\nPowered by Shanindu Rajapaksha" ,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.grey,
              fontFamily: 'Lato',
              fontSize: 14.0
          ),),
      ),
    );
  }
}
