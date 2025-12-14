import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // collection reference
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  Future<void> updateUserData(String mobileNumber) async {
    if (uid == null) {
      return;
    }
    try {
      await userCollection.doc(uid).set({
        'mobileNumber': mobileNumber,
      });
    } catch (e) {
      return;
    }
  }

  // Get user document stream
  Stream<DocumentSnapshot> get userData {
    return userCollection.doc(uid).snapshots();
  }
}
