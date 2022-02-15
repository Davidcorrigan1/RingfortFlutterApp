import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ringfort_app/screens/map_overview_screen.dart';

import '../firebase/firebaseAuth.dart';
import '../screens/add_ringfort_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var userEmail = Provider.of<User>(context).email;

    return Drawer(
      child: Column(
        children: [
          // adding appbar with automaticallyimpliedleading false to no Back button!
          AppBar(
            title: Text('$userEmail'),
            //automaticallyImplyLeading: true,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.list_alt_outlined),
            title: Text('List Sites'),
            onTap: () => Navigator.of(context).pushReplacementNamed('/'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.map_rounded),
            title: Text('Map View'),
            onTap: () =>
                Navigator.of(context).pushNamed(MapOverviewScreen.routeName),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.add),
            title: Text('Add New'),
            onTap: () => Navigator.of(context)
                .pushReplacementNamed(AddRingfortScreen.routeName),
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
