import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wingspot/src/views/chat.dart';
import 'package:wingspot/src/views/home.dart';
import 'package:wingspot/src/views/login.dart';
import 'package:wingspot/src/views/logintype.dart';
import 'package:wingspot/src/views/register.dart';
import 'package:wingspot/src/views/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/chat': (context) => ChatScreen(),
      },
    );
  }
}
