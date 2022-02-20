import 'package:flutter/material.dart';
import 'package:ringfort_app/screens/authentication_screen.dart';
import 'package:ringfort_app/screens/map_overview_screen.dart';
import 'package:ringfort_app/screens/ringforts_List_screen.dart';

class RingfortHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // WillPopScope stops the screen from popping from Stack
    // i.e. setting to false here.
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height - 100.0,
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
                    onTap: () => Navigator.of(context)
                        .pushNamed(AuthenticationScreen.routeName),
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
