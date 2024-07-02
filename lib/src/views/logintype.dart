import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wingspot/src/views/login.dart';

class Logintype extends StatelessWidget {
  const Logintype({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/Login3.png'), // Path to your background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Buttons
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: SizedBox(
                  width: double.infinity, // Full width
                  height: 50, // Set the height as desired
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) =>
                                LoginScreen()), // Replace with your home screen
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors
                          .lightGreenAccent[700], // Set the background color
                    ),
                    child: const Text(
                      'User',
                      style: TextStyle(fontSize: 18), // Set the font size
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Add some space between the buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: SizedBox(
                  width: double.infinity, // Full width
                  height: 50, // Set the height as desired
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      primary: Colors
                          .lightGreenAccent[700], // Set the background color
                    ),
                    child: const Text(
                      'Admin',
                      style: TextStyle(fontSize: 18), // Set the font size
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40), // Add space at the bottom
            ],
          ),
        ],
      ),
    );
  }
}
