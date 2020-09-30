import 'dart:core';
import 'package:hive/hive.dart';
part 'UserContact.g.dart';
@HiveType(typeId: 2)
class UserContact {
  @HiveField(0)
  String displayName;
  @HiveField(1)
  List<String> emails;
  @HiveField(2)
  List<String> phones;
  UserContact({this.displayName,this.emails,this.phones});
}
