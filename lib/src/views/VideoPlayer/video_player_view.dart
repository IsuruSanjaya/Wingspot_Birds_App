// import 'package:flutter/material.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';

// class VideoPlayerScreen extends StatefulWidget {
//   final String videoUrl;

//   const VideoPlayerScreen({required this.videoUrl, super.key});

//   @override
//   _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
// }

// class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
//   late VlcPlayerController _controller;
//   bool _isPlaying = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller = VlcPlayerController.network(widget.videoUrl)
//       ..addListener(() {
//         setState(() {
//           _isPlaying = _controller.value.isPlaying;
//         });
//       });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Video Player'),
//       ),
//       body: Center(
//         child: VlcPlayer(
//           controller: _controller,
//           aspectRatio: 16 / 9,
//           url: widget.videoUrl,
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           setState(() {
//             if (_isPlaying) {
//               _controller.pause();
//             } else {
//               _controller.play();
//             }
//             _isPlaying = !_isPlaying;
//           });
//         },
//         child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _controller.dispose();
//   }
// }
