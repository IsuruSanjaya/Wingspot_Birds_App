import 'package:flutter/material.dart';
import 'package:wingspot/src/views/Behaviour/audioScreen.dart';
import 'package:wingspot/src/views/Behaviour/videoScreen.dart';
import 'package:wingspot/src/views/Login/login.dart';

class SideNavigation extends StatelessWidget {
  const SideNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 18, 71, 33),
            ),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'BEHAVIOURAL ANALYSIS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
            ),
            padding: const EdgeInsets.all(
                16.0), // Adjust padding to make the background smaller
            margin: EdgeInsets.zero, // Remove margin if needed
          ),
          ListTile(
            title: const Text('AUDIO ANALYSIS'),
            leading: const Icon(Icons.audio_file),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AudioScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('VIDEO ANALYSIS'),
            leading: const Icon(Icons.video_collection),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VideoScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
