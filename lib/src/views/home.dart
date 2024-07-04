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
  String _userName = 'Default Name'; // Initialized with a default value
  String _userImageUrl =
      'default_image_url.png'; // Initialized with a default value

  @override
  void initState() {
    super.initState();
    _fetchImageUrls();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (widget.userId != null) {
      _userId = widget.userId;
      // Here you can call a function to load additional user data
      _loadAdditionalUserData();
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _userId = prefs.getString('userId');
        // Load other user data
        _loadAdditionalUserData();
      });
    }
  }

  void _loadAdditionalUserData() async {
    // Replace 'users' with your Firestore collection name and 'userId' with the actual user ID
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('users').doc(_userId).get();

    if (snapshot.exists) {
      setState(() {
        var userData = snapshot.data();
        _userName = userData!['name'] ?? 'Default Name';
        _userImageUrl = userData['imageUrl'] ?? 'default_image_url.png';
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
          SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(_userImageUrl),
                  radius: 25,
                ),
                SizedBox(width: 10),
                Text(
                  'Welcome $_userName!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                // Display a single bird image
                _imageUrls.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: AssetImage('assets/images/hbird.png'),
                        radius: 25,
                      )
                    : Container(), // Display an empty container or placeholder if _imageUrls is empty
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildTabButton('Categories'),
                SizedBox(width: 10),
                _buildTabButton('New & Noteworthy'),
              ],
            ),
          ),
          SizedBox(height: 20),
          _buildFeaturedGameCard(),
          SizedBox(height: 20),
          _buildImageSlider(),
          SizedBox(height: 20),
          Container(
            height: 200,
            child: Center(child: Text('Home')),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        primary: Colors.grey[200],
        onPrimary: Colors.black,
        shape: StadiumBorder(),
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
                    children: [
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
                      primary: Colors.pink,
                      shape: StadiumBorder(),
                    ),
                    child: Text('Birds'),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Horizon Zero Dawn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Recommended because you played games tagged with...',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSlider() {
    if (_imageUrls.isEmpty) {
      return Center(child: Text('No images found'));
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 200.0,
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        autoPlayInterval: Duration(seconds: 3),
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
      ),
      items: _imageUrls.map((url) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
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
                  return Center(child: Icon(Icons.error));
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

    if (index == 1) {
      Navigator.pushNamed(context, '/chat');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/profile', arguments: widget.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0
          ? _buildHomePage()
          : _selectedIndex == 1
              ? Center(child: Text('Chat'))
              : _selectedIndex == 2
                  ? Center(child: Text('Notifications'))
                  : Center(child: Text('Profile')),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  CustomBottomNavigationBar({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: onItemTapped,
        showUnselectedLabels: true,
        showSelectedLabels: true,
      ),
    );
  }
}
