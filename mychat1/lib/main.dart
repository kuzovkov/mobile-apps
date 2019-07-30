import 'package:flutter/material.dart';
import 'package:mychat1/modules/auth.dart';
import 'package:mychat1/modules/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mychat1/modules/style.dart';
import 'package:mychat1/modules/menu.dart';
import 'package:mychat1/modules/mylocation.dart';
import 'package:location/location.dart';


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
  final Firestore firestore = Firestore.instance;


  @override
  Widget build(BuildContext context) {

    return (Auth.currentUser != null) ? Scaffold(
        appBar: AppBar(title: Text(widget._title)),
        body: _buildPage(),
      drawer: Menu.getNavDrawer(context, this),
       ) : Scaffold(
        appBar: AppBar(title: Text(widget._title)),
        body: _buildPage());
  }

  @override
  void initState() {
    super.initState();
  }


  _saveCurrUserOnServer () async{
    if (Auth.currentUser == null)
      return null;
    final QuerySnapshot result = await Firestore.instance.collection('users').where('id', isEqualTo: Auth.currentUser.uid).getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    LocationData location = await MyLocation.getCurrentLocation();
    if (documents.length == 0) {
      // Update data to server if new user
      var data = {
        'nickname': Auth.currentUser.nickname,
        'photoUrl': Auth.currentUser.photoUrl,
        'id': Auth.currentUser.uid,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
        'chattingWith': null,
        'email': Auth.currentUser.email
      };
      if (location != null){
        data['location'] = {'lat': location.latitude, 'lng': location.latitude};
      }
      Firestore.instance.collection('users')
          .document(Auth.currentUser.uid)
          .setData(data);
    }else{
      Map<String, Object> data = {
        'updatedAt': DateTime.now()
      };
      if (location != null){
        data['location'] = {'lat': location.latitude, 'lng': location.latitude};
      }
      Firestore.instance.collection('users')
          .document(Auth.currentUser.uid)
          .updateData({
        'updatedAt': DateTime.now(),
        'location': {'lat': location.latitude, 'lng': location.longitude}
      });
    }
    MyLocation.onChangeLocation((LocationData newLocation){
      if (Auth.currentUser != null){
          Firestore.instance.collection('users')
              .document(Auth.currentUser.uid)
              .updateData({
          'updatedAt': DateTime.now(),
          'location': {'lat': newLocation.latitude, 'lng': newLocation.longitude}
          });
      }
    });
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
        return _buildUserList();
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

  Widget _buildUserList(){
    return
      Flex(
        children: <Widget>[
            Flexible(
              child:
                StreamBuilder<QuerySnapshot>(
                  stream: firestore.collection('users').snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return Center(
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)));
                final int userCount = snapshot.data.documents.length;
                  return ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: userCount,
                itemBuilder: (_, int index) {
                final DocumentSnapshot document = snapshot.data.documents[index];
                if (document['id'] == Auth.currentUser.uid)
                  return Container();
                User user = User.fromDocument(document);
                  return CustomUserItem(user);
                },
                separatorBuilder: (BuildContext context, int index){
                  DocumentSnapshot document = snapshot.data.documents[index];
                  return (document['id'] != Auth.currentUser.uid)? Divider() : Container();
                },
              );
            },
            )
          )
        ],
        direction: Axis.vertical,
      );

  }

  Widget _invitePage(){
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          child: Row(
            children: <Widget>[
              Image.asset("assets/img/google3.png", width: 40.0, height: 40.0,),
              Container(padding: EdgeInsets.all(10.0)),
              Text("Sign with Google")
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
              Container(padding: EdgeInsets.all(8.0)),
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
              Icon(Icons.add, size: 50.0,),
              Icon(Icons.account_circle, size: 30.0,),
              Container(padding: EdgeInsets.all(10.0)),
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



