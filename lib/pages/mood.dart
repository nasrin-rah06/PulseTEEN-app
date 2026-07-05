import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'memory_game.dart';
import 'petal_game.dart';

class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  String? selectedMood;
  bool saved = false;

  final List<Map<String, String>> moods = [
    {'emoji': '😊', 'label': 'Happy'},
    {'emoji': '😢', 'label': 'Sad'},
    {'emoji': '😤', 'label': 'Stressed'},
    {'emoji': '😐', 'label': 'Neutral'},
    {'emoji': '😴', 'label': 'Tired'},
    {'emoji': '😡', 'label': 'Angry'},
  ];

  void saveMood() async {
  if (selectedMood == null) return;
  final user = FirebaseAuth.instance.currentUser;
  final today = DateTime.now().toIso8601String().substring(0, 10);

  final existing = await FirebaseFirestore.instance
      .collection('mood_logs')
      .where('teen_id', isEqualTo: user?.uid)
      .get();

  final todayLogs = existing.docs.where((doc) =>
      doc.data()['date'].toString().substring(0, 10) == today).toList();

  if (todayLogs.length >= 3) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Limit reached! 😊'),
        content: const Text('You have logged your mood 3 times today. Come back tomorrow!'),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return;
  }

  await FirebaseFirestore.instance.collection('mood_logs').add({
    'teen_id': user?.uid,
    'mood': selectedMood,
    'date': DateTime.now().toIso8601String(),
  });
  setState(() => saved = true);

  if (selectedMood == 'Stressed' || selectedMood == 'Sad' || selectedMood == 'Angry') {
    Future.delayed(const Duration(milliseconds: 500), () {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Take a Mindful Break 🌿'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You seem to be feeling low. Try one of these:'),
              SizedBox(height: 12),
              Text('✏️  Doodle or draw something'),
              Text('📓  Write in your journal'),
              Text('🧘  Do some light stretches'),
              Text('🎮  Play a quick memory game'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Maybe later'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MemoryGamePage()));
              },
              child: const Text('Play Memory Game 🧠'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade300,
                  foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const HangmanGamePage()));
              },
              child: const Text('Play Petal Drop 🌸'),
            ),
          ],
        ),
      );
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Check-in'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How are you feeling today?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: moods.map((mood) {
                bool isSelected = selectedMood == mood['label'];
                return GestureDetector(
                  onTap: () => setState(() => selectedMood = mood['label']),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.deepPurple.shade100
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected
                          ? Border.all(color: Colors.deepPurple, width: 2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(mood['emoji']!,
                            style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 6),
                        Text(mood['label']!,
                            style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            if (saved)
              const Center(
                child: Text('Mood saved! ✅',
                    style: TextStyle(color: Colors.green, fontSize: 16)),
              ),
            if (!saved)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: saveMood,
                  child: const Text('Save Mood'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}