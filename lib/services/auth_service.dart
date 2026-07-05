import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> register(String email, String password, String role,
      String name, String teenUid) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(result.user!.uid)
          .set({
        'email': email,
        'role': role,
        'name': name,
        'uid': result.user!.uid,
        'teen_uid': teenUid,
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}