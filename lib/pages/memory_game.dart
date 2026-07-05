import 'package:flutter/material.dart';
import 'dart:async';

class MemoryGamePage extends StatefulWidget {
  const MemoryGamePage({super.key});

  @override
  State<MemoryGamePage> createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> {
  final List<String> emojis = ['🌸', '🌟', '🎵', '🌈', '🦋', '🍀'];
  late List<String> cards;
  List<int> flipped = [];
  List<int> matched = [];
  bool checking = false;
  int moves = 0;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    final doubled = [...emojis, ...emojis];
    doubled.shuffle();
    setState(() {
      cards = doubled;
      flipped = [];
      matched = [];
      moves = 0;
      checking = false;
    });
  }

  void onTap(int index) {
    if (checking) return;
    if (flipped.contains(index)) return;
    if (matched.contains(index)) return;

    setState(() => flipped.add(index));

    if (flipped.length == 2) {
      checking = true;
      moves++;
      if (cards[flipped[0]] == cards[flipped[1]]) {
        setState(() {
          matched.addAll(flipped);
          flipped = [];
          checking = false;
        });
        if (matched.length == cards.length) {
          Future.delayed(const Duration(milliseconds: 500), () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('You won! 🎉'),
                content: Text('Completed in $moves moves!'),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                      startGame();
                    },
                    child: const Text('Play Again'),
                  ),
                ],
              ),
            );
          });
        }
      } else {
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            flipped = [];
            checking = false;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Game 🧠'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: startGame,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text('Moves: $moves',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold,
                    color: Colors.deepPurple)),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final isFlipped = flipped.contains(index) ||
                      matched.contains(index);
                  return GestureDetector(
                    onTap: () => onTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: isFlipped
                            ? Colors.deepPurple.shade100
                            : Colors.deepPurple,
                        borderRadius: BorderRadius.circular(12),
                        border: matched.contains(index)
                            ? Border.all(color: Colors.green, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          isFlipped ? cards[index] : '?',
                          style: TextStyle(
                            fontSize: 36,
                            color: isFlipped ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}