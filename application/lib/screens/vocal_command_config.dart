import 'package:flutter/material.dart';

class VocalCommandConfig extends StatefulWidget {
  @override
  _VocalCommandConfigState createState() => _VocalCommandConfigState();
}

class _VocalCommandConfigState extends State<VocalCommandConfig> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vocal Commands",
          style: TextStyle(
            fontFamily: 'Lato',
          ),),
        centerTitle: true,
        backgroundColor: Color(0xFF00979d),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Container(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: (){},
              child: Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }
}
