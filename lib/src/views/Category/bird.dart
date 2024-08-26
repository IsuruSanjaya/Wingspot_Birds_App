import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  bool isUploadingImage = false;
  bool isLoadingImages = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchUnknownSpecies();
  }

  Future<void> fetchUnknownSpecies() async {
    setState(() {
      isLoadingImages = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://wingspotbackend-dzc0anehbyfzg7a9.eastus-01.azurewebsites.net/images/'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          unknownSpecies = data.map((item) {
            final base64String = item['image'].split(',').last;
            return base64Decode(base64String);
          }).toList();
        });
      } else {
        throw Exception('Failed to load unknown species');
      }
    } catch (e) {
      print('Error: $e');
      // Handle the error here
    } finally {
      setState(() {
        isLoadingImages = false;
      });
    }
  }

  Future<void> shareImageToFacebook(Uint8List imageBytes) async {
    setState(() {
      isUploadingImage = true;
    });

    try {
      final uri = Uri.parse(
          'https://graph.facebook.com/401231743073984/photos'); // Replace with correct API version and endpoint
      final accessToken =
          'EAAP3BZAomIEsBOZBm07fQT4xxukvfZBBUBtSS7Snd7lAjqMdaWSxoAKIb4BaaAIflcHLjYPlRRvAHb8Kk1uqjPE7U5ZCad1bduKPSrqGOr5biwLmz9RJpoZC92vl8Ecd6MvSNSZAtUAQ0ZCgQ8mRFQpWiOnPnN4F6igGgPtKZCZBA7ZAT5sj5MJ2obIl4fb1ZC87Gtcs0uk3a8b8eZBecfqB'; // Replace with your actual Facebook access token

      final request = http.MultipartRequest('POST', uri);

      // Add the access token
      request.fields['access_token'] = accessToken;

      // Add the message field
      request.fields['message'] = 'Do you know this bird?';

      // Add the image file as form data
      request.files.add(http.MultipartFile.fromBytes(
        'source', // Field name in the form
        imageBytes, // Image bytes
        filename: 'bird_image.png', // Filename to be used
        contentType:
            MediaType('image', 'png'), // Optional: Specify content type
      ));

      // Send the request
      final response = await request.send();

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Image uploaded successfully!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        print('Failed to upload image. Status code: ${response.statusCode}');
        print(response.reasonPhrase);
        Fluttertoast.showToast(
          msg: "Failed to upload image. Please try again.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      print('Error: $e');
      Fluttertoast.showToast(
        msg: "An error occurred. Please try again.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      setState(() {
        isUploadingImage = false;
      });
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
                onPressed: () async {
                  Navigator.of(context).pop(); // Close the dialog
                  await shareImageToFacebook(imageBytes);
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
            const Color.fromARGB(255, 17, 55, 13), // Change app bar color
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Unknown Species'),
            Tab(text: 'Known Species'),
          ],
        ),
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: isUploadingImage || isLoadingImages,
            child: TabBarView(
              controller: _tabController,
              children: [
                isLoadingImages
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, // 4 images per row
                          crossAxisSpacing:
                              8.0, // Space between images horizontally
                          mainAxisSpacing:
                              8.0, // Space between images vertically
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
          ),
          if (isUploadingImage)
            const Center(child: CircularProgressIndicator()),
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
