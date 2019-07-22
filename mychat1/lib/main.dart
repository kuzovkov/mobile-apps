import 'package:flutter/material.dart';
import 'package:mychat1/modules/auth.dart';
import 'package:mychat1/modules/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mychat1/modules/style.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyChat1',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.orange,
      ),
      home: MainPage()
    );
  }

}


class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);
  final String _title = "MyChat1";


  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {

  List<User> _users;
  String _error;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {

    AppBar appbar;

    if (Auth.currentUser == null){
      appbar = AppBar(

        title: Text(widget._title),
      );
    }else{
      appbar = AppBar(

        title: Text(widget._title),
        actions: <Widget>[
          Builder(builder: (BuildContext context) {
            return FlatButton(
              child: Text("Sign out(${Auth.currentUser.nickname})"),
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
      );
    }


    return Scaffold(
        appBar: appbar,
        body: _buildPage());
  }

  @override
  void initState() {
    super.initState();
  }


  _saveCurrUserOnServer () async{
    final QuerySnapshot result = await Firestore.instance.collection('users').where('id', isEqualTo: Auth.currentUser.uid).getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    if (documents.length == 0) {
      // Update data to server if new user
      Firestore.instance.collection('users')
          .document(Auth.currentUser.uid)
          .setData({
        'nickname': Auth.currentUser.nickname,
        'photoUrl': Auth.currentUser.photoUrl,
        'id': Auth.currentUser.uid,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
        'chattingWith': null,
        'email': Auth.currentUser.email
      });
    }else{
      Firestore.instance.collection('users')
          .document(Auth.currentUser.uid)
          .updateData({
        'updatedAt': DateTime.now()
      });
    }
  }

  _getUsersFromServer () async{
    _users = [];
    try{
      final QuerySnapshot result = await Firestore.instance.collection('users').getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      for (var document in documents) {
        print(Auth.currentUser.uid);
        print(document['id']);
        if (document['id'] == Auth.currentUser.uid)
           continue;
        print(document['createdAt']);
        _users.add(User(document['nickname'], document['id'], document['email'], document['aboutMe'], document['photoUrl']));
      }
    }on Exception catch (e){
      _error = e.toString();
    }
    setState(() {

    });
  }

  Widget _buildPage () {
    if (Auth.currentUser != null){
      if(_users == null){
        _getUsersFromServer();
        //show preloader
        return _preloader();
      }else if(_users.length > 0){
        //show user's list
        return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: (_users == null)? 0 : _users.length,
            itemBuilder: /*1*/ (context, i) {
              return CustomUserItem(_users[i]);
            },
            separatorBuilder: (BuildContext context, int index) => const Divider());
      }else if (_error != null){
         return _showError(_error);
      }else{
        return Container(
            child: Center(
                child:
                Text("List of users is empty", style: bold24Roboto)
            )
        );
      }

    }else{
      //show login form
      return ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          _EmailPasswordForm(),
          Center(child: Text("OR")),
          _GoogleSignInSection()
        ],
      );
    }
  }


  Widget _preloader(){
    return Container(
      child: Center(
          child:
              CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                    Colors.orange),
              )
        )
      );
  }

  Widget _showError(msg){
    return Container(
      child: Center(
          child:
              Text(msg, style: bold24Roboto)
              )
        );
  }

  Widget _EmailPasswordForm(){
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: const Text('Sign in email and password'),
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
          ),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
            validator: (String value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            validator: (String value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            alignment: Alignment.center,
            child: RaisedButton(
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  Auth.signInWithEmailAndPassword(_emailController.text, _passwordController.text).then((user){
                    print('logied with email/pass');
                    setState(() {
                      _saveCurrUserOnServer ();
                      _getUsersFromServer();
                    });
                  });
                }
              },
              child: const Text('Sign in'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _GoogleSignInSection(){
    return Column(
      children: <Widget>[
        Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            alignment: Alignment.center,
            child: RaisedButton(
              onPressed: () async {
                Auth.signInGoogle().then((user){
                  print('logied with google');
                  setState(() {
                    _saveCurrUserOnServer ();
                    _getUsersFromServer();
                  });
                });
              },
              child: Text("Sign in with Google"),
            )
        ),
      ],
    );
  }

}



