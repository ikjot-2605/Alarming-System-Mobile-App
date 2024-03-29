import 'package:alarming_system_mobile_app/model/AppUser.dart';
import 'package:alarming_system_mobile_app/model/UserContact.dart';
import 'package:alarming_system_mobile_app/pages/home_page.dart';
import 'package:alarming_system_mobile_app/pages/register_page.dart';
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<String> fetchDetailsAdmin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('user_name');
    return name;
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: fetchDetailsAdmin(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        print(snapshot);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          if (snapshot.data == null) {
            return RegisterPage();
          } else {
            return HomePage();
          }
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