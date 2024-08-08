import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final String? userId;

  const HomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<String> _imageUrls = [];
  String? _userId;
  String? _role;

  String _userName = 'Default Name'; // Initialized with a default value
  String _userImageUrl =
      'assets/images/hbird.png'; // Initialized with a default value

  @override
  void initState() {
    super.initState();
    _fetchImageUrls();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (widget.userId != null && widget.userId!.isNotEmpty) {
      _userId = widget.userId!;

      // Here you can call a function to load additional user data
      _loadAdditionalUserData(_userId);
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _userId = prefs.getString('userId');
        _role = prefs.getString('role');
        // Load other user data
        _loadAdditionalUserData(_userId);
      });
    }
  }

  void _loadAdditionalUserData(String? userId) async {
    if (userId == null || userId.isEmpty) {
      print('User ID is null or empty');
      return;
    }

    // Replace 'users' with your Firestore collection name and 'userId' with the actual user ID
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (snapshot.exists) {
      setState(() {
        var userData = snapshot.data();
        _userName = userData!['name'] ?? 'Default Name';
        _userImageUrl = userData['imageUrl'] ?? 'assets/images/hbird.png';
        _role = userData['role'] ?? 'user';
        // Update UI with fetched data
      });
    } else {
      print('Document does not exist');
    }
  }

  Future<void> _fetchImageUrls() async {
    try {
      final ListResult result =
          await FirebaseStorage.instance.ref().child('birds').listAll();

      final List<String> urls = await Future.wait(
          result.items.map((Reference ref) => ref.getDownloadURL()));
      setState(() {
        _imageUrls = urls;
      });
    } catch (e) {
      print('Error fetching image URLs: $e');
    }
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
                  backgroundImage: NetworkImage(_userImageUrl),
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
                const Spacer(),
                // Display a single bird image
                _imageUrls.isNotEmpty
                    ? const CircleAvatar(
                        backgroundImage: AssetImage('assets/images/hb.png'),
                        radius: 25,
                      )
                    : Container(), // Display an empty container or placeholder if _imageUrls is empty
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildTabButton('Categories'),
                const SizedBox(width: 10),
                _buildTabButton('New & Noteworthy'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildFeaturedGameCard(),
          const SizedBox(height: 20),
          _buildImageSlider(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        primary: const Color.fromARGB(255, 18, 71, 33),
        onPrimary: Colors.white,
        shape: const StadiumBorder(),
      ),
      child: Text(title),
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
                Image.network(
                  'https://encrypted-tbn0.gstatic.com/licensed-image?q=tbn:ANd9GcRy1-sy_4UzjKSwnTP8y2Lp_vVtcnGRvu4nEaNUuv0dgHSTZdvjg2vmqKpTk94HWPxmpjHiATjcLIae9F0qYU08OObujZDcBVv263MWZQN4U6uJ3LAUqujMDiKPhqfOBAz9Pb_6-o4R',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Row(
                    children: const [
                      Icon(Icons.apple, color: Colors.white),
                      SizedBox(width: 5),
                      Icon(Icons.android, color: Colors.white),
                      SizedBox(width: 5),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromARGB(255, 18, 71, 33),
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
                'Horizon Zero Dawn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Recommended because you played games tagged with...',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSlider() {
    if (_imageUrls.isEmpty) {
      return const Center(child: Text('No images found'));
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 200.0,
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
      ),
      items: _imageUrls.map((url) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: const BoxDecoration(
                color: Colors.amber,
              ),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  print('Error loading image: $exception');
                  return const Center(child: Icon(Icons.error));
                },
              ),
            );
          },
        );
      }).toList(),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (_role == 'user') {
      if (index == 1) {
        Navigator.pushNamed(context, '/chat');
      } else if (index == 2) {
        Navigator.pushNamed(context, '/profile', arguments: widget.userId);
      }
    } else if (_role == 'admin') {
      if (index == 1) {
        Navigator.pushNamed(context, '/admin');
      } else if (index == 2) {
        Navigator.pushNamed(context, '/chat');
      } else if (index == 3) {
        Navigator.pushNamed(context, '/profile', arguments: widget.userId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildHomePage(),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        role: _role,
      ),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final String? role;

  const CustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.role,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = role == 'user';
    final items = isUser
        ? [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chat',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ]
        : [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: 'Admin',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.comment),
              label: 'Community',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ];

    return BottomNavigationBar(
      items: items,
      currentIndex: selectedIndex,
      selectedItemColor: Colors.white, // White selected item color
      unselectedItemColor: Colors.white70, // White70 unselected item color
      backgroundColor:
          const Color.fromARGB(255, 18, 71, 33), // Green background color
      onTap: onItemTapped,
      type:
          BottomNavigationBarType.fixed, // Ensure fixed type to avoid shifting
    );
  }
}
