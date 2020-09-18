import 'package:application/model/app_state.dart';
import 'package:application/redux/actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class VocalCommandConfig extends StatefulWidget {
  @override
  _VocalCommandConfigState createState() => _VocalCommandConfigState();
}

class _VocalCommandConfigState extends State<VocalCommandConfig> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Vocal Commands",
          style: TextStyle(
            fontFamily: 'Lato',
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF00979d),
      ),
      body: StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    show();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Command 01',
                            textAlign: TextAlign.left,
                            style:
                                TextStyle(fontFamily: 'Lato', fontSize: 20.0),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  color: Colors.black,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Command 02',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontFamily: 'Lato', fontSize: 20.0),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.black,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Command 03',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontFamily: 'Lato', fontSize: 20.0),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.black,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Command 05',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontFamily: 'Lato', fontSize: 20.0),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.black,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Command 06',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontFamily: 'Lato', fontSize: 20.0),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.black,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Command 07',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontFamily: 'Lato', fontSize: 20.0),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.black,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Command 08',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontFamily: 'Lato', fontSize: 20.0),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.black,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Command 09',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontFamily: 'Lato', fontSize: 20.0),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.black,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Command 10',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontFamily: 'Lato', fontSize: 20.0),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.black,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void show() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'What do you want to remember?'),
                    ),
                    SizedBox(
                      width: 320.0,
                      child: RaisedButton(
                        onPressed: () {},
                        child: Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: const Color(0xFF1BC0C5),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
