import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:split_bill_app/models/event_model.dart';
import 'package:split_bill_app/services/firestore.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    fetchUserName();
    _saveNewBillExample();
    _loadUserEvents();
  }

  final FirestoreService _firestoreService = FirestoreService();

  String? _name;
  String? _email;
  // String? _friends;

  void _saveNewBillExample() async {
    String currentUserId = user!.uid; // Ganti dengan UID pengguna yang membayar

    // Buat daftar partisipan
    List<Participant> participantsForNewBill = [
      Participant(
        userId: 'ksFrPghZJJhgXDzzk39jPLBgD5p2',
        amountOwed: 25000,
        isSettled: false,
      ),
      Participant(
        userId: 'Hq1tN6s3XAPQQlhQ27EmiqDK0g33',
        amountOwed: 25000,
        isSettled: false,
      ),
      Participant(
        userId: 'hBq1pi7NxXOzCw3BmkZ84KnwG082',
        amountOwed: 25000,
        isSettled: false,
      ),
    ];
    double billTotalAmount = 75000.0;
    Event newBill = Event(
      id: '',
      eventName: 'Test',
      createdAt: Timestamp.now(), // Waktu saat ini
      totalAmount: billTotalAmount,
      payerId: currentUserId,
      participants: participantsForNewBill,
    );

    // Panggil fungsi untuk menambahkan ke Firestore
    String? newEventId = await _firestoreService.addEventToFirestore(newBill);

    if (newEventId != null) {
      // Tampilkan pesan sukses atau navigasi ke halaman lain
      print('Tagihan baru berhasil disimpan dengan ID: $newEventId');
      // Contoh: ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tagihan berhasil disimpan!')));
    } else {
      print('Gagal menyimpan tagihan baru.');
    }
  }

  void fetchUserName() async {
    if (user != null) {
      final data = await _firestoreService.getPerson(user!.uid);
      if (data != null && mounted) {
        setState(() {
          _name = data['name'];
          _email = data['email'];
          // _friends = data['friends'] ?? '';
        });
      }
    }
  }

  void _loadAllEvents() async {
    List<Event> allEvents = await _firestoreService.getAllEvents();
    // Lakukan sesuatu dengan allEvents, misalnya tampilkan di UI
    for (var event in allEvents) {
      if (kDebugMode) {
        print(
          'Event ID: ${event.id}, Name: ${event.eventName}, Payer: ${event.payerId}',
        );
      }
    }
  }

  void _loadUserEvents() async {
    final user = FirebaseAuth.instance.currentUser;
    print('masuk sini ${user!.uid}');
    List<Event> eventsForUser = await _firestoreService.getEventsForUser(
      user!.uid,
    );
    print('Events for user ${user.uid}: ${eventsForUser.length}');
    // Lakukan sesuatu dengan eventsForUser
    for (var event in eventsForUser) {
      if (kDebugMode) {
        print(
          'User Event ID: ${event.id}, Name: ${event.eventName}, Payer: ${event.payerId}',
        );
        // Cek apakah user ini berhutang atau orang lain berhutang padanya
        if (event.payerId == user.uid) {
          print('  Anda adalah pembayar untuk event ini.');
          for (var p in event.participants) {
            if (!p.isSettled) {
              print('    - ${p.userId} berhutang ${p.amountOwed} kepada Anda.');
            }
          }
        } else {
          var myParticipation = event.participants.firstWhere(
            (p) => p.userId == user.uid,
            orElse:
                () => Participant(userId: '', amountOwed: 0, isSettled: true),
          ); // Handle jika tidak ketemu
          if (myParticipation.userId.isNotEmpty && !myParticipation.isSettled) {
            print(
              '  Anda berhutang ${myParticipation.amountOwed} kepada ${event.payerId} untuk event ini.',
            );
          } else if (myParticipation.userId.isNotEmpty &&
              myParticipation.isSettled) {
            print(
              '  Anda sudah melunasi hutang kepada ${event.payerId} untuk event ini.',
            );
          }
        }
      }
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacementNamed(context, '/login');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your account has been logged out!')),
    );
  }

  int size = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: size,
              itemBuilder: (context, index) {
                return ListTile(title: Text('Item $index'));
              },
            ),
          ),
        ],
      ),
      drawer: SafeArea(
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Color(0xff9ea8db)),
                accountName: Text(
                  '$_name',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                accountEmail: Text('$_email'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.black, size: 50),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
              ),
              ListTile(
                leading: const Icon(Icons.group),
                title: const Text('Friends'),
                onTap: () {
                  Navigator.pushNamed(context, '/friend');
                },
              ),
              ListTile(
                leading: const Icon(Icons.group),
                title: const Text('Inbox'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: logout,
              ),
              ListTile(
                leading: const Icon(Icons.group),
                title: const Text('Add Bill'),
                onTap: () {
                  Navigator.pushNamed(context, '/ocr');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
