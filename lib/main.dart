import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wingspot/src/views/Behaviour/audioScreen.dart';
import 'package:wingspot/src/views/Behaviour/bDashboard.dart';
import 'package:wingspot/src/views/Behaviour/videoScreen.dart';
import 'package:wingspot/src/views/Category/bird.dart';
import 'package:wingspot/src/views/Category/speciesIdentify.dart';
import 'package:wingspot/src/views/EggAnalysis/DetectView.dart';
import 'package:wingspot/src/views/EggAnalysis/resultJsonView.dart';
import 'package:wingspot/src/views/Lora/loraHistory_view.dart';
import 'package:wingspot/src/views/Lora/lora_view.dart';
import 'package:wingspot/src/views/Lora/loraimage_view.dart';
import 'package:wingspot/src/views/chat.dart';
import 'package:wingspot/src/views/Home/home.dart';
import 'package:wingspot/src/views/Login/login.dart';
import 'package:wingspot/src/views/Profile/profile.dart';
import 'package:wingspot/src/views/Register/register.dart';
import 'package:wingspot/src/views/SplashScreen/splash.dart';
import 'package:device_preview/device_preview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    DevicePreview(
      enabled: !const bool.fromEnvironment(
          'dart.vm.product'), // Enables DevicePreview in debug mode only
      builder: (context) => MyApp(), // Wrap your app
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: DevicePreview.appBuilder, // Add this line
      useInheritedMediaQuery:
          true, // Add this line to use the media query from DevicePreview
      locale: DevicePreview.locale(
          context), // Add this line to get locale from DevicePreview
      home: const HomeScreen(
        email: null,
        mobile: '',
        name: '',
      ),
      routes: {
        // '/home': (context) =>
        // const HomeScreen(email: '', mobile: '', name: '', image: null,),
        '/chat': (context) => const BirdScreen(),
        '/egg': (context) => const DetectView(),
        '/success': (context) => const ResultJsonView(),
        '/birdanalysis': (context) => const BirdAnalysis(),
        '/birdspecies': (context) => const SpeciesIdentify(),

        '/profile': (context) => const Profile(),
        '/login': (context) => const LoginScreen(),
        '/birda': (context) => const VideoScreen(),
        // '/birddash': (context) => const AnalysisScreen(),
        '/lora': (context) => const LoraImageView(),
        '/loralogs': (context) => const LoraViewLogs(),
        '/lorahistory': (context) => const LoraHistoryView(),
      },
    );
  }
}
