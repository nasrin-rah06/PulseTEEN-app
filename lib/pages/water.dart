import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WaterPage extends StatefulWidget {
  const WaterPage({super.key});

  @override
  State<WaterPage> createState() => _WaterPageState();
}

class _WaterPageState extends State<WaterPage> {
  int glasses = 0;
  bool saved = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTodayWater();
  }

  void loadTodayWater() async {
    final user = FirebaseAuth.instance.currentUser;
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final existing = await FirebaseFirestore.instance
        .collection('water_logs')
        .where('teen_id', isEqualTo: user?.uid)
        .get();

    final todayLogs = existing.docs.where((doc) =>
        doc.data()['date'].toString().substring(0, 10) == today).toList();

    if (todayLogs.isNotEmpty) {
      setState(() {
        glasses = todayLogs.last.data()['glasses'] as int;
        saved = true;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void saveWater() async {
    if (glasses == 0) return;
    final user = FirebaseAuth.instance.currentUser;
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final existing = await FirebaseFirestore.instance
        .collection('water_logs')
        .where('teen_id', isEqualTo: user?.uid)
        .get();

    final todayLogs = existing.docs.where((doc) =>
        doc.data()['date'].toString().substring(0, 10) == today).toList();

    if (todayLogs.isNotEmpty) {
      // Update existing log
      await FirebaseFirestore.instance
          .collection('water_logs')
          .doc(todayLogs.last.id)
          .update({
        'glasses': glasses,
        'date': DateTime.now().toIso8601String(),
      });
    } else {
      // Create new log
      await FirebaseFirestore.instance.collection('water_logs').add({
        'teen_id': user?.uid,
        'glasses': glasses,
        'date': DateTime.now().toIso8601String(),
      });
    }
    setState(() => saved = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Intake'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Tap the glasses you drank!',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    '$glasses / 8 glasses',
                    style: const TextStyle(
                        fontSize: 16, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 32),

                  // 8 glasses grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      final isFilled = index < glasses;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isFilled) {
                              glasses = index;
                            } else {
                              glasses = index + 1;
                            }
                            saved = false;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isFilled
                                ? Colors.blue.shade200
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isFilled
                                  ? Colors.blue.shade400
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isFilled ? '💧' : '🫙',
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isFilled
                                      ? Colors.blue.shade700
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Status message
                  Text(
                    glasses == 0
                        ? 'Tap a glass to log your water! 💧'
                        : glasses >= 8
                            ? 'Amazing! You hit your goal! 🎉'
                            : glasses >= 5
                                ? 'Good job! Keep drinking! 💪'
                                : 'Keep going! You can do it! 😊',
                    style: TextStyle(
                      fontSize: 14,
                      color: glasses >= 8
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (saved)
                    const Text('Water intake saved! ✅',
                        style:
                            TextStyle(color: Colors.green, fontSize: 16)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16)),
                      onPressed: saveWater,
                      child: const Text('Save Water Intake'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}