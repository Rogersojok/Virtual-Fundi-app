import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../widgets/custom_scaffold.dart';
import 'activity_page.dart'; // Import the Activity page
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:flutter_html/flutter_html.dart';
import '../database/database.dart';

class SessionDetailsPage extends StatefulWidget {
  final String sessionName;
  final int sessionId;

  SessionDetailsPage({required this.sessionName, required this.sessionId});

  @override
  _SessionDetailsPageState createState() => _SessionDetailsPageState();
}

class _SessionDetailsPageState extends State<SessionDetailsPage> {
  late final session;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initializeDatabaseAndFetchData();
  }

  Future<void> initializeDatabaseAndFetchData() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initializeDatabase();
    await fetchDataT();
  }

  Future<void> fetchDataT() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initializeDatabase();
    session = (await dbHelper.getSessionById(widget.sessionId))!;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: widget.sessionName,
      onBackPressed: () => Navigator.pop(context),
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background_texture.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16.0), // Adjusted spacing
                  _buildTimelineItem(
                    title: 'Resources Provided by Fundi Bots',
                    description: session.fundibotsResources,
                    icon: Icons.school,
                    iconColor: Colors.white,
                  ),
                  _buildTimelineItem(
                    title: 'Resources Provided by School',
                    description: session.schoolResources,
                    icon: Icons.business,
                    iconColor: Colors.white,
                  ),
                  _buildTimelineItem(
                    title: 'Session Duration',
                    description: '${session.duration} minutes',
                    icon: Icons.access_time,
                    iconColor: Colors.white,
                  ),
                  _buildTimelineItem(
                    title: 'Learning Objectives',
                    description: session.learningObjective,
                    icon: Icons.lightbulb,
                    iconColor: Colors.white,
                  ),
                  const SizedBox(height: 32.0),
                  Center(
                    child: _buildStyledButton(
                      text: 'Next',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ActivityPage(
                              sessionId: session.id,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Reduced vertical spacing
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.orange[200], // Changed to orange color
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.orange, // Matching icon container color
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                Container(
                  width: 2,
                  height: 80,
                  color: Colors.grey,
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Html(
                    data: description,
                    style: {
                      "body": Style(
                        fontSize: FontSize.medium,
                        color: Colors.black54,
                      ),
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledButton({required String text, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      splashColor: Colors.blueAccent.withOpacity(0.2),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
