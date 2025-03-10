import 'package:flutter/material.dart';
import '../database/database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

List<int> ids = [];

class AppInitializationService {
  static final AppInitializationService _singleton = AppInitializationService._internal();

  factory AppInitializationService() {
    return _singleton;
  }

  AppInitializationService._internal();

  // Method that runs initialization code
  void runInitialization() {
    print('App Initialization code running...');
    showFeedback();
    // Add any code you want to keep running here
  }

  // Add any other methods for recurring tasks
  void backgroundTask() {
    print('Running background task...');
  }
}


Future<void> showFeedback() async {
  List<Map<String, dynamic>> feedbackD = [];

  final dbHelper = DatabaseHelper();
  await dbHelper.initializeDatabase();

  // Fetch the feedbacks from the database
  final feedbacks = await dbHelper.getAllTeacherData();

  // Map the feedbacks into a List<Map<String, dynamic>> directly
  feedbackD = feedbacks.map((feedback) => feedback.toMap()).toList();

  // Loop through the feedback and print each one
  for (var f in feedbackD) {
    print("+++++++++++++++++++++++++++++++++++++++");
    print(f);
    sendData(f);
    print("+++++++++++++++++++++++++++++++++++++++");
  }
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
      ids.add(data['id']);
      print(ids);
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
