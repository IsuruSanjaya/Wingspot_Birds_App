import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
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
  List<dynamic> knownSpecies = [];
  List<dynamic> unknownSpecies = [];
  List<String> categories = [
    'All',
    'Red Wattled Lapwing',
    'Indian Thick Knee',
    'Black Winged Stilt'
  ];
  String selectedCategory = 'All';

  bool isUploadingImage = false;
  bool isLoadingImages = true;
  dynamic selectedImageItem;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchImages();
  }

  Future<void> fetchImages() async {
    setState(() {
      isLoadingImages = true;
    });

    try {
      final response = await http
          .get(Uri.parse('http://52.220.106.102:8090/api/videos/images/all'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        knownSpecies.clear();
        unknownSpecies.clear();

        for (var item in data) {
          String key = item['key'];
          String url = item['url'];

          if (key.contains('Red_Wattled_Lapwing')) {
            knownSpecies.add({
              'name': 'Red Wattled Lapwing',
              'image': url,
              'category': 'Red Wattled Lapwing',
              'postUrl': '', // Initialize empty post URL
            });
          } else if (key.contains('Indian Thick Knee')) {
            knownSpecies.add({
              'name': 'Indian Thick Knee',
              'image': url,
              'category': 'Indian Thick Knee',
              'postUrl': '',
            });
          } else if (key.contains('Black_Winged_Stilt')) {
            knownSpecies.add({
              'name': 'Black Winged Stilt',
              'image': url,
              'category': 'Black Winged Stilt',
              'postUrl': '',
            });
          } else {
            unknownSpecies.add({'image': url, 'postUrl': ''});
          }
        }
      } else {
        _showToast("Failed to load images.", Colors.red);
      }
    } catch (e) {
      _showToast("An error occurred while fetching images.", Colors.red);
    } finally {
      setState(() {
        isLoadingImages = false;
      });
    }
  }

  void _showToast(String message, Color color) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> shareImageToFacebook(
      Uint8List imageBytes, dynamic imageItem) async {
    setState(() {
      isUploadingImage = true;
    });

    try {
      final uri =
          Uri.parse('https://graph.facebook.com/401231743073984/photos');
      final accessToken =
          'EAAP3BZAomIEsBO0ZBmBxNEijKozaZBIDc8uVD2Bs31yvQjCzsdGtmsifRsTs2VBsRBDVxP2kApdjtZCtO4AAnF4eV9MAy0CvesFLJvGWHcBhHjEbdHQAnuvyvG6ZAprI5tW2QMAXKpymWsRsdaYyuNih1gacEbbCX8mjmGAVDerimRCxufd23sAqG8TrxSbZBgeUtU0sdblHzML5HS'; // Update with your actual token

      final request = http.MultipartRequest('POST', uri);
      request.fields['access_token'] = accessToken;
      request.fields['message'] = 'Do you know this bird?';

      request.files.add(http.MultipartFile.fromBytes(
        'source',
        imageBytes,
        filename: 'bird_image.png',
        contentType: MediaType('image', 'png'),
      ));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final responseJson = jsonDecode(responseBody);
        final imageId = responseJson["id"];
        final pageId = '401231743073984';
        final postUrl = "https://www.facebook.com/$pageId/posts/$imageId";
        _showToast("Image uploaded successfully!", Colors.green);

        // Save the post URL for the specific image
        setState(() {
          imageItem['postUrl'] = postUrl;
        });
      } else {
        _showToast("Failed to upload image. Please try again.", Colors.red);
      }
    } catch (e) {
      _showToast("An error occurred. Please try again.", Colors.red);
    } finally {
      setState(() {
        isUploadingImage = false;
      });
    }
  }

  void _showImagePreview(Uint8List imageBytes, dynamic imageItem) {
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
                  Navigator.of(context).pop();
                  await shareImageToFacebook(imageBytes, imageItem);
                  setState(() {
                    selectedImageItem = imageItem;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> checkComments(String postUrl) async {
    try {
      final apiUrl = Uri.parse(
          'http://wsflaskapploadbalancer-1950839340.us-east-1.elb.amazonaws.com/verify_comments');

      // Send a POST request with a JSON body
      final response = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'bird_category': 'Unknown', // Modify as needed
          'url': postUrl,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        _showCommentsDialog(
            result['comments_app_count'], result['sum_app_count']);
      } else {
        _showToast("Failed to fetch comments. Please try again.", Colors.red);
      }
    } catch (e) {
      _showToast("An error occurred while fetching comments.", Colors.red);
    }
  }

  void _showCommentsDialog(List<String> comments, String count) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Comments'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ...comments.map((comment) => Text(comment)).toList(),
              const SizedBox(height: 10),
              Text('Total Comments: $count'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text('Species'),
        backgroundColor: const Color.fromARGB(255, 17, 55, 13),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Known Species'),
            Tab(text: 'Unknown Species'),
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
                // Known Species Tab
                Column(
                  children: [
                    DropdownButton<String>(
                      value: selectedCategory,
                      onChanged: (String? value) {
                        setState(() {
                          selectedCategory = value ?? 'All';
                        });
                      },
                      items: categories
                          .map<DropdownMenuItem<String>>((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: knownSpecies.length,
                        itemBuilder: (context, index) {
                          final item = knownSpecies[index];
                          if (selectedCategory != 'All' &&
                              item['category'] != selectedCategory) {
                            return Container();
                          }
                          return Card(
                            margin: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(item['image']),
                                const SizedBox(height: 10),
                                Center(
                                  child: ElevatedButton(
                                    child: const Text('Preview'),
                                    onPressed: () async {
                                      final response = await http
                                          .get(Uri.parse(item['image']));
                                      final imageBytes = response.bodyBytes;
                                      _showImagePreview(imageBytes, item);
                                    },
                                  ),
                                ),
                                if (item['postUrl'] != '')
                                  FloatingActionButton(
                                    child: const Icon(Icons.comment),
                                    onPressed: () {
                                      checkComments(item['postUrl']);
                                    },
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                // Unknown Species Tab
                Expanded(
                  child: ListView.builder(
                    itemCount: unknownSpecies.length,
                    itemBuilder: (context, index) {
                      final item = unknownSpecies[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(item['image']),
                            const SizedBox(height: 10),
                            Center(
                              child: ElevatedButton(
                                child: const Text('Preview'),
                                onPressed: () async {
                                  final response =
                                      await http.get(Uri.parse(item['image']));
                                  final imageBytes = response.bodyBytes;
                                  _showImagePreview(imageBytes, item);
                                },
                              ),
                            ),
                            if (item['postUrl'] != '')
                              FloatingActionButton(
                                child: const Icon(Icons.comment),
                                onPressed: () {
                                  checkComments(item['postUrl']);
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (isUploadingImage || isLoadingImages)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
