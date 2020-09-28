import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';

class LoginPage extends StatefulWidget {
  final String name;

  LoginPage(this.name, {Key key}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void checkDetailsUser(String email,String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String passwordReceived = prefs.getString('user_password');
    String emailReceived = prefs.getString('user_email');
    if (passwordReceived == password&&emailReceived==email) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } else {
      Flushbar(
        title: "Password Issue",
        message: "Please Ensure Your Password is correct",
        duration: Duration(seconds: 3),
      )..show(context);
    }
  }
  final _formKey = GlobalKey<FormState>();
  bool _autovalidate = false;
  bool obscure=true;
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        elevation: 0,
        backgroundColor: Theme.of(context).brightness!=Brightness.dark?Color(0xFF6770D2):Colors.grey[900],
        centerTitle: true,
      ),
      body: Form(
        // ignore: deprecated_member_use
        autovalidate: _autovalidate,
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Container(
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
                    labelText: ' Email',
                    labelStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Color(0xFF767676),
                        fontSize: 14),
                  ),
                  autocorrect: false,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: MediaQuery.of(context).size.width / 1.15,
              child: TextFormField(
                controller: _passwordController,
                obscureText: obscure,
                validator: (value) {
                  _autovalidate = true;
                  if (value.isEmpty) {
                    return 'This field cannot be empty';
                  }
                  return null;
                },
                // controller: passwordController,
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
                  labelStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Color(0xFF767676),
                      fontSize: 14),
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.visibility),
                    padding: EdgeInsets.all(0),
                    onPressed: () {
                      setState(() {
                        obscure = !obscure;
                      });
                    },
                  ),
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
                child: Text("Sign In"),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _removeKeyboard(context);
                  }
                  checkDetailsUser(_nameController.text,_passwordController.text);
                },
                color: Color(0xFF6770D2),
              ),
            ),
          ],
        ),
      ),
    );
  }
  _removeKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }
}
