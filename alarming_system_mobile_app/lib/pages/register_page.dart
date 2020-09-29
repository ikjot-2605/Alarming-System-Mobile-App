import 'package:alarming_system_mobile_app/pages/home_page.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../model/AppUser.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

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
    print('signInWithGoogle succeeded: $user');
    storeDetailsInHive(user.displayName,user.email,user.phoneNumber,user.photoURL,true);
    return '$user';
  }

  return null;
}

void storeDetailsInHive(String name, String email,String phone,String photoUrl,bool googleLoggedIn)async{
  var users = await Hive.openBox('users');
  AppUser user = new AppUser(name:name,email:email,imageUrl:photoUrl,phoneNumber:phone,googleLoggedIn:googleLoggedIn);
  users.add(user);
  print(users.getAt(0).name);
  print(users.getAt(0).imageUrl);
  print(users.getAt(0).email);
  print(users.getAt(0).phoneNumber);
  print(users.getAt(0).googleLoggedIn);
}

Future<void> signOutGoogle() async {
  await googleSignIn.signOut();

  print("User Signed Out");
}
class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _autovalidate = false;
  bool obscure = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        elevation: 0,
        backgroundColor: Theme.of(context).brightness != Brightness.dark
            ? Color(0xFF6770D2)
            : Colors.grey[900],
        centerTitle: true,
      ),
      body: Form(
        // ignore: deprecated_member_use
        autovalidate: _autovalidate,
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Text(
                  'Please enter the following details',
                  style: TextStyle(height: 14, letterSpacing: 0.5),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 1.15,
                child: TextFormField(
                  controller: _nameController,
                  validator: (value) {
                    if (value.isEmpty) {
                      _autovalidate = true;
                      return 'This field cannot be empty';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: Colors.red,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: Color(0xFF6770D2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[500]
                            : Color(0xffDCDCDC),
                        width: 2,
                      ),
                    ),
                    labelText: 'Name',
                    labelStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Color(0xFF767676),
                        fontSize: 14),
                  ),
                  autocorrect: false,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: MediaQuery.of(context).size.width / 1.15,
                child: TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value.isEmpty) {
                      _autovalidate = true;
                      return 'This field cannot be empty';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: Colors.red,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: Color(0xFF6770D2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[500]
                            : Color(0xffDCDCDC),
                        width: 2,
                      ),
                    ),
                    labelText: 'Email',
                    labelStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Color(0xFF767676),
                        fontSize: 14),
                  ),
                  autocorrect: false,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: MediaQuery.of(context).size.width / 1.15,
                child: TextFormField(
                  controller: _phoneController,
                  validator: (value) {
                    if (value.isEmpty) {
                      _autovalidate = true;
                      return 'This field cannot be empty';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: Colors.red,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: Color(0xFF6770D2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[500]
                            : Color(0xffDCDCDC),
                        width: 2,
                      ),
                    ),
                    labelText: 'Phone',
                    labelStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Color(0xFF767676),
                        fontSize: 14),
                  ),
                  autocorrect: false,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 40,
                width: MediaQuery.of(context).size.width / 1.15,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  textColor: Colors.white,
                  child: Text("Register"),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _removeKeyboard(context);
                      setDetailsUser(_nameController.text,
                          _emailController.text,_phoneController.text);
                    }
                  },
                  color: Color(0xFF6770D2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('OR'),
              ),
              _signInWithGoogleButton()
            ],
          ),
        ),
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

  void setDetailsUser(String name, String email,String phone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    await prefs.setString('user_phone', phone);
    String nameFound = prefs.getString('user_name');
    print(nameFound);
    storeDetailsInHive(name, email, phone,'https://upload.wikimedia.org/wikipedia/commons/8/89/Portrait_Placeholder.png',false);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }
  Widget _signInWithGoogleButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        signInWithGoogle().then((result) {
          if (result != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return HomePage();
                },
              ),
            );
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
}
