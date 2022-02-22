import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../firebase/firebaseDB.dart';
import '../firebase/firebaseAuth.dart';
import '../models/user_data.dart';

class UserProvider with ChangeNotifier {
  var firebaseDB = FirebaseDB();

  UserData _currentUserData;

  UserData get currentUserData {
    return _currentUserData;
  }

  List<String> get userFavourites {
    return _currentUserData.favourites;
  }

  Future<UserData> getCurrentUserData(String uid) async {
    String uid;
    if (uid == null) {
      User firebaseAuth = await FireBaseAuth.getCurrent();
      uid = firebaseAuth.uid;
    } else {
      uid = uid;
    }
    _currentUserData = await firebaseDB.getUserdata(uid);
    notifyListeners();
    return _currentUserData;
    
  }

  // Clear the cuurent user data on logout
  void logoutUser() {
    _currentUserData = null;
    notifyListeners();
  }

  // Add a new user to the users collection
  Future<void> addUser(UserData user) async {
    await firebaseDB.addUser(user);
    notifyListeners();
  }

  // Adds a favourite to the user if it doesn't exist and updates firestore.
  Future<void> addFavouritetoCurrentUser(String favouriteUID) async {
    bool exists =
        _currentUserData.favourites.any((element) => element == favouriteUID);

    if (!exists) {
      _currentUserData.favourites.add(favouriteUID);
      await firebaseDB.updateUser(_currentUserData);
    }
    notifyListeners();
  }

  // Removes a favourite to the user if it doesn't exist and updates firestore.
  Future<void> removeFavouriteFromCurrentUser(String favouriteUID) async {
    bool exists =
        _currentUserData.favourites.any((element) => element == favouriteUID);

    if (exists) {
      _currentUserData.favourites.remove(favouriteUID);
      await firebaseDB.updateUser(_currentUserData);
    }
    notifyListeners();
  }
}
