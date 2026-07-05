import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CaretakerMealsPage extends StatefulWidget {
  final String teenUid;
  const CaretakerMealsPage({super.key, required this.teenUid});

  @override
  State<CaretakerMealsPage> createState() => _CaretakerMealsPageState();
}

class _CaretakerMealsPageState extends State<CaretakerMealsPage> {
  void addMealDetails(String docId) {
    List<String> selected = [];
    final options = ['Vegetables', 'Meat', 'Egg', 'Fish', 'Junk food', 'Other'];
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Add Meal Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return CheckboxListTile(
                title: Text(option),
                value: selected.contains(option),
                activeColor: Colors.deepPurple,
                onChanged: (val) {
                  setStateDialog(() {
                    if (val == true) {
                      selected.add(option);
                    } else {
                      selected.remove(option);
                    }
                  });
                },
              );
            }).toList(),
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
                    .collection('meal_logs')
                    .doc(docId)
                    .update({'meal_details': selected});
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Logs'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('meal_logs')
            .where('teen_id', isEqualTo: widget.teenUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No meal logs yet.'));
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final date = data['date'].toString().substring(0, 10);
              final breakfast = data['breakfast'] == true ? '✅' : '❌';
              final lunch = data['lunch'] == true ? '✅' : '❌';
              final dinner = data['dinner'] == true ? '✅' : '❌';
              final details = data['meal_details'] != null
                  ? (data['meal_details'] as List).join(', ')
                  : 'No details yet';
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🍽️', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Text(date,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.add_circle,
                              color: Colors.deepPurple),
                          onPressed: () => addMealDetails(docs[index].id),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('🍳 Breakfast: $breakfast  '),
                        Text('🍱 Lunch: $lunch  '),
                        Text('🍽️ Dinner: $dinner'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Details: $details',
                        style: const TextStyle(
                            fontSize: 13, color: Colors.deepPurple)),
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