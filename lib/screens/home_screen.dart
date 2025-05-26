import 'package:flutter/material.dart';
import '../widgets/custom_scaffold.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'SessionsPage.dart';
import 'addSubject_Class.dart';
import '../database/database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:virtualfundi/services/access_token.dart';


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
    // retrive access token
    String? token = await getToken(); // Retrieve stored token
    // initialize the database
    final dbHelper = DatabaseHelper();
    await dbHelper.initializeDatabase();
    //checkInternet3();

    final response = await http.get(Uri.parse('https://fbappliedscience.com/api/'),
      headers: {
        'Authorization': 'Token $token', // Add token to request
        'Content-Type': 'application/json',
      },
    );

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

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('topic ${jsonData['topicName']}')));

        // get all sessions under this topic
        final response = await http.get(
          Uri.parse('https://fbappliedscience.com/api/viewSessions/${jsonData['id']}'),
          headers: {
            'Authorization': 'Token $token', // Add token to request
            'Content-Type': 'application/json',
          },
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
            final topics = await dbHelper.getTopicsForUser(widget.userId!);

            setState(() {
              scienceTopics = topics.map((topic) => topic.toMap()).toList();
              filteredTopics = List.from(scienceTopics);
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                  SnackBar(content: Text('session ${jsonData['sessionName']}')));
            });

            //get all activities under each session here
            final response = await http.get(Uri.parse(
                'https://fbappliedscience.com/api/viewActivities/${jsonData['id']}'),
              headers: {
                'Authorization': 'Token $token', // Add token to request
                'Content-Type': 'application/json',
              },
            );

            if (response.statusCode == 200) {
              List<dynamic> data = json.decode(response.body);

              // Convert JSON data to Session objects and insert into the database
              for (var jsonData in data) {
                // download video here before inserting in the database.

                // insert the data including the video url.
                final activity = Activity(
                  id: jsonData['id'],
                  title: jsonData['title'],
                  session: jsonData['session'],
                  teacherActivity: jsonData['teacherActivity'],
                  studentActivity: jsonData['studentActivity'],
                  mediaType: jsonData['mediaType'],
                  time: jsonData['time'] ?? 5,
                  notes: jsonData['notes'],
                  image: jsonData['image'] ?? "",
                  imageTitle: jsonData['image_title'] ?? "",
                  video: jsonData['video'] ?? "",
                  videoTitle: jsonData['video_title'] ?? "",
                  realVideo: jsonData['real_video'],
                  createdAt: DateTime.parse(jsonData['created_at']),
                );
                await dbHelper.insertActivity(activity);

                setState(() {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                      SnackBar(content: Text('activity ${jsonData['title']}')));
                });
              }
            } else {
              throw Exception('Failed to load activity data');
            }
          }
        } else {
          print('failed response ${response.body}');
          throw Exception('Failed to load session data');
        }
      }

      final topics = await dbHelper.getTopicsForUser(widget.userId!);

      setState(() {
        scienceTopics = topics.map((topic) => topic.toMap()).toList();
        filteredTopics = List.from(scienceTopics);
      });
    } else {
      throw Exception('Failed to load topic data');
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
    // loop through topics and get sessions under each topic


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
            ElevatedButton(onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FeedbackScreen(),
                ),
              );
            }, child: Text('Feedback', style: TextStyle(color: Colors.blue),)),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 16.0, horizontal: 12.0),
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
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 12),
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
                                    style: const TextStyle(
                                        color: Colors.white70),
                                  ),
                                  Text(
                                    'Term: ${topic['term']}',
                                    style: const TextStyle(
                                        color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                  Icons.backpack, color: Colors.white),
                              onPressed: () {},
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SessionsPage(
                                        topic: topic['topicName'],
                                        topicId: topic['id'],
                                      ),
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SessionsPage(
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
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SessionsPage(
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
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold),
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



  // download video
  Future<String> downloadFile(String fileUrl, Function(int) onProgress,
      String isVideo) async {
    // Check if fileUrl is empty before proceeding
    if (fileUrl
        .trim()
        .isEmpty) {
      print("File URL is empty. Skipping download.");
      return "File URL is empty";
    }

    try {
      // check if video is not a placeholder
      if (isVideo == "placeholder" && fileUrl
          .trim()
          .isEmpty) {
        return "placeholder video";
      } else {
        var httpClient = http.Client();
        var request = http.Request('GET', Uri.parse(
            'https://fbappliedscience.com/api${fileUrl}'),

        );

        var response = await httpClient.send(request);


        // Extract filename from the URL
        Uri uri = Uri.parse(fileUrl);
        String fileName = uri.pathSegments.last;

        late String filePath = '';

        int totalBytes = response.contentLength ?? -1;
        int receivedBytes = 0;

        if (response.statusCode == 200) {
          //var bytes = await response.stream.toBytes();
          var bytes = <int>[];
          print(response.headers);

          response.stream.listen(
                (List<int> chunk) {
              bytes.addAll(chunk);
              receivedBytes += chunk.length;

              // Calculate progress and call the onProgress function
              double progress = (receivedBytes / totalBytes) * 100;
              onProgress(progress.toInt()); // Pass the progress value
              // Show progress in a ScaffoldMessenger
              setState(() {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                    SnackBar(
                        content: Text('downloading.. $fileName -- $progress')));
              });
            },
            onDone: () async {
              // When download completes, write the file to local storage
              var appDir = await getApplicationDocumentsDirectory();
              filePath = '${appDir.path}/$fileName';
              File file = File(filePath);
              await file.writeAsBytes(bytes);
              //print('filePath in download function: $filePath');
            },
            onError: (e) async {
              throw Exception('Failed to download file: $e');
            },
          );
          return filePath;
        } else {
          // Handle HTTP error response
          ScaffoldMessenger.of(context)
              .showSnackBar(
              SnackBar(content: Text('Failed to download file')));
          throw Exception(
              'Failed to download file: HTTP ${response.statusCode}');
        }
      }
    } catch (e) {
        print("try error $e");
        return "try cach part";
    }
  }
}