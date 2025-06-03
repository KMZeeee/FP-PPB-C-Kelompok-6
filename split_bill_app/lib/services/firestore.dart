import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference event = FirebaseFirestore.instance.collection(
    'events',
  );

  Future<void> addEvent({
    required String Name,
    required String Date,
    required List<Map<String, dynamic>> member,
    required int total_expense,
  }) async {
    try {
      await event.add({
        'Name': Name,
        'Date': Date,
        'member': member,
        'total_expense': total_expense,
      });
    } catch (e) {
      print('Error adding event: $e');
      rethrow;
    }
  }

  Future<void> updateEvent({
    required String eventId,
    required String Name,
    required String Date,
    required String Time,
    required String Location,
  }) async {
    try {
      await event.doc(eventId).update({
        'Name': Name,
        'Date': Date,
        'Time': Time,
        'Location': Location,
      });
    } catch (e) {
      print('Error updating event: $e');
      rethrow;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await event.doc(eventId).delete();
    } catch (e) {
      print('Error deleting event: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getEvents() async {
    try {
      QuerySnapshot snapshot = await event.get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching events: $e');
      rethrow;
    }
  }
}
