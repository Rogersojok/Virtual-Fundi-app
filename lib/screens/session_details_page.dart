import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../widgets/custom_scaffold.dart';
import 'activity_page.dart'; // Import the Activity page
import 'dart:convert'; // for convert response to json
import 'package:http/http.dart' as http; // Import http package for making api request.
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
  bool _showScrollIndicator = false;
  double _viewportHeight = 0;
  double _contentHeight = 0;

  @override
  void initState() {
    super.initState();
    initializeDatabaseAndFetchData();
    _scrollController.addListener(() {
      setState(() {
        _showScrollIndicator = _scrollController.hasClients &&
            _scrollController.offset < _scrollController.position.maxScrollExtent - 50;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewportHeight = MediaQuery.of(context).size.height;
      final contentHeight = _scrollController.position.maxScrollExtent + viewportHeight;
      setState(() {
        _viewportHeight = viewportHeight;
        _contentHeight = contentHeight;
        _showScrollIndicator = _contentHeight > _viewportHeight;
      });
    });
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
    setState(() {
      print(session.sessionName);
      print("-------------session details above------------------");
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: widget.sessionName,
      onBackPressed: () => Navigator.pop(context),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ' ${widget.sessionName}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: lightColorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  // Session details
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Html(data: '<b>Resources Provided by Fundi Bots</b>: ${session.fundibotsResources}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Html(data: '<b>Resources Provided by School</b>: ${session.schoolResources}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time),
                        const SizedBox(width: 5),
                        Text(
                          'Duration: ${session.duration} minutes',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Html(data: '<b>Learning Objectives</b>: ${session.learningObjective}'),
                  ),
                  const SizedBox(height: 80.0), // Additional space for the scroll indicator
                  AnimatedElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ActivityPage(sessionId: widget.sessionId,)),
                      );
                    },
                    text: 'Next',
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          ),
          if (_showScrollIndicator)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Scroll down for more',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Icon(Icons.arrow_downward, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
