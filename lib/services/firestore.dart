import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:split_bill_app/models/event_model.dart';
import 'package:flutter/foundation.dart';

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

  Future<String?> addEventToFirestore(Event eventData) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      // Kita tidak menyertakan ID saat menambah karena Firestore akan generate otomatis
      // Map yang dikirim tidak mengandung 'id'
      Map<String, dynamic> eventMap = eventData.toMap();

      DocumentReference docRef = await firestore
          .collection('events')
          .add(eventMap);
      if (kDebugMode) {
        print('Event berhasil ditambahkan dengan ID: ${docRef.id}');
      }
      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('Error menambahkan event: $e');
      }
      return null;
    }
  }

  // --- Fungsi untuk Mengambil Data Event ---

  // 1. Mengambil semua event
  Future<List<Event>> getAllEvents() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await firestore
              .collection('events')
              .orderBy('createdAt', descending: true)
              .get();

      List<Event> events =
          querySnapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();

      if (kDebugMode) {
        print('Berhasil mengambil ${events.length} events.');
      }
      return events;
    } catch (e) {
      if (kDebugMode) {
        print('Error mengambil semua events: $e');
      }
      return []; // Kembalikan list kosong jika error
    }
  }

  // 2. Mengambil event yang melibatkan pengguna tertentu (sebagai pembayar atau partisipan)
  Future<List<Event>> getEventsForUser(String userId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Event> userEvents = [];

    try {
      // Ambil event di mana pengguna adalah pembayar (payerId)
      QuerySnapshot<Map<String, dynamic>> paidByUserData =
          await firestore
              .collection('events')
              .where('payerId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      userEvents.addAll(
        paidByUserData.docs.map((doc) => Event.fromFirestore(doc)),
      );

      QuerySnapshot<Map<String, dynamic>> participatedEventsSnapshot =
          await firestore
              .collection('events')
              .where('payerId', isNotEqualTo: userId)
              .get();

      for (var doc in participatedEventsSnapshot.docs) {
        Event event = Event.fromFirestore(doc);
        // Cek apakah userId ada di dalam list participants event ini
        if (event.participants.any(
          (participant) => participant.userId == userId,
        )) {
          // Hindari duplikasi jika sebuah event sudah diambil dari query payerId (seharusnya tidak terjadi karena filter payerId != userId)
          if (!userEvents.any((e) => e.id == event.id)) {
            userEvents.add(event);
          }
        }
      }

      // Urutkan kembali semua event yang terkumpul berdasarkan tanggal
      userEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (kDebugMode) {
        print(
          'Berhasil mengambil ${userEvents.length} events untuk user $userId.',
        );
      }
      return userEvents;
    } catch (e) {
      if (kDebugMode) {
        print('Error mengambil events untuk user $userId: $e');
      }
      return []; // Kembalikan list kosong jika error
    }
  }
}
