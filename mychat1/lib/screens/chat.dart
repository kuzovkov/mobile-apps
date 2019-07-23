import 'package:flutter/material.dart';
import 'package:mychat1/modules/auth.dart';
import 'package:mychat1/modules/user.dart';
import 'package:mychat1/modules/message.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mychat1/modules/style.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';


class ChatPage extends StatefulWidget {
  final String _title = "MyChat1";
  final User responseUser;
  ChatPage({Key key, @required this.responseUser}) : super(key: key);

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {

  List<Message> _messages;
  String _error;
  bool isShowSticker = false;
  File imageFile;
  bool isLoading;
  String imageUrl;
  String peerAvatar;

  final TextEditingController textEditingController = new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();

  @override
  Widget build(BuildContext context) {
    AppBar appbar;

    if (Auth.currentUser == null){
      appbar = AppBar(

        title: Text(widget._title),
      );
    }else{
      appbar = AppBar(

        title: Text(widget.responseUser.nickname),
        actions: <Widget>[
          Builder(builder: (BuildContext context) {
            return FlatButton(
              child: Icon(Icons.exit_to_app, color: Colors.white, size: 30),
              textColor: Theme.of(context).buttonColor,
              onPressed: () async {
                Auth.handleSignOut().whenComplete((){
                  print('here users logout');
                  print(Auth.currentUser);
                  Navigator.pop(context);
                });
              },
            );
          }),
        ],
      );
    }

    return Scaffold(
        appBar: appbar,
        body: _buildPage(context));
  }

  @override
  void initState() {
    super.initState();
    peerAvatar = widget.responseUser.photoUrl;
    focusNode.addListener(onFocusChange);
    isLoading = false;
    isShowSticker = false;
    imageUrl = '';
    _getMessegesFromServer();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  _getMessegesFromServer() async{
    _messages = [];
    isLoading = true;
    try{
      final QuerySnapshot resultFrom = await Firestore.instance.collection('messages')
          .where('idFrom', isEqualTo: Auth.currentUser.uid)
          .where('idTo', isEqualTo: widget.responseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documentsFrom = resultFrom.documents;
      final QuerySnapshot resultTo = await Firestore.instance.collection('messages')
          .where('idFrom', isEqualTo: widget.responseUser.uid)
          .where('idTo', isEqualTo: Auth.currentUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documentsTo = resultTo.documents;
      for (var document in documentsFrom) {
        _messages.add(Message(document['content'], document['idFrom'], document['idTo'], document['type'], document['timestamp']));
      }
      for (var document in documentsTo) {
        _messages.add(Message(document['content'], document['idFrom'], document['idTo'], document['type'], document['timestamp']));
      }
      _messages.sort((a, b) => -a.createdAt.compareTo(b.createdAt));

    }on Exception catch (e){
      _error = e.toString();
    }
    setState(() {
        isLoading = false;
    });
  }

  @override
  Widget _buildPage(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
              // List of messages
              buildListMessage2(),

              // Sticker
              (isShowSticker ? buildSticker() : Container()),

              // Input content
              buildInput(),


          // Loading
          buildLoading()
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
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
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(Icons.face),
                onPressed: getSticker,
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

  Widget buildListMessage() {
    return Flexible(
        child: StreamBuilder(
        stream: Firestore.instance
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(20)
            .snapshots(),
        builder: (context, snapshot){
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)));
          } else{
            var documents = snapshot.data.documents;
            return ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: (_messages == null)? 0 : _messages.length,
                itemBuilder: /*1*/ (context, i) {
                  var document = documents[i];
                  Message message = Message(document['content'], document['idFrom'], document['idTo'], document['type'], document['timestamp']);
                  return buildItem(i, message);
                },
                separatorBuilder: (BuildContext context, int index) => const Divider(),
                controller: listScrollController
            );
          }
        })
    );
  }


  Widget buildListMessage2() {
    return ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: (_messages == null)? 0 : _messages.length,
        itemBuilder: /*1*/ (context, i) {
          return buildItem(i, _messages[i]);
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        controller: listScrollController
    );
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

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();
      Firestore.instance.collection('messages')
          .document()
          .setData({
        'content': content,
        'idFrom': Auth.currentUser.uid,
        'idTo': widget.responseUser.uid,
        'timestamp': DateTime.now(),
        'type': type
      });

      listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
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

  Widget buildItem(int index, Message message) {
    if (message.idFrom == Auth.currentUser.uid) {
      // Right (my message)
      return Row(
        children: <Widget>[
          message.type == 0
          // Text
              ? Container(
            child: Text(
              message.content,
              style: TextStyle(color: primaryColor),
            ),
            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
            width: 200.0,
            decoration: BoxDecoration(color: greyColor2, borderRadius: BorderRadius.circular(8.0)),
            margin: EdgeInsets.only(bottom: true ? 20.0 : 10.0, right: 10.0),
          )
              : message.type == 1
          // Image
              ? Container(
            child: Material(
              child: CachedNetworkImage(
                placeholder: (context, url) => Container(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                  ),
                  width: 200.0,
                  height: 200.0,
                  padding: EdgeInsets.all(70.0),
                  decoration: BoxDecoration(
                    color: greyColor2,
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Material(
                  child: Image.asset(
                    'assets/img/img_not_available.jpeg',
                    width: 200.0,
                    height: 200.0,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                ),
                imageUrl: message.content,
                width: 200.0,
                height: 200.0,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              clipBehavior: Clip.hardEdge,
            ),
            margin: EdgeInsets.only(bottom: true ? 20.0 : 10.0, right: 10.0),
          )
          // Sticker
              : Container(
            child: new Image.asset(
              'assets/img/${message.content}.gif',
              width: 100.0,
              height: 100.0,
              fit: BoxFit.cover,
            ),
            margin: EdgeInsets.only(bottom: true ? 20.0 : 10.0, right: 10.0),
          ),
          Container(child: Text(Message.datetime2string(message.createdAt), style:dateStyle),)
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isLastMessageLeft(index)
                    ? Material(
                  child: CachedNetworkImage(
                    placeholder: (context, url) => Container(
                      child: CircularProgressIndicator(
                        strokeWidth: 1.0,
                        valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                      ),
                      width: 35.0,
                      height: 35.0,
                      padding: EdgeInsets.all(10.0),
                    ),
                    imageUrl: peerAvatar,
                    width: 35.0,
                    height: 35.0,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(18.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                )
                    : Container(width: 35.0),
                message.type == 0
                    ? Container(
                  child: Text(
                    message.content,
                    style: TextStyle(color: Colors.white),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(left: 10.0),
                )
                    : message.type == 1
                    ? Container(
                  child: Material(
                    child: CachedNetworkImage(
                      placeholder: (context, url) => Container(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                        ),
                        width: 200.0,
                        height: 200.0,
                        padding: EdgeInsets.all(70.0),
                        decoration: BoxDecoration(
                          color: greyColor2,
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Material(
                        child: Image.asset(
                          'assets/img/img_not_available.jpeg',
                          width: 200.0,
                          height: 200.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      ),
                      imageUrl: message.content,
                      width: 200.0,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    clipBehavior: Clip.hardEdge,
                  ),
                  margin: EdgeInsets.only(left: 10.0),
                )
                    : Container(
                  child: new Image.asset(
                    'assets/img/${message.content}.gif',
                    width: 100.0,
                    height: 100.0,
                    fit: BoxFit.cover,
                  ),
                  margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                ),
                Container(child: Text(Message.datetime2string(message.createdAt), style:dateStyle),)
              ],
            ),

            // Time
            isLastMessageLeft(index)
                ? Container(
              child: Text(
                DateFormat('dd MMM kk:mm')
                    .format(message.createdAt),
                style: TextStyle(color: greyColor, fontSize: 12.0, fontStyle: FontStyle.italic),
              ),
              margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
            )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && _messages != null && _messages[index - 1].idFrom == Auth.currentUser.uid) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && _messages != null && _messages[index - 1].idFrom != Auth.currentUser.uid) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

}