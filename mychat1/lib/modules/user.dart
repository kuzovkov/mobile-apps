import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mychat1/modules/style.dart';
import 'package:mychat1/screens/chat.dart';

class User extends Object{
  String nickname;
  String uid;
  String aboutMe;
  String photoUrl;
  String email;
  DateTime createdAt;
  DateTime updatedAt;
  Map<String, double> location;

  User(@required nickname, @required uid,  @required email, aboutMe, photoUrl, createdAt, updatedAt, location){
    this.nickname = nickname ?? email;
    this.uid = uid;
    this.email = email;
    this.aboutMe = aboutMe;
    this.photoUrl = photoUrl;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
    this.location = location;
  }

  User.fromDocument(@required document){
    this.nickname = document['nickname'] ?? document['email'];
    this.uid = document['id'];
    this.email = document['email'];
    this.aboutMe = document['aboutMe'];
    this.photoUrl = document['photoUrl'];
    if (document['createdAt'] == null){
      this.createdAt = DateTime.now();
    }else if (document['createdAt'] is DateTime){
       this.createdAt = document['createdAt'];
    }else if (document['createdAt'] is int){
      if (document['createdAt'] < DateTime.now().millisecond)
        document['createdAt'] *= 1000;
      this.createdAt = DateTime.fromMillisecondsSinceEpoch(document['createdAt']);
    }else{
      this.createdAt = document['createdAt'].toDate();
    }
    if (document['updatedAt'] == null){
      this.updatedAt = DateTime.now();
    }else if (document['updatedAt'] is DateTime){
      this.updatedAt = document['updatedAt'];
    }else if (document['updatedAt'] is int){
      if (document['updatedAt'] < DateTime.now().millisecond)
        document['updatedAt'] *= 1000;
      this.updatedAt = DateTime.fromMillisecondsSinceEpoch(document['updatedAt']);
    }else{
      this.updatedAt = document['updatedAt'].toDate();
    }
    if (document['location'] != null)
      this.location = {'lat': document['location']['lat'], 'lng': document['location']['lng']};
  }

  static String datetime2string(DateTime datetime){
    if (datetime == null)
      return "Not defined";
    else if (datetime is String)
      return datetime.toString();
    return "${datetime.year}/${datetime.month}/${datetime.day}";
  }

  String getLastSeen(){
    DateTime now = DateTime.now();
    List<String> monthes = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    if (this.updatedAt.year != now.year && this.updatedAt.month != now.month && this.updatedAt.day != now.day)
      return "Last seen: ${this.updatedAt.day}.${this.updatedAt.month}.${this.updatedAt.year} ${this.updatedAt.hour}:${this.updatedAt.minute}";
    if (this.updatedAt.year == now.year && this.updatedAt.month != now.month && this.updatedAt.day != now.day)
      return "Last seen: ${this.updatedAt.day}.${this.updatedAt.month} ${this.updatedAt.hour}:${this.updatedAt.minute}";
    if (this.updatedAt.year == now.year && this.updatedAt.month == now.month && this.updatedAt.day != now.day)
      return "Last seen: ${this.updatedAt.day} of ${monthes[this.updatedAt.month - 1]} ${this.updatedAt.hour}:${this.updatedAt.minute}";
    if (this.updatedAt.year == now.year && this.updatedAt.month == now.month && this.updatedAt.day == now.day)
      return "Last seen: today ${this.updatedAt.hour}:${this.updatedAt.minute}";
  }

  Widget getUserAvatar(){
    return  Material(
      child: this.photoUrl != null
          ? CachedNetworkImage(
        placeholder: (context, url) => Container(
          child: CircularProgressIndicator(
            strokeWidth: 1.0,
            valueColor: AlwaysStoppedAnimation<Color>(themeColor),
          ),
          width: 50.0,
          height: 50.0,
          padding: EdgeInsets.all(15.0),
        ),
        imageUrl: this.photoUrl,
        width: 50.0,
        height: 50.0,
        fit: BoxFit.cover,
      )
          : Icon(
        Icons.account_circle,
        size: 50.0,
        color: greyColor,
      ),
      borderRadius: BorderRadius.all(Radius.circular(25.0)),
      clipBehavior: Clip.hardEdge,
    );
  }

}


class CustomUserItem extends StatelessWidget {

  CustomUserItem(User user){
    this.user = user;
    this.photo = user.getUserAvatar();
  }

  User user;
  Widget photo;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 0,
            child: this.photo,
          ),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 10)),
          Expanded(
            flex: 0,
            child: _UserDescription(
                this.user
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 1.0, color: Colors.orange),
          left: BorderSide(width: 1.0, color: Colors.orange),
          right: BorderSide(width: 1.0, color: Colors.orange),
          bottom: BorderSide(width: 1.0, color: Colors.orange)
        ),
        color: Colors.amberAccent,
        borderRadius: BorderRadius.circular(10.0),
        shape: BoxShape.rectangle
      ),
    ), onTap: (){
      print(this.user.uid);
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(responseUser: this.user)));
    },
    );
  }
}

class _UserDescription extends StatelessWidget {
  _UserDescription(User user){
    this.name = user.nickname ?? '';
    this.email = user.email ?? '';
    this.aboutMe = user.aboutMe ?? '';
    this.uid = user.uid;
    this.photoUrl = user.photoUrl;
    this.lastSeen = user.getLastSeen();
  }

  String name;
  String aboutMe;
  String email;
  String uid;
  String photoUrl;
  String lastSeen;

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
          const Padding(padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 20)),
          Text(
            email,
            style: const TextStyle(fontSize: 10.0),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 20)),
          Text(
            aboutMe,
            style: const TextStyle(fontSize: 10.0),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 20)),
          Text(
            lastSeen,
            style: const TextStyle(fontSize: 10.0),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 20)),
        ],
      ),
    );
  }
}



