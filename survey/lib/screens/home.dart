import 'package:flutter/material.dart';
import 'package:survey/screens/survey.dart';
import 'package:survey/screens/result.dart';
import 'package:survey/screens/view.dart';
import 'package:survey/screens/menu.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => new HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Home"),
        backgroundColor: Color.fromRGBO(100, 100, 100, 0.5),
      ),
      body: new Container(
          child: new Center(
            child: new RaisedButton(child: new Text("I want start survey"),
                onPressed: () {
                  setState(() {
                    // navigate to the route
                    Navigator.of(context).pushNamed(SurveyScreen.routeName);
                  });
                }),

          ),
          decoration: new BoxDecoration(
          image: new DecorationImage(
            // Load image from assets
              image: new AssetImage('assets/img/bg1.jpg'),
              // Make the image cover the whole area
              fit: BoxFit.cover))
      ),
      // Set the nav drawer
      drawer: Menu.getNavDrawer(context, this),
    );
  }
}