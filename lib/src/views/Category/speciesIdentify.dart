import 'dart:convert'; // Import for JSON decoding
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class SpeciesIdentify extends StatefulWidget {
  const SpeciesIdentify({super.key});

  @override
  _SpeciesIdentifyState createState() => _SpeciesIdentifyState();
}

class _SpeciesIdentifyState extends State<SpeciesIdentify> {
  File? _image;
  String BIRD = '';
  String Status = '';

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'http://wsflaskapploadbalancer-1950839340.us-east-1.elb.amazonaws.com/detect_bird_category'),
    );

    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        setState(() {
          // Decode the JSON response
          Map<String, dynamic> jsonResponse = json.decode(responseBody);
          // Extract the bird category and status
          BIRD = jsonResponse['bird_category'] ??
              'Unknown bird'; // Store the bird category
          Status =
              jsonResponse['status'] ?? 'Unknown status'; // Store the status
        });
      } else {
        setState(() {
          BIRD = 'Error: ${response.reasonPhrase}';
          Status = ''; // Clear Status on error
        });
      }
    } catch (e) {
      setState(() {
        BIRD = 'Error: $e';
        Status = ''; // Clear Status on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Species Identification'),
        backgroundColor: const Color.fromARGB(255, 18, 71, 33),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null
                ? const Text('No image selected.')
                : Image.file(_image!),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 18, 71, 33),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: _pickImage,
              child: const Text('Select Image from Gallery'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 18, 71, 33),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: _uploadImage,
              child: const Text('Post'),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border:
                    Border.all(color: const Color.fromARGB(255, 18, 71, 33)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    'Result:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'BIRD: $BIRD', // Display the bird category
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Status: $Status', // Display the status
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
