import 'package:alarming_system_mobile_app/model/AppUser.dart';
import 'package:alarming_system_mobile_app/model/UserContact.dart';
import 'package:alarming_system_mobile_app/pages/select_emergency_contacts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';

import 'error_page.dart';

class WaitingPage extends StatefulWidget {
  final List<Contact> contactList;
  final AppUser appUser;
  const WaitingPage({
    Key key,
    this.contactList,
    this.appUser,
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
          List<UserContact> contactList=[];
          for(int i=0;i<snapshot.data.length;i++){
            UserContact userContact = new UserContact();
            userContact.displayName=snapshot.data[i].displayName;
            List<String> phones=[];
            for(int j=0;j<snapshot.data[i].phones.length;j++){
              phones.add(snapshot.data[i].phones.elementAt(j).value);
            }
            userContact.phones=phones;
            List<String> emails=[];
            for(int j=0;j<snapshot.data[i].emails.length;j++){
              phones.add(snapshot.data[i].emails.elementAt(j).value);
            }
            userContact.emails=emails;
            contactList.add(userContact);
          }
          return SelectEmergencyContactsPage(contactList,widget.appUser);
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
