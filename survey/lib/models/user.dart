import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';


enum Sex { male, female }
var sexName = ['Male', 'Female'];

class User extends Object{
  String name;
  String lastName;
  String email;
  Sex sex;
  DateTime birthday;
  DateTime createdAt;
  Image photo;


  User(@required name, @required lastName, @required email, @required sex, @required birthday, @required  createdAt, photo){
    this.name = name;
    this.lastName = lastName;
    this.email = email;
    if (sex is String)
      this.sex = (sex.toLowerCase() == "male")? Sex.male : Sex.female;
    else if (sex is Sex)
      this.sex = sex;
    if (birthday is DateTime){
      this.birthday = birthday;
    }else if (birthday is String){
      this.birthday = DateTime.tryParse(birthday);
    }
    if (createdAt is DateTime){
      this.createdAt = createdAt;
    }else if (birthday is String){
      this.createdAt = DateTime.tryParse(createdAt);
    }
    if (photo != null){
      if (photo is String)
        this.photo = Image.memory(base64.decode(photo), scale: 1.0, width: 100.0, height: 100.0);
      else if (photo is Image)
        this.photo = photo;
    }

  }

  static String datetime2string(DateTime datetime){
    if (datetime == null)
      return "Not defined";
    else if (datetime is String)
      return datetime.toString();
    return "${datetime.year}/${datetime.month}/${datetime.day}";
  }

}

class CustomUserItem extends StatelessWidget {

  CustomUserItem(User user){
    this.user = user;
    this.photo = (user.photo == null)? Image.asset("assets/img/male.png") : this.user.photo;
  }

  User user;
  Image photo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: this.photo,
          ),
          Expanded(
            flex: 3,
            child: _UserDescription(
                this.user
            ),
          ),
          const Icon(
              Icons.more_vert,
              size: 16.0
          ),
        ],
      ),
    );
  }
}

class _UserDescription extends StatelessWidget {
  _UserDescription(User user){
    this.name = user.name;
    this.lastName = user.lastName;
    this.email = user.email;
    this.sex = sexName[user.sex.index];
    this.birthday = User.datetime2string(user.birthday);
    this.createdAt = user.createdAt.toString();
  }

  String name;
  String lastName;
  String email;
  String sex;
  String birthday;
  String createdAt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14.0,
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
          Text(
            lastName,
            style: const TextStyle(fontSize: 10.0),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
          Text(
            email,
            style: const TextStyle(fontSize: 10.0),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
          Text(
            sex,
            style: const TextStyle(fontSize: 10.0),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
          Text(
            birthday,
            style: const TextStyle(fontSize: 10.0),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
          Text(
            createdAt,
            style: const TextStyle(fontSize: 10.0),
          ),
        ],
      ),
    );
  }
}


