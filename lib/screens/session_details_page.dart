import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../widgets/custom_scaffold.dart';
import 'activity_page.dart'; // Import the Activity page
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:flutter_html/flutter_html.dart';
import '../database/database.dart';
import '../utills/animateAButton.dart';

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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimelineItem(
                title: 'Resources Provided by Fundi Bots',
                description: session.fundibotsResources,
                icon: Icons.school,
              ),
              _buildTimelineItem(
                title: 'Resources Provided by School',
                description: session.schoolResources,
                icon: Icons.business,
              ),
              _buildTimelineItem(
                title: 'Session Duration',
                description: '${session.duration} minutes',
                icon: Icons.access_time,
              ),
              _buildTimelineItem(
                title: 'Learning Objectives',
                description: session.learningObjective,
                icon: Icons.lightbulb,
              ),
              const SizedBox(height: 40.0),
              Center(
                child: AnimatedElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivityPage(
                          sessionId: widget.sessionId,
                        ),
                      ),
                    );
                  },
                  text: 'Next',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 16,
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 8),
                Html(
                  data: description,
                  style: {
                    "body": Style(fontSize: FontSize.medium),
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
