import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ringfort_app/screens/map_overview_screen.dart';
import 'package:ringfort_app/screens/ringforts_List_screen.dart';

import '../firebase/firebaseAuth.dart';
import '../screens/add_ringfort_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var userEmail;
    try {
      userEmail = Provider.of<User>(context, listen: false).email;
    } catch (e) {
      print('Error: $e');
    }

    return Drawer(
      child: Column(
        children: [
          // adding appbar with automaticallyimpliedleading false to no Back button!
          AppBar(
            title: userEmail == null ? Text('Guest User') : Text('$userEmail'),
            //automaticallyImplyLeading: true,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.list_alt_outlined),
            title: Text('List Sites'),
            onTap: () =>
                Navigator.of(context).pushNamed(RingfortsListScreen.routeName),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.map_rounded),
            title: Text('Map View'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed(MapOverviewScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.add),
            title: Text('Add New'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed(AddRingfortScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () {
                // Call the pop first to close the drawer,
                Navigator.of(context).pop();
                // Then navigate to home screen which will check login status and switch to login screen
                Navigator.of(context).pushReplacementNamed('/');
                //then FirebaseAuth to logout.
                FireBaseAuth.logoutUser();
              }),
        ],
      ),
    );
  }
}
