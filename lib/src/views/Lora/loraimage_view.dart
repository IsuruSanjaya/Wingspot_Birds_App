import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:wingspot/src/views/Behaviour/videoScreen.dart';

class LoraImageView extends StatefulWidget {
  const LoraImageView({super.key});

  @override
  _LoraImageViewState createState() => _LoraImageViewState();
}

class _LoraImageViewState extends State<LoraImageView> {
  List<String> imageUrls = [];
  List<String> videoUrls = [];
  bool isLoading = true;

  VlcPlayerController? _videoPlayerController; // Changed to nullable
  String? _currentlyPlayingVideo;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    // Ensure the controller is disposed of only if it's initialized
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final response = await http
          .get(Uri.parse('http://52.220.37.106:8090/api/lora/images/all'));

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

        if (await File(mp4Path).exists()) {
          print('MP4 conversion successful: $mp4Path');
        } else {
          print('MP4 conversion failed');
        }

        setState(() {
          videoUrls.add(mp4Path); // Add the path of the converted video
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
      return thumbnailPath!;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return '';
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

  Future<void> analyzeVideo(String videoPath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://52.220.37.106:5000/api/v1/model/predict'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', videoPath));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);

        String prediction = jsonResponse['prediction'];
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Video Analysis Result'),
            content: Text('Prediction: $prediction'),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await savePredictionToDatabase(videoPath, prediction);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const VideoScreen(),
                    ),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        print('Failed to analyze video');
      }
    } catch (e) {
      print('Error analyzing video: $e');
    }
  }

  Future<void> savePredictionToDatabase(
      String videoPath, String prediction) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://52.220.37.106:8090/api/videos/upload-video'),
      );

      request.files.add(await http.MultipartFile.fromPath('video', videoPath));
      request.fields['description'] = prediction;

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Prediction and video saved to database');
      } else {
        print('Failed to save prediction and video');
      }
    } catch (e) {
      print('Error saving prediction and video: $e');
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
            : Column(
                children: [
                  if (_currentlyPlayingVideo != null &&
                      _videoPlayerController != null)
                    Stack(
                      children: [
                        Expanded(
                          child: VlcPlayer(
                            controller: _videoPlayerController!,
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
        crossAxisCount: 2,
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
        crossAxisCount: 2,
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
                onTap: () async {
                  // Ensure video player controller is disposed before initializing a new one
                  _videoPlayerController?.dispose();

                  setState(() {
                    _currentlyPlayingVideo = videoUrls[index];
                    _videoPlayerController = VlcPlayerController.file(
                      File(videoUrls[index]),
                      autoPlay: true,
                      options: VlcPlayerOptions(),
                    );
                  });

                  // After playing, call analyzeVideo
                  await analyzeVideo(videoUrls[index]);
                },
                child: Stack(
                  children: [
                    Image.file(
                      File(snapshot.data!),
                      fit: BoxFit.cover,
                    ),
                    const Positioned(
                      bottom: 8.0,
                      right: 8.0,
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                        size: 30.0,
                      ),
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
