import 'package:hive/hive.dart';
part 'AppUser.g.dart';
@HiveType(typeId: 1)
class AppUser {
  @HiveField(0)
  String name;
  @HiveField(1)
  String email;
  @HiveField(2)
  String imageUrl;
  @HiveField(3)
  String phoneNumber;
  @HiveField(5)
  bool googleLoggedIn;
  AppUser({this.name,this.email,this.imageUrl,this.phoneNumber,this.googleLoggedIn});
}