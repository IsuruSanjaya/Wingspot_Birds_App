import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _db.collection('users').doc(userId).get();

      if (snapshot.exists) {
        return snapshot.data();
      } else {
        throw Exception("Document does not exist for userId: $userId");
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }
}
