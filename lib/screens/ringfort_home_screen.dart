import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../screens/authentication_screen.dart';
import '../screens/map_overview_screen.dart';
import '../screens/ringforts_List_screen.dart';
import '../providers/user_provider.dart';
import '../firebase/firebaseAuth.dart';

class RingfortHomeScreen extends StatefulWidget {
  static const routeName = '/ringfort-home';

  @override
  State<RingfortHomeScreen> createState() => _RingfortHomeScreenState();
}

class _RingfortHomeScreenState extends State<RingfortHomeScreen> {
  User user;
  bool _initFirst = true;
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    print('Run didChangeDependencies');
    if (_initFirst) {
      try {
        user = Provider.of<User>(context, listen: false);
        print('home screen user: $user');
        if (user != null) {
          setState(() {
            print('We are logged in!!');
            _isLoggedIn = true;
          });
        }
        _isLoading = false;
      } catch (error) {
        print('Found an error : $error');
      }
    }
    _initFirst = false;
    print('Auth Status: $_isLoggedIn');

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // WillPopScope stops the screen from popping from Stack
    // i.e. setting to false here.
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Container(
                    // Height after bottons and possible pop-up keyboard
                    height: MediaQuery.of(context).size.height -
                        100.0 -
                        MediaQuery.of(context).viewInsets.bottom,
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height,
                          width: double.infinity,
                          child: Image.asset(
                            'assets/images/ringfort.jpg',
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 190, left: 80),
                          child: Text(
                            'Ringforts',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 70,
                                fontWeight: FontWeight.w900,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context)
                              .pushNamed(RingfortsListScreen.routeName),
                          child: Container(
                            height: 100,
                            width: MediaQuery.of(context).size.width / 3.0,
                            decoration: BoxDecoration(
                              color: Theme.of(context).backgroundColor,
                              border: Border.all(
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Center(
                                child: Text(
                                  'List',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context)
                              .pushNamed(MapOverviewScreen.routeName),
                          child: Container(
                            height: 100,
                            width: MediaQuery.of(context).size.width / 3.0,
                            decoration: BoxDecoration(
                              color: Theme.of(context).backgroundColor,
                              border: Border.all(
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Center(
                                child: Text(
                                  'Map',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_isLoggedIn) {
                              FireBaseAuth.logoutUser();
                              setState(() {
                                Provider.of<UserProvider>(context,
                                        listen: false)
                                    .logoutUser;
                              });
                            } else {
                              Navigator.of(context)
                                  .pushNamed(AuthenticationScreen.routeName);
                            }
                          },
                          child: Container(
                            height: 100,
                            width: MediaQuery.of(context).size.width / 3.0,
                            decoration: BoxDecoration(
                              color: Theme.of(context).backgroundColor,
                              border: Border.all(
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Center(
                                child: _isLoggedIn
                                    ? Text(
                                        'Logout',
                                        textAlign: TextAlign.center,
                                      )
                                    : Text(
                                        'Login',
                                        textAlign: TextAlign.center,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}