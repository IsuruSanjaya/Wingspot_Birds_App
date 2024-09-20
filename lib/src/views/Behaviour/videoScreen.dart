import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 1;
  List<Map<String, dynamic>> _relaxedVideos = [];
  List<Map<String, dynamic>> _agitatedVideos = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchVideos();
  }

  Future<void> _fetchVideos() async {
    final response = await http
        .get(Uri.parse('http://52.220.37.106:8090/api/videos/videos'));

    if (response.statusCode == 200) {
      final List<dynamic> videosJson = json.decode(response.body);
      final List<Map<String, dynamic>> videos =
          videosJson.cast<Map<String, dynamic>>();

      setState(() {
        _relaxedVideos =
            videos.where((video) => video['description'] == 'Relaxed').toList();
        _agitatedVideos = videos
            .where((video) => video['description'] == 'Stressed')
            .toList();
      });
    } else {
      throw Exception('Failed to load videos');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BEHAVIOUR ANALYSIS VIDEO'),
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
          _buildContent(_relaxedVideos),
          _buildContent(_agitatedVideos),
        ],
      ),
    );
  }

  Widget _buildContent(List<Map<String, dynamic>> videos) {
    if (videos.isEmpty) {
      return const Center(child: Text('No videos available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return VideoCard(video: video);
      },
    );
  }
}

class VideoCard extends StatefulWidget {
  final Map<String, dynamic> video;

  const VideoCard({super.key, required this.video});

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  bool _loadingThumbnails = true;
  String? _thumbnailPath;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
    try {
      setState(() {
        _loadingThumbnails = true;
      });

      final directory = await getApplicationDocumentsDirectory();

      // Generate a thumbnail
      _thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: widget.video['url'],
        thumbnailPath: directory.path,
        imageFormat: ImageFormat.PNG,
        maxHeight: 150,
        quality: 75,
      );

      print('Thumbnail generated at: $_thumbnailPath');

      if (mounted) {
        // Check if the widget is still mounted before calling setState
        setState(() {
          _loadingThumbnails = false;
        });
      }
    } catch (error) {
      print('Error generating thumbnail: $error');
      if (mounted) {
        // Check if the widget is still mounted before calling setState
        setState(() {
          _loadingThumbnails = false;
        });
      }
    }
  }

  Future<void> _downloadVideo() async {
    try {
      // Get the directory for saving the file
      final directory = await getExternalStorageDirectory();
      final filePath = '${directory?.path}/${widget.video['id']}.mp4';

      // Download the video file from the provided URL
      final response = await Dio().download(widget.video['url'], filePath);

      if (response.statusCode == 200) {
        if (mounted) {
          // Check if the widget is still mounted before showing the SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Video downloaded to $filePath')),
          );
        }
      } else {
        if (mounted) {
          // Check if the widget is still mounted before showing the SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to download video')),
          );
        }
      }
    } catch (error) {
      print('Error downloading video: $error');
      if (mounted) {
        // Check if the widget is still mounted before showing the SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error downloading video')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              'Video',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(_formatDate(widget.video['createdAt'])),
          ),
          if (_loadingThumbnails) // Show loader if thumbnails are loading
            const Center(
              child: CircularProgressIndicator(),
            )
          else
            Center(
              child: _thumbnailPath != null
                  ? Image.file(File(_thumbnailPath!), width: 128, height: 128)
                  : const Icon(Icons.video_library, size: 128),
            ),
          const SizedBox(height: 8.0),
          Center(
            child: ElevatedButton(
              onPressed: _downloadVideo,
              child: const Text('Download Video'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.video['description'] ?? 'No Description',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown Date';
    try {
      final DateTime date = DateTime.parse(dateString);
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      return formatter.format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }
}
