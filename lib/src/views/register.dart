import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wingspot/src/views/home.dart';
import 'package:wingspot/src/views/login.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  File? _image, profileImg;
  String? profileImgBase64;

  bool _isLoading = false; // Track loading state

  Future<void> _getImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> _register() async {
    // Set loading state to true

    final String name = _nameController.text.trim();
    final String mobileNo = _mobileNoController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String username = _usernameController.text.trim();

    // Check if any field is empty
    if (name.isEmpty ||
        mobileNo.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        username.isEmpty) {
      // Show error message
      Fluttertoast.showToast(
        msg: 'Please fill all the fields',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      String? imageUrl;

      if (_image != null) {
        // Upload image to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredential.user!.uid}.jpg');
        await storageRef.putFile(_image!);

        // Get download URL of the uploaded image
        imageUrl = await storageRef.getDownloadURL();
      }

      // Save user data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': name,
        'mobileNo': mobileNo,
        'email': email,
        'username': username,
        // 'evidence': profileImg,
        'imageUrl': imageUrl, // Store the download URL
        'flag': 0,
        'role': 'user' // Add the flag field
        // Add other fields here
      });

      // Call additional API to save user data to MongoDB
      final response = await http.post(
        Uri.parse(
            'https://wingspotbackend-dzc0anehbyfzg7a9.eastus-01.azurewebsites.net/requests/create/req'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'mobile': mobileNo,
          'email': email,
          'username': username,
          'image': imageUrl ?? '',
          'flag': '0',
          'password': password,
        }),
      );

      // Show success message
      Fluttertoast.showToast(
        msg: 'Registration successful',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Navigate to home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      // Show error message
      Fluttertoast.showToast(
        msg: 'Registration failed',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      // Set loading state to false after registration process is completed
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/register.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Transparent overlay
          // Container(
          //   color:
          //       Colors.white.withOpacity(0.5), // Semi-transparent white color
          // ),
          Center(
            child: AbsorbPointer(
              absorbing: _isLoading, // Disable screen interaction while loading
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      _image == null
                          ? GestureDetector(
                              onTap: _getImage,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey[300],
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: _getImage,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundImage: FileImage(_image!),
                              ),
                            ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _mobileNoController,
                        decoration: InputDecoration(
                          labelText: 'Mobile No',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // profileImg == null
                      //     ? SizedBox(
                      //         width: double.infinity, // Make button full width
                      //         child: ElevatedButton(
                      //           onPressed: _getPImage,
                      //           style: ElevatedButton.styleFrom(
                      //             primary: Color.fromARGB(
                      //                 255, 231, 44, 44), // Light green color
                      //           ),
                      //           child: Text('NIC Image'),
                      //         ),
                      //       )
                      //     : Image.file(
                      //         profileImg!,
                      //         height: 100,
                      //       ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 50, // Make button full width
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                              primary: Color.fromARGB(255, 28, 87, 2),
                              foregroundColor: Colors.white // Light green color
                              ),
                          child: const Text('Register'),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) =>
                                    const LoginScreen()), // Replace with your register screen
                          );
                        },
                        child: Text(
                          "ALREADY HAVE AN ACCOUNT? SIGN IN",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading) // Show loader if isLoading is true
            Container(
              color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
