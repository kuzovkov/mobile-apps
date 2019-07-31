import 'package:flutter/material.dart';
import 'package:mychat1/modules/auth.dart';
import 'package:mychat1/modules/user.dart';
import 'package:mychat1/screens/gmap.dart';
import 'package:mychat1/screens/ymap.dart';
import 'package:mychat1/modules/mylocation.dart';


class Menu extends Object{
  static Drawer getNavDrawer(BuildContext context, State parentObject){
    var headerChild = new DrawerHeader(child:
        ListTile(
          leading: Auth.currentUser.getUserAvatar(),
          title: Text(Auth.currentUser.nickname),
          subtitle: Text(Auth.currentUser.email)
        )
    );
    var aboutChild = new AboutListTile(
        child: new Text("About"),
        applicationName: "MyChat1",
        applicationVersion: "v1.0.0",
        applicationIcon: new Icon(Icons.chat),
        icon: new Icon(Icons.info));

    ListTile exitItem() {
      return new ListTile(
        leading: new Icon(Icons.exit_to_app),
        title: new Text("Logout"),
        onTap: () async {
          await Auth.handleSignOut().whenComplete((){
            print('here users logout');
            print(Auth.currentUser);
            parentObject.setState((){
              Navigator.of(context).pop();
            });
          });
        },
      );
    }

    ListTile googleMapItem() {
      return new ListTile(
        leading: new Icon(Icons.map),
        title: new Text("Google map"),
        onTap: () async {
          var location = await MyLocation.getCurrentLocation();
          Navigator.of(context).pop();
          Navigator.push(context, MaterialPageRoute(builder: (context) => GMapSample(currentLocation: location)));
        },
      );
    }

    ListTile yandexMapItem() {
      return new ListTile(
        leading: new Icon(Icons.map),
        title: new Text("Yandex map"),
        onTap: () async {
          var location = await MyLocation.getCurrentLocation();
          Navigator.of(context).pop();
          Navigator.push(context, MaterialPageRoute(builder: (context) => YMapSample(currentLocation: location)));
        },
      );
    }

    var myNavChildren = [
      headerChild,
      googleMapItem(),
      yandexMapItem(),
      exitItem(),
      aboutChild
    ];
    ListView listView = new ListView(children: myNavChildren);

    return new Drawer(
      child: listView,
    );
  }

}
