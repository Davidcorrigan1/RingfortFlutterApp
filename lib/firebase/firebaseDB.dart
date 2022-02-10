import 'dart:io' as io;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/historic_site.dart';

class FirebaseDB {
  // Store a reference to the 'historicSites' collection
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('historicSites');

  // Store a reference to the Firebase Storage
  final FirebaseStorage storage = FirebaseStorage.instance;

  // Use the snaphots method to get a stream of snapshots
  // This listens for updates automatically
  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  // Add a new Ringfort. This returns a Future if you want to wait for the result
  // Ity will automatically create a new document uid for the site
  Future<DocumentReference> addSite(HistoricSite site) {
    return collection.add(site.toJson());
  }

  // Update a specific ringfort document in the collection
  void updateSite(HistoricSite site) async {
    await collection.doc(site.uid).update(site.toJson());
  }

  // Delete a specific ringfort document from the collection
  void deleteSite(HistoricSite site) async {
    await collection.doc(site.uid).delete();
  }

  Future<String> addImage(io.File image) async {
    String imageUrl = '';
    Reference ref = await storage.ref().child("images/imagename.jpg");
    var snapshot = await ref.putFile(image);
    if (snapshot.state == TaskState.success) {
      imageUrl = await snapshot.ref.getDownloadURL();
    } else {
      print('Error from image repo ${snapshot.state.toString()}');
    }
    return imageUrl;
  }
}
