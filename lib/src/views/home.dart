import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late List<Widget> _pages;
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _fetchImageUrls();
    _pages = [
      Column(
        children: [
          SizedBox(height: 50), // Space from the top
          _buildImageSlider(),
          Expanded(
            child: Center(child: Text('Home')),
          ),
        ],
      ),
      Center(child: Text('Chat')),
      Center(child: Text('Notifications')),
      Center(child: Text('Profile')),
    ];
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
      print('Fetched image URLs: $_imageUrls');
    }
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

  // Widget _buildImageSlider() {
  //   if (_imageUrls.isEmpty) {
  //     return Center(child: CircularProgressIndicator());
  //   }
  //   return CarouselSlider(
  //     options: CarouselOptions(
  //       height: 200.0,
  //       autoPlay: true,
  //       enlargeCenterPage: true,
  //       aspectRatio: 16 / 9,
  //       autoPlayInterval: Duration(seconds: 3),
  //       autoPlayAnimationDuration: Duration(milliseconds: 800),
  //       autoPlayCurve: Curves.fastOutSlowIn,
  //     ),
  //     items: _imageUrls.map((url) {
  //       return Builder(
  //         builder: (BuildContext context) {
  //           return Container(
  //             width: MediaQuery.of(context).size.width,
  //             margin: EdgeInsets.symmetric(horizontal: 5.0),
  //             decoration: BoxDecoration(
  //               color: Colors.amber,
  //             ),
  //             child: Image.network(
  //               url,
  //               fit: BoxFit.cover,
  //             ),
  //           );
  //         },
  //       );
  //     }).toList(),
  //   );
  // }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        Navigator.pushNamed(context, '/chat');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
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
        color: Color.fromARGB(255, 16, 255, 72),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 38, 255, 0).withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, -2), // changes position of shadow
          ),
        ],
      ),
      child: BottomNavigationBar(
        selectedItemColor: Color.fromARGB(255, 0, 0, 0),
        unselectedItemColor: Colors.grey,
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: buildIcon(Icons.home, Colors.red, 0),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: buildIcon(Icons.message, Colors.blue, 1),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: buildIcon(Icons.notifications, Colors.green, 2),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: buildIcon(Icons.person, Colors.orange, 3),
            label: 'Profile',
          ),
        ],
        onTap: onItemTapped,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        selectedLabelStyle: TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
        ),
        unselectedLabelStyle: TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
        ),
      ),
    );
  }

  Widget buildIcon(IconData iconData, Color color, int index) {
    return Stack(
      children: [
        Icon(iconData, color: color),
        if (selectedIndex == index)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
