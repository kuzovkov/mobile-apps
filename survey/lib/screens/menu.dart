import 'package:flutter/material.dart';
import 'package:survey/screens/survey.dart';
import 'package:survey/screens/result.dart';
import 'package:survey/screens/view.dart';

class Menu extends Object{
  static Drawer getNavDrawer(BuildContext context, State parentObject){
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
          parentObject.setState(() {
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

}
