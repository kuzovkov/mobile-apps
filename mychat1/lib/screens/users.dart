import 'package:flutter/material.dart';
import 'package:mychat1/modules/auth.dart';


class UsersPage extends StatefulWidget {
  UsersPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {

  String nicname;

  @override
  Widget build(BuildContext context) {
    if (Auth.currentUser != null)
      nicname = Auth.currentUser.nickname ?? Auth.currentUser.email;
    return Scaffold(
      appBar: AppBar(

        title: Text("Users"),
        actions: <Widget>[
          Builder(builder: (BuildContext context) {
            return FlatButton(
              child: Text("Sign out(${nicname})"),
              textColor: Theme.of(context).buttonColor,
              onPressed: () async {
                Auth.handleSignOut().whenComplete((){
                  print('here users logout');
                  print(Auth.currentUser);
                  setState(() {

                  });
                });
              },
            );
          })
        ],
      ),
      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("User's list"),
          ],
        ),
      ),

    );
  }
}