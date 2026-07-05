import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CaretakerWaterPage extends StatelessWidget {
  final String teenUid;
  const CaretakerWaterPage({super.key, required this.teenUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Logs'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('water_logs')
            .where('teen_id', isEqualTo: teenUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No water logs yet.'));
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final date = data['date'].toString().substring(0, 10);
              final glasses = data['glasses'];
              final color = glasses >= 8
                  ? Colors.green.shade100
                  : glasses >= 5
                      ? Colors.orange.shade100
                      : Colors.red.shade100;
              final status = glasses >= 8
                  ? 'Great hydration! 💧'
                  : glasses >= 5
                      ? 'Could drink more 💧'
                      : 'Low intake ⚠️';
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('💧', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(date,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('$glasses glasses',
                            style: const TextStyle(fontSize: 14)),
                        Text(status,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}