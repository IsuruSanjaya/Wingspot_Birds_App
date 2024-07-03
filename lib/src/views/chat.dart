import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:wingspot/src/views/home.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  void _sendMessage(String text) {
    if (text.isNotEmpty) {
      setState(() {
        _messages.add(Message(
          content: text,
          type: MessageType.text,
          isSent: true,
          timestamp: DateTime.now(),
          status: MessageStatus.sent,
        ));
      });
      _controller.clear();
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _sendImage() {
    if (_imageFile != null) {
      setState(() {
        _messages.add(Message(
          content: _imageFile!.path,
          type: MessageType.image,
          isSent: true,
          timestamp: DateTime.now(),
          status: MessageStatus.sent,
        ));
        _imageFile = null;
      });
    }
  }

  Widget _buildMessage(Message message) {
    final alignment =
        message.isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final backgroundColor =
        message.isSent ? Colors.lightBlueAccent : Colors.grey[300];
    final textColor = message.isSent ? Colors.white : Colors.black;

    String formattedTime = DateFormat('hh:mm a').format(message.timestamp);
    Icon statusIcon;

    switch (message.status) {
      case MessageStatus.sent:
        statusIcon = const Icon(Icons.check, size: 14, color: Colors.grey);
        break;
      case MessageStatus.delivered:
        statusIcon = const Icon(Icons.done_all, size: 14, color: Colors.grey);
        break;
      case MessageStatus.read:
        statusIcon = const Icon(Icons.done_all, size: 14, color: Colors.blue);
        break;
      default:
        statusIcon = const Icon(Icons.check, size: 14, color: Colors.grey);
    }

    if (message.type == MessageType.text) {
      return Align(
        alignment:
            message.isSent ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: alignment,
            children: [
              Text(message.content, style: TextStyle(color: textColor)),
              const SizedBox(height: 5),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formattedTime,
                    style: TextStyle(color: textColor, fontSize: 10),
                  ),
                  if (message.isSent) ...[
                    const SizedBox(width: 5),
                    statusIcon,
                  ]
                ],
              ),
            ],
          ),
        ),
      );
    } else if (message.type == MessageType.image) {
      return Align(
        alignment:
            message.isSent ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: alignment,
            children: [
              Image.file(File(message.content),
                  width: 150, height: 150, fit: BoxFit.cover),
              const SizedBox(height: 5),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formattedTime,
                    style: TextStyle(color: textColor, fontSize: 10),
                  ),
                  if (message.isSent) ...[
                    const SizedBox(width: 5),
                    statusIcon,
                  ]
                ],
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildPreview() {
    if (_imageFile == null) return const SizedBox.shrink();
    return Container(
      color: Colors.grey[500], // Set the background color
      padding: const EdgeInsets.all(8.0), // Add padding
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(_imageFile!, width: 250, height: 250, fit: BoxFit.cover),
            const SizedBox(height: 8.0), // Add spacing between image and row
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center the row content
              children: [
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendImage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop();
          return true;
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 40),
              alignment: Alignment.center,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen(
                                  userId: '',
                                )), // Replace with your home screen
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Community Chat',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessage(_messages[index]);
                },
              ),
            ),
            if (_imageFile != null) _buildPreview(),
            if (_imageFile == null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.image),
                      onPressed: _pickImage,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration:
                            const InputDecoration(hintText: 'Type a message'),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => _sendMessage(_controller.text),
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
