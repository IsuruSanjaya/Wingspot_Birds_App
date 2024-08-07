import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class BirdScreen extends StatefulWidget {
  const BirdScreen({super.key});

  @override
  State<BirdScreen> createState() => _BirdScreenState();
}

class _BirdScreenState extends State<BirdScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> unknownSpecies = [];
  List<dynamic> knownSpecies = [
    {'name': 'Species 1', 'details': 'Details about Species 1'},
    {'name': 'Species 2', 'details': 'Details about Species 2'},
    {'name': 'Species 3', 'details': 'Details about Species 3'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchUnknownSpecies();
  }

  Future<void> fetchUnknownSpecies() async {
    try {
      final response = await http.get(Uri.parse(
          'https://wingspotbackend-dzc0anehbyfzg7a9.eastus-01.azurewebsites.net/images/'));

      if (response.statusCode == 200) {
        // Print the raw response body
        print('Response body: ${response.body}');

        final List<dynamic> data = json.decode(response.body);

        // Print the decoded data
        print('Decoded data: $data');

        // Map the base64 data to Uint8List and print to verify
        setState(() {
          unknownSpecies = data.map((item) {
            // Assuming the base64 string is in the 'image' field
            final base64String = item['image'].split(',').last;
            final imageBytes = base64Decode(base64String);
            print('Image bytes length: ${imageBytes.length}');
            return imageBytes;
          }).toList();
        });
      } else {
        throw Exception('Failed to load unknown species');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch unknown species');
    }
  }

  void _showImagePreview(Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.memory(imageBytes),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.share),
                label: const Text('Share on FB'),
                onPressed: () {
                  // Handle share functionality here
                  // You might use a plugin like `share_plus` for actual sharing functionality

                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        automaticallyImplyLeading: false, // Hide the back button
        backgroundColor:
            Color.fromARGB(255, 17, 55, 13), // Change app bar color
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Unknown Species'),
            const Tab(text: 'Known Species'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          unknownSpecies.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // 4 images per row
                    crossAxisSpacing: 8.0, // Space between images horizontally
                    mainAxisSpacing: 8.0, // Space between images vertically
                  ),
                  itemCount: unknownSpecies.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _showImagePreview(unknownSpecies[index]);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.memory(unknownSpecies[index]),
                      ),
                    );
                  },
                ),
          ListView.builder(
            itemCount: knownSpecies.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(knownSpecies[index]['name']),
                subtitle: Text(knownSpecies[index]['details']),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
