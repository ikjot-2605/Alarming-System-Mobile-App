import 'package:alarming_system_mobile_app/pages/select_emergency_contacts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';

import 'error_page.dart';

class WaitingPage extends StatefulWidget {
  final List<Contact> contactList;
  const WaitingPage({
    Key key,
    this.contactList,
  }) : super(key: key);
  @override
  _WaitingPageState createState() => _WaitingPageState();
}

class _WaitingPageState extends State<WaitingPage> {
  Set selectedElements = new  Set();
  ValueNotifier<bool> isSearching = ValueNotifier<bool>(false);
  ValueNotifier<List> contacts = ValueNotifier<List>([]);
  TextEditingController searchTextController = TextEditingController();
  List<Contact> searchResults;


  @override
  void dispose() {
    super.dispose();
    searchTextController.dispose();
    isSearching.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Contact>>(
      future:getContacts(),
      builder: (BuildContext context, AsyncSnapshot<List<Contact>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          contacts.value= snapshot.data;
          return SelectEmergencyContactsPage(snapshot.data);
        } else if (snapshot.hasError) {
          return ErrorPage();
        } else if (snapshot.data == null) {
          return Scaffold(
            body: Center(
              child: Text('You Have No Contacts:('),
            ),
          );
        }
        else return Scaffold(
            appBar: AppBar(title: Text('Error Screen'),),
          );
      },
    );

  }

  Widget card(Contact contact,int index) {
    return InkWell(
      onTap: (){
        setState(() {
          selectedElements.add(index);
        });
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: (selectedElements.contains(index))?Colors.grey[200]:Colors.transparent,
          border: Border.symmetric(
            vertical: BorderSide(
              width: 1 / 2,
              color: Colors.grey[400],
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16, 16, 0, 16,),
          child: contact.displayName!=null?Text(
            contact.displayName,
            style: TextStyle(fontSize: 14,),
          ):Text('Name not Specified',
            style: TextStyle(fontSize: 14,),),
        ),
      ),
    );
  }

  void searchOp(String searchQuery,List<Contact> contactsList) {
    List<Contact> list = [];
    for (int i = 0; i < contactsList.length; i++) {
      if (contactsList[i].displayName!=null&&contactsList[i].displayName!=""&&contactsList[i].displayName
          .toLowerCase()
          .contains(searchQuery.toLowerCase())) {
        list.add(contactsList[i]);
      }
    }
    contacts.value = list;
  }

  Future<List<Contact>> getContacts() async{
    Iterable<Contact> contacts = await ContactsService.getContacts();
    List<Contact> contactsList = contacts.toList();
    return contactsList;
  }
}
