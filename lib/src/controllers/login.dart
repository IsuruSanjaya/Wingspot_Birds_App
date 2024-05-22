// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// Future<void> _login() async {
//   try {
//     await FirebaseAuth.instance.signInWithEmailAndPassword(
//       email: _emailController.text.trim(),
//       password: _passwordController.text.trim(),
//     );
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(builder: (context) => HomeScreen()), // Replace with your home screen
//     );
//   } on FirebaseAuthException catch (e) {
//     if (e.code == 'user-not-found') {
//       print('No user found for that email.');
//     } else if (e.code == 'wrong-password') {
//       print('Wrong password provided.');
//     }
//   }
// }
