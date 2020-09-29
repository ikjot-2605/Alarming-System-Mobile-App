import 'package:alarming_system_mobile_app/model/AppUser.dart';
import 'package:alarming_system_mobile_app/pages/draft_message_page.dart';
import 'package:alarming_system_mobile_app/pages/error_page.dart';
import 'package:alarming_system_mobile_app/pages/register_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position currPos;
  String currAdd;
  getCurrLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        currPos = position;
      });

      getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          currPos.latitude, currPos.longitude);

      Placemark place = p[0];

      setState(() {
        currAdd = "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> signOut(bool google) async {
    if (google) {
      await googleSignIn.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Hive.box('users').clear();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => RegisterPage()));
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Hive.box('users').clear();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => RegisterPage()));
    }
    print("User Signed Out");
  }

  @override
  void initState() {
    getUserFromHive();
    getCurrLocation();
    super.initState();
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
                              radius: MediaQuery.of(context).size.height / 20,
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
                  ListTile(
                    onTap: () {
                      signOut(snapshot.data.googleLoggedIn);
                    },
                    leading: Icon(Icons.exit_to_app),
                    title: Text('Logout'),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>DraftMessagePage()));
                    },
                    leading: Icon(Icons.message),
                    title: Text('Modify Emergency Message'),
                  ),
                ],
              ),
            ),
            body: Column(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(Icons.location_on),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Location',
                                  style: Theme.of(context).textTheme.caption,
                                ),
                                if (currPos != null && currAdd != null)
                                  Text(currAdd,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
