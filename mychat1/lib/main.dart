import 'package:flutter/material.dart';
import 'package:mychat1/screens/users.dart';
import 'package:mychat1/modules/auth.dart';
import 'package:mychat1/screens/users.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mychat1/examples/signis_page.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

  static bool isLoading = false;



  @override
  Widget build(BuildContext context) {

    AppBar appbar;

    if (Auth.currentUser == null){
      appbar = AppBar(

        title: Text(widget._title),
      );
    }else{
      appbar = AppBar(

        title: Text("Users"),
        actions: <Widget>[
          Builder(builder: (BuildContext context) {
            return FlatButton(
              child: Text("Sign out(${Auth.currentUser.nicname})"),
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

  Widget _buildPage(){
     if (Auth.currentUser == null){
       return ListView(
         padding: const EdgeInsets.all(8.0),
         children: <Widget>[
           _EmailPasswordForm(),
           Center(child: Text("OR")),
           _GoogleSignInSection()
         ],
       );
     }else{
       return Center(

         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: <Widget>[
             Text("User's list"),
           ],
         ),
       );
     }
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



