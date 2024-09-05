import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:video_thumbnail/video_thumbnail.dart';

class LoraImageView extends StatefulWidget {
  const LoraImageView({super.key});

  @override
  _LoraImageViewState createState() => _LoraImageViewState();
}

class _LoraImageViewState extends State<LoraImageView> {
  List<String> imageUrls = [];
  List<String> videoUrls = [];
  bool isLoading = true;

  late VlcPlayerController _videoPlayerController;
  String? _currentlyPlayingVideo;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://wingspotbackend-dzc0anehbyfzg7a9.eastus-01.azurewebsites.net/api/lora/images/all'));

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

        // Process video files
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

      // Download the .h264 file
      final response = await http.get(Uri.parse(videoUrl));
      if (response.statusCode == 200) {
        final file = File(h264Path);
        await file.writeAsBytes(response.bodyBytes);

        // Convert the .h264 file to .mp4 using ffmpeg
        final ffmpegResponse =
            await FFmpegKit.execute('-i $h264Path -c:v copy $mp4Path');

        // Debug print to check if the conversion was successful
        if (await File(mp4Path).exists()) {
          print('MP4 conversion successful: $mp4Path');
        } else {
          print('MP4 conversion failed');
        }

        setState(() {
          videoUrls.add(mp4Path); // Add the path of the converted video
          print('Video URLs: $videoUrls'); // Debug print
        });

        // Optionally, delete the .h264 file after conversion
        await file.delete();
      }
    } catch (e) {
      print('Error downloading or converting video: $e');
    }
  }

  Future<String> getVideoThumbnail(String videoPath) async {
    try {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 150,
        quality: 75,
      );
      print('Thumbnail generated at: $thumbnailPath'); // Debug print
      return thumbnailPath!;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return '';
    }
  }

  void closePreview() {
    setState(() {
      _videoPlayerController.stop();
      _currentlyPlayingVideo = null;
    });
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
            : Column(
                children: [
                  if (_currentlyPlayingVideo != null)
                    Stack(
                      children: [
                        Expanded(
                          child: VlcPlayer(
                            controller: _videoPlayerController,
                            aspectRatio: 16 / 9,
                            placeholder: const Center(
                                child: CircularProgressIndicator()),
                          ),
                        ),
                        Positioned(
                          top: 8.0,
                          right: 8.0,
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 30.0,
                            ),
                            onPressed: closePreview,
                          ),
                        ),
                      ],
                    ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        buildImageGrid(),
                        buildVideoGrid(),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget buildImageGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of columns
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            // Optionally, handle image tap to show full-screen view
          },
          child: Image.network(
            imageUrls[index],
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  Widget buildVideoGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of columns
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: videoUrls.length,
      itemBuilder: (context, index) {
        return FutureBuilder<String>(
          future: getVideoThumbnail(videoUrls[index]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentlyPlayingVideo = videoUrls[index];
                    if (File(_currentlyPlayingVideo!).existsSync()) {
                      print('Playing video: $_currentlyPlayingVideo');
                      _videoPlayerController = VlcPlayerController.file(
                        File(_currentlyPlayingVideo!),
                        hwAcc: HwAcc.full,
                        autoPlay: true,
                      );
                    } else {
                      print(
                          'Video file does not exist at path: $_currentlyPlayingVideo');
                    }
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.file(
                      File(snapshot.data!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    const Icon(
                      Icons.play_circle_outline,
                      color: Colors.white,
                      size: 50.0,
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }
}
