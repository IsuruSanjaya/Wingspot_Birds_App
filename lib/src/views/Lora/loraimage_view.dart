import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class LoraImageView extends StatefulWidget {
  const LoraImageView({super.key});

  @override
  _LoraImageViewState createState() => _LoraImageViewState();
}

class _LoraImageViewState extends State<LoraImageView> {
  List<String> imageUrls = [];
  List<String> videoUrls = [];
  bool isLoading = true;

  VlcPlayerController? _videoPlayerController;
  String? _currentlyPlayingVideo;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final response = await http
          .get(Uri.parse('http://52.220.106.102:8090/api/lora/images/all'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          imageUrls = data
              .where((item) =>
                  item['key'].toString().endsWith('.jpg') ||
                  item['key'].toString().endsWith('.png'))
              .map<String>((item) => item['url'] as String)
              .toList();
        });

        for (var item in data) {
          if (item['key'].toString().endsWith('.h264') ||
              item['key'].toString().endsWith('.mp4')) {
            String videoUrl = item['url'] as String;
            await downloadAndConvertVideo(videoUrl);
          }
        }

        setState(() {
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> downloadAndConvertVideo(String videoUrl) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final h264Path = path.join(directory.path, path.basename(videoUrl));
      final mp4Path = path.join(
          directory.path, '${path.basenameWithoutExtension(h264Path)}.mp4');

      final response = await http.get(Uri.parse(videoUrl));
      if (response.statusCode == 200) {
        final file = File(h264Path);
        await file.writeAsBytes(response.bodyBytes);

        final ffmpegResponse =
            await FFmpegKit.execute('-i $h264Path -c:v copy $mp4Path');

        if (await File(mp4Path).exists()) {
          print('MP4 conversion successful: $mp4Path');
        } else {
          print('MP4 conversion failed');
        }

        setState(() {
          videoUrls.add(mp4Path);
        });

        await file.delete();
      }
    } catch (e) {
      print('Error downloading or converting video: $e');
    }
  }

  void closePreview() {
    setState(() {
      if (_videoPlayerController != null) {
        _videoPlayerController!.stop();
        _videoPlayerController!.dispose();
      }
      _currentlyPlayingVideo = null;
      _videoPlayerController = null;
    });
  }

  Future<void> downloadFile(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final status = await Permission.storage.request();
        if (status.isGranted) {
          final result = await ImageGallerySaver.saveImage(
            Uint8List.fromList(response.bodyBytes),
            quality: 100,
            name: path.basename(url),
          );
          print('File downloaded and saved to gallery: $result');
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Download Complete'),
              content: Text('Image saved to gallery.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          print('Permission denied');
        }
      } else {
        print('Failed to download file: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error downloading file: $e');
    }
  }

  Future<void> identifySpecies(String imageUrl) async {
    try {
      // Download the image from the URL
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        print('Failed to download image: ${response.reasonPhrase}');
        return;
      }

      // Create a multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://wsflaskapploadbalancer-1950839340.us-east-1.elb.amazonaws.com/detect_bird_category'),
      );

      // Add the image file to the request
      request.files.add(
        http.MultipartFile.fromBytes(
          'image', // This is the key your API expects
          response.bodyBytes,
          filename:
              'bird_image.jpg', // You can use a dynamic name or keep it static
        ),
      );

      // Send the request
      var streamedResponse = await request.send();

      // Handle the response
      if (streamedResponse.statusCode == 200) {
        // Convert the stream to a list of bytes
        final responseData = await streamedResponse.stream.toBytes();
        final result = utf8.decode(responseData);
        final data = json.decode(result);

        String birdCategory = data['bird_category'];
        String status = data['status'];

        // Show identification result in a dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Species Identified'),
            content: Text('Bird Category: $birdCategory\nStatus: $status'),
            actions: [
              TextButton(
                onPressed: () {
                  // Call the upload function when OK is pressed
                  uploadImageToS3(imageUrl, birdCategory,
                      status); // Pass the status as well
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        print('Failed to identify species: ${streamedResponse.reasonPhrase}');
      }
    } catch (e) {
      print('Error identifying species: $e');
    }
  }

  Future<void> uploadImageToS3(
      String imageUrl, String birdCategory, String status) async {
    try {
      // Download the image from the URL
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        print('Failed to download image for upload: ${response.reasonPhrase}');
        return;
      }

      // Create a multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://52.220.106.102:8090/api/videos/upload/image'),
      );

      // Add the image file to the request with the bird category as the filename
      request.files.add(
        http.MultipartFile.fromBytes(
          'image', // This is the key your API expects
          response.bodyBytes,
          filename:
              '${birdCategory.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.jpg', // Use birdCategory as filename, sanitize it
        ),
      );

      // Set the description field as the status
      request.fields['description'] = status;

      // Send the request
      var streamedResponse = await request.send();

      // Handle the response
      if (streamedResponse.statusCode == 200) {
        print(
            'Image uploaded successfully with filename: ${birdCategory.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.jpg');
      } else {
        print('Failed to upload image: ${streamedResponse.reasonPhrase}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 17, 55, 13),
          title: const Text('Lora Media Gallery'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Images'),
              Tab(text: 'Videos'),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  buildImageTab(),
                  buildVideoTab(),
                ],
              ),
      ),
    );
  }

  Widget buildImageTab() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Image Options'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.network(
                        imageUrls[index],
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 10),
                      Text('Would you like to identify the species?'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // Call the identifySpecies function here
                        identifySpecies(imageUrls[index]);
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text('See Result'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                );
              },
            );
          },
          child: Image.network(
            imageUrls[index],
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  Widget buildVideoTab() {
    return ListView.builder(
      itemCount: videoUrls.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Video ${index + 1}'),
          onTap: () {
            if (_currentlyPlayingVideo == videoUrls[index]) {
              closePreview();
            } else {
              _currentlyPlayingVideo = videoUrls[index];
              _videoPlayerController = VlcPlayerController.network(
                videoUrls[index],
                hwAcc: HwAcc.full,
                autoPlay: true,
                options: VlcPlayerOptions(),
              );
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Video Preview'),
                    content: Container(
                      width: double.maxFinite,
                      height: 200,
                      child: VlcPlayer(
                        controller: _videoPlayerController!,
                        aspectRatio: 16 / 9,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          closePreview();
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              );
            }
          },
        );
      },
    );
  }
}
