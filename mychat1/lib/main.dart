import 'package:flutter/material.dart';
import 'package:mychat1/modules/auth.dart';
import 'package:mychat1/modules/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mychat1/modules/style.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

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
  bool showSignEmailPassForm = false;
  bool showRegisterForm = false;
  bool showInvitePage = true;
  final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();


  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      showNotification(message['notification']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      Firestore.instance.collection('users').document(Auth.currentUser.uid).updateData({'pushToken': token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  void configLocalNotification() {
    var initializationSettingsAndroid = new AndroidInitializationSettings('chat1');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid ? 'com.company.mychat1': 'com.company.mychat1',
      'MyChat1',
      'MyChat1',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics =
    new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, message['title'].toString(), message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));
  }

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
              child: Icon(Icons.exit_to_app, color: Colors.white, size: 30),
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
    registerNotification();
    configLocalNotification();
  }


  _saveCurrUserOnServer () async{
    if (Auth.currentUser == null)
      return null;
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
    if (Auth.currentUser == null)
      return null;
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
        _users.add(User.fromDocument(document));
      }
    }on Exception catch (e){
      _error = e.toString();
    }
    setState(() {
      _isLoading = false;
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
        return _isLoading ? _preloader() : Container(
            child: Center(
                child:
                Text("List of users is empty", style: bold24Roboto)
            )
        );
      }

    }else{
      //show login form
      return (showInvitePage) ? _invitePage() : Center(child: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          (showSignEmailPassForm) ? _EmailPasswordForm() : Container(),
          //Center(child: Text("OR"))
          //Center(child: Text("OR")),
          (showRegisterForm) ? _RegisterForm() : Container()
        ],
      )
      );
    }
  }

  Widget _invitePage(){
    return Center(
        child: ListView(
      children: <Widget>[
        GestureDetector(
          child: Row(
            children: <Widget>[
              Image.asset("assets/img/btn_google_signin.png"),
            ],
            mainAxisSize: MainAxisSize.min,
          ),
          onTap: () async {
            Auth.signInGoogle().then((user){
              print('logied with google');
              setState(() {
                _saveCurrUserOnServer ();
                _isLoading = true;
                _getUsersFromServer();
              });
            });
          },
        ),
        GestureDetector(
          child: Row(
            children: <Widget>[
              Icon(Icons.email, size: 50.0,),
              Text("Sign with email/password")
            ],
            mainAxisSize: MainAxisSize.min,
          ),
          onTap: (){
            setState(() {
              showRegisterForm = false;
              showSignEmailPassForm = true;
              showInvitePage = false;
            });
          },
        ),
        GestureDetector(
          child: Row(
            children: <Widget>[
              Icon(Icons.account_circle, size: 50.0,),
              Text("Create new user")
            ],
            mainAxisSize: MainAxisSize.min,
          ),
          onTap: (){
            setState(() {
              showRegisterForm = true;
              showSignEmailPassForm = false;
              showInvitePage = false;
            });
          },
        ),
      ],
      )
    );

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
    return Center(child: Form(
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
            obscureText: true,
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
                  Auth.signInWithEmailAndPassword(_emailController.text.trim(), _passwordController.text.trim()).then((user){
                    print('logied with email/pass');
                    setState(() {
                      _saveCurrUserOnServer ();
                      _isLoading = true;
                      _getUsersFromServer();
                    });
                  });
                }
              },
              child: const Text('Sign in'),
            ),
          ),
          GestureDetector(
            child: Row(
              children: <Widget>[
                Icon(Icons.arrow_back, size: 50.0,),
                Text("Back")
              ],
              mainAxisSize: MainAxisSize.min,
            ),
            onTap: (){
              setState(() {
                showRegisterForm = false;
                showSignEmailPassForm = false;
                showInvitePage = true;
              });
            },
          ),
        ],
      ),
    ));
  }


  Widget _RegisterForm(){
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: const Text('Create new user:'),
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
            obscureText: true,
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
                  Auth.createUserWithEmailPassword(_emailController.text.trim(), _passwordController.text.trim()).then((user){
                    print('creating new with email/pass');
                    print(user);
                    setState(() {
                      _saveCurrUserOnServer ();
                      _isLoading = true;
                      _getUsersFromServer();
                    });
                  });
                }
              },
              child: const Text('Create user'),
            ),
          ),
          GestureDetector(
            child: Row(
              children: <Widget>[
                Icon(Icons.arrow_back, size: 50.0,),
                Text("Back")
              ],
              mainAxisSize: MainAxisSize.min,
            ),
            onTap: (){
              setState(() {
                showRegisterForm = false;
                showSignEmailPassForm = false;
                showInvitePage = true;
              });
            },
          ),
        ],
      ),
    );
  }


}



