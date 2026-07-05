import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'login.dart';
import 'mood.dart';
import 'sleep.dart';
import 'water.dart';
import 'meals.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String todayMood = '';
  double todaySleep = 0;
  int todayWater = 0;
  bool todayMealsLogged = false;
  bool todayBreakfast = false;
  bool todayLunch = false;
  bool todayDinner = false;
  int moodCount = 0;

  @override
  void initState() {
    super.initState();
    loadTodayLogs();
  }

  void loadTodayLogs() async {
    final user = FirebaseAuth.instance.currentUser;
    final today = DateTime.now().toIso8601String().substring(0, 10);

    // Mood
    final moodSnap = await FirebaseFirestore.instance
        .collection('mood_logs')
        .where('teen_id', isEqualTo: user?.uid)
        .get();
    final todayMoods = moodSnap.docs.where((d) =>
        d.data()['date'].toString().substring(0, 10) == today).toList();
    if (todayMoods.isNotEmpty) {
      setState(() {
        todayMood = todayMoods.last.data()['mood'];
        moodCount = todayMoods.length;
      });
    }

    // Sleep
    final sleepSnap = await FirebaseFirestore.instance
        .collection('sleep_logs')
        .where('teen_id', isEqualTo: user?.uid)
        .get();
    final todaySleeps = sleepSnap.docs.where((d) =>
        d.data()['date'].toString().substring(0, 10) == today).toList();
    if (todaySleeps.isNotEmpty) {
      setState(() => todaySleep =
          (todaySleeps.last.data()['hours'] as num).toDouble());
    }

    // Water
    final waterSnap = await FirebaseFirestore.instance
        .collection('water_logs')
        .where('teen_id', isEqualTo: user?.uid)
        .get();
    final todayWaters = waterSnap.docs.where((d) =>
        d.data()['date'].toString().substring(0, 10) == today).toList();
    if (todayWaters.isNotEmpty) {
      setState(() =>
          todayWater = todayWaters.last.data()['glasses'] as int);
    }

    // Meals
    final mealSnap = await FirebaseFirestore.instance
        .collection('meal_logs')
        .where('teen_id', isEqualTo: user?.uid)
        .get();
    final todayMeals = mealSnap.docs.where((d) =>
        d.data()['date'].toString().substring(0, 10) == today).toList();
    if (todayMeals.isNotEmpty) {
      final data = todayMeals.last.data();
      setState(() {
        todayMealsLogged = true;
        todayBreakfast = data['breakfast'] == true;
        todayLunch = data['lunch'] == true;
        todayDinner = data['dinner'] == true;
      });
    } else {
      setState(() {
        todayMealsLogged = false;
        todayBreakfast = false;
        todayLunch = false;
        todayDinner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('PulseTEEN'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => loadTodayLogs(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Good day! 👋',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('How are you doing today?',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 24),

              // Today's summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Today's Log",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _summaryRow('😊 Mood',
                        todayMood.isEmpty
                            ? 'Not logged'
                            : '$todayMood ($moodCount/3)'),
                    _summaryRow('😴 Sleep',
                        todaySleep == 0
                            ? 'Not logged'
                            : '$todaySleep hrs'),
                    _summaryRow('💧 Water',
                        todayWater == 0
                            ? 'Not logged'
                            : '$todayWater glasses'),
                    const SizedBox(height: 4),
                    const Text('🍽️ Meals',
                        style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 6),
                    if (!todayMealsLogged)
                      const Text('Not logged',
                          style: TextStyle(
                              fontSize: 13, color: Colors.red))
                    else
                      Row(
                        children: [
                          _mealChip('🍳 Breakfast', todayBreakfast),
                          const SizedBox(width: 6),
                          _mealChip('🍱 Lunch', todayLunch),
                          const SizedBox(width: 6),
                          _mealChip('🍽️ Dinner', todayDinner),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text('Log your habits',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildCard(context, '😊 Mood', 'Log your mood',
                      Colors.purple.shade100, () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MoodPage()));
                    loadTodayLogs();
                  }),
                  _buildCard(context, '😴 Sleep', 'Track sleep',
                      Colors.blue.shade100, () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SleepPage()));
                    loadTodayLogs();
                  }),
                  _buildCard(context, '💧 Water', 'Log water intake',
                      Colors.cyan.shade100, () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WaterPage()));
                    loadTodayLogs();
                  }),
                  _buildCard(context, '🍽️ Meals', 'Track meals',
                      Colors.orange.shade100, () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MealsPage()));
                    loadTodayLogs();
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: value.contains('Not logged')
                      ? Colors.red.shade300
                      : Colors.deepPurple)),
        ],
      ),
    );
  }

  Widget _mealChip(String label, bool eaten) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: eaten ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11,
            color: eaten
                ? Colors.green.shade700
                : Colors.red.shade700),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, String subtitle,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 13, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}