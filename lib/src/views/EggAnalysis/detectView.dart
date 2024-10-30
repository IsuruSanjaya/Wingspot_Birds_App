import 'dart:convert'; // Add this import to handle JSON
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class DetectView extends StatefulWidget {
  const DetectView({super.key});

  @override
  State<DetectView> createState() => _DetectViewState();
}

class _DetectViewState extends State<DetectView> {
  File? _videoFile;
  String _uploadStatus = '';

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
        _uploadStatus = 'Video selected: ${_videoFile!.path}';
      });
    }
  }

  Future<void> _uploadVideo() async {
    if (_videoFile == null) {
      setState(() {
        _uploadStatus = 'No video selected!';
      });
      return;
    }

    final uri = Uri.parse('http://localhost:5000/process_video'); // Update with your API endpoint
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('video', _videoFile!.path));

    setState(() {
      _uploadStatus = 'Uploading...';
    });

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        // Get the response body
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);

        // Show dialog with results
        _showResultsDialog(jsonResponse);
      } else {
        setState(() {
          _uploadStatus = 'Upload failed: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _uploadStatus = 'Upload failed: $e';
      });
    }
  }

  void _showResultsDialog(Map<String, dynamic> jsonResponse) {
    // Prepare details to display
    final behaviorDurations = jsonResponse['behavior_durations'];
    final consistentEggCount = jsonResponse['consistent_egg_count'];
    final hatchlingMax = jsonResponse['hatchling_max'];
    final totalDuration = jsonResponse['total_duration'];
    final percentages = jsonResponse['percentages'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Analysis Results'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Behavior Durations:'),
                Text('Incubation: ${behaviorDurations['Incubation']}'),
                Text('Attention: ${behaviorDurations['Attention']}'),
                Text('Unattended: ${behaviorDurations['Unattended']}'),
                Text('Absent: ${behaviorDurations['Absent']}'),
                const SizedBox(height: 10),
                Text('Consistent Egg Count: $consistentEggCount'),
                Text('Hatchling Max: $hatchlingMax'),
                Text('Total Duration: $totalDuration'),
                const SizedBox(height: 10),
                Text('Percentages:'),
                Text('Incubation: ${percentages['Incubation']}%'),
                Text('Attention: ${percentages['Attention']}%'),
                Text('Unattended: ${percentages['Unattended']}%'),
                Text('Absent: ${percentages['Absent']}%'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
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
      appBar: AppBar(
        title: const Text('Egg Analysis'),
        backgroundColor: const Color.fromARGB(255, 18, 71, 33),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 18, 71, 33),
                ),
                icon: const Icon(Icons.video_library),
                label: const Text('Select Video from Gallery'),
                onPressed: _pickVideo,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 18, 71, 33),
                ),
                icon: const Icon(Icons.upload),
                label: const Text('Upload Video'),
                onPressed: _uploadVideo,
              ),
              const SizedBox(height: 20),
              Text(
                _uploadStatus,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
