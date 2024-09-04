import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/theme.dart';
import '../widgets/custom_scaffold.dart';
import '../database/database.dart';
import 'session_details_page.dart';
import 'home_screen.dart'; // Import the HomeScreen
import 'package:connectivity_plus/connectivity_plus.dart';

class SessionsPage extends StatefulWidget {
  final String topic;
  final int topicId;

  SessionsPage({required this.topic, required this.topicId});

  @override
  _SessionsPageState createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  List<Map<String, dynamic>> sessions = [];
  late final Connectivity _connectivity;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    fetchData();
    fetchLocalData();
  }

  Future<void> fetchData() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initializeDatabase();

    final response = await http
        .get(Uri.parse('http://161.97.81.168:8080/viewSessions/${widget.topicId}'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      for (var jsonData in data) {
        final session = Session(
          id: jsonData['id'],
          sessionName: jsonData['sessionName'],
          topic: jsonData['topic'],
          duration: jsonData['duration'],
          learningObjective: jsonData['learningObjective'],
          fundibotsResources: jsonData['fundibotsResources'],
          schoolResources: jsonData['schoolResources'],
          dateCreated: DateTime.parse(jsonData['dateCreated']),
        );
        await dbHelper.insertSession(session);
      }

      final sessionsData = await dbHelper.retrieveAllSession(widget.topicId);

      setState(() {
        sessions = sessionsData.map((session) => session.toMap()).toList();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchLocalData() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initializeDatabase();

    final sessionsData = await dbHelper.retrieveAllSession(widget.topicId);

    setState(() {
      sessions = sessionsData.map((session) => session.toMap()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Sessions',
      onBackPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userId: 1), // Replace with actual userId
          ),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              SizedBox(height: 20.0),
              Expanded(
                child: Container(
                  color: Colors.grey[100], // Match the background color of HomeScreen
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 16,
                      headingRowColor: MaterialStateColor.resolveWith(
                              (states) => Colors.blueGrey.shade50),
                      dataRowColor: MaterialStateColor.resolveWith(
                              (states) => Colors.white),
                      headingTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      columns: [
                        DataColumn(label: Text('Session Name')),
                        DataColumn(label: Text('Start Session')),
                      ],
                      rows: sessions.map((session) {
                        return DataRow(cells: [
                          DataCell(
                            Container(
                              width: constraints.maxWidth * 0.4, // 40% of the screen width
                              child: Text(
                                session['sessionName']!,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              width: constraints.maxWidth * 0.1, // 10% of the screen width
                              child: _buildStyledButton(
                                text: 'View',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SessionDetailsPage(
                                        sessionName: session['sessionName']!,
                                        sessionId: session['id']!,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        shadowColor: Colors.grey.withOpacity(0.5),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}
