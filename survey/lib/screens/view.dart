import 'package:flutter/material.dart';
import 'package:survey/screens/result.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:survey/screens/menu.dart';
import 'package:survey/models/user.dart';

class ViewScreen extends StatelessWidget {
  static const String routeName = "/view";
  static const String _title = "List of users";

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new UserListWidget(),
    );
  }


}

class UserListWidget extends StatefulWidget {

  UserListWidget({Key key}) : super(key: key);
  @override
  _UserListWidgetState createState() => _UserListWidgetState();
}


class _UserListWidgetState extends State<UserListWidget>{
  List<User> _users;
  String _error;

  void _loadDataFromServer() async {
    var request = new http.MultipartRequest("POST", Uri.parse(ResultScreen.API_URL));
    request.fields['optype'] = 'json';
    request.send().then((response) {
      response.stream.bytesToString().then((body){
        if (response.statusCode == 200){
          //print(body);
          setState(() {
            _users = [];
            _error = null;
            try{
              var data = jsonDecode(body);
              for (var row in data) {
                User user = new User(row['name'], row['lastName'], row['email'], row['sex'], row['birthday'], row['created_at'], row['photo']);
                this._users.add(user);
              }
            } on Exception catch(e){
              _users = [];
              _error = "${e}";
            }

          });
        }else{
          setState(() {
            _users = [];
            _error = "Error: ${response.statusCode}: ${body}";
          });
        }
      });
    });
  }


  TextStyle bold24Roboto = TextStyle(
    color: Colors.red,
    fontSize: 24.0,
    fontWeight: FontWeight.w900,
  );

  Widget _buildUserList() {

    if (_users == null){
      return Container(
        child: Center(
          child:
        Column(
          children: <Widget>[
          Text("Load data from server. Wait please...", style: bold24Roboto),
          CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(
              Colors.green),

          )]
        )
      ),);
    } else if (_users.length > 0 ){
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: (_users == null)? 0 : _users.length,
        itemBuilder: /*1*/ (context, i) {
        return CustomUserItem(_users[i]);
      });

    } else {
      String msg = "List of users is empty";
      if (_error != null){
        msg = "Error: ${_error}";
      }
      return Container(
          child: Center(
              child:
              Text(msg,style: bold24Roboto)
          ),
      );

    }
  }

  @override
  Widget build (BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(ViewScreen._title),
          backgroundColor: Color.fromRGBO(100, 100, 100, 0.5),
        ),
        body: _buildUserList(),
        // Set the nav drawer
        drawer: Menu.getNavDrawer(context, this));

  }

  @override
  void initState() {
    super.initState();
    this._loadDataFromServer();
  }

}
