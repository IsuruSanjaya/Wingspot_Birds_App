import 'package:flutter/material.dart';
import 'package:wingspot/src/views/chat.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Center(child: Text('Home')),
    Center(child: Text('Chat')),
    Center(child: Text('Notifications')),
    Center(child: Text('Profile')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
