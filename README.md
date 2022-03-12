# Ringforts - Final Year Project

This Ringforts mobile app was build using Flutter and Dart. It will run on Android and IOS Devices.

* https://github.com/Davidcorrigan1/RingfortFlutterApp


## Getting Started

The Ringfort app c 

## How to Use 

**Step 1:**

Download or clone this repo by using the link below:

```
https://github.com/Davidcorrigan1/RingfortFlutterApp.git
```

**Step 2:**

Go to project root and execute the following command in console to get the required dependencies: 

```
flutter pub get 
```




## Main Features:

* Splash
* Login
* Sign-up
* List Ringforts
* Map Overview if Ringforts


### Up-Coming Features:

* Connectivity Support
* Background Fetch Support

### Libraries & Tools Used

* [Provider](https://github.com/rrousselGit/provider) (State Management)


### Folder Structure
Here is the core folder structure which flutter provides.

```
flutter-app/
|- android
|- build
|- ios
|- lib
|- test
|- web
```

Here is the folder structure we have been using in this project

```
lib/
|- auth/
|- firebase/
|- helpers/
|- models/
|- providers/
|- screens/
|- widgets/
|- main.dart
```

Now, lets dive into the lib folder which has the main code for the application.

```
1- auth - Authentication related data
2- firebase - This contains the access method for the Firestore collections, with read, add and update functionality.
3- helpers - These are useful helper methods for some location and map features 
4- models -  This contains the definition of the data models for the Data Classes to which the firebase collections are mapped.
5- providers — Provides the state management for the application. Giving the screens methods to access to the data and update and add.
6- screens — Contains all the ui of the project, contains sub directory for each screen.
7- widgets —  Contains the common widgets for the application, like app_drawer
8- main.dart - This is the starting point of the application. All the application level configurations are defined in this file i.e, theme, routes, title, orientation etc.
```

### firebase

All the Firebase access method are contained in these classes..

```
firebase/
|- firebaseAuth.dart
|- firebaseDB.dart

```

### helpers

These are the helper method files:

```
helpers/
|- location_helper.dart
|- map_helper.dart
```

### models

This directory defines the data classes for the application:

```
models/
|- historic_site_staging.dart
|- historic_site.dart
|- NMS_data.dart
|- user_data.dart

```

### Providers

These are the state-management classes which deliver data to the screens: 

```
providers/
|- historic_sites_providers.dart
|- NMS_provider.dart
|- user_provider.dart
```

### Screens

These are the UI screens.

```
screens/
|- add_ringfort_screen.dart
|- approval_detail_screen.dart
|- approval_history_screen.dart
|- authentication_screen.dart
|- change_approval_screen.dart
|- display_image_screen.dart
|- map_overview_screen.dart
|- maps_detail_screen.dart
|- nms_overview_screen.dart
|- ringfort_detail_screen.dart
|- ringfort_home_screen.dart
|- ringfort_list_screen.dart

```

### Widgets

Contains the common widgets that are shared across multiple screens. For example, app_drawer, 

```
widgets/
|- app_drawer.dart
|- authentication_card.dart
|- favourite_icon.dart
|- image_input.dart
|- location_input.dart
|- map_card.dart
|- nms_card.dart
|- ringfort_card.dart
|- staging_card.dart
|- text_box.dart

```


### Main

This is the starting point of the application. All the application level configurations are defined in this file i.e, theme, routes, title, orientation etc.

```dart
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
  // Remove the Splash Screen after the Firebase Initialisation method runs
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
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
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
```


## Conclusion

This application is deployable on both Android and IOS devices.
