import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  State<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  double sleepHours = 7.0;
  bool saved = false;

  void onPanUpdate(DragUpdateDetails details, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final position = details.localPosition;
    final angle = atan2(position.dy - center.dy, position.dx - center.dx);
    double hours = (angle + pi / 2) / (2 * pi) * 12;
    if (hours < 0) hours += 12;
    setState(() => sleepHours = double.parse(hours.toStringAsFixed(1)));
  }

  void saveSleep() async {
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('sleep_logs').add({
      'teen_id': user?.uid,
      'hours': sleepHours,
      'date': DateTime.now().toIso8601String(),
      'edited_by_caretaker': false,
    });
    setState(() => saved = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Tracking'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('How many hours did you sleep?',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),

            // Clock slider
            LayoutBuilder(builder: (context, constraints) {
              final size = Size(constraints.maxWidth, 300);
              return GestureDetector(
                onPanUpdate: (d) => onPanUpdate(d, size),
                child: CustomPaint(
                  size: size,
                  painter: ClockPainter(sleepHours),
                ),
              );
            }),

            const SizedBox(height: 24),
            Text(
              '${sleepHours.toStringAsFixed(1)} hours',
              style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple),
            ),
            const SizedBox(height: 8),
            Text(
              sleepHours >= 8
                  ? 'Great sleep! 🌙'
                  : sleepHours >= 6
                      ? 'Could be better 😴'
                      : 'Too little sleep ⚠️',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            if (saved)
              const Text('Sleep logged! ✅',
                  style: TextStyle(color: Colors.green, fontSize: 16)),
            if (!saved)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: saveSleep,
                  child: const Text('Save Sleep'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  final double sleepHours;
  ClockPainter(this.sleepHours);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = min(cx, cy) - 20;

    // Background circle
    canvas.drawCircle(
      Offset(cx, cy),
      radius,
      Paint()..color = Colors.deepPurple.shade50,
    );

    // Arc
    final arcAngle = (sleepHours / 12) * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius - 10),
      -pi / 2,
      arcAngle,
      false,
      Paint()
        ..color = Colors.deepPurple
        ..strokeWidth = 16
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Hour markers
    for (int i = 1; i <= 12; i++) {
      final angle = (i / 12) * 2 * pi - pi / 2;
      final x = cx + (radius - 30) * cos(angle);
      final y = cy + (radius - 30) * sin(angle);
      final textPainter = TextPainter(
        text: TextSpan(
          text: '$i',
          style: const TextStyle(color: Colors.deepPurple, fontSize: 14),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
          canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
    }

    // Handle dot
    final handleAngle = (sleepHours / 12) * 2 * pi - pi / 2;
    final hx = cx + (radius - 10) * cos(handleAngle);
    final hy = cy + (radius - 10) * sin(handleAngle);
    canvas.drawCircle(
      Offset(hx, hy),
      14,
      Paint()..color = Colors.deepPurple,
    );
    canvas.drawCircle(
      Offset(hx, hy),
      8,
      Paint()..color = Colors.white,
    );

    // Center text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${sleepHours.toStringAsFixed(1)}h',
        style: const TextStyle(
            color: Colors.deepPurple,
            fontSize: 28,
            fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(cx - textPainter.width / 2, cy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(ClockPainter old) => old.sleepHours != sleepHours;
}