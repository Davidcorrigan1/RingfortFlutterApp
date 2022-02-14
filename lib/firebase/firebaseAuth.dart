import 'package:firebase_auth/firebase_auth.dart';

import '../firebase/firebaseDB.dart';

import '../models/user_data.dart';

class FireBaseAuth {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> loginUser(String email, String password) async {
    User user;

    final authResult = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    user = authResult.user;

    if (authResult.additionalUserInfo.isNewUser) {
      // add user to user collecion
    }
  }

  static Future<void> registerUser(String email, String password) async {
    User user;

    final registerResult = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    user = registerResult.user;

    String uid = await FirebaseDB().generateDocumentId();
    UserData newUser = UserData(uid: uid, email: user.email);
    await FirebaseDB().addUser(newUser);
  }

  static Future<void> logoutUser() async {
    await _auth.signOut();
  }

  static Stream<User> getUserStatus() {
    return _auth.authStateChanges();
  }
}
