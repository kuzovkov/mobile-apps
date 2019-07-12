import 'package:flutter/material.dart';
import 'package:survey/screens/survey.dart';
import 'package:survey/screens/result.dart';
import 'package:survey/screens/view.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => new HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Drawer getNavDrawer(BuildContext context) {
    var headerChild = new DrawerHeader(child: new Text("Menu"));
    var aboutChild = new AboutListTile(
        child: new Text("About"),
        applicationName: "Survey",
        applicationVersion: "v1.0.0",
        applicationIcon: new Icon(Icons.adb),
        icon: new Icon(Icons.info));

    ListTile getNavItem(var icon, String s, String routeName) {
      return new ListTile(
        leading: new Icon(icon),
        title: new Text(s),
        onTap: () {
          setState(() {
            // pop closes the drawer
            Navigator.of(context).pop();
            // navigate to the route
            Navigator.of(context).pushNamed(routeName);
          });
        },
      );
    }

    var myNavChildren = [
      headerChild,
      getNavItem(Icons.home, "Home", "/"),
      getNavItem(Icons.speaker_notes, "Survey", SurveyScreen.routeName),
      getNavItem(Icons.account_box, "Result", ResultScreen.routeName),
      getNavItem(Icons.list, "View", ViewScreen.routeName),
      aboutChild
    ];

    ListView listView = new ListView(children: myNavChildren);

    return new Drawer(
      child: listView,
    );
  }

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
              image: new AssetImage('data_repo/img/bg1.jpg'),
              // Make the image cover the whole area
              fit: BoxFit.cover))
      ),
      // Set the nav drawer
      drawer: getNavDrawer(context),
    );
  }
}