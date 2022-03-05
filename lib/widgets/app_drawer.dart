import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ringfort_app/screens/nms_overview_screen.dart';

import '../models/user_data.dart';
import '../screens/approval_history_screen.dart';
import '../screens/authentication_screen.dart';
import '../screens/change_approval_screen.dart';
import '../screens/map_overview_screen.dart';
import '../screens/ringfort_home_screen.dart';
import '../screens/ringforts_List_screen.dart';
import '../providers/historic_sites_provider.dart';

import '../firebase/firebaseAuth.dart';
import '../screens/add_ringfort_screen.dart';
import '../providers/user_provider.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var userEmail;
    var user;
    UserData userData;

    // This method will ask user if they want to login to proceed Yes or no
    void _showErrorDialog(BuildContext ctx) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('This option is only available to logged in Users'),
          content: Text('Do you want to login?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: Text('No '),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(ctx).backgroundColor,
              ),
              onPressed: () {
                Navigator.of(ctx).pushNamed(AuthenticationScreen.routeName);
              },
              child: Text('Yes'),
            ),
          ],
        ),
      );
    }

    // Here we check if the user is logged in, and get the email if they are.
    try {
      user = Provider.of<User>(context, listen: false);
      if (user != null) {
        userEmail = user.email;
        userData =
            Provider.of<UserProvider>(context, listen: false).currentUserData;
      }
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
            leading: Icon(Icons.archive),
            title: Text('NMS Upload Data'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed(NmsOverviewScreen.routeName);
            },
          ),
          // The link to the Approvals Screen for Admin users
          if (userData != null) ...[
            if (userData.adminUser) ...[
              Divider(),
              ListTile(
                leading: Icon(Icons.approval),
                title: Text(
                    'Approvals (${Provider.of<HistoricSitesProvider>(context, listen: false).awaitingApprovalSites.length.toString()})'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context)
                      .pushNamed(ChangeApprovalScreen.routeName);
                },
              ),
            ] else ...[
              Divider(),
              ListTile(
                leading: Icon(Icons.history),
                title: Text('My Change History'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context)
                      .pushNamed(ApprovalHistoryScreen.routeName);
                },
              ),
            ],
          ],
          Divider(),
          // This is the add Ringfort option, when tapped it checks if the
          // user is logged on or not and asks them to logon to proceed if not.
          ListTile(
            leading: Icon(Icons.add),
            title: Text('Add New'),
            onTap: () {
              if (user == null) {
                Navigator.pop(context);
                _showErrorDialog(context);
              } else {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AddRingfortScreen.routeName);
              }
            },
          ),
          Divider(),
          // Show the logout option if currently logged in else show the
          // login option on the Nav Drawer
          user != null
              ? ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Logout'),
                  onTap: () {
                    // Call the pop first to close the drawer,
                    Navigator.of(context).pop();
                    // Then navigate to home screen which will check login status and switch to login screen
                    Navigator.of(context)
                        .pushReplacementNamed(RingfortHomeScreen.routeName);
                    //then FirebaseAuth to logout.
                    FireBaseAuth.logoutUser();
                    Provider.of<UserProvider>(context, listen: false)
                        .logoutUser;
                  })
              : ListTile(
                  leading: Icon(Icons.login),
                  title: Text('Login'),
                  onTap: () {
                    // Call the pop first to close the drawer,
                    Navigator.of(context).pop();
                    // Then navigate to home screen which will check login status and switch to login screen
                    Navigator.of(context)
                        .pushNamed(AuthenticationScreen.routeName);
                  }),
        ],
      ),
    );
  }
}
