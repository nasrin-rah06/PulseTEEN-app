import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MealsPage extends StatefulWidget {
  const MealsPage({super.key});

  @override
  State<MealsPage> createState() => _MealsPageState();
}

class _MealsPageState extends State<MealsPage> {
  bool breakfast = false;
  bool lunch = false;
  bool dinner = false;
  bool saved = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTodayMeals();
  }

  void loadTodayMeals() async {
    final user = FirebaseAuth.instance.currentUser;
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final existing = await FirebaseFirestore.instance
        .collection('meal_logs')
        .where('teen_id', isEqualTo: user?.uid)
        .get();

    final todayLogs = existing.docs.where((doc) =>
        doc.data()['date'].toString().substring(0, 10) == today).toList();

    if (todayLogs.isNotEmpty) {
      final data = todayLogs.last.data();
      setState(() {
        breakfast = data['breakfast'] == true;
        lunch = data['lunch'] == true;
        dinner = data['dinner'] == true;
        saved = true;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void saveMeals() async {
    final user = FirebaseAuth.instance.currentUser;
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final existing = await FirebaseFirestore.instance
        .collection('meal_logs')
        .where('teen_id', isEqualTo: user?.uid)
        .get();

    if (existing.docs.where((doc) =>
        doc.data()['date'].toString().substring(0, 10) == today).length >= 3) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Already logged! 🍽️'),
          content: const Text('You have logged your meals 3 times today. Come back tomorrow!'),
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

    await FirebaseFirestore.instance.collection('meal_logs').add({
      'teen_id': user?.uid,
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'date': DateTime.now().toIso8601String(),
    });
    setState(() => saved = true);
  }

  Widget _mealTile(String meal, String emoji, String time, bool value,
      Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: value ? Colors.deepPurple.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: value ? Border.all(color: Colors.deepPurple, width: 1.5) : null,
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(meal,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Text(time,
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.deepPurple,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Tracking'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('What did you eat today?',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _mealTile('Breakfast', '🍳', 'Morning meal', breakfast,
                      (val) => setState(() => breakfast = val)),
                  _mealTile('Lunch', '🍱', 'Midday meal', lunch,
                      (val) => setState(() => lunch = val)),
                  _mealTile('Dinner', '🍽️', 'Evening meal', dinner,
                      (val) => setState(() => dinner = val)),
                  const SizedBox(height: 16),
                  if (saved)
                  const Center(
                    child: Text('Meals saved! ✅',
                    style: TextStyle(color: Colors.green, fontSize: 16)),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                          onPressed: saveMeals,
                          child: const Text('Update Meals'),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}