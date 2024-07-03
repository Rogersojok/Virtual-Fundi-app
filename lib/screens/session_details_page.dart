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
    setState(() {
      print(session.sessionName);
      print("-------------session details above------------------");
    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScaffold(
        child: Column(
          children: [
            const Expanded(
              flex: 1,
              child: SizedBox(height: 10),
            ),
            Expanded(
              flex: 7,
              child: Container(
                padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 20.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20.0),
                      Text(
                        ' ${widget.sessionName}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      // Session details
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Html(data:'<b>Resources Provided by Fundi Bots</b>: ${session.fundibotsResources}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Html(data: '<b>Resources Provided by School</b>: ${session.schoolResources}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.access_time),
                            SizedBox(width: 5),
                            //Text('Duration: ${session.duration} minutes'),
                            Text(
                              'Duration: ${session.duration} minutes',
                              style: TextStyle(
                                fontWeight: FontWeight.bold, // Replace with your desired color
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Html(data:'<b>Learning Objectives</b>: ${session.learningObjective}'),
                      ),


                      const SizedBox(height: 20.0),
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
            ),
          ],
        ),
      ),
    );


  }
}

