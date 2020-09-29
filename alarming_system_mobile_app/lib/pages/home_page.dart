import 'package:alarming_system_mobile_app/model/AppUser.dart';
import 'package:alarming_system_mobile_app/pages/error_page.dart';
import 'package:alarming_system_mobile_app/pages/register_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AppUser user;
  @override
  void initState() {
    getUserFromHive();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUser>(
      future: getUserFromHive(),
      builder: (BuildContext context, AsyncSnapshot<AppUser> snapshot) {
        print(snapshot);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          print(snapshot.data.imageUrl);
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text('Home'),
              automaticallyImplyLeading: true,
              backgroundColor: Theme.of(context).brightness != Brightness.dark
                  ? Color(0xFF6770D2)
                  : Colors.grey[900],
            ),
            drawer: Drawer(
              child: ListView(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 5,
                    color: Theme.of(context).brightness != Brightness.dark
                        ? Color(0xFF6770D2)
                        : Colors.grey[900],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: MediaQuery.of(context).size.height/20,
                              child: ClipOval(
                                child: Image.network(
                                  snapshot.data.imageUrl,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            snapshot.data.name,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 18.0),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            snapshot.data.email,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w200,
                                fontSize: 14.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                  ),
                ],
              ),
            ),
            body: Column(),
          );
        } else if (snapshot.hasError) {
          return ErrorPage();
        } else if (snapshot.data == null) {
          return RegisterPage();
        } else
          return ErrorPage();
      },
    );
  }

  Future<AppUser> getUserFromHive() async {
    var users = await Hive.openBox('users');
    print(users.getAt(0));
    return users.getAt(0);
  }
}
