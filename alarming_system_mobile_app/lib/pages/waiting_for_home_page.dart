import 'package:alarming_system_mobile_app/model/AppUser.dart';
import 'package:alarming_system_mobile_app/model/UserContact.dart';
import 'package:alarming_system_mobile_app/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class WaitingForHomePage extends StatefulWidget {
  final AppUser appUser;

  WaitingForHomePage(this.appUser, {Key key}) : super(key: key);
  @override
  _WaitingForHomePageState createState() => _WaitingForHomePageState();
}

class _WaitingForHomePageState extends State<WaitingForHomePage> {
  void fetchMessageAndContactsFromFirestore() async {
    await Firebase.initializeApp();
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    users.doc(widget.appUser.firebaseId).get().then((value) {
      List<UserContact> emergencyContactsFromFirebase=[];
      for(int i=0;i<value["emergency_contacts"].length;i++){
        Map<String,dynamic> temp = value["emergency_contacts"]["$i"];
        emergencyContactsFromFirebase.add(UserContact(displayName:temp["name"],emails: [temp["email"]],phones:[temp["phone"]] ));
      }
      AppUser toSend = new AppUser(
        name: widget.appUser.name,
        email: widget.appUser.email,
        imageUrl: widget.appUser.imageUrl,
        phoneNumber: widget.appUser.phoneNumber,
        googleLoggedIn: true,
        firebaseId: widget.appUser.firebaseId,
        emergencyContacts: emergencyContactsFromFirebase,
        emergencyMessage: value["message"]
      );
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(toSend)));
    });
  }

  @override
  void initState() {
    fetchMessageAndContactsFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: AppBar(
//        title: Text('Please Wait'),
//        backgroundColor: Color(0xFF6770D2),
//        automaticallyImplyLeading: false,
//        centerTitle: true,
//        bottom: PreferredSize(
//          child: LinearProgressIndicator(
//            backgroundColor: Color(0xFF6770D2),
//          ),
//        ),
//      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Text(
                  'Kindly wait while we fetch your latest data from the cloud.',style: TextStyle(fontWeight: FontWeight.w600),)),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}
