import 'package:flutter/material.dart';
import 'package:survey/screens/survey.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:survey/models/user.dart';

class ResultScreen extends StatelessWidget {
  static const String routeName = "/result";
  static const String API_URL = "http://kuzovkov12.ru/api/api.php";

  void _saveDataOnServer(context) async {
    List<String> data = [SurveyFormWidget.name, SurveyFormWidget.lastName, SurveyFormWidget.email, sexName[SurveyFormWidget.sex.index], SurveyFormWidget.birthdayText, (DateTime.now()).toString()];
    String dataString = data.join(';');
    var file = await http.MultipartFile.fromPath(
      'photo',
      SurveyFormWidget.imagePath,
      contentType: new MediaType('image', 'png'),
    );

    var request = new http.MultipartRequest("POST", Uri.parse(API_URL));
    request.fields['optype'] = 'save';
    request.fields['data'] = dataString;
    request.files.add(file);
    request.send().then((response) {
      response.stream.bytesToString().then((body){
        print(body);
        if (response.statusCode == 200 && body == "Command execute success"){
          print("Uploaded!");
          Fluttertoast.showToast(msg: "Data saved");
        }else{
          Fluttertoast.showToast(msg: "Error saving data");
        }
      });
    });
  }

  void _deleteDataOnServer(context) async {
    List<String> data = [SurveyFormWidget.name, SurveyFormWidget.lastName, SurveyFormWidget.email, sexName[SurveyFormWidget.sex.index], SurveyFormWidget.birthdayText, (DateTime.now()).toString()];
    String dataString = data.join(';');
    var request = new http.MultipartRequest("POST", Uri.parse(API_URL));
    request.fields['optype'] = 'delete';
    request.fields['data'] = dataString;
    request.send().then((response) {
      response.stream.bytesToString().then((body){
        print(body);
        if (response.statusCode == 200 && body == "Command execute success"){
          print("Deleted!");
          Fluttertoast.showToast(msg: "Data deleted");
        }else{
          Fluttertoast.showToast(msg: "Error deleting data");
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    if (SurveyFormWidget.name.length == 0 || SurveyFormWidget.lastName.length == 0 || SurveyFormWidget.email.length == 0)
      return SurveyScreen();

    Image image = Image.file(File(SurveyFormWidget.imagePath));
    User user = User(SurveyFormWidget.name, SurveyFormWidget.lastName, SurveyFormWidget.email, SurveyFormWidget.sex, SurveyFormWidget.birthday, DateTime.now(), image);


    RaisedButton saveButton = RaisedButton(
        child: new Text("Save To Server"),
        onPressed: () {
            _saveDataOnServer(context);
        });

    RaisedButton deleteButton = RaisedButton(
        child: new Text("Delete on Server"),
        onPressed: () {
          _deleteDataOnServer(context);
        });


    Container container = new Container(
        padding: const EdgeInsets.all(16.0),
        child: new Column(
            children: [CustomUserItem(user), saveButton, deleteButton])

    );

    ListView listview = ListView(
      padding: const EdgeInsets.all(16.0),
      children: <Widget>[container],
    );

    return new Scaffold(
        appBar: AppBar(title: Text("Result"), backgroundColor: Color.fromRGBO(100, 100, 100, 0.5)),
        body: listview
    );
  }
}