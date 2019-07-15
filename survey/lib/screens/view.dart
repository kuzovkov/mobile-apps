import 'package:flutter/material.dart';
import 'package:survey/screens/result.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:survey/screens/menu.dart';

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


class User extends Object{
  String name;
  String lastName;
  String email;
  String sex;
  String birthday;
  String createdAt;
  Uint8List photo;

  User(@required name, @required lastName, @required email, @required sex, @required birthday, @required  createdAt, photo){
    this.name = name;
    this.lastName = lastName;
    this.email = email;
    this.sex = sex;
    this.birthday = birthday;
    this.createdAt = createdAt;
    if (photo != null)
      this.photo = base64.decode(photo);
  }

}

class _UserListWidgetState extends State<UserListWidget>{
  List<User> _users = [];

  void _loadDataFromServer() async {
    var request = new http.MultipartRequest("POST", Uri.parse(ResultScreen.API_URL));
    request.fields['optype'] = 'json';
    request.send().then((response) {
      response.stream.bytesToString().then((body){
        if (response.statusCode == 200){
          //print(body);
          setState(() {
            _users = [];
            var data = jsonDecode(body);
            for (var row in data) {
              User user = new User(row['name'], row['lastName'], row['email'], row['sex'], row['birthday'], row['created_at'], row['photo']);
              this._users.add(user);
            }
          });
        }
      });
    });
  }

  Widget _buildUserList() {
    if (_users.length > 0 ){
      return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: (_users == null)? 0 : _users.length,
          itemBuilder: /*1*/ (context, i) {
            return _buildRow(_users[i]);
          });
    }else{
      return Container(
        child: Center(
          child:
        Column(
          children: <Widget>[
          Text("Load data from server. Wait please..."),
          CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(
              Colors.green),

          )]
        )
      ),);
    }
  }

  Widget _buildRow(User user) {
    if (user.photo == null){
      return ListTile(
        title: Text(
            [user.name, user.lastName, user.email, user.sex, user.birthday, user.createdAt].join("\n")
        )
      );
    }else{
      return ListTile(
      title: Text(
          [user.name, user.lastName, user.email, user.sex, user.birthday, user.createdAt].join("\n")
      ),
      trailing: Image.memory(
            user.photo,
            scale: 1.0,
            width: 100.0,
          height: 100.0,
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
