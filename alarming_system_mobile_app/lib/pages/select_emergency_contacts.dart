import 'package:alarming_system_mobile_app/model/AppUser.dart';
import 'package:alarming_system_mobile_app/model/UserContact.dart';
import 'package:alarming_system_mobile_app/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:hive/hive.dart';

import 'error_page.dart';

class SelectEmergencyContactsPage extends StatefulWidget {
  final List<UserContact> contactList;
  final AppUser appUser;
  SelectEmergencyContactsPage(this.contactList, this.appUser, {Key key})
      : super(key: key);
  @override
  _SelectEmergencyContactsPageState createState() =>
      _SelectEmergencyContactsPageState();
}

class _SelectEmergencyContactsPageState
    extends State<SelectEmergencyContactsPage> {
  void initializeFirebase()async{
    await Firebase.initializeApp();
  }
  Set<UserContact> selectedElements = new Set();
  ValueNotifier<bool> isSearching = ValueNotifier<bool>(false);
  ValueNotifier<List> contacts = ValueNotifier<List>([]);
  TextEditingController searchTextController = TextEditingController();
  List<UserContact> searchResults;
  @override
  void initState() {
    for(int i=0;i<widget.contactList.length;i++){
      if(widget.contactList[i].displayName=="Bro!"){
        print(widget.contactList[i].displayName);
        print(widget.contactList[i].emails);
        print(widget.contactList[i].phones);
      }
    }
    getContactsFromHive();
    initializeFirebase();
    contacts.value = widget.contactList;
  }

  @override
  void dispose() {
    super.dispose();
    searchTextController.dispose();
    isSearching.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: (selectedElements.length != 0)
          ? FloatingActionButton(
              onPressed: () {
                print(selectedElements);
                List<UserContact> contactList = [];
                for (int i = 0; i < selectedElements.length; i++) {
                  print(selectedElements.elementAt(i));
                  contactList.add(selectedElements.elementAt(i));
                }
                storeDetailsInHive(contactList);
              },
              child: Icon(Icons.check),
            )
          : Container(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.transparent
            : Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextField(
          autofocus: true,
          controller: searchTextController,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Search",
          ),
          onChanged: (value) {
            searchOp(value, widget.contactList);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.close,
              size: 16,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            onPressed: () {
              contacts.value = widget.contactList;
              searchTextController.text = "";
              isSearching.value = false;
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              0,
              12,
            ),
            child: Text(
              'Choose Emergency Contacts',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: contacts,
            builder: (BuildContext context, value, Widget child) {
              if (contacts.value.length > 0)
                return Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: contacts.value.length,
                    itemBuilder: (context, index) {
                      return card(contacts.value[index], index);
                    },
                  ),
                );
              else
                return Center(
                  child: Text('No contacts found'),
                );
            },
          )
        ],
      ),
    );
  }

  Widget card(UserContact contact, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          print('THIS CONTACT EXISTS IN THE SET');
          print(selectedElements.contains(contact));
          if (!selectedElements.contains(contact))
            selectedElements.add(contact);
          else {
            selectedElements.remove(contact);
          }
        });
      },
      child: contact.displayName != null
          ? Container(
              height: 52,
              decoration: BoxDecoration(
                color: (selectedElements.contains(contact))
                    ? Theme.of(context).brightness==Brightness.dark?Colors.grey[900]:Colors.grey[200]
                    : Colors.transparent,
                border: Border.symmetric(
                  vertical: BorderSide(
                    width: 1 / 2,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    16,
                    0,
                    16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          contact.displayName,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      (selectedElements.contains(contact))
                          ? Icon(Icons.check)
                          : Container(),
                    ],
                  )),
            )
          : Container(),
    );
  }

  void searchOp(String searchQuery, List<UserContact> contactsList) {
    List<UserContact> list = [];
    for (int i = 0; i < contactsList.length; i++) {
      if (contactsList[i].displayName != null &&
          contactsList[i].displayName != "" &&
          contactsList[i]
              .displayName
              .toLowerCase()
              .contains(searchQuery.toLowerCase())) {
        list.add(contactsList[i]);
      }
    }
    contacts.value = list;
  }

  void getContactsFromHive() async {
    List<UserContact> contacts = widget.appUser.emergencyContacts;
    for (int i = 0; i < contacts.length; i++) {
      if(contacts[i].displayName=="Bro!"){
        print('HILO');
        print(contacts[i].displayName);
        print(contacts[i].phones);
        print(contacts[i].emails);
      }
      selectedElements.add(contacts[i]);
    }
  }

  void storeDetailsInHive(List<UserContact> contactList) async {
    print('THIS IS THE LENGTH NOW');
    print(contactList.length);
    createMap(contactList);
  }

  Future<void> sendRecordsToFirestore(
      Map<String, Map<String, String>> maps) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return users.doc(widget.appUser.firebaseId).update({
      'emergency_contacts': maps
    });
  }

  void createMap(List<UserContact> contactsListForMap) async{
    var usersBox = await Hive.openBox('users');
    for(int i=0;i<usersBox.length;i++){
      if(usersBox.getAt(i).email==widget.appUser.email){
        usersBox.deleteAt(i);
        break;
      }
    }
    AppUser sendingAppUser = new AppUser(name: widget.appUser.name,email: widget.appUser.email,phoneNumber: widget.appUser.phoneNumber,firebaseId: widget.appUser.firebaseId,imageUrl: widget.appUser.imageUrl,emergencyContacts: contactsListForMap,emergencyMessage: widget.appUser.emergencyMessage,googleLoggedIn: true);
    usersBox.add(sendingAppUser);
    print('THIS IS THE LENGTH NOW');
    print(contactsListForMap.length);
    Map<String, Map<String,String>> mapContacts = new Map();
    for (int i = 0; i < contactsListForMap.length; i++) {
      mapContacts["$i"] = {
        "name": contactsListForMap[i].displayName,
        "phone": contactsListForMap[i].phones.length > 0
            ? contactsListForMap[i].phones[0]
            : "Not Specified",
        "email": contactsListForMap[i].emails.length > 0
            ? contactsListForMap[i].emails[0]
            : "Not Specified"
      };
    }
    print('THIS IS THE LENGTH NOW');
    print(mapContacts.length);
    sendRecordsToFirestore(mapContacts).then((value) {
      AppUser toSend = new AppUser(
          name: widget.appUser.name,
          email: widget.appUser.email,
          imageUrl: widget.appUser.imageUrl,
          phoneNumber: widget.appUser.phoneNumber,
          googleLoggedIn: true,
          firebaseId: widget.appUser.firebaseId,
          emergencyContacts: contactsListForMap,
          emergencyMessage: widget.appUser.emergencyMessage,
      );
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => HomePage(toSend)));
      Flushbar(
        title: "Success",
        message: "Your contacts were saved successfully",
        duration: Duration(seconds: 3),
      )..show(context);
      setState(() {});
    });
  }
}
