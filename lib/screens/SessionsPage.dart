import 'package:flutter/material.dart';
import 'package:virtualfundi/screens/signup_screen.dart';
import '../theme/theme.dart';
import '../widgets/custom_scaffold.dart';
import 'session_details_page.dart'; // Import the session details page
import 'dart:convert'; // for convert response to json
import 'package:http/http.dart' as http; // Import http package for making api request.
import '../database/database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utills/animateAButton.dart';

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
    //_checkInternetAndFetchData();
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

      // Convert JSON data to Session objects and insert into the database
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

      // Retrieve all topics from the database and print them
      final sessionsData = await dbHelper.retrieveAllSession(widget.topicId);
      //print(sessionsData);

      setState(() {
        sessions = sessionsData.map((session) => session.toMap()).toList();
        //print(sessions);
        print("------------------session page------------------------------");
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchLocalData() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initializeDatabase();

    // Retrieve all sessions under a topic from the database and print them
    final sessionsData = await dbHelper.retrieveAllSession(widget.topicId);
    //print(sessionsData);

    setState(() {
      sessions = sessionsData.map((session) => session.toMap()).toList();
      //print(sessions);
      print("------------------session page------------------------------");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20.0),
                      Text(
                        widget.topic,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: DataTable(
                            columnSpacing: 30.0,
                            columns: [
                              DataColumn(label: Text('No.', textAlign: TextAlign.center)),
                              DataColumn(label: Text('Session Name', textAlign: TextAlign.center)),
                              DataColumn(label: Text('Start Session', textAlign: TextAlign.center)),
                            ],
                            rows: sessions.map((session) {
                              int index = sessions.indexOf(session) + 1; // Calculate the index
                              return DataRow(cells: [
                                DataCell(
                                  Text(
                                    '$index',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    child: Text(
                                      session['sessionName'],
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.3,
                                    child: AnimatedElevatedButton(
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

                                      text:'View',
                                      ),
                                    ),
                                  ),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                      SizedBox(height: 25.0),
                      Divider(
                        thickness: 0.7,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      SizedBox(height: 25.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // IconButtons or Icons for social media login
                        ],
                      ),
                      SizedBox(height: 25.0),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpScreen(),
                            ),
                          );
                        },
                        child: Text(
                          '',
                          style: TextStyle(fontWeight: FontWeight.bold, color: lightColorScheme.primary),
                        ),
                      ),
                      SizedBox(height: 20.0),
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
