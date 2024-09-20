import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen(
      {Key? key,
      required String name,
      required Uint8List image,
      required String mobile,
      required email})
      : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<String> _imageUrls = [
    'https://example.com/image1.jpg',
    'https://example.com/image2.jpg',
    'https://example.com/image3.jpg',
  ]; // Hardcoded image URLs
  String? _email;
  String? _mobileNo;

  String _userName = '';
  String _userImageUrl = 'assets/images/hbird.png'; // Hardcoded profile image

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _mobileNo = prefs.getString('mobile');
      _email = prefs.getString('email');
      _userName = prefs.getString('name') ?? 'Guest'; // Load the user's name
    });
  }

  Widget _buildAnalysisButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSquareButtonWithImageIcon(
                  'Bird Species Analysis',
                  'assets/images/dove.png',
                  const Color.fromARGB(255, 18, 71, 33), // Light opacity
                  () {
                    Navigator.pushNamed(context, '/birda');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSquareButtonWithImageIcon(
                  'Egg Behavior Analysis',
                  'assets/images/egg.png',
                  const Color.fromARGB(255, 18, 71, 33), // Light opacity
                  () {
                    // Navigator.pushNamed(context, '/eggAnalysis');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSquareButtonWithImageIcon(
                  'Lora Live Logs',
                  'assets/images/live-streaming.png',
                  const Color.fromARGB(255, 18, 71, 33), // Light opacity
                  () {
                    Navigator.pushNamed(context, '/loralogs');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSquareButtonWithImageIcon(
                  'Lora Log History',
                  'assets/images/refresh.png',
                  const Color.fromARGB(255, 18, 71, 33), // Light opacity
                  () {
                    Navigator.pushNamed(context, '/lorahistory');
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSquareButtonWithImageIcon(
      String title, String imagePath, Color color, VoidCallback onPressed) {
    return SizedBox(
      height: 100.0, // Adjust height to make it square
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ImageIcon(
              AssetImage(imagePath),
              size: 30.0,
              color: Colors.white,
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(_userImageUrl),
                  radius: 25,
                ),
                const SizedBox(width: 10),
                Text(
                  'Welcome $_userName!',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildFeaturedGameCard(),
          const SizedBox(height: 20),
          _buildAnalysisButtons(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFeaturedGameCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/images/red2.png',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 18, 71, 33),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Birds'),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Red Wattled Lapwing',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'The red-wattled lapwing is an Asian lapwing or large plover, a wader in the family Charadriidae.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.pushNamed(context, '/chat');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/lora');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildHomePage(),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      // const BottomNavigationBarItem(
      //   icon: Icon(Icons.admin_panel_settings),
      //   label: 'Admin',
      // ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.comment),
        label: 'Community',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.private_connectivity_rounded),
        label: 'Lora',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];

    return BottomNavigationBar(
      items: items,
      currentIndex: selectedIndex,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      backgroundColor: const Color.fromARGB(255, 18, 71, 33),
      onTap: onItemTapped,
      type: BottomNavigationBarType.fixed,
    );
  }
}
