import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  // Ambil daftar personel
  Future<List<String>> getPersonelNames() async {
    try {
      final querySnapshot = await _userCollection.get();
      return querySnapshot.docs
          .map((doc) => doc['name'] as String) // Ambil field 'nama' saja
          .toList();
    } catch (e) {
      print('Error fetching personel: $e');
      return [];
    }
  }
}
