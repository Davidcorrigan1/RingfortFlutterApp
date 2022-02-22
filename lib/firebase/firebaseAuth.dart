import 'package:firebase_auth/firebase_auth.dart';

import '../firebase/firebaseDB.dart';
import '../models/user_data.dart';

class FireBaseAuth {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Logging in a user and returning the uid if found.
  static Future<String> loginUser(String email, String password) async {
    User user;

    final authResult = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    user = authResult.user;

    return user.uid;
  }


  // Registering a new user to FirebaseAuth and adding a new user to the 'users' collection.
  static Future<String> registerUser(String email, String password) async {
    User user;

    final registerResult = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    user = registerResult.user;

    List<String> favourites = [];

 
    UserData newUser =
        UserData(uid: user.uid, email: user.email, favourites: favourites);
    await FirebaseDB().addUser(newUser);

    return newUser.uid;
  }

  static Future<void> logoutUser() async {
    await _auth.signOut();
  }

  static Stream<User> getUserStatus() {
    return _auth.authStateChanges();
  }

  static Future<User> getCurrent() async {
    return _auth.currentUser;
  }
}
