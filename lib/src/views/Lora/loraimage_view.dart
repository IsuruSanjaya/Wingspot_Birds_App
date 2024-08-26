import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoraImageView extends StatefulWidget {
  const LoraImageView({super.key});

  @override
  _LoraImageViewState createState() => _LoraImageViewState();
}

class _LoraImageViewState extends State<LoraImageView> {
  List<String> imageUrls = [];
  List<String> videoUrls = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://wingspotbackend-dzc0anehbyfzg7a9.eastus-01.azurewebsites.net/api/lora/images/all'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print('Fetched data: $data'); // Debug: print fetched data

        setState(() {
          imageUrls = data
              .where((item) => item['key'].toString().endsWith('.jpg'))
              .map<String>((item) => item['url'] as String)
              .toList();
          videoUrls = data
              .where((item) => item['key'].toString().endsWith('.h264'))
              .map<String>((item) => item['url'] as String)
              .toList();

          // Debug: print image and video URLs
          print('Image URLs: $imageUrls');
          print('Video URLs: $videoUrls');

          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e'); // Debug: print any error that occurs
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
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
                  buildImageGrid(),
                  buildVideoGrid(),
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
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    VideoPlayerScreen(videoUrl: videoUrls[index]),
              ),
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                color: Colors.black,
                child: Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    color: Colors.white,
                    size: 50.0,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Text(
                  'Video ${index + 1}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({required this.videoUrl, super.key});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VlcPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VlcPlayerController.network(
      widget.videoUrl,
      hwAcc: HwAcc.full,
    )..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? VlcPlayer(
                controller: _controller,
                aspectRatio: 16 / 9,
                placeholder: const Center(child: CircularProgressIndicator()),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
            _isPlaying = !_isPlaying;
          });
        },
        child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
