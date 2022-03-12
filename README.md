# Ringforts - Final Year Project

The Ringforts project is a mobile app which was build using Flutter and Dart and which will run on both Android and IOS Devices.
The application main object is to allow users to discover ringfort around the island of ireland, and also to give them the opportunity to add this database of information by adding new ringfort locations or by updating the information of existing locations. The app give the user the ability to search the list of Ringforts sites and add them to a list of favourites.

One of the tools which the user can take advantage of is the National Monument Services (NMS) of Ireland data on Ringforts. This is data which was downloaded from [Data.gov.ie](https://data.gov.ie/dataset/national-monuments-service-archaeological-survey-of-ireland), and uploaded to databse available to the application. This data can be accessed on a map view by using the 'NMS Uploaded Data' option from the Nav Drawer. The user can select any of these sites and quickly update the information and add it to the live ringforts database.

 Any updates made by a 'normal' user need to be approved by an Admin user before they become live on the system. This approval process was added to protect the integrity of the data and to make sure it stays high quality. By contrast when a 'Admin' user makes any updates they are reflected in the 'live' collection immediately without any need for approval.

All data for the application is stored in the cloud in Firebase Firestore collections.

## Firestore Collections
* **historicSites** - This is the collection of 'live' Ringfort data which is maintained by the application. This populates the main Ringfort List and Map Overview screens.

* **historicSitesStaging** - This is a staging collection. When a normal user attempts to makes any updates to the live data, the updates get stored on this staging collection with a status of 'awaiting' approval until an admin user approves or rejects the update. Approval will trigger the updates to be applied to the live 'historicSites' collection, and the status on the staging record gets updated to 'approved'. And rejection means no update is applied and the status of the staging record gets updated to 'rejected'

* **NMS-Ringforts** - This is the collection which stores the data downloaded from the National Monument Services website. When one of these is selected by the user and updated it will appear on the 'historicSitesStaging' collection as a new Ringfort awaiting approval. When it the addition is approved, then the data gets added to the live 'historicSites' collection and deleted from the NMS-Ringforts collection. The staging record status will get updated to approved.

* **users** - This collection will store information about registered users, including their favourite if they have selected any.



* https://github.com/Davidcorrigan1/RingfortFlutterApp



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

**Step 3:**
Note you will need Firebase API keys to run.


## Main Features:

* Splash
* Login/Logout
* Sign-up
* List Ringforts
* Map Overview of Ringforts
* Map of NMS Sites
* Approval Functionality
* Add new Ringfort 
* Update/Delete Ringfort
* Search and Favourites Functionality
* Adding Ringfort images from Camera, Photos or Satelitte image of location 
* View map by favourites and view local sites within 50km.


### Libraries & Tools Used

* [provider](https://pub.dev/packages/provider) (State Management)
* [image_picker](https://pub.dev/packages/image_picker) (For camera images and picking images)
* [path_provider](https://pub.dev/packages/path_provider) (For finding usage storage locations on devices)
* [path](https://pub.dev/packages/path) (Helps with constructing file paths)
* [location](https://pub.dev/packages/location) (Package to handle getting user location)
* [google_maps_flutter](https://pub.dev/packages/google_maps_flutter) (Google Maps Package)
* [http](https://pub.dev/packages/http) (For making Http requests easily)
* [firebase_core](https://pub.dev/packages/firebase_core) (To anable connections to multiple Firebase apps)
* [cloud_firestore](https://pub.dev/packages/cloud_firestore) (A Flutter plugin to use the Cloud Firestore API)
* [firebase_storage](https://pub.dev/packages/firebase_storage) (A Flutter plugin to use the Firebase Cloud Storage API)
* [firebase_auth](https://pub.dev/packages/firebase_auth) (A Flutter plugin to use the Firebase Authentication API.)
* [tuple](https://pub.dev/packages/tuple) (For dart tuple imeplentation)
* [extended_image](https://pub.dev/packages/extended_image) (Additional Image capabilities)
* [scrollable_positioned_list](https://pub.dev/packages/scrollable_positioned_list) (To scroll to a specific item in a list)
* [geolocator](https://pub.dev/packages/geolocator) (To calculate distance between 2 points)
* [recase](https://pub.dev/packages/recase) (For String case managemnent)
* [flutter_native_splash](https://pub.dev/packages/flutter_native_splash) (For generating a splash screen)
* [flutter_switch](https://pub.dev/packages/flutter_switch) (For additional Switch button implementation option)




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

Here is the folder structure I used in this project

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
