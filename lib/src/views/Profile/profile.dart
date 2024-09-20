import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wingspot/src/views/Login/login.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? userData;
  String? _email;
  String? _mobileNo;
  String _userName = '';
  String _userImageUrl = 'assets/images/hbird.png'; // Default profile image

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _mobileNo = prefs.getString('mobile');
      _email = prefs.getString('email');
      _userName = prefs.getString('name') ?? 'Guest';
      _userImageUrl =
          prefs.getString('userImageUrl') ?? 'assets/images/hbird.png';

      // Populate userData map with values from SharedPreferences
      userData = {
        'username': _userName,
        'email': _email,
        'mobileNo': _mobileNo,
        '_userImageUrl': _userImageUrl,
      };
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _logout() async {
    try {
      // Assuming _authService.logout() is defined somewhere
      // Clear the saved userId from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('name');
      await prefs.remove('email');
      await prefs.remove('mobile');

      // Navigate to login screen after logout
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    } catch (e) {
      print("Error logging out: $e");
      // Handle error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/register.jpg'), // Path to your background image
            fit: BoxFit.cover,
          ),
        ),
        child: userData == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  const SizedBox(
                      height:
                          80), // Space between the top and the profile image

                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage(userData!['_userImageUrl']),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      userData!['username'],
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Image.asset(
                        'assets/images/user.png', // Replace with your image asset path
                        width: 28,
                        height: 28,
                      ),
                      title: const Text('Name'),
                      subtitle: Text(userData!['username']),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Image.asset(
                        'assets/images/gmail.png', // Replace with your image asset path
                        width: 24,
                        height: 24,
                      ),
                      title: const Text('Email'),
                      subtitle: Text(userData!['email'] ?? 'N/A'),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Image.asset(
                        'assets/images/phone-call.png', // Replace with your image asset path
                        width: 24,
                        height: 24,
                      ),
                      title: const Text('Mobile'),
                      subtitle: Text(userData!['mobileNo'] ?? 'N/A'),
                    ),
                  ),
                  const SizedBox(height: 80),
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
      ),
    );
  }
}
