import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'login.dart';
import 'caretaker_sleep.dart';
import 'caretaker_meal.dart';
import 'caretaker_water.dart';
import 'wellness_summary.dart';

class CaretakerDashboard extends StatefulWidget {
  const CaretakerDashboard({super.key});

  @override
  State<CaretakerDashboard> createState() => _CaretakerDashboardState();
}

class _CaretakerDashboardState extends State<CaretakerDashboard> {
  String teenName = '';
  String teenUid = '';
  String teenEmail = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadTeenInfo();
  }

  void loadTeenInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();

    final tUid = doc.data()?['teen_uid'] ?? '';

    if (tUid.isNotEmpty) {
      final teenDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(tUid)
          .get();
      setState(() {
        teenName = teenDoc.data()?['name'] ?? 'Unknown';
        teenEmail = teenDoc.data()?['email'] ?? '';
        teenUid = tUid;
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Caretaker Dashboard'),
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
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Welcome, Caretaker! 👋',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Teen info card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: teenUid.isEmpty
                        ? const Text('No teen linked to this account.',
                            style: TextStyle(color: Colors.red))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Linked Teen',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey)),
                              const SizedBox(height: 6),
                              Text(teenName,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple)),
                              const SizedBox(height: 4),
                              Text(teenEmail,
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text('UID: $teenUid',
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                  ),
                  const SizedBox(height: 24),

                  if (teenUid.isNotEmpty) ...[
                    _buildCard('😴 Sleep', 'Edit sleep hours',
                        Colors.blue.shade100, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  CaretakerSleepPage(teenUid: teenUid)));
                    }),
                    const SizedBox(height: 16),
                    _buildCard('💧 Water', 'View water intake',
                        Colors.cyan.shade100, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  CaretakerWaterPage(teenUid: teenUid)));
                    }),
                    const SizedBox(height: 16),
                    _buildCard('🍽️ Meals', 'Review meal details',
                        Colors.orange.shade100, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  CaretakerMealsPage(teenUid: teenUid)));
                    }),
                    const SizedBox(height: 16),
                    _buildCard('📊 Summary', 'View wellness summary',
                        Colors.purple.shade100, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  WellnessSummaryPage(teenUid: teenUid)));
                    }),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildCard(
      String title, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle,
                style:
                    const TextStyle(fontSize: 13, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}