import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/historic_sites_provider.dart';
import './screens/add_ringfort_screen.dart';
import './screens/ringforts_List_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: HistoricSitesProvider(),
      child: MaterialApp(
        title: 'Ringforts of Ireland',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          primaryColor: Colors.amber,
        ),
        home: RingfortsListScreen(),
        // Routing table for the app screens
        routes: {
          AddRingfortScreen.routeName: (ctx) => AddRingfortScreen(),
        },
      ),
    );
  }
}
