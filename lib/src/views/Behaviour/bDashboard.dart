import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BirdAnalysis extends StatefulWidget {
  const BirdAnalysis({super.key});

  @override
  _BirdAnalysisState createState() => _BirdAnalysisState();
}

class _BirdAnalysisState extends State<BirdAnalysis> {
  File? _selectedVideo;
  bool _isLoading = false;

  Future<void> _pickVideo() async {
    final pickedFile =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedVideo = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadVideo() async {
    if (_selectedVideo == null) {
      _showDialog("Error", "Please select a video first.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://localhost:5000/upload_video'));
      request.files.add(
          await http.MultipartFile.fromPath('video', _selectedVideo!.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonData = jsonDecode(responseData);

        // Showing the response in a popup
        _showDialog(
            "Analysis Result",
            "Audio Classification: ${jsonData['audio_classification']}\n"
                "Final Classification: ${jsonData['final_classification']}\n"
                "Relaxed Percentage: ${jsonData['relaxed_percentage']}\n"
                "Stressed Percentage: ${jsonData['stressed_percentage']}");
      } else {
        _showDialog("Error", "Failed to upload video. Please try again.");
      }
    } catch (e) {
      _showDialog("Error", "An error occurred: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bird Analysis"),
        backgroundColor: const Color.fromARGB(255, 18, 71, 33),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 18, 71, 33),
              ),
              onPressed: _pickVideo,
              child: const Text("Select Video from Gallery"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 18, 71, 33),
              ),
              onPressed: _isLoading ? null : _uploadVideo,
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text("Upload Video"),
            ),
          ],
        ),
      ),
    );
  }
}
