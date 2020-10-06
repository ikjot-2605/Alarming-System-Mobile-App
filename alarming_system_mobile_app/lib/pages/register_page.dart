import 'package:alarming_system_mobile_app/pages/home_page.dart';
import 'package:alarming_system_mobile_app/pages/waiting_for_home_page.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../model/AppUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
FirebaseFirestore firestore = FirebaseFirestore.instance;

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  Future<String> checkIfUserExists(String appUserEmail)async{
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    var result = await users
        .where("email", isEqualTo: appUserEmail)
        .get();
    result.docs.forEach((res) {
      print(res.data);
    });
    if(result.docs.length>0){
      print(result.docs[0].id);
      return result.docs[0].id;
    }
    else{
      return null;
    }
  }
  Future<String> signInWithGoogle() async {
    await Firebase.initializeApp();

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult = await _auth.signInWithCredential(credential);
    final User user = authResult.user;
    if (user != null) {
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);
      final User currentUser = _auth.currentUser;
      assert(user.uid == currentUser.uid);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('curruser',user.email);
      checkIfUserExists(user.email).then((value){
        if(value!=null){
          AppUser appUsers = new AppUser(name:user.displayName,email:user.email,imageUrl:user.photoURL,phoneNumber:user.phoneNumber,googleLoggedIn:true,firebaseId: value);
          Navigator.push(context, MaterialPageRoute(builder: (context)=>WaitingForHomePage(appUsers)));
        }
        else{
          createRecord(user.displayName, user.email, user.phoneNumber,user.photoURL,true);
        }
      });

      return '$user';
    }

    return null;
  }


  Future<void> signOutGoogle() async {
    await googleSignIn.signOut();

  }
  void createRecord(String name,String email, String phone,String photoURL,bool googleLoggedIn) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return users
        .add({
      'name': name,
      'email': email,
      'phone': phone,
      'message':"",
      'emergency_contacts':{}
    })
        .then((value){
      storeDetailsInHive(name, email, phone, photoURL, googleLoggedIn, value.id);
    })
        .catchError((error) => print("Failed to add user: $error"));
  }

  void storeDetailsInHive(String name, String email,String phone,String photoUrl,bool googleLoggedIn,String firebaseId)async{
    var users = await Hive.openBox('users');
    AppUser user = new AppUser(name:name,email:email,imageUrl:photoUrl,phoneNumber:phone,googleLoggedIn:googleLoggedIn,firebaseId: firebaseId);
    users.add(user);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('user_name'+email, name);
    await prefs.setString('user_email'+email, email);
    await prefs.setString('user_phone'+email, phone);
    await prefs.setString('user_id'+email, firebaseId);
    Navigator.push(context,
      MaterialPageRoute(
        builder: (context) {
          return HomePage(AppUser(name: name,email: email,phoneNumber: phone,imageUrl: photoUrl,googleLoggedIn: googleLoggedIn,firebaseId: firebaseId,emergencyContacts:[],emergencyMessage:""));
        },
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Theme.of(context).brightness != Brightness.dark
            ? Color(0xFF6770D2)
            : Colors.grey[900],
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Welcome to the alarming system app.',style: TextStyle(fontSize: 18,),),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Please use your google account to login.',style: TextStyle(fontSize: 14,),),
          ),
          Center(child: _signInWithGoogleButton())
        ],
      ),
    );
  }

  Widget horizontalLine(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Container(
          width: 4,
          height: 1,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black12.withOpacity(1),
        ),
      );
  _removeKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }


  Widget _signInWithGoogleButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        signInWithGoogle().then((result) {
          if (result != null) {

          }
        });
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("assets/google_logo.png"), height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  Future<AppUser> checkIfFirstTime(String givenEmail)async{
    var users = await Hive.openBox('users');
    for(int i=0;i<users.length;i++){
      if(givenEmail==users.getAt(i).email){
        return users.getAt(i);
      }
    }
    return null;
  }
}
