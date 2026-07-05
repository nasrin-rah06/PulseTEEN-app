# PulseTEEN-app

Second Year College app-making project centered around adolescent well-being, involving caretaker monitoring.

## About

PulseTEEN is a Flutter-based wellness app built as a second-year CSE college project. It helps track adolescent wellness (mood, meals, sleep, water intake) and includes a caretaker dashboard for monitoring. Created in 2026.

## Tech Stack and Developing Environment

- Flutter / Dart
- Firebase (Firestore, Authentication)
- VSCode
- Android Emulator

## Features

- Mood tracking
- Meal, sleep, and water logging
- Caretaker dashboard for monitoring
- Caretaker allowed to edit meal and sleep details
- Interactive wellness games (memory game, petal game)

## Setup

This project uses Firebase (Firestore). Since Firebase config files are excluded from this repo for security, you'll need to:

1. Create a Firebase project at [https://console.firebase.google.com](https://console.firebase.google.com)
2. Enable Firestore
3. Run `flutterfire configure` in the project root to generate `lib/firebase_options.dart`
4. Add your `google-services.json` to `android/app/`
5. Run `flutter pub get`
6. Run `flutter run`

## Android Emulator

This project uses Android Emulator.
Setup Assistance: [Android Emulator](https://www.youtube.com/watch?v=fzJqHYjyA90)

## Getting Started with Flutter

If you're new to Flutter, these resources are useful:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)
