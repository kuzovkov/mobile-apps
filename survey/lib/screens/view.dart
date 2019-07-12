import 'package:flutter/material.dart';

class ViewScreen extends StatelessWidget {
  static const String routeName = "/view";

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("View"),
        backgroundColor: Color.fromRGBO(100, 100, 100, 0.5),
      ),
      body: new Container(
          child: new Center(
            child: new Text("View Screen"),
          )),
    );
  }
}