import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/custom_scaffold.dart';
import '../database/database.dart';
import 'session_details_page.dart';
import 'home_screen.dart';
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
  List<Map<String, dynamic>> filteredSessions = [];
  late final Connectivity _connectivity;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    //fetchData();
    fetchLocalData();
    _searchController.addListener(_filterSessions);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initializeDatabase();

    final response = await http.get(
      Uri.parse('http://161.97.81.168:8080/viewSessions/${widget.topicId}'),
    );

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
        filteredSessions = List.from(sessions);
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
      filteredSessions = List.from(sessions);
    });
  }

  void _filterSessions() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredSessions = sessions
          .where((session) =>
          session['sessionName']!.toLowerCase().contains(query))
          .toList();
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
            builder: (context) => HomeScreen(userId: 1),
          ),
        );
      },
      child: SafeArea(
        child: Container(
          // Updated gradient background leaning toward an indigo (near purple) hue
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.indigo.shade50,
                Colors.indigo.shade100,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Banner with updated indigo gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.indigo.shade400,
                        Colors.indigo.shade600,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.shade300.withOpacity(0.4),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'Sessions for: ${widget.topic}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                // Search Bar with focus color updated to indigo
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    hintText: 'Search sessions...',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    prefixIcon:
                    Icon(Icons.search, color: Colors.grey.shade600),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.indigo),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Sessions List
                Expanded(
                  child: filteredSessions.isEmpty
                      ? Center(
                    child: Text(
                      'No sessions available at the moment.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                      : ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: filteredSessions.length,
                    itemBuilder: (context, index) {
                      final session = filteredSessions[index];
                      return InkWell(
                        onTap: () {
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
                        child: Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white,
                                  Colors.grey.shade50,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              // Styled leading icon inside a CircleAvatar
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigo.shade100,
                                radius: 24,
                                child: Icon(
                                  Icons.event,
                                  color: Colors.indigo.shade700,
                                  size: 28,
                                ),
                              ),
                              title: Text(
                                session['sessionName']!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              // Styled trailing icon with a custom container
                              trailing: Container(
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade100,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: Colors.indigo.shade700,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
