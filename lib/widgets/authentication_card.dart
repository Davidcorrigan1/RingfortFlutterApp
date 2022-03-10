import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../firebase/firebaseAuth.dart';
import '../screens/ringforts_List_screen.dart';
import '../providers/user_provider.dart';

enum AuthMode { Signup, Login }

class AuthenticationCard extends StatefulWidget {
  const AuthenticationCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthenticationCardState createState() => _AuthenticationCardState();
}

class _AuthenticationCardState extends State<AuthenticationCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  var _isLoading = false;
  final _passwordController = TextEditingController();

  // This method will display the screen message for the login/signup process
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error has occurred'),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close the dialogue
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  //--------------------------------------------------------------
  // Submitting the form (either login or Signup)
  //--------------------------------------------------------------
  void _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      String uid;
      if (_authMode == AuthMode.Login) {
        uid = await FireBaseAuth.loginUser(
            _authData['email'], _authData['password']);
      } else {
        uid = await FireBaseAuth.registerUser(
            _authData['email'], _authData['password']);
      }
      // retrieve the Firestore collection for the loggin user.
      await Provider.of<UserProvider>(context, listen: false)
          .getCurrentUserData(uid);
    } on Exception catch (error) {
      var errorMessage = 'Authentication Failed';

      if (error.toString().contains('firebase_auth/wrong-password')) {
        errorMessage = 'Invalid Password';
      } else if (error.toString().contains('firebase_auth/user-not-found')) {
        errorMessage = 'Could not find a user with that email';
      } else if (error
          .toString()
          .contains('firebase_auth/email-already-in-use')) {
        errorMessage = 'This email address is already in use';
      } else if (error.toString().contains('firebase_auth/invalid-email')) {
        errorMessage = 'This is not a valid email address';
      }
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });

    // Check if the user is logged in, if they are go to the List screen
    try {
      var user = Provider.of<User>(context, listen: false);
      if (user != null) {
        Navigator.of(context).pushNamed(RingfortsListScreen.routeName);
      }
    } on Exception catch (error) {
      print(error);
    }
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        color: Colors.white10,
        height: _authMode == AuthMode.Signup ? 380 : 310,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 380 : 310),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                ),
                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    enabled: _authMode == AuthMode.Signup,
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                    validator: _authMode == AuthMode.Signup
                        ? (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match!';
                            }
                            return null;
                          }
                        : null,
                  ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _submit,
                  ),
                TextButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
