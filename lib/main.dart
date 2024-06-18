import 'package:flutter/material.dart';
//import 'package:login_signup/screens/welcome_screen.dart';
import 'package:virtualfundi/screens/welcome_screen.dart';
//import 'package:login_signup/theme/theme.dart';
import 'package:virtualfundi/theme/theme.dart';
import 'database/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().initializeDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
