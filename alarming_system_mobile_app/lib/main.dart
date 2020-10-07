import 'package:alarming_system_mobile_app/model/AppUser.dart';
import 'package:alarming_system_mobile_app/model/UserContact.dart';
import 'package:alarming_system_mobile_app/pages/home_page.dart';
import 'package:alarming_system_mobile_app/pages/register_page.dart';
import 'package:alarming_system_mobile_app/pages/waiting_for_home_page.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
  Hive.registerAdapter(AppUserAdapter());
  Hive.registerAdapter(UserContactAdapter());
  await Hive.initFlutter();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
        defaultBrightness: Brightness.dark,
        data: (brightness) => new ThemeData(
          primarySwatch: Colors.indigo,
          brightness: brightness,
        ),
        themedWidgetBuilder: (context, theme) {
          return new MaterialApp(
            title: 'Alarming App',
            theme: theme,
            home:  MyHomePage(),
          );
        }
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<AppUser> fetchDetailsAdmin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String emailII = prefs.getString('curruser');
    var users = await Hive.openBox('users');
    print(users.length);
    for(int i=0;i<users.length;i++){
      print(users.getAt(i).email);
      print(users.getAt(i).emergencyContacts);
      print(users.getAt(i).emergencyMessage);
      if(emailII==users.getAt(i).email){
        print(users.getAt(i).email);
        return users.getAt(i);
      }
    }

  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUser>(
      future: fetchDetailsAdmin(),
      builder: (BuildContext context, AsyncSnapshot<AppUser> snapshot) {
        print(snapshot);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          return HomePage(snapshot.data);
        } else if (snapshot.hasError) {
          return RegisterPage();
        } else if (snapshot.data == null) {
          return RegisterPage();
        }
        else return Scaffold(
            appBar: AppBar(title: Text('Error Screen'),),
          );
      },
    );
  }
}