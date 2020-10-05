import 'package:alarming_system_mobile_app/model/AppUser.dart';
import 'package:alarming_system_mobile_app/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class DraftMessagePage extends StatefulWidget {
  final AppUser appUser;
  DraftMessagePage(this.appUser, {Key key})
      : super(key: key);
  @override
  _DraftMessagePageState createState() => _DraftMessagePageState();
}

class _DraftMessagePageState extends State<DraftMessagePage> {
  final _messageController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Modify Emergency Message'),
        automaticallyImplyLeading: true,
        backgroundColor: Theme.of(context).brightness != Brightness.dark
            ? Color(0xFF6770D2)
            : Colors.grey[900],
      ),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Your Current Message'),
                ),
              ),
              FutureBuilder<String>(
                future: getMessageFromHive(),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasData) {
                    return Center(
                      child: Text(snapshot.data),
                    );
                  } else if (snapshot.data == null) {
                    return Center(
                      child: Text("You haven't set up a message yet"),
                    );
                  } else
                    return Scaffold(
                      appBar: AppBar(
                        title: Text('Error Screen'),
                      ),
                    );
                  return Container();
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('New Message'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: MediaQuery.of(context).size.height / 3,
                  child: TextFormField(
                    controller: _messageController,
                    textInputAction: TextInputAction.send,
                    keyboardType: TextInputType.text,
                    maxLines: 5,
                    decoration: InputDecoration(
                      fillColor: Colors.black,
                      hintText: 'Emergency Message',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          5,
                        ),
                        borderSide: BorderSide(
                          color: Colors.grey[400],
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          5,
                        ),
                        borderSide: BorderSide(
                          color: Colors.grey[400],
                          width: 2,
                        ),
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    // ignore: missing_return
                  ),
                ),
              ),
              Center(
                child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width / 1.15,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    textColor: Colors.white,
                    child: Text("Save Message"),
                    onPressed: () {
                      if (_messageController.text == "" ||
                          _messageController.text == null) {
                        Flushbar(
                          title: "Error",
                          message:
                              "Please ensure you enter a valid message containing more than zero characters",
                          duration: Duration(seconds: 3),
                        )..show(context);
                      } else {
                        storeDetailsInHive(_messageController.text);
                      }
                    },
                    color: Color(0xFF6770D2),
                  ),
                ),
              ),
            ]),
      ),
    );
  }

  Future<String> getMessageFromHive() async {
    return widget.appUser.emergencyMessage;
  }

  void storeDetailsInHive(String message) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return users.doc(widget.appUser.firebaseId).update({
      'message':message
    }).then((value){
      AppUser toSend = new AppUser(
        name: widget.appUser.name,
        email: widget.appUser.email,
        imageUrl: widget.appUser.imageUrl,
        phoneNumber: widget.appUser.phoneNumber,
        googleLoggedIn: true,
        firebaseId: widget.appUser.firebaseId,
        emergencyContacts: widget.appUser.emergencyContacts,
        emergencyMessage: message,
      );
      Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage(toSend)));
      Flushbar(
        title: "Success",
        message: "Your message was saved successfully",
        duration: Duration(seconds: 3),
      )..show(context);
    });
  }
}
