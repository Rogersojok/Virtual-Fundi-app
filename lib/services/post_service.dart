import 'package:flutter/material.dart';
import '../database/database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:virtualfundi/services/sharedP.dart';
import 'package:virtualfundi/services/access_token.dart';



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
    showSessionFeedback(context);
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

  // Loop through the feedback and print each one
  for (var f in feedbackD) {
    if (ids.contains(f['teacherId'].toString())) {
    }else{
      sendData(context, f);
    }
  }
}


// Send POST request to Django server
Future<void> sendData(BuildContext context, data) async {
  final url = Uri.parse('https://fbappliedscience.com/api/addFeedback'); // Replace with your Django API URL
  String? token = await getToken(); // Retrieve stored token
  print(token);

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Token $token', // Add token to request
        'Content-Type': 'application/json', // Ensure you're sending JSON
      },
      body: json.encode(data), // Convert the data to JSON format
    );
    if (response.statusCode == 201) {
      // Success
      //ids.add(data['teacherId']);
      await SharedPrefsHelper.saveId(data['teacherId']);
      print('Data sent successfully: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Done Sycing feedback"),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      // Handle failure
      print('Failed to send data: ${response.statusCode}, ${response.body}');
    }
  } catch (e) {
    // Handle errors, such as no internet connection
    print('Error occurred: $e');
  }
}


//

Future<void> showSessionFeedback(BuildContext context) async {
  List<Map<String, dynamic>> SessionfeedbackD = [];
  List<String> ids = await SharedPrefsHelper.loadSessionFeedbackIds();
  print("Session Feedback Saved IDs: $ids");

  final dbHelper = DatabaseHelper();
  await dbHelper.initializeDatabase();

  // Fetch the feedbacks from the database
  final sessionFeedbacks = await dbHelper.getAllSessionFeedback();

  // Map the feedbacks into a List<Map<String, dynamic>> directly
  SessionfeedbackD = sessionFeedbacks.map((sessionFeedback) => sessionFeedback.toMap()).toList();


  // Loop through the feedback and print each one
  for (var sessionFeedaback in SessionfeedbackD) {
    if (ids.contains(sessionFeedaback['feedbackId'].toString())) {
    }else{
      final timestamp = sessionFeedaback['time'];
      DateTime dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
      sessionFeedaback['time'] = dt.toIso8601String();
      sendSessionFeedbackData(context, sessionFeedaback);
    }
  }
}


Future<void> sendSessionFeedbackData(BuildContext context, data) async {
  final url = Uri.parse('https://fbappliedscience.com/api/addSessionFeedback'); // Replace with your Django API URL
  String? token = await getToken(); // Retrieve stored token
  print(token);

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Token $token', // Add token to request
        'Content-Type': 'application/json', // Ensure you're sending JSON
      },
      body: json.encode(data), // Convert the data to JSON format
    );
    if (response.statusCode == 201) {
      // Success
      //ids.add(data['teacherId']);
      await SharedPrefsHelper.sessionFeedbackId(data['feedbackId']);
      print('Session Feedback Data sent successfully: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Done Syncing session feedback"),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      // Handle failure
      print('Failed to send SessionFeedback data: ${response.statusCode}, ${response.body}');
    }
  } catch (e) {
    // Handle errors, such as no internet connection
    print('Error occurred: $e');
  }
}


