import 'package:flutter/material.dart';

class Message extends Object{
  String content;
  String idFrom;
  String idTo;
  int type;
  DateTime createdAt;

  Message(@required content, @required idFrom,  @required idTo, type, createdAt){
    this.content = content;
    this.idFrom = idFrom;
    this.idTo = idTo;
    this.type = type ?? 0;
    if (createdAt == null)
      this.createdAt = DateTime.now();
    else if (createdAt is DateTime)
      this.createdAt = createdAt;
    else
     this.createdAt = createdAt.toDate();
  }

  static String datetime2string(DateTime datetime){
    if (datetime == null)
      return "Not defined";
    else if (datetime is String)
      return datetime.toString();
    return "${datetime.year}/${datetime.month}/${datetime.day}\n${datetime.hour}:${datetime.minute}";
  }

}






