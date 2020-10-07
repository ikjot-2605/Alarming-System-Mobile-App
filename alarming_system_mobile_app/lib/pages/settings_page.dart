import 'package:alarming_system_mobile_app/model/AppUser.dart';
import 'package:alarming_system_mobile_app/pages/draft_message_page.dart';
import 'package:alarming_system_mobile_app/pages/register_page.dart';
import 'package:alarming_system_mobile_app/pages/waiting_page.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final AppUser appUser;
  SettingsPage(this.appUser, {Key key}) : super(key: key);
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
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
                          widget.appUser.imageUrl,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    widget.appUser.name,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 18.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.appUser.email,
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
            onTap: () async {
              Navigator.pop(context);
            },
            leading: Icon(Icons.arrow_back),
            title: Text('Head back to the main screen'),
          ),
          ListTile(
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('curruser');
              signOut(widget.appUser.googleLoggedIn);
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
                      builder: (context) => WaitingPage(
                            appUser: widget.appUser,
                          )));
            },
            leading: Icon(Icons.contacts),
            title: Text('Modify Emergency Contacts'),
          ),
          ListTile(
            onTap: () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DraftMessagePage(widget.appUser)));
            },
            leading: Icon(Icons.wb_sunny),
            trailing: CupertinoSwitch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (value) {
//                  DynamicTheme.of(context).setBrightness(
//                      Theme.of(context).brightness == Brightness.dark
//                          ? Brightness.light
//                          : Brightness.dark);
                }),
            title: Text('Dark theme'),
            subtitle: Text('Currently not in production'),
          ),
        ],
      ),
    );
  }
}
