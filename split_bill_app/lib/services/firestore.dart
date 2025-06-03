import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // menambah data user ke table person
  Future<void> addPerson({
    required String uid,
    required String name,
    required String email,
    int balance = 0,
    List<String> friends = const [],
  }) async {
    await _db.collection('person').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'balance': balance,
      'friends': friends,
    });
  }

  // mengambil data user
  Future<Map<String, dynamic>?> getPerson(String uid) async {
    final doc = await _db.collection('person').doc(uid).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  // top up balance
  Future<void> topUpBalance(String uid, int amount) async {
    final doc = _db.collection('person').doc(uid);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(doc);
      final currentBalance = snapshot.get('balance') as int;
      final newBalance = currentBalance + amount;

      transaction.update(doc, {'balance': newBalance});
    });
  }
}
