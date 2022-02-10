import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import '../providers/historic_sites_provider.dart';
import './screens/add_ringfort_screen.dart';
import './screens/ringforts_List_screen.dart';
import './screens/ringfort_detail_screen.dart';

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
    return ChangeNotifierProvider.value(
      value: HistoricSitesProvider(),
      child: MaterialApp(
        title: 'Ringforts of Ireland',
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: Colors.amber,
        ),
        home: RingfortsListScreen(),
        // Routing table for the app screens
        routes: {
          AddRingfortScreen.routeName: (ctx) => AddRingfortScreen(),
          RingfortDetailScreen.routeName: (ctx) => RingfortDetailScreen(),
        },
      ),
    );
  }
}
