import 'package:alarming_system_mobile_app/pages/home_page.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _autovalidate = false;
  bool obscure = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        elevation: 0,
        backgroundColor: Theme.of(context).brightness!=Brightness.dark?Color(0xFF6770D2):Colors.grey[900],
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
                width: MediaQuery.of(context).size.width / 1.15,
                child: TextFormField(
                  controller: _confirmPasswordController,
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
                    labelText: 'Confirm Password',
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
                  child: Text("Register"),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _removeKeyboard(context);
                      if (_passwordController.text ==
                          _confirmPasswordController.text) {
                        setDetailsUser(
                            _nameController.text,
                            _emailController.text,
                            _passwordController.text);
                      } else {
                        Flushbar(
                          title: "Password Issue",
                          message:
                          "Please Ensure Your Password and Confirmed Password are the same.",
                          duration: Duration(seconds: 3),
                        )..show(context);
                      }
                    }
                  },
                  color: Color(0xFF6770D2),
                ),
              ),
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
  void setDetailsUser(
      String name, String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_password', password);
    await prefs.setString('user_email', email);
    String nameFound = prefs.getString('user_name');
    print(nameFound);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }

}
