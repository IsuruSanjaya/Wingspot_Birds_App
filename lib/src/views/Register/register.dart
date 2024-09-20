import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wingspot/src/views/Login/login.dart';
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

  File? _image;
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
    final String name = _nameController.text.trim();
    final String mobileNo = _mobileNoController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String username = _usernameController.text.trim();

    if (name.isEmpty ||
        mobileNo.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        username.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please fill all the fields',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Convert image to base64 if available
      String base64Image = '';
      if (_image != null) {
        List<int> imageBytes = await _image!.readAsBytes();
        base64Image = base64Encode(imageBytes);
      }

      // Prepare the JSON payload
      final body = jsonEncode({
        'username': username,
        'password': password,
        'name': name,
        'mobile': mobileNo,
        'email': email,
        // 'image':
        //     base64Image, // Image is optional; send an empty string if not available
      });

      // Send POST request
      final response = await http.post(
        Uri.parse('http://52.220.37.106:8090/login/create/new'),
        headers: {'Content-Type': 'application/json'},
        body: body, // JSON body
      );

      // Handle response
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: 'Registration successful',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      } else {
        final decodedResponse = jsonDecode(response.body);
        Fluttertoast.showToast(
          msg: 'Registration failed',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'An error occurred',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
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
                                    const LoginScreen()), // Replace with your login screen
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
