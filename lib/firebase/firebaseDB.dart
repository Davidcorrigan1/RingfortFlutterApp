import 'dart:io' as io;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/historic_site_staging.dart';
import '../models/historic_site.dart';
import '../models/user_data.dart';

class FirebaseDB {
  // Store a reference to the 'historicSites' collection
  final CollectionReference siteCollection =
      FirebaseFirestore.instance.collection('historicSites');

  // Store a reference to the 'historicSitesStaging' collection
  final CollectionReference siteStagingCollection =
      FirebaseFirestore.instance.collection('historicSitesStaging');

  // Store a reference to the 'users' collection
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  // Store a reference to the 'NMS-Ringforts' collection
  final CollectionReference NMSCollection =
      FirebaseFirestore.instance.collection('NMS-Ringforts');

  // Store a reference to the Firebase Storage
  final FirebaseStorage storage = FirebaseStorage.instance;

  // Use the snaphots method to get a stream of snapshots
  // This listens for updates automatically
  // Decided not to use this in the end as I only want to
  // refresh when the users triggers it.
  Stream<QuerySnapshot> getStream() {
    return siteCollection.snapshots();
  }

  // Retrieve all ringforts from the HistoricSites collection
  Future<QuerySnapshot> fetchSites() async {
    return siteCollection.get();
  }

  // Retrieve all Staging ringforts changes from the HistoricSitesStaging collection
  Future<QuerySnapshot> fetchStagingSites() async {
    return siteStagingCollection.get();
  }

  // Retrieve 300 Ringfort site documents from NMS-Ringforts collection. Limiting
  // here to manage the costs.
  Future<QuerySnapshot> fetchNMSSites() async {
    return NMSCollection.limit(500).get();
  }

  // Add site document on Firebase
  Future<void> addSite(bool adminUser, HistoricSite site,
      HistoricSiteStaging stageingSite) async {
    if (adminUser) {
      return siteCollection.doc(site.uid).set(site.toJson());
    } else {
      return siteStagingCollection
          .doc(stageingSite.uid)
          .set(stageingSite.toJson());
    }
  }

  // Add user document on Firebase
  Future<void> addUser(UserData user) async {
    return userCollection.doc(user.uid).set(user.toJson());
  }

  // Update user document on Firebase
  Future<void> updateUser(UserData user) async {
    return userCollection.doc(user.uid).update(user.toJson());
  }

  // Update a specific ringfort document in the collection
  void updateSite(HistoricSite site) async {
    await siteCollection.doc(site.uid).update(site.toJson());
  }

  // Update a specific ringfort document in the staging collection
  void updateStagingSite(HistoricSiteStaging site) async {
    await siteStagingCollection.doc(site.uid).update(site.toJson());
  }

  // Delete a specific ringfort document from the collection
  void deleteSite(String uid) async {
    await siteCollection.doc(uid).delete();
  }

  // Delete a specific ringfort document from the staging collection
  void deleteStagingSite(String uid) async {
    await siteStagingCollection.doc(uid).delete();
  }

  // Delete a specific ringfort document from the NMS collection
  void deleteNMSSite(String uid) async {
    await NMSCollection.doc(uid).delete();
  }

  Future<String> addImage(io.File image, String imageName) async {
    String imageUrl = '';
    Reference ref = await storage.ref().child("images/image-${imageName}.jpg");
    if (image != null) {
      var snapshot = await ref.putFile(image);
      if (snapshot.state == TaskState.success) {
        imageUrl = await snapshot.ref.getDownloadURL();
        print('Image updated successfully');
      }
    }
    return imageUrl;
  }

  // Generates a document id which can be used to add a new document
  Future<String> generateDocumentId() async {
    var randomDoc = await siteCollection.doc();
    String docId = randomDoc.id;
    return docId;
  }

  // retrieve user data from Firestore and convert to 'UserData' class object
  Future<UserData> getUserdata(String uid) async {
    print('userid: $uid');
    var snapshot = await userCollection.doc(uid).get();
    print('snapshot: $snapshot');
    UserData userData = UserData.fromJson(snapshot.data());
    return userData;
  }
}
