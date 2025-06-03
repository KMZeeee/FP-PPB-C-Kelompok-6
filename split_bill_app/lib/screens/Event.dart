import 'package:flutter/material.dart';
import 'package:split_bill_app/services/firestore.dart';

class Event extends StatefulWidget {
  const Event({super.key});

  @override
  State<Event> createState() => _EventState();
}

class _EventState extends State<Event> {
  List<Map<String, dynamic>> events = [];

  void fetchdata() {
    FirestoreService firestoreService = FirestoreService();
    setState(() async {
      events = await firestoreService.getEvents();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchdata();
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    return Scaffold(
      appBar: AppBar(title: Text('Event Screen'), backgroundColor: Colors.blue),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: Text('Event 1'),
              subtitle: Text('Date: 2023-10-01'),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // Navigate to event details
              },
            ),
            ListTile(
              title: Text('Event 2'),
              subtitle: Text('Date: 2023-10-02'),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // Navigate to event details
              },
            ),
            // Add more ListTiles for other events
          ],
        ),
      ),
    );
  }
}
