import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user
  User? get currentUser => _auth.currentUser;

  // Stream to listen for authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login with email and password
  Future<UserCredential?> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      print('Error logging in: $e');
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error logging out: $e');
    }
  }
}
