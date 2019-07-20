import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mychat1/modules/user.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Auth extends Object{
  static GoogleSignIn _googleSignIn = GoogleSignIn();
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static User currentUser;

  static Future<FirebaseUser> signInGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user = await _auth.signInWithCredential(credential);
    print("signed in " + user.displayName);
    currentUser = User(user.displayName, user.uid, user.email, "I'm ${user.displayName}", user.photoUrl);
    return user;
  }

  static Future<FirebaseUser> signInWithEmailAndPassword(email, password) async {
    final FirebaseUser user = await _auth.signInWithEmailAndPassword(email: email, password: password);
    currentUser = User(user.displayName, user.uid, user.email, "I'm ${user.displayName}", user.photoUrl);
    return user;
  }

  static Future<Null> handleSignOut() async {
    await FirebaseAuth.instance.signOut().whenComplete(
        (){  print('logout'); currentUser = null; }
    );
    await _googleSignIn.disconnect();
    await _auth.signOut().whenComplete(
        (){}
    );
  }


}



