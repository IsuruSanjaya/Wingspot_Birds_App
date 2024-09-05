import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoraHistoryView extends StatefulWidget {
  const LoraHistoryView({Key? key}) : super(key: key);

  @override
  _LoraHistoryViewState createState() => _LoraHistoryViewState();
}

class _LoraHistoryViewState extends State<LoraHistoryView> {
  List<Map<String, dynamic>> logs = [];
  DateTime? _startDate;
  DateTime? _endDate = DateTime.now();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    const String apiUrl =
        'https://wingspotbackend-dzc0anehbyfzg7a9.eastus-01.azurewebsites.net/api/lora/all';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        // Print the raw response body
        print("API Response: ${response.body}");

        // Decode the JSON response and print it for better visibility
        final List<dynamic> data = json.decode(response.body);
        print("Parsed Data: $data");

        setState(() {
          logs = data
              .map((log) => {
                    "id": log['id'],
                    "detail": log['detail'],
                    "time": log['time'],
                    "logmessage": log['logmessage'],
                    "createdAt": log['createdAt'],
                  })
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load logs: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching logs: $e')),
      );
    }
  }

  void _filterLogs() {
    if (_startDate != null && _endDate != null) {
      setState(() {
        logs = logs.where((log) {
          DateTime logDate = DateTime.parse(log['createdAt']);
          return logDate.isAfter(_startDate!) &&
              logDate.isBefore(_endDate!.add(const Duration(days: 1)));
        }).toList();
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = DateTime.now();
    });
    _fetchLogs(); // Refetch logs to show unfiltered data
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate ?? DateTime.now() : _endDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lora Log History'),
        backgroundColor: const Color.fromARGB(255, 17, 55, 13),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Text("Start Date"),
                              TextButton(
                                onPressed: () => _selectDate(context, true),
                                child: Text(_startDate != null
                                    ? "${_startDate!.toLocal()}".split(' ')[0]
                                    : 'Select Start Date'),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Text("End Date"),
                              TextButton(
                                onPressed: () => _selectDate(context, false),
                                child: Text(_endDate != null
                                    ? "${_endDate!.toLocal()}".split(' ')[0]
                                    : 'Select End Date'),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _filterLogs,
                              style: ElevatedButton.styleFrom(
                                primary: Colors
                                    .green, // Set the background color to green
                              ),
                              child: const Text('Search'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _clearFilters,
                              style: ElevatedButton.styleFrom(
                                primary: Colors
                                    .green, // Set the background color to green
                              ),
                              child: const Text('Clear'),
                            ),
                          ],
                        )
                      ],
                    )),
                Expanded(
                  child: logs.isNotEmpty
                      ? ListView.builder(
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            final log = logs[index];

                            // Define a common text style
                            final textStyle = TextStyle(
                              color:
                                  Colors.black, // Set the color you want here
                            );

                            return Card(
                              margin: const EdgeInsets.all(8.0),
                              child: ListTile(
                                leading: Image.asset(
                                  'assets/images/dove.png',
                                  width: 34,
                                  height: 34,
                                  color: const Color.fromARGB(255, 13, 58, 6),
                                ),
                                title: Text(
                                  "Detail: ${log['logmessage']}",
                                  style: textStyle,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Time: ${log['time']}",
                                      style: textStyle,
                                    ),
                                    Text(
                                      "Date: ${log['createdAt'].split('T')[0]}",
                                      style: textStyle,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(child: Text('No logs available')),
                )
              ],
            ),
    );
  }
}
