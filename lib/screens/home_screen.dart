import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
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

  Future<String> downloadFile(Activity activity, Function(int) onProgress) async {
    String? token = await getToken();
    try {
      var httpClient = http.Client();

      // Get activity data
      var activityResponse = await http.get(
        Uri.parse('https://fbappliedscience.com/api/getActivity/${activity.id}'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> data = json.decode(activityResponse.body);
      String fileUrl = data['video'];
      if (data['real_video'] == "placeholder") {
        return "placeholder video";
      }

      // Extract filename
      Uri uri = Uri.parse(fileUrl);
      String fileName = uri.pathSegments.last;

      // Prepare file path
      final appDir = await getApplicationDocumentsDirectory();
      final filePath = '${appDir.path}/$fileName';
      final file = File(filePath);

      // Stream download directly to file
      var request = http.Request('GET', Uri.parse('https://fbappliedscience.com/api$fileUrl'));
      var response = await httpClient.send(request);

      if (response.statusCode != 200) {
        throw Exception('Failed to download file: HTTP ${response.statusCode}');
      }

      int totalBytes = response.contentLength ?? -1;
      int receivedBytes = 0;

      final sink = file.openWrite();

      // Stream chunks directly to disk
      await for (var chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          double progress = (receivedBytes / totalBytes) * 100;
          onProgress(progress.toInt());
          setState(() {}); // optional: update UI
        }
      }

      await sink.close();

      // Update activity in database
      final dbHelper = DatabaseHelper();
      await dbHelper.initializeDatabase();

      final updatedActivity = Activity(
        id: activity.id,
        title: activity.title,
        session: activity.session,
        teacherActivity: activity.teacherActivity,
        studentActivity: activity.studentActivity,
        mediaType: activity.mediaType,
        time: activity.time ?? 5,
        notes: activity.notes,
        image: activity.image ?? "",
        imageTitle: activity.imageTitle ?? "",
        video: filePath,
        videoTitle: activity.videoTitle,
        realVideo: data['real_video'],
        createdAt: activity.createdAt,
      );

      await dbHelper.updateActivity(updatedActivity);

      return filePath;
    } catch (error) {
      throw Exception('Failed to download file: $error');
    }
  }


/*
  Future<void> fetchData() async {
    // retrive access token
    String? token = await getToken(); // Retrieve stored token
    // initialize the database
    final dbHelper = DatabaseHelper();
    await dbHelper.initializeDatabase();
    //checkInternet3();

    final response = await http.get(
      Uri.parse('https://fbappliedscience.com/api/'),
      headers: {
        'Authorization': 'Token $token', // Add token to request
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      // get all topics from the database
      final localTimestamps = await dbHelper.retrieveTopicTimestamps();

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

        // get the online time
        final onlineTime = DateTime.parse(jsonData['dateCreated']);
        final localUpdateTime = localTimestamps[topic.id];

        if (localUpdateTime == null) {
          // topic doesnt exit, insert
          bool success = await dbHelper.insertTopic(topic);

          if (success) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(
                content: Text('inserted topic ${jsonData['topicName']}')));
          }
        } else {
          // Timestamp exists — compare and update if needed
          final localUpdateT = DateTime.parse(localUpdateTime);

          if (onlineTime.isAfter(localUpdateT)) {
            // update the topic
            // topic doesnt exit, insert
            bool success = await dbHelper.updateTopic(topic);

            if (success) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(
                  content: Text('Updated topic ${jsonData['topicName']}')));
            }
          }
        }

        // get all sessions under this topic
        final response = await http.get(
          Uri.parse(
              'https://fbappliedscience.com/api/viewSessions/${jsonData['id']}'),
          headers: {
            'Authorization': 'Token $token', // Add token to request
            'Content-Type': 'application/json',
          },
        );

        // get session list
        final localTimestampsSession = await dbHelper
            .retrieveSessionTimestamps();


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

            // get the online time
            final onlineTimeSession = DateTime.parse(jsonData['dateCreated']);
            final localUpdateTimeSession = localTimestampsSession[session.id];

            if (localUpdateTimeSession == null) {
              // session doesnt exist, insert
              bool success = await dbHelper.insertSession(session);

              if (success) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                    SnackBar(content: Text(
                        'inserted session ${jsonData['sessionName']}')));
              }
            } else {
              // Timestamp exists — compare and update if needed
              final localUpdateS = DateTime.parse(localUpdateTimeSession);

              if (onlineTimeSession.isAfter(localUpdateS)) {
                // update the topic
                bool success = await dbHelper.updateSession(session);
                if (success) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(
                      'Updated session ${jsonData['sessionName']}')));
                }
              }
            }


            //get all activities under each session here
            final response = await http.get(Uri.parse(
                'https://fbappliedscience.com/api/viewActivities/${jsonData['id']}'),
              headers: {
                'Authorization': 'Token $token', // Add token to request
                'Content-Type': 'application/json',
              },
            );

            // get activities timestamp
            final activityTimeStamp = await dbHelper
                .retrieveActivitiesTimestamps();

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

                // get online timestamp
                final activityOnlineTimeStamp = DateTime.parse(
                    jsonData['created_at']);
                // get each local time stamp by id
                final localUpdateTimeStampActivity = activityTimeStamp[activity
                    .id];


                if (localUpdateTimeStampActivity == null) {
                  // activity doesnt exist, insert
                  bool success = await dbHelper.insertActivity(activity);
                  // check if its video activity then download the video
                  if (activity.mediaType == "video" &&
                      activity.realVideo != "placeholder") {
                    downloadFile(activity, (progress) {});
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                        SnackBar(content: Text(
                            'downlaoding.. ${jsonData['video_title']}')));
                  }
                  if (success) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                        SnackBar(content: Text(
                            'inserted activity ${jsonData['title']}')));
                  }
                } else {
                  // Timestamp exists — compare and update if needed
                  final localUpdateA = DateTime.parse(
                      localUpdateTimeStampActivity);

                  if (activityOnlineTimeStamp.isAfter(localUpdateA)) {
                    // update the activity
                    // check if its video then download and update else just update

                    if (activity.mediaType == "video" &&
                        activity.realVideo != "placeholder") {
                      downloadFile(activity, (progress) {});
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                          SnackBar(content: Text(
                              'downlaoding.. ${jsonData['video_title']}')));
                    } else {
                      bool success = await dbHelper.updateActivity(activity);
                      if (success) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(
                            'Updated activity ${jsonData['title']}')));
                      }
                    }
                  }
                }
              }
            } else {
              throw Exception('Failed to load activity data');
            }
          }
        } else {
          print('failed response ${response.body}');
          throw Exception('Failed to load session data');
        }

        final topics = await dbHelper.getTopicsForUser(widget.userId!);

        setState(() {
          scienceTopics = topics.map((topic) => topic.toMap()).toList();
          filteredTopics = List.from(scienceTopics);
        });
      }
    } else {
      throw Exception('Failed to load topic data');
    }
  }

 */

  Future<void> fetchData() async{
    final dbHelper = DatabaseHelper();
    await dbHelper.initializeDatabase();

    String? token = await getToken();

    // fetch all topics
    final response = await http.get(
      Uri.parse('https://fbappliedscience.com/api/'),
      headers: {
        'Authorization': 'Token $token',
        'Content-type': 'application/json',
      },
    );

    if(response.statusCode != 200) throw Exception('Failed to load topics');
    List<dynamic> topicsData = json.decode(response.body);

    // Retreive local timestamps
    final localTopicTimestamps = await dbHelper.retrieveTopicTimestamps();
    final localSessionTimestamps = await dbHelper.retrieveSessionTimestamps();
    final localActivityTimestamps = await dbHelper.retrieveActivitiesTimestamps();

    //prepare bulk list
    List<Map<String, dynamic>> topicsToInsert = [];
    List<Map<String, dynamic>> topicsToUpdate = [];

    List<Map<String, dynamic>> sessionsToInsert = [];
    List<Map<String, dynamic>> sessionsToUpdate = [];

    List<Map<String, dynamic>> activitiesToInsert = [];
    List<Map<String, dynamic>> activitiesToUpdate = [];

    Queue<Activity> videoQueue = Queue<Activity>();

    for (var topicJson in topicsData){
      final topic = Topic.fromMap(topicJson);
      final onlineTime = DateTime.parse(topicJson['dateCreated']);
      final localTime = localTopicTimestamps[topic.id];

      if(localTime == null){
        topicsToInsert.add(topic.toMap());
      }else if(onlineTime.isAfter(DateTime.parse(localTime))){
        topicsToUpdate.add(topic.toMap());
      }

      //fetch sessions for this topic
      final sessionResp = await http.get(
        Uri.parse('https://fbappliedscience.com/api/viewSessions/${topic.id}'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if(sessionResp.statusCode != 200) continue;

      final sessionData = json.decode(sessionResp.body);
      for(var sessionJson in sessionData){
        final session = Session.fromMap(sessionJson);
        final onlineSessionTime = DateTime.parse(sessionJson['dateCreated']);
        final localSessionTime = localSessionTimestamps[session.id];

        if(localSessionTime == null){
          sessionsToInsert.add(session.toMap());
        }else if(onlineSessionTime.isAfter(DateTime.parse(localSessionTime))){
          sessionsToUpdate.add(session.toMap());
        }

        // fetch activities for this sessions
        final activityResp = await http.get(
            Uri.parse('https://fbappliedscience.com/api/viewActivities/${session.id}'),
            headers: {
              'Authorization': 'Token $token',
              'Content-Type': 'application/json',
            }
        );

        if(activityResp.statusCode != 200) throw Exception('Failed to load activities');


        final activitiesData = json.decode(activityResp.body);
        final localVideoActivities = await dbHelper.retrieveActivitiesBySession(session.id);
        final localVideoMap = {
          for (var a in localVideoActivities) a.id: a
        };

        for(var activityJson in activitiesData){
          //print(activityJson);
          final activity = Activity.fromMap(activityJson);
          final onlineActivityTime = DateTime.parse(activityJson['created_at']);
          final localActivityTime = localActivityTimestamps[activity.id];

          // check if video path is missing.
          var videosActivityExist = localVideoMap[activity.id];
          if (videosActivityExist != null && videosActivityExist.mediaType == "video" && videosActivityExist.realVideo != 'placeholder' && videosActivityExist.video.startsWith('/media')) {
            videoQueue.add(activity);
          }

          if(localActivityTime == null){
            activitiesToInsert.add(activity.toMap());
            // Queue videos for download/
            if(activity.mediaType == 'video' && activity.realVideo != 'placeholder'){
              videoQueue.add(activity);
            }
          }else if(onlineActivityTime.isAfter(DateTime.parse(localActivityTime))){
            activitiesToUpdate.add(activity.toMap());
            // Queue videos for download/
            if(activity.mediaType == 'video' && activity.realVideo != 'placeholder'){
              videoQueue.add(activity);
            }
          }

        }

      }
    }

    // bulk insert/update
    await dbHelper.runInTransaction((txn) async{
      for(var t in topicsToInsert){
        await txn.insert('topics', t, conflictAlgorithm: ConflictAlgorithm.abort);
      }
      for(var t in topicsToUpdate){
        await txn.update('topics', t, where: 'id= ?', whereArgs: [t['id']]);
      }

      // sessions
      for(var s in sessionsToInsert){
        await txn.insert('sessions', s, conflictAlgorithm: ConflictAlgorithm.abort);
      }
      for(var s in sessionsToUpdate){
        await txn.update('sessions', s, where: 'id = ?', whereArgs: [s['id']]);
      }

      // activities
      for(var a in activitiesToInsert){
        await txn.insert('activities', a, conflictAlgorithm: ConflictAlgorithm.abort);
      }
      for(var a in activitiesToUpdate){
        await txn.update('activities', a, where: 'id = ?', whereArgs: [a['id']]);
      }

    });

    // download videos sequentially
    const int maxRetries = 3;

    while (videoQueue.isNotEmpty) {
      final activity = videoQueue.removeFirst();

      if (activity.realVideo != 'placeholder') {
        int attempt = 0;
        bool success = false;

        while (!success && attempt < maxRetries) {
          attempt++;
          try {
            final localPath = await downloadFile(activity, (p0) => null);
            print("Downloaded, local path: $localPath");

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Downloaded video: ${activity.videoTitle}')),
            );

            success = true; // exit retry loop
          } catch (e) {
            print("Video download failed on attempt $attempt: $e");
            if (attempt >= maxRetries) {
              print("Giving up on this video after $maxRetries attempts");
            } else {
              await Future.delayed(
                  Duration(seconds: 2)); // optional wait before retry
            }
          }
        }
      }
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
            const SizedBox(height: 30.0),

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

}