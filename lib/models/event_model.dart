import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Participant {
  final String userId;
  final double amountOwed;
  bool isSettled;

  Participant({
    required this.userId,
    required this.amountOwed,
    this.isSettled = false,
  });

  Map<String, dynamic> toMap() {
    return {'userId': userId, 'amountOwed': amountOwed, 'isSettled': isSettled};
  }

  factory Participant.fromMap(Map<String, dynamic> map) {
    return Participant(
      userId: map['userId'] ?? '',
      amountOwed: (map['amountOwed'] as num?)?.toDouble() ?? 0.0,
      isSettled: map['isSettled'] ?? false,
    );
  }
}

class Event {
  final String id;
  final String eventName;
  final Timestamp createdAt;
  final double totalAmount;
  final String payerId;
  final List<Participant> participants;

  Event({
    required this.id,
    required this.eventName,
    required this.createdAt,
    required this.totalAmount,
    required this.payerId,
    required this.participants,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventName': eventName,
      'createdAt': createdAt,
      'totalAmount': totalAmount,
      'payerId': payerId,
      'participants': participants.map((p) => p.toMap()).toList(),
    };
  }

  factory Event.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError('Missing data for EventId: ${snapshot.id}');
    }

    final List<dynamic> participantsData =
        data['participants'] as List<dynamic>? ?? [];
    final List<Participant> participantsList =
        participantsData
            .map(
              (pData) => Participant.fromMap(pData as Map<String, dynamic>),
            ) // Pemanggilan Participant.fromMap
            .toList();
    return Event(
      id: snapshot.id, // Ambil ID dokumen
      eventName: data['eventName'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      payerId: data['payerId'] ?? '',
      participants: participantsList,
    );
  }
}
