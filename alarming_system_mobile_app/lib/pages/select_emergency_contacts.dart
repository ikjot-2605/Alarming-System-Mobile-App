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
  final String userMessage;
  final Map<String,Map<String,String>> userContacts;
  SelectEmergencyContactsPage(this.contactList, this.appUser,this.userContacts,this.userMessage, {Key key})
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
                List<UserContact> contactList = [];
                for (int i = 0; i < selectedElements.length; i++) {
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
              'Choose UserContact',
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
                    ? Colors.grey[200]
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
    var contacts = await Hive.openBox('contacts');
    for (int i = 0; i < contacts.length; i++) {
      selectedElements.add(contacts.getAt(i));
    }
  }

  void storeDetailsInHive(List<UserContact> contactList) async {
    var contacts = await Hive.openBox('contacts');
    while (contacts.length > 0) {
      contacts.deleteAt(0);
    }
    for (int i = 0; i < contactList.length; i++) {
      contacts.add(contactList[i]);
    }
    createMap(contactList);
  }

  Future<void> sendRecordsToFirestore(
      Map<String, Map<String, String>> maps) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return users.doc(widget.appUser.firebaseId).update({
      'name': widget.appUser.name,
      'email': widget.appUser.email,
      'phone': widget.appUser.phoneNumber,
      'emergency_contacts': maps
    });
  }

  void createMap(List<UserContact> contactsListForMap) {
    Map<String, Map<String,String>> mapContacts = new Map();
    print(mapContacts);
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
    print(widget.appUser.firebaseId);
    sendRecordsToFirestore(mapContacts).then((value) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => HomePage(widget.appUser,widget.userMessage,widget.userContacts)));
      Flushbar(
        title: "Success",
        message: "Your contacts were saved successfully",
        duration: Duration(seconds: 3),
      )..show(context);
      setState(() {});
    });
  }
}
