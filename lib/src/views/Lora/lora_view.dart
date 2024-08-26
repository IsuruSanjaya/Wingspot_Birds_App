import 'package:flutter/material.dart';

class LoraView extends StatelessWidget {
  const LoraView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Hard-coded log details
    final List<Map<String, String>> logs = [
      {"time": "12:45", "details": "Bird Detection"},
      {"time": "12:50", "details": "No Detection"},
      {"time": "12:55", "details": "Bird Detection"},
      {"time": "13:05", "details": "Bird Detection"},
      {"time": "12:50", "details": "No Detection"},
      {"time": "12:55", "details": "Bird Detection"},
      {"time": "13:05", "details": "Bird Detection"},
      {"time": "12:50", "details": "No Detection"},
      {"time": "12:55", "details": "Bird Detection"},
      {"time": "13:05", "details": "Bird Detection"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LoRa Log',
          style: TextStyle(),
        ),
        backgroundColor: const Color.fromARGB(255, 18, 71, 33),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              // Determine opacity based on log details
              double opacity =
                  logs[index]['details'] == "No Detection" ? 0.5 : 1.0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    if (logs[index]['details'] == "Bird Detection") ...[
                      Image.asset(
                        'assets/images/dove.png',
                        width: 34, // Adjust the width as needed
                        height: 34, // Adjust the height as needed
                        color: Color.fromARGB(
                            255, 13, 58, 6), // Optionally apply color tint
                      ),
                      const SizedBox(width: 8),
                    ],
                    // Main log container with conditional opacity
                    Expanded(
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Time: ${logs[index]['time']}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (logs[index]['details'] !=
                                      "Bird Detection") ...[
                                    const Icon(Icons.info_outline,
                                        color: Colors.green),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    "Details: ${logs[index]['details']}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
