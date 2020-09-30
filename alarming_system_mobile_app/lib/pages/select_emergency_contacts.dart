import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';

import 'error_page.dart';

class SelectEmergencyContactsPage extends StatefulWidget {
  final List<Contact> contactList;

  SelectEmergencyContactsPage(this.contactList, {Key key}) : super(key: key);
  @override
  _SelectEmergencyContactsPageState createState() =>
      _SelectEmergencyContactsPageState();
}

class _SelectEmergencyContactsPageState
    extends State<SelectEmergencyContactsPage> {
  Set selectedElements = new Set();
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
    return Scaffold(
      floatingActionButton: (selectedElements.length != 0)
          ? FloatingActionButton(onPressed: () {},child: Icon(Icons.check),)
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
              'Choose Contact',
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

  Widget card(Contact contact, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          if (!selectedElements.contains(index))
            selectedElements.add(index);
          else {
            selectedElements.remove(index);
          }
        });
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: (selectedElements.contains(index))
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
            child: contact.displayName != null
                ? Row(
                    children: [
                      Expanded(
                        child: Text(
                          contact.displayName,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      (selectedElements.contains(index))
                          ? Icon(Icons.check)
                          : Container(),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Name not specified',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      (selectedElements.contains(index))
                          ? Icon(Icons.check)
                          : Container(),
                    ],
                  )),
      ),
    );
  }

  void searchOp(String searchQuery, List<Contact> contactsList) {
    List<Contact> list = [];
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

  Future<List<Contact>> getContacts() async {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    List<Contact> contactsList = contacts.toList();
    return contactsList;
  }
}
