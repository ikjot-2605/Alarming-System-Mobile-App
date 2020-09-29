import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';

import 'error_page.dart';

class SelectEmergencyContactsPage extends StatefulWidget {
  final List<Contact> contactList;
  const SelectEmergencyContactsPage({
    Key key,
    this.contactList,
  }) : super(key: key);
  @override
  _SelectEmergencyContactsPageState createState() => _SelectEmergencyContactsPageState();
}

class _SelectEmergencyContactsPageState extends State<SelectEmergencyContactsPage> {
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
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).brightness==Brightness.dark?Colors.transparent:Colors.white,
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                  color: Theme.of(context).brightness==Brightness.dark?Colors.white:Colors.black, ),
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
                  searchOp(value,snapshot.data);
                },
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 16,
                    color: Theme.of(context).brightness==Brightness.dark?Colors.white:Colors.black,
                  ),
                  onPressed: () {
                    contacts.value = snapshot.data;
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
                  padding:const EdgeInsets.fromLTRB(16,8,0,12,),
                  child: Text('Choose Contact',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,),),
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
                            return card(contacts.value[index]);
                          },
                        ),
                      );
                    else
                      return Center(child: Text('No contacts found'),);
                  },
                )
              ],
            ),
          );
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

  Widget card(Contact contact) {
    return InkWell(
      onTap: () {
        Navigator.pop(context, contact);
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
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
