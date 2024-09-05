import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class LoraViewLogs extends StatefulWidget {
  const LoraViewLogs({Key? key}) : super(key: key);

  @override
  _LoraViewLogsState createState() => _LoraViewLogsState();
}

class _LoraViewLogsState extends State<LoraViewLogs> {
  final List<Map<String, String>> logs = [];
  BluetoothDevice? connectedDevice;
  BluetoothConnection? connection;
  List<BluetoothDevice> pairedDevices = [];

  @override
  void initState() {
    super.initState();
    fetchPairedDevices();
  }

  void fetchPairedDevices() async {
    List<BluetoothDevice> bondedDevices =
        await FlutterBluetoothSerial.instance.getBondedDevices();

    setState(() {
      pairedDevices = bondedDevices;
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    if (connectedDevice != null) {
      print('Already connected to another device');
      return;
    }

    try {
      // Attempt to establish a connection
      BluetoothConnection.toAddress(device.address)
          .then((BluetoothConnection conn) {
        setState(() {
          connection = conn;
          connectedDevice = device;
        });
        print('Connected to device with address: ${device.address}');
        connection?.input?.listen((data) {
          String message = String.fromCharCodes(data);
          processMessage(message);
        }).onDone(() {
          print('Disconnected by remote device');
          setState(() {
            connectedDevice = null;
            connection = null;
          });
        });
      }).catchError((error) {
        print('Error connecting to device: $error');
        // Optionally, handle retries or show user-friendly error messages
      });
    } catch (e) {
      print('Error connecting to device: $e');
      // Retry connection after a delay
      await Future.delayed(Duration(seconds: 5));
      connectToDevice(device); // Retry connection
    }
  }

  void processMessage(String message) {
    setState(() {
      // Add the message to the logs
      logs.add({
        "time": DateTime.now().toLocal().toString().split(' ')[1],
        "details": message.trim()
      });
    });
  }

  void showDeviceSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select a device'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300.0,
            child: ListView.builder(
              itemCount: pairedDevices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(pairedDevices[index].name ?? 'Unknown Device'),
                  subtitle: Text(pairedDevices[index].address),
                  onTap: () {
                    Navigator.of(context).pop();
                    connectToDevice(pairedDevices[index]);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
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
        title: const Text('LoRa Live Logs'),
        backgroundColor: const Color.fromARGB(255, 18, 71, 33),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                if (connectedDevice == null) {
                  showDeviceSelectionDialog();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bluetooth, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      connectedDevice != null
                          ? 'Connected to ${connectedDevice!.name}'
                          : 'Not Connected - Tap to Connect',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            connectedDevice != null ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    if (index >= 0 && index < logs.length) {
                      String logMessage = logs[index]['details'] ?? '';
                      double opacity =
                          logMessage.contains("Bird Detected") ? 1.0 : 0.5;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            if (logMessage.contains("Bird Detected")) ...[
                              Image.asset(
                                'assets/images/dove.png',
                                width: 34,
                                height: 34,
                                color: const Color.fromARGB(255, 13, 58, 6),
                              ),
                              const SizedBox(width: 8),
                            ],
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          if (!logMessage
                                              .contains("Bird Detected")) ...[
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
                    } else {
                      return const SizedBox
                          .shrink(); // Return an empty widget if the index is invalid
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
