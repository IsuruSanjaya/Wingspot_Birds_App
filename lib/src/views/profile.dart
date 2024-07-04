import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wingspot/src/views/logintype.dart';
import '../controllers/FirestoreService.dart'; // Adjust the import path as needed
import '../controllers/AuthService.dart'; // Import your AuthService

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService(); // Instantiate AuthService
  Map<String, dynamic>? userData;
  late String userId; // Declare userId variable

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getUserId().then((id) {
      if (id != null) {
        setState(() {
          userId = id;
        });
        _loadUserData(userId);
      } else {
        // Handle the case when userId is not available
        print("User ID is not available.");
      }
    });
  }

  Future<void> _loadUserData(String userId) async {
    try {
      Map<String, dynamic>? data = await _firestoreService.getUserData(userId);
      setState(() {
        userData = data;
      });
    } catch (e) {
      print("Error loading user data: $e");
      // Handle error as needed (e.g., show error message)
    }
  }

  Future<String?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> _logout() async {
    try {
      await _authService.logout();
      // Clear the saved userId from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');

      // Navigate to login screen after logout
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                Logintype()), // Replace with your login screen widget
      );
    } catch (e) {
      print("Error logging out: $e");
      // Handle error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(userData!['imageUrl']),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    userData!['username'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Name'),
                    subtitle: Text(userData!['name']),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email'),
                    subtitle: Text(userData!['email']),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('Mobile'),
                    subtitle: Text(userData!['mobileNo']),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red, // Red background color
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32.0,
                        vertical: 16.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.logout, size: 24), // Logout icon
                        SizedBox(width: 8),
                        Text('Logout', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
