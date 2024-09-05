import 'package:flutter/material.dart';
import 'package:wingspot/src/views/Behaviour/audioScreen.dart';
import 'package:wingspot/src/views/Behaviour/videoScreen.dart';
import 'package:wingspot/src/views/Home/home.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 1; // Set this to the index for Video Analysis
  String? userId; // Make userId nullable

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      // Index 0 for Audio Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AudioScreen()),
      );
    } else if (index == 1) {
      // Index 1 for Video Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const VideoScreen()),
      );
    } else if (index == 2) {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //       builder: (context) => const HomeScreen(
      //             userId: '',
      //           )),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ANALYSIS - VIDEO'),
        backgroundColor: const Color.fromARGB(255, 18, 71, 33),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'RELAXED'),
            Tab(text: 'AGITATED'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContent(),
          _buildContent(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 18, 71, 33),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.audio_file),
            label: 'Audio Analysis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_collection),
            label: 'Video Analysis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Color.fromARGB(255, 171, 155, 155),
        selectedItemColor: Color.fromARGB(255, 255, 255, 255),
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        _buildCard(),
        _buildCard(),
      ],
    );
  }

  Widget _buildCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text(
              'RED WATTLED LAPWING',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('VANELLUS INDICUS'),
          ),
          Image.network('https://via.placeholder.com/150'),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('East Coast, Sri Lanka'),
                SizedBox(height: 4.0),
                Text('3rd August 2024'),
                SizedBox(height: 8.0),
                Text(
                  'Description - Male and female red wattled lapwings fighting with a snake in order to protect their nest.',
                ),
              ],
            ),
          ),
          ButtonBar(
            children: [
              TextButton(
                onPressed: () {},
                child: const Text('Save'),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Share'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
