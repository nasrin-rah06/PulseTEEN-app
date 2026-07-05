import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CaretakerSleepPage extends StatefulWidget {
  final String teenUid;
  const CaretakerSleepPage({super.key, required this.teenUid});

  @override
  State<CaretakerSleepPage> createState() => _CaretakerSleepPageState();
}

class _CaretakerSleepPageState extends State<CaretakerSleepPage> {
  void editSleep(String docId, double currentHours) {
    final controller = TextEditingController(text: currentHours.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Sleep Hours'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Hours of sleep'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('sleep_logs')
                  .doc(docId)
                  .update({
                'hours': double.parse(controller.text),
                'edited_by_caretaker': true,
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Logs'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sleep_logs')
            .where('teen_id', isEqualTo: widget.teenUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No sleep logs yet.'));
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final date = data['date'].toString().substring(0, 10);
              final hours = data['hours'];
              final edited = data['edited_by_caretaker'] == true;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: edited
                      ? Border.all(color: Colors.deepPurple, width: 1.5)
                      : null,
                ),
                child: Row(
                  children: [
                    const Text('😴', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(date,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('$hours hours',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54)),
                        if (edited)
                          const Text('✏️ Edited by caretaker',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.deepPurple)),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.deepPurple),
                      onPressed: () =>
                          editSleep(docs[index].id, (hours as num).toDouble()),
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