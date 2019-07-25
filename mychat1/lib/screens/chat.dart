// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mychat1/modules/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mychat1/modules/auth.dart';
import 'package:mychat1/modules/style.dart';
import 'package:mychat1/modules/message.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mychat1/screens/photo.dart';
import 'package:mychat1/screens/view.dart';

class MessageList extends StatelessWidget {
  final Firestore firestore;
  final User responseUser;
  Widget currUserAvatar;
  Widget respUserAvatar;
  String groupChatId;
  final ScrollController listScrollController = new ScrollController();

  MessageList({this.firestore, this.responseUser}){
    currUserAvatar = Auth.currentUser.getUserAvatar();
    respUserAvatar = responseUser.getUserAvatar();

  }

  @override
  Widget build(BuildContext context) {
    return
      Flexible(
        child:
      StreamBuilder<QuerySnapshot>(
      stream: _buildStream(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return Center(
            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)));
        final int messageCount = snapshot.data.documents.length;
        return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: messageCount,
          itemBuilder: (_, int index) {
            final DocumentSnapshot document = snapshot.data.documents[index];
            try{
              listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
            }catch(e){print(e);};

            return _buildItem(document, context);
          },
            separatorBuilder: (BuildContext context, int index) => const Divider(),
          controller: listScrollController,
          reverse: true,
        );
      },
    )
      );
  }

   _buildStream(){
     String groupChatId;
     if (Auth.currentUser.uid.hashCode <= responseUser.uid.hashCode) {
       groupChatId = '${Auth.currentUser.uid.hashCode}-${responseUser.uid.hashCode}';
     } else {
       groupChatId = '${responseUser.uid.hashCode}-${Auth.currentUser.uid.hashCode}';
     }
    CollectionReference mesRef = firestore.collection('messages');
     var res = mesRef.where('conversation', isEqualTo: groupChatId).orderBy('timestamp', descending: true).snapshots();
     return res;
  }

  Widget _buildNetworkImage(String url, {double width=100.0, double height=100.0, double border_radius=8.0}){
    if (url == null)
      return Image.asset(
        'assets/img/img_not_available.jpeg',
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    return CachedNetworkImage(
      placeholder: (context, url) => Container(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
        width: width,
        height: height,
        padding: EdgeInsets.all(70.0),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.all(
            Radius.circular(border_radius),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Material(
        child: Image.asset(
          'assets/img/img_not_available.jpeg',
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(border_radius),
        ),
        clipBehavior: Clip.hardEdge,
      ),
      imageUrl: url,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }

  _buildMessageAvatar(String idFrom){
    return (idFrom == Auth.currentUser.uid)? currUserAvatar : respUserAvatar;
  }


  Widget _buildItem(document, context){
    var msg;
    if (document['type'] == 0)
      msg = Container( child: Text(document['content'] ?? '<No message retrieved>'), width: 150);
    else if (document['type'] == 1)
      msg = _buildNetworkImage(document['content']);
    else if (document['type'] == 2)
      msg = Image.asset(
        'assets/img/${document['content']}.gif',
        width: 50.0,
        height: 50.0,
        fit: BoxFit.cover,
      );
    msg = Container(
      child: msg,
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(width: 1.0, color: Colors.orange),
              left: BorderSide(width: 1.0, color: Colors.orange),
              right: BorderSide(width: 1.0, color: Colors.orange),
              bottom: BorderSide(width: 1.0, color: Colors.orange)
          ),
          color: document['idFrom'] == Auth.currentUser.uid ? Colors.amberAccent : Colors.green,
          borderRadius: BorderRadius.circular(5.0),
          shape: BoxShape.rectangle,
      ),
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
    );
    if (document['type'] == 1){
      msg = GestureDetector(
        child: msg,
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => ViewScreen(imageUrl: document['content'])));
        },
      );
    }
    double leftmargin = document['idFrom'] == Auth.currentUser.uid ? 100.0 : 0;
    return Container(
      child: Row(
        children: <Widget>[
          document['idFrom'] == Auth.currentUser.uid ? Container() : _buildMessageAvatar(document['idFrom']),
          Container(padding: EdgeInsets.all(10.0)),
          Column(
            children: <Widget>[
              msg,
              Text(Message.datetime2string(document['timestamp'].toDate()), style: dateStyle),
            ],
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
      margin: EdgeInsets.fromLTRB(leftmargin, 0, 0, 10),
    );

  }

}

class ChatPage extends StatefulWidget {
  ChatPage({Key key, @required this.responseUser}) : super(key: key);
  final User responseUser;
  @override
  ChatPageState createState() => ChatPageState();
}


class ChatPageState extends State<ChatPage> {

  final Firestore firestore = Firestore.instance;
  CollectionReference get messages => firestore.collection('messages');
  final TextEditingController textEditingController = new TextEditingController();
  final FocusNode focusNode = new FocusNode();
  bool isShowSticker = false;
  File imageFile;
  bool isLoading=false;
  String imageUrl;

  @override
  initState(){
    super.initState();
    Firestore.instance.collection('users').document(Auth.currentUser.uid).updateData({'chattingWith': widget.responseUser.uid});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
      appBar: AppBar(
        title: Text('${widget.responseUser.nickname}'),
      ),
      body: Container(child:
          Stack(
            children: <Widget>[
              Column(
              children: <Widget>[
                  MessageList(firestore: firestore, responseUser: widget.responseUser),
                  // Sticker
                  (isShowSticker ? buildSticker() : Container()),
                  // Input content
                  buildInput()
            ],
          ),
              buildLoading()

            ],
          )
        )

    ),
      onWillPop: onBackPress,
    );
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      Firestore.instance.collection('users').document(Auth.currentUser.uid).updateData({'chattingWith': null});
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
        child: Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
        ),
        color: Colors.white.withOpacity(0.8),
      )
          : Container(),
    );
  }


  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 0.0),
              child: new IconButton(
                icon: new Icon(Icons.image),
                onPressed: getImage,
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 0.0),
              child: new IconButton(
                icon: new Icon(Icons.face),
                onPressed: getSticker,
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),

          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 0.0),
              child: new IconButton(
                icon: new Icon(Icons.camera_alt),
                onPressed: getPhoto,
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(color: primaryColor, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: greyColor),
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border: new Border(top: new BorderSide(color: greyColor2, width: 0.5)), color: Colors.white),
    );
  }

  void onSendMessage (String content, int type) async {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      String groupChatId;
      if (Auth.currentUser.uid.hashCode <= widget.responseUser.uid.hashCode) {
        groupChatId = '${Auth.currentUser.uid.hashCode}-${widget.responseUser.uid.hashCode}';
      } else {
        groupChatId = '${widget.responseUser.uid.hashCode}-${Auth.currentUser.uid.hashCode}';
      }
      textEditingController.clear();
      Firestore.instance.collection('messages')
          .document()
          .setData({
        'content': content,
        'idFrom': Auth.currentUser.uid,
        'idTo': widget.responseUser.uid,
        'timestamp': DateTime.now(),
        'type': type,
        'conversation': groupChatId
      });

    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile();
    }
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  void getPhoto() async {
    List<File> files = await Navigator.push(context, MaterialPageRoute(builder: (context) => TakePictureScreen(responseUser: widget.responseUser)));
    for (File file in files){
      imageFile = file;
      setState(() {
        isLoading = true;
      });
      uploadFile();
    }
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }

  Widget buildSticker() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi1', 2),
                child: new Image.asset(
                  'assets/img/mimi1.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi2', 2),
                child: new Image.asset(
                  'assets/img/mimi2.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi3', 2),
                child: new Image.asset(
                  'assets/img/mimi3.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi4', 2),
                child: new Image.asset(
                  'assets/img/mimi4.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi5', 2),
                child: new Image.asset(
                  'assets/img/mimi5.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi6', 2),
                child: new Image.asset(
                  'assets/img/mimi6.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi7', 2),
                child: new Image.asset(
                  'assets/img/mimi7.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi8', 2),
                child: new Image.asset(
                  'assets/img/mimi8.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi9', 2),
                child: new Image.asset(
                  'assets/img/mimi9.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: new BoxDecoration(
          border: new Border(top: new BorderSide(color: greyColor2, width: 0.5)), color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }


}
