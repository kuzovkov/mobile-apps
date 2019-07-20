import 'package:flutter/material.dart';

class User extends Object{
  String nicname;
  String uid;
  String aboutMe;
  String photoUrl;
  String email;

  User(@required nicname, @required uid,  @required email, aboutMe, photoUrl){
    this.nicname = nicname;
    this.uid = uid;
    this.email = email;
    this.aboutMe = aboutMe;
    this.photoUrl = photoUrl;
  }

  static String datetime2string(DateTime datetime){
    if (datetime == null)
      return "Not defined";
    else if (datetime is String)
      return datetime.toString();
    return "${datetime.year}/${datetime.month}/${datetime.day}";
  }

}



