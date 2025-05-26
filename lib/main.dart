import 'package:flutter/material.dart';
import 'package:virtualfundi/screens/welcome_screen.dart';
import 'package:virtualfundi/theme/theme.dart';
import 'database/database.dart';
import 'package:virtualfundi/services/post_service.dart';
import 'dart:io';
import 'package:virtualfundi/services/access_token.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().initializeDatabase();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});


  @override
  State<MyApp> createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  void initState() {
    super.initState();
    checkInternet3();
    saveToken("virtual_app_token");
    AppInitializationService().runInitialization(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: lightMode,
      home: const WelcomeScreen(),
    );
  }
}

// fetch data from the teacherTable
// and post it

void checkInternet3() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('Connected to the internet');
    }
  } catch (_) {
      print('No internet connection');
  }
}
