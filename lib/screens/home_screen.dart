import 'package:flutter/material.dart';
import '../widgets/custom_scaffold.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'SessionsPage.dart';
import 'addSubject_Class.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';
import '../theme/theme.dart';
import '../database/database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utills/animateAButton.dart';

class HomeScreen extends StatefulWidget {
  final int? userId;

  HomeScreen({required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> scienceTopics = [];
  List<Map<String, dynamic>> filteredTopics = [];
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    _connectivity.onConnectivityChanged;
    fetchData();
    fetchLocalData();
  }

  Future<void> fetchData() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initializeDatabase();

    final response = await http.get(Uri.parse('http://161.97.81.168:8080/'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      for (var jsonData in data) {
        final topic = Topic(
          id: jsonData['id'],
          topicName: jsonData['topicName'],
          topicCode: jsonData['topicCode'],
          term: jsonData['term'],
          cat: jsonData['cat'],
          subject: jsonData['subject'],
          classTaught: jsonData['classTaught'],
          dateCreated: DateTime.parse(jsonData['dateCreated']),
        );
        await dbHelper.insertTopic(topic);
      }

      final topics = await dbHelper.getTopicsForUser(widget.userId!);

      setState(() {
        scienceTopics = topics.map((topic) => topic.toMap()).toList();
        filteredTopics = List.from(scienceTopics);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchLocalData() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initializeDatabase();

    final topics = await dbHelper.getTopicsForUser(widget.userId!);

    setState(() {
      scienceTopics = topics.map((topic) => topic.toMap()).toList();
      filteredTopics = List.from(scienceTopics);
    });
  }

  void filterTopics(String query) {
    setState(() {
      filteredTopics = scienceTopics
          .where((topic) =>
          topic['topicName']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScaffold(
        child: Container(
          color: Colors.white, // Background color of the entire screen
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20.0),
                    Container(
                      color: Colors.grey[100], // Light grey background for the form area
                      padding: const EdgeInsets.all(16.0), // Padding for better layout
                      margin: const EdgeInsets.symmetric(horizontal: 16.0), // Margin for centering
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth,
                        ),
                        child: DataTable(
                          columnSpacing: 16, // Increased spacing for readability
                          headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey.shade50),
                          dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
                          headingTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          columns: const [
                            DataColumn(label: Text('Topic')),
                            DataColumn(label: Text('Class')),
                            DataColumn(label: Text('Term')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: filteredTopics.map((topic) => DataRow(cells: [
                            DataCell(
                              Container(
                                width: 200, // Fixed width for Topic column
                                child: Text(
                                  topic['topicName']!,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                width: 100, // Fixed width for Class column
                                child: Text(
                                  topic['classTaught']!,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                width: 100, // Fixed width for Term column
                                child: Text(
                                  topic['term']!,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  _buildStyledButton(
                                    text: 'Prepare',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SessionsPage(
                                            topic: topic['topicName'],
                                            topicId: topic['id'],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 8.0),
                                  _buildStyledButton(
                                    text: 'Start Class',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SessionsPage(
                                            topic: topic['topicName']!,
                                            topicId: topic['id']!,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ])).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25.0),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Add_Subject_Class(userId: widget.userId),
            ),
          );
        },
        backgroundColor: Colors.blueAccent, // Blue background for FAB
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: const Icon(Icons.add),
        tooltip: 'Add Subject and Class',
      ),
    );
  }

  // Function to build styled buttons
  Widget _buildStyledButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, // Text color
        backgroundColor: Colors.blueAccent, // Button color
        shadowColor: Colors.grey.withOpacity(0.5),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}
