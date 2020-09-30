import 'dart:core';
import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
part 'UserContact.g.dart';
@HiveType(typeId: 2)
class UserContact extends Equatable{
  @HiveField(0)
  String displayName;
  @HiveField(1)
  List<String> emails;
  @HiveField(2)
  List<String> phones;
  UserContact({this.displayName,this.emails,this.phones});
  @override
  List<Object> get props => [displayName,emails,phones];
}
