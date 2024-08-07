// import 'dart:js';

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:wingspot/src/views/home.dart';


//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _mobileNoController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _usernameController = TextEditingController();

// Future<void> _login() async {
//   try {
//     await FirebaseAuth.instance.signInWithEmailAndPassword(
//       email: _emailController.text.trim(),
//       password: _passwordController.text.trim(),
//     );
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(builder: (context) => HomeScreen(userId: '',)), // Replace with your home screen
//     );
//   } on FirebaseAuthException catch (e) {
//     if (e.code == 'user-not-found') {
//       print('No user found for that email.');
//     } else if (e.code == 'wrong-password') {
//       print('Wrong password provided.');
//     }
//   }
// }

// Future<void> _register() async {
//     // Set loading state to true
//     setState(() {
//       _isLoading = true;
//     });

//     final String name = _nameController.text.trim();
//     final String mobileNo = _mobileNoController.text.trim();
//     final String email = _emailController.text.trim();
//     final String password = _passwordController.text.trim();
//     final String username = _usernameController.text.trim();

//     try {
//       UserCredential userCredential = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(email: email, password: password);
//       String? imageUrl;

//       if (_image != null) {
//         // Upload image to Firebase Storage
//         final storageRef = FirebaseStorage.instance
//             .ref()
//             .child('user_images')
//             .child('${userCredential.user!.uid}.jpg');
//         await storageRef.putFile(_image!);

//         // Get download URL of the uploaded image
//         imageUrl = await storageRef.getDownloadURL();
//       }

//       // Save user data to Firestore
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userCredential.user!.uid)
//           .set({
//         'name': name,
//         'mobileNo': mobileNo,
//         'email': email,
//         'username': username,
//         'evidence': profileImg,
//         // 'imageUrl': imageUrl, // Store the download URL
//         'flag': 0,
//         'role': 'user' // Add the flag field
//         // Add other fields here
//       });

//       // Show success message
//       Fluttertoast.showToast(
//         msg: 'Registration successful',
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: Colors.green,
//         textColor: Colors.white,
//         fontSize: 16.0,
//       );

//       // Navigate to home screen
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(
//             builder: (context) => HomeScreen(
//                   userId: '',
//                 )),
//       );
//     } catch (e) {
//       // Show error message
//       Fluttertoast.showToast(
//         msg: 'Registration failed',
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//         fontSize: 16.0,
//       );
//     } finally {
//       // Set loading state to false after registration process is completed
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
