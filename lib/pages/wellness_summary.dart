import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WellnessSummaryPage extends StatefulWidget {
  final String teenUid;
  const WellnessSummaryPage({super.key, required this.teenUid});

  @override
  State<WellnessSummaryPage> createState() => _WellnessSummaryPageState();
}

class _WellnessSummaryPageState extends State<WellnessSummaryPage> {
  double avgSleep = 0;
  double avgWater = 0;
  String moodSummary = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadSummary();
  }

  void loadSummary() async {
    // Sleep average
    final sleepSnap = await FirebaseFirestore.instance
        .collection('sleep_logs')
        .where('teen_id', isEqualTo: widget.teenUid)
        .get();
    if (sleepSnap.docs.isNotEmpty) {
      final total = sleepSnap.docs
          .map((d) => (d.data()['hours'] as num).toDouble())
          .reduce((a, b) => a + b);
      avgSleep = total / sleepSnap.docs.length;
    }

    // Water average
    final waterSnap = await FirebaseFirestore.instance
        .collection('water_logs')
        .where('teen_id', isEqualTo: widget.teenUid)
        .get();
    if (waterSnap.docs.isNotEmpty) {
      final total = waterSnap.docs
          .map((d) => (d.data()['glasses'] as num).toDouble())
          .reduce((a, b) => a + b);
      avgWater = total / waterSnap.docs.length;
    }

    // Mood summary
    final moodSnap = await FirebaseFirestore.instance
        .collection('mood_logs')
        .where('teen_id', isEqualTo: widget.teenUid)
        .get();
    if (moodSnap.docs.isNotEmpty) {
      final moods =
          moodSnap.docs.map((d) => d.data()['mood'].toString()).toList();
      final stressCount = moods
          .where((m) => m == 'Stressed' || m == 'Sad' || m == 'Angry')
          .length;
      if (stressCount >= 3) {
        moodSummary = 'Teen has been feeling low this week ⚠️';
      } else if (stressCount >= 1) {
        moodSummary = 'Some stress detected this week 😐';
      } else {
        moodSummary = 'Teen has been feeling good this week 😊';
      }
    } else {
      moodSummary = 'No mood data this week';
    }

    setState(() => loading = false);
  }

  Widget _summaryCard(String title, String value, String status,
      Color color, String emoji) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple)),
              Text(status,
                  style:
                      const TextStyle(fontSize: 13, color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness Summary'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('This Week\'s Overview',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _summaryCard(
                    'Average Sleep',
                    '${avgSleep.toStringAsFixed(1)} hrs',
                    avgSleep >= 8
                        ? 'Great sleep! 🌙'
                        : avgSleep >= 6
                            ? 'Sleep could be better'
                            : 'Sleep has been inconsistent ⚠️',
                    Colors.blue.shade100,
                    '😴',
                  ),
                  _summaryCard(
                    'Average Water',
                    '${avgWater.toStringAsFixed(1)} glasses',
                    avgWater >= 8
                        ? 'Well hydrated! 💧'
                        : avgWater >= 5
                            ? 'Could drink more water'
                            : 'Low water intake this week ⚠️',
                    Colors.cyan.shade100,
                    '💧',
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Text('😊', style: TextStyle(fontSize: 36)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Mood',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Text(moodSummary,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}