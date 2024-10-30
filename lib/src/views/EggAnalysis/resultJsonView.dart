import 'package:flutter/material.dart';
import 'dart:convert';

class ResultJsonView extends StatefulWidget {
  const ResultJsonView({super.key});

  @override
  State<ResultJsonView> createState() => _ResultJsonViewState();
}

class _ResultJsonViewState extends State<ResultJsonView> {
  // Sample JSON files or file names. Replace with actual JSON files fetched from your backend.
  final List<Map<String, dynamic>> jsonFiles = [
    {
      "fileName": "File1.json",
      "content": {"data": "Sample Data 1"}
    },
    {
      "fileName": "File2.json",
      "content": {"data": "Sample Data 2"}
    },
    // Add more JSON file entries as needed.
  ];

  // List to keep track of selected files
  final List<Map<String, dynamic>> _selectedFiles = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON Gallery'),
        backgroundColor: const Color.fromARGB(255, 18, 71, 33),
      ),
      body: Stack(
        children: [
          GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  2, // Adjust the number of columns as per your needs
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: jsonFiles.length,
            itemBuilder: (context, index) {
              final file = jsonFiles[index];
              final isSelected = _selectedFiles.contains(file);
              return GestureDetector(
                onTap: () => _toggleSelection(file),
                child: Card(
                  elevation: 5,
                  color: isSelected ? Colors.green.shade200 : Colors.white,
                  child: Center(
                    child: Text(
                      file['fileName'],
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          ),
          // Centered bottom button
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 18, 71, 33),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                onPressed: _selectedFiles.isNotEmpty
                    ? () {
                        _showCalculationResult(context);
                      }
                    : null, // Disable button if no files are selected
                child: const Text(
                  'Calculate Success Rate',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to toggle selection of a file
  void _toggleSelection(Map<String, dynamic> jsonFile) {
    setState(() {
      if (_selectedFiles.contains(jsonFile)) {
        _selectedFiles.remove(jsonFile);
      } else {
        _selectedFiles.add(jsonFile);
      }
    });
  }

  // Function to display calculation result in a dialog
  void _showCalculationResult(BuildContext context) {
    // Simulate calculation based on selected files
    String result =
        "Success rate calculated for ${_selectedFiles.map((file) => file['fileName']).join(", ")}";

    // Show result in a dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Calculation Result'),
          content: Text(result),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
