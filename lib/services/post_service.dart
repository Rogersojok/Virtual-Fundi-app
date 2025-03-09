import 'package:flutter/material.dart';
import '../database/database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:virtualfundi/services/sharedP.dart';



class AppInitializationService {
  static final AppInitializationService _singleton = AppInitializationService._internal();

  factory AppInitializationService() {
    return _singleton;
  }

  AppInitializationService._internal();

  // Method that runs initialization code
  void runInitialization(BuildContext context) {
    print('App Initialization code running...');
    showFeedback(context);
    // Add any code you want to keep running here
  }

  // Add any other methods for recurring tasks
  void backgroundTask() {
    print('Running background task...');
  }
}


Future<void> showFeedback(BuildContext context) async {
  List<Map<String, dynamic>> feedbackD = [];
  List<String> ids = await SharedPrefsHelper.loadIds();
  print("Saved IDs: $ids");

  final dbHelper = DatabaseHelper();
  await dbHelper.initializeDatabase();

  // Fetch the feedbacks from the database
  final feedbacks = await dbHelper.getAllTeacherData();

  // Map the feedbacks into a List<Map<String, dynamic>> directly
  feedbackD = feedbacks.map((feedback) => feedback.toMap()).toList();

  // Show a Snackbar to indicate syncing has started
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("Syncing data..."),
      duration: Duration(seconds: 3),
    ),
  );

  // Loop through the feedback and print each one
  for (var f in feedbackD) {
    print("+++++++++++++++++++++++++++++++++++++++");
    if (ids.contains(f['teacherId'].toString())) {
      print("data has been sync already");
    }else{
      sendData(f);
    }
    print("+++++++++++++++++++++++++++++++++++++++");
  }
  // Show a final message when sync is complete
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("Sync complete!"),
      duration: Duration(seconds: 3),
    ),
  );
}


// Send POST request to Django server
Future<void> sendData(data) async {
  final url = Uri.parse('http://161.97.81.168:8080/addFeedback'); // Replace with your Django API URL

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json', // Ensure you're sending JSON
      },
      body: json.encode(data), // Convert the data to JSON format
    );
    if (response.statusCode == 201) {
      // Success
      //ids.add(data['teacherId']);
      await SharedPrefsHelper.saveId(data['teacherId']);
      print('Data sent successfully: ${response.body}');
    } else {
      // Handle failure
      print('Failed to send data: ${response.statusCode}');
    }
  } catch (e) {
    // Handle errors, such as no internet connection
    print('Error occurred: $e');
  }
}
