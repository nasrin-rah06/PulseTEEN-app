import 'package:flutter/material.dart';
import 'dart:math';

class HangmanGamePage extends StatefulWidget {
  const HangmanGamePage({super.key});

  @override
  State<HangmanGamePage> createState() => _HangmanGamePageState();
}

class _HangmanGamePageState extends State<HangmanGamePage> {
  final Map<String, List<String>> categories = {
    'Fruits': ['apple', 'banana', 'cherry', 'orange', 'grape', 'watermelon', 'kiwi', 'strawberry'],
    'Animals': ['horse', 'koala', 'elephant', 'duck', 'hippopotamus', 'crocodile', 'lion', 'cheetah'],
    'Programming': ['list', 'string', 'dictionary', 'syntax', 'variable', 'function', 'identifier'],
  };

  String selectedCategory = '';
  String wordToGuess = '';
  Set<String> guessedLetters = {};
  int attemptsLeft = 5;
  int score = 0;
  final controller = TextEditingController();

  void selectCategory(String category) {
    final words = categories[category]!;
    setState(() {
      selectedCategory = category;
      wordToGuess = words[Random().nextInt(words.length)];
      guessedLetters = {};
      attemptsLeft = 5;
      controller.clear();
    });
  }

  String displayWord() {
    return wordToGuess.split('').map((l) => guessedLetters.contains(l) ? l : '_').join(' ');
  }

  void makeGuess() {
    final guess = controller.text.toLowerCase().trim();
    controller.clear();

    if (guess.length != 1 || !RegExp(r'[a-z]').hasMatch(guess)) {
      showMessage('Invalid', 'Please enter a single letter.');
      return;
    }
    if (guessedLetters.contains(guess)) {
      showMessage('Duplicate', 'You already guessed that letter!');
      return;
    }

    setState(() {
      guessedLetters.add(guess);
      if (!wordToGuess.contains(guess)) {
        attemptsLeft--;
      }
    });

    if (attemptsLeft == 0) {
      showMessage('Game Over 😢', 'The word was: $wordToGuess', isEnd: true);
    } else if (!displayWord().contains('_')) {
      setState(() => score += 10);
      showMessage('You won! 🎉', 'You guessed "$wordToGuess"!\nScore: $score', isWin: true);
    }
  }

  void showMessage(String title, String msg, {bool isEnd = false, bool isWin = false}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              if (isEnd || isWin) selectCategory(selectedCategory);
            },
            child: Text(isEnd || isWin ? 'Play Again' : 'OK'),
          ),
        ],
      ),
    );
  }

  Widget buildFlower() {
    return SizedBox(
      height: 180,
      child: CustomPaint(
        painter: FlowerPainter(attemptsLeft),
        child: Container(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Petal Drop 🌸'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Score
            Align(
              alignment: Alignment.centerRight,
              child: Text('Score: $score',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                      color: Colors.deepPurple)),
            ),
            const SizedBox(height: 8),

            // Category buttons
            const Text('Choose a category:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: categories.keys.map((cat) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedCategory == cat
                          ? Colors.deepPurple
                          : Colors.deepPurple.shade100,
                      foregroundColor: selectedCategory == cat
                          ? Colors.white
                          : Colors.deepPurple,
                    ),
                    onPressed: () => selectCategory(cat),
                    child: Text(cat, style: const TextStyle(fontSize: 12)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Flower
            buildFlower(),
            const SizedBox(height: 8),
            Text('Petals left: $attemptsLeft',
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),

            // Word display
            wordToGuess.isEmpty
                ? const Text('Select a category to start!',
                    style: TextStyle(fontSize: 16, color: Colors.grey))
                : Text(displayWord(),
                    style: const TextStyle(fontSize: 28,
                        fontWeight: FontWeight.bold, letterSpacing: 6)),
            const SizedBox(height: 24),

            // Guessed letters
            if (guessedLetters.isNotEmpty)
              Text('Guessed: ${guessedLetters.join(', ')}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 16),

            // Input
            if (wordToGuess.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: controller,
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'A',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16)),
                    onPressed: makeGuess,
                    child: const Text('Guess'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class FlowerPainter extends CustomPainter {
  final int petalsLeft;
  FlowerPainter(this.petalsLeft);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Stem
    final stemPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx, cy + 20), Offset(cx, cy + 80), stemPaint);

    // Center
    final centerPaint = Paint()..color = Colors.yellow;
    canvas.drawCircle(Offset(cx, cy), 18, centerPaint);

    // Petals
    final petalPaint = Paint()..color = Colors.blue.shade300;
    final angles = [0, 60, 120, 180, 240, 300];
    for (int i = 0; i < petalsLeft; i++) {
      final angle = angles[i] * pi / 180;
      final px = cx + 35 * cos(angle);
      final py = cy + 35 * sin(angle);
      canvas.drawCircle(Offset(px, py), 14, petalPaint);
    }
  }

  @override
  bool shouldRepaint(FlowerPainter old) => old.petalsLeft != petalsLeft;
}