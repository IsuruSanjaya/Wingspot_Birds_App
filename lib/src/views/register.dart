import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wingspot/src/views/home.dart';

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

  File? _image;
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
    setState(() {
      _isLoading = true;
    });

    final String name = _nameController.text.trim();
    final String mobileNo = _mobileNoController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String username = _usernameController.text.trim();

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      String? imageUrl;

      if (_image != null) {
        // Upload image to Firebase Storage
        final storageRef = FirebaseStorage.instance.ref().child('user_images').child('${userCredential.user!.uid}.jpg');
        await storageRef.putFile(_image!);

        // Get download URL of the uploaded image
        imageUrl = await storageRef.getDownloadURL();
      }

      // Save user data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'mobileNo': mobileNo,
        'email': email,
        'username': username,
        'imageUrl': imageUrl, // Store the download URL
        // Add other fields here
      });

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
        MaterialPageRoute(builder: (context) => HomeScreen()),
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
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/loginu.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Transparent overlay
          Container(
            color: Colors.white.withOpacity(0.5), // Semi-transparent white color
          ),
          Center(
            child: AbsorbPointer(
              absorbing: _isLoading, // Disable screen interaction while loading
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _mobileNoController,
                        decoration: InputDecoration(
                          labelText: 'Mobile No',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      _image == null
                          ? SizedBox(
                              width: double.infinity, // Make button full width
                              child: ElevatedButton(
                                onPressed: _getImage,
                                style: ElevatedButton.styleFrom(
                                  primary: Color.fromARGB(255, 231, 44, 44), // Light green color
                                ),
                                child: Text('Add Image'),
                              ),
                            )
                          : Image.file(
                              _image!,
                              height: 150,
                            ),
                      SizedBox(height: 80),
                      SizedBox(
                        width: double.infinity,
                        height: 50, // Make button full width
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            primary: Colors.lightGreen,
                            foregroundColor: Colors.white // Light green color
                          ),
                          child: Text('Register'),
                        ),
                      ),
                    ],

                  ),
                ),
              ),
            ),
          ),
          if (_isLoading) // Show loader if isLoading is true
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
