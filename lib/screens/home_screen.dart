import 'package:flutter/material.dart';
import '../widgets/custom_scaffold.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'SessionsPage.dart';
import 'addSubject_Class.dart';
import '../database/database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'feedback_screen.dart';

class HomeScreen extends StatefulWidget {
  final int? userId;

  const HomeScreen({required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> scienceTopics = [];
  List<Map<String, dynamic>> filteredTopics = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchLocalData();

    // Add a listener to the search controller
    _searchController.addListener(_filterTopics);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  void _filterTopics() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      filteredTopics = scienceTopics.where((topic) {
        final topicName = topic['topicName'].toLowerCase();
        return topicName.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScaffold(
        title: 'Topics',
        child: Column(
          children: [
            ElevatedButton(onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FeedbackScreen(),
                ),
              );
            }, child: Text('Feedback', style: TextStyle(color: Colors.blue),)),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search topics...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            // Topic list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                itemCount: filteredTopics.length,
                itemBuilder: (context, index) {
                  final topic = filteredTopics[index];
                  final backgroundColor = _getRowColor(index);
                  final icon = _getIconForIndex(index);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            leading: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(
                                icon,
                                color: backgroundColor,
                              ),
                            ),
                            title: Text(
                              topic['topicName']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Class: ${topic['classTaught']}',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  Text(
                                    'Term: ${topic['term']}',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.backpack, color: Colors.white),
                              onPressed: () {},
                            ),
                            onTap: () {
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
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
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: backgroundColor,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                      horizontal: 24.0,
                                    ),
                                  ),
                                  child: const Text(
                                    'Prepare',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                ElevatedButton(
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
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: backgroundColor,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                      horizontal: 24.0,
                                    ),
                                  ),
                                  child: const Text(
                                    'Start Class',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        tooltip: 'Add Subject and Class',
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    final icons = [
      Icons.design_services,
      Icons.design_services,
      Icons.design_services,
      Icons.design_services,
    ];
    return icons[index % icons.length];
  }

  Color _getRowColor(int index) {
    final colors = [
      Colors.green,
      Colors.orange,
      Colors.blue,
      Colors.pink,
    ];
    return colors[index % colors.length].withOpacity(0.9);
  }
}
