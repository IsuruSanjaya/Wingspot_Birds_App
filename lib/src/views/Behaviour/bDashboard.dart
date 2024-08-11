// import 'package:flutter/material.dart';

// class AnalysisScreen extends StatefulWidget {
//   const AnalysisScreen({super.key});

//   @override
//   _AnalysisScreenState createState() => _AnalysisScreenState();
// }

// class _AnalysisScreenState extends State<AnalysisScreen> {
//   int videoCount = 5; // Example count of videos
//   int audioCount = 3; // Example count of audios
//   String query = ''; // For search query
//   List<Bird> birds = []; // List to hold bird data

//   @override
//   void initState() {
//     super.initState();
//     fetchBirds(); // Fetch data when the screen initializes
//   }

//   Future<void> fetchBirds() async {
//     // Example API call
//     // Replace with your actual API call and parsing logic
//     final response = await fetchFromApi(); // Replace this with your API call
//     setState(() {
//       birds = response.map((data) => Bird.fromJson(data)).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'Search',
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   query = value;
//                 });
//                 // Implement search functionality here
//               },
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: birds.length,
//               itemBuilder: (context, index) {
//                 final bird = birds[index];
//                 return _buildCard(bird);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCard(Bird bird) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.red, width: 2.0), // Red border
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//       child: Card(
//         margin: EdgeInsets.zero,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ListTile(
//               title: Text(
//                 bird.name,
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               subtitle: Text(bird.species),
//             ),
//             Image.network(bird.imageUrl),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(bird.location),
//                   SizedBox(height: 4.0),
//                   Text(bird.date),
//                   SizedBox(height: 8.0),
//                   Text(bird.description),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _buildButton(
//                           Icons.video_file, 'Record Video', videoCount),
//                     ],
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _buildButton(
//                           Icons.audio_file, 'Record Audio', audioCount),
//                     ],
//                   ),
//                   // Add more rows if needed
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildButton(IconData icon, String label, int count) {
//     return ElevatedButton.icon(
//       onPressed: () {
//         // Implement the functionality
//       },
//       icon: Icon(icon, color: Colors.white),
//       label: Text('$label ($count)'),
//       style: ElevatedButton.styleFrom(
//         primary: Colors.green, // Set button color to green
//         onPrimary: Colors.white, // Set text color
//       ),
//     );
//   }

//   Future<List<Map<String, dynamic>>> fetchFromApi() async {
//     // Replace with your API call and parsing logic
//     // This is a placeholder
//     return Future.delayed(
//       Duration(seconds: 2),
//       () => [
//         {
//           'name': 'RED WATTLED LAPWING',
//           'species': 'VANELLUS INDICUS',
//           'imageUrl': 'https://via.placeholder.com/150',
//           'location': 'East Coast, Sri Lanka',
//           'date': '3rd August 2024',
//           'description':
//               'Description - Male and female red wattled lapwings fighting with a snake in order to protect their nest.',
//         },
//         // Add more bird data here
//       ],
//     );
//   }
// }

// class Bird {
//   final String name;
//   final String species;
//   final String imageUrl;
//   final String location;
//   final String date;
//   final String description;

//   Bird({
//     required this.name,
//     required this.species,
//     required this.imageUrl,
//     required this.location,
//     required this.date,
//     required this.description,
//   });

//   factory Bird.fromJson(Map<String, dynamic> json) {
//     return Bird(
//       name: json['name'],
//       species: json['species'],
//       imageUrl: json['imageUrl'],
//       location: json['location'],
//       date: json['date'],
//       description: json['description'],
//     );
//   }
// }

import 'package:flutter/material.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  int videoCount = 5; // Example count of videos
  int audioCount = 3; // Example count of audios
  String query = ''; // For search query

  // Sample data for bird categories
  final List<Map<String, dynamic>> exampleBirdsData = [
    {
      'name': 'RED WATTLED LAPWING',
      'species': 'VANELLUS INDICUS',
      'imageUrl': 'https://via.placeholder.com/150',
      'location': 'East Coast, Sri Lanka',
      'date': '3rd August 2024',
      'description':
          'Male and female red wattled lapwings fighting with a snake to protect their nest.',
    },
    {
      'name': 'EASTERN BLUEBIRD',
      'species': 'SIALIA SIALIS',
      'imageUrl': 'https://via.placeholder.com/150',
      'location': 'North America',
      'date': '12th July 2024',
      'description':
          'A bright blue bird with a reddish-orange chest and white belly, often seen perched on fences.',
    },
    {
      'name': 'AFRICAN PIED WAGTAIL',
      'species': 'MOTACILLA AGLEOLUS',
      'imageUrl': 'https://via.placeholder.com/150',
      'location': 'Sub-Saharan Africa',
      'date': '19th June 2024',
      'description':
          'A small black-and-white bird with a distinctive tail that wags constantly while foraging.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  query = value;
                });
                // Implement search functionality here
              },
            ),
          ),
          Expanded(
            child: ListView(
              children: exampleBirdsData
                  .where((bird) =>
                      bird['name'].toLowerCase().contains(query.toLowerCase()))
                  .map((bird) => _buildCard(bird))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> bird) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, width: 2.0), // Red border
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                bird['name'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(bird['species']),
            ),
            Image.network(bird['imageUrl']),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bird['location']),
                  SizedBox(height: 4.0),
                  Text(bird['date']),
                  SizedBox(height: 8.0),
                  Text(bird['description']),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildButton(
                          Icons.video_file, 'Record Video', videoCount),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildButton(
                          Icons.audio_file, 'Record Audio', audioCount),
                    ],
                  ),
                  // Add more rows if needed
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(IconData icon, String label, int count) {
    return ElevatedButton.icon(
      onPressed: () {
        // Implement the functionality
      },
      icon: Icon(icon, color: Colors.white),
      label: Text('$label ($count)'),
      style: ElevatedButton.styleFrom(
        primary: Colors.green, // Set button color to green
        onPrimary: Colors.white, // Set text color
      ),
    );
  }
}
