import 'package:alarming_system_mobile_app/model/AppUser.dart';
import 'package:alarming_system_mobile_app/pages/draft_message_page.dart';
import 'package:alarming_system_mobile_app/pages/error_page.dart';
import 'package:alarming_system_mobile_app/pages/register_page.dart';
import 'package:alarming_system_mobile_app/pages/select_emergency_contacts.dart';
import 'package:alarming_system_mobile_app/pages/waiting_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final AppUser appUser;
  HomePage(this.appUser, {Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position currPos;
  String currAdd;
  int contactCount = 0;
  String currentMessage;
  //String preview;
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
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => RegisterPage()));
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => RegisterPage()));
    }
    print("User Signed Out");
  }

  @override
  void initState() {
    getUserFromHive();
    getCurrLocation();
    getDetails();
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
                    onTap: () async{
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.remove('curruser');
                      signOut(snapshot.data.googleLoggedIn);
                    },
                    leading: Icon(Icons.exit_to_app),
                    title: Text('Logout'),
                  ),
                  ListTile(
                    onTap: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DraftMessagePage(widget.appUser)));
                    },
                    leading: Icon(Icons.message),
                    title: Text('Modify Emergency Message'),
                  ),
                  ListTile(
                    onTap: () async {
                      if (!((await Permission.contacts.isGranted) == true))
                        await Permission.contacts.request();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WaitingPage(appUser: widget.appUser,)));
                    },
                    leading: Icon(Icons.contacts),
                    title: Text('Modify Emergency Contacts'),
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width/1.1,
                    height:50.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      color: Colors.grey[300],
                    ),
                    child: (widget.appUser.emergencyContacts.length == 0)
                        ? Center(child: Text("You haven't set-up your emergency contacts yet."))
                        : Center(
                          child: Text(
                              "You have ${widget.appUser.emergencyContacts.length} emergency contacts set up."),
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width/1.1,
                    height:50.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      color: Colors.grey[300],
                    ),
                    child: (widget.appUser.emergencyMessage == null||widget.appUser.emergencyMessage == "")
                        ? Center(child: Text("You haven't set-up your emergency message yet."))
                        : Center(
                      child: Text(
                          "Your emergency message : ${widget.appUser.emergencyMessage}"),
                    ),
                  ),
                ),
//                Padding(
//                  padding: const EdgeInsets.all(8.0),
//                  child: Container(
//                    width: MediaQuery.of(context).size.width/1.1,
//                    height:50.0,
//                    decoration: BoxDecoration(
//                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                      color: Colors.grey[300],
//                    ),
//                    child: Center(
//                      child: Text(
//                        'Your emergency message preview : $preview'
//                      ),
//                    ),
//                    ),
//                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      color: Color(0xFF6770D2),
                    ),
                    child: FlatButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.sentiment_neutral,color: Colors.white,),
                          ),
                          Text('Send Message',style: TextStyle(color:Colors.white),),
                        ],
                      ),
                      onPressed: () {
                        _sendSms();
                      },
                    ),
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
    return widget.appUser;
  }

  void _sendSms() async {
    List<String> recepients = [];
    var contacts = await Hive.openBox('contacts');
    for (int i = 0; i < contacts.length; i++) {
      recepients.add(contacts.getAt(i).phones[0]);
      print(contacts.getAt(i).phones[0]);
    }
    String emergencyMessage = "Help Me";
    var message = await Hive.openBox('message');
    if (message.length != 0) {
      emergencyMessage = message.getAt(0);
    }
    emergencyMessage = emergencyMessage +
        "\nMy Location is latitude: " +
        currPos.latitude.toString() +
        " longitude: " +
        currPos.longitude.toString();
    for (int i = 0; i < recepients.length; i++) {}
    String _result =
        await sendSMS(message: emergencyMessage, recipients: recepients)
            .catchError((onError) {
      print(onError);
    });
    print(_result);
  }

  void getDetails() async {
    var contacts = await Hive.openBox('contacts');
    contactCount = contacts.length;
    currentMessage = null;
    var message = await Hive.openBox('message');
    if (message.length != 0) currentMessage = message.getAt(0);
//    if (currentMessage != null)
//      preview = currentMessage +
//          "\nMy Location is latitude: " +
//          currPos.latitude.toString() +
//          " longitude: " +
//          currPos.longitude.toString();
//    else
//      preview = "Help Me" +
//          "\nMy Location is latitude: " +
//          currPos.latitude.toString() +
//          " longitude: " +
//          currPos.longitude.toString();
  }
}
