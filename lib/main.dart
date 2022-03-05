import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './firebase/firebaseAuth.dart';
import './providers/user_provider.dart';
import './providers/historic_sites_provider.dart';
import './providers/NMS_provider.dart';
import './screens/approval_detail_screen.dart';
import './screens/add_ringfort_screen.dart';
import './screens/ringfort_home_screen.dart';
import './screens/ringforts_List_screen.dart';
import './screens/ringfort_detail_screen.dart';
import './screens/authentication_screen.dart';
import './screens/map_overview_screen.dart';
import './screens/change_approval_screen.dart';
import './screens/approval_history_screen.dart';
import './screens/display_image_screen.dart';
import './screens/nms_overview_screen.dart';

Future<void> main() async {
  // WidgetsFlutterBinding is used to interact with the Flutter engine,
  // which is used by Flutter plugins through platform channel to interact
  // with the native code. Therefore, you need to call ensureInitialized to
  // ensure the binding between widget layer and flutter engine is initialized
  // before calling the initializeApp() method of Firebase plugin
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp() initializes the Firebase app and then
  // rest of the code is executed.
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // The StreamProvider will keep the user authentication status
        // up to date across all widgets that consume it.
        StreamProvider<User>(
          create: (context) => FireBaseAuth.getUserStatus(),
          initialData: null,
        ),
        ChangeNotifierProvider<HistoricSitesProvider>.value(
          value: HistoricSitesProvider(),
        ),
        ChangeNotifierProvider<NMSProvider>.value(
          value: NMSProvider(),
        ),
        ChangeNotifierProvider<UserProvider>.value(
          value: UserProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Ringforts of Ireland',
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: Colors.grey,
        ),
        home: RingfortHomeScreen(),
        // Routing table for the app screens
        routes: {
          //Route - Ringfort Home screen
          RingfortHomeScreen.routeName: (context) => RingfortHomeScreen(),
          //Route - add a ringfort screen
          AddRingfortScreen.routeName: (context) => AddRingfortScreen(),
          //Route - Ringfort List screen
          RingfortsListScreen.routeName: (context) => RingfortsListScreen(),
          //Route - Ringfort Detail screen
          RingfortDetailScreen.routeName: (context) => RingfortDetailScreen(),
          //Route - AuthScreen
          AuthenticationScreen.routeName: (context) => AuthenticationScreen(),
          //Route - Map Overview screen
          MapOverviewScreen.routeName: (context) => MapOverviewScreen(),
          //Route - Update Approval screen
          ChangeApprovalScreen.routeName: (context) => ChangeApprovalScreen(),
          //Route - Approval Detail screen
          ApprovalDetailScreen.routeName: (context) => ApprovalDetailScreen(),
          //Route - User Approval History screen
          ApprovalHistoryScreen.routeName: (context) => ApprovalHistoryScreen(),
          //Route - Display Image screen
          DisplayImageScreen.routeName: (context) => DisplayImageScreen(),
          //Route - NMS Map Overview screen
          NmsOverviewScreen.routeName: (context) => NmsOverviewScreen(),
        },
      ),
    );
  }
}
