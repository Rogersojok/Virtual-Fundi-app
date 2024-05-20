import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../widgets/custom_scaffold.dart';
import 'dart:convert'; // for convert response to json
import 'package:http/http.dart' as http; // Import http package for making api request.
import 'package:video_player/video_player.dart';
import 'package:virtualfundi/widgets/video_player_widget.dart';
import 'package:flutter_html/flutter_html.dart';
import '../database/database.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// class for data fetched from the database

class ActivityPage extends StatefulWidget {
  final int sessionId;
  ActivityPage({required this.sessionId});

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  // List of activities fetched from the database
  List<Map<String, dynamic>> activities = [];
  int currentIndex = 0;
  int progressD = 0;
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  late String filePath = "";
  List<dynamic> dataVideoD = [];
  List<Activity> activitiesD = [];

  double _progress = 0.0;
  late String _videoFilePath;
  late final Connectivity _connectivity;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    // _checkInternetAndFetchData();
    fetchData();
    fetchLocalData();
  }

  /*
  Future<void> _checkInternetAndFetchData() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      fetchData();
      print("-------------------------- internet -------------");
    } else {
      fetchLocalData();
      print("--------------------------no internet -------------");
    }
  }

   */

  Future<void> fetchData() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initializeDatabase();

    final response = await http.get(Uri.parse(
        'http://161.97.81.168:8080/viewActivities/${widget.sessionId}'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      dataVideoD = data;

      // Convert JSON data to Session objects and insert into the database
      for (var jsonData in data) {
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
          video: filePath ?? "",
          videoTitle: jsonData['video_title'] ?? "",
          createdAt: DateTime.parse(jsonData['created_at']),
        );
        await dbHelper.insertActivity(activity);
      }

      // Retrieve all topics from the database and print them
      activitiesD =
      await dbHelper.retrieveActivitiesBySession(widget.sessionId);

      setState(() {
        activities =
            activitiesD.map((activity) => activity.toMap()).toList();
        print(activities); // Handle null items in the list
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchLocalData() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initializeDatabase();

    // Retrieve all topics from the database and print them
    activitiesD =
    await dbHelper.retrieveActivitiesBySession(widget.sessionId);

    setState(() {
      activities =
          activitiesD.map((activity) => activity.toMap()).toList();
      print(activities); // Handle null items in the list
    });
  }

  Future<String> downloadFile(
      String fileUrl, Function(int) onProgress) async {
    try {
      var httpClient = http.Client();
      var request = http.Request('GET', Uri.parse(
          'http://161.97.81.168:8080${fileUrl}'));
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

        response.stream.listen(
              (List<int> chunk) {
            bytes.addAll(chunk);
            receivedBytes += chunk.length;

            // Calculate progress and call the onProgress function
            double progress = (receivedBytes / totalBytes) * 100;
            onProgress(progress.toInt()); // Pass the progress value
          },
          onDone: () async {
            // When download completes, write the file to local storage
            var appDir = await getApplicationDocumentsDirectory();
            filePath = '${appDir.path}/$fileName';
            File file = File(filePath);
            await file.writeAsBytes(bytes);
            print('filePath in download function: $filePath');

            _videoFilePath = filePath;
            print('onDone _videofilepath ${_videoFilePath}');

            // update the database
            final dbHelper = DatabaseHelper();
            await dbHelper.initializeDatabase();

            final UpdateActivity = Activity(
              id: activities[currentIndex]['id'],
              title: activities[currentIndex]['title'],
              session: activities[currentIndex]['session'],
              teacherActivity: activities[currentIndex]['teacherActivity'],
              studentActivity: activities[currentIndex]['studentActivity'],
              mediaType: activities[currentIndex]['mediaType'],
              time: activities[currentIndex]['time'] ?? 5,
              notes: activities[currentIndex]['notes'],
              image: activities[currentIndex]['image'] ?? "",
              imageTitle: activities[currentIndex]['imageTitle'] ?? "",
              video: filePath ?? "",
              videoTitle: activities[currentIndex]['videoTitle'] ?? "",
              createdAt:
              DateTime.parse(activities[currentIndex]['createdAt']),
            );
            // Update the activity in the database
            await dbHelper.updateActivity(UpdateActivity);

            // update activity data
            activitiesD =
            await dbHelper.retrieveActivitiesBySession(widget.sessionId);

            setState(() {
              activities =
                  activitiesD.map((activity) => activity.toMap()).toList();
              print(activities); // Handle null items in the list
            });
          },

          onError: (e) {
            throw Exception('Failed to download file: $e');
          },
        );
        return filePath;
      } else {
        // Handle HTTP error response
        throw Exception(
            'Failed to download file: HTTP ${response.statusCode}');
      }
    } catch (e) {
      // Handle other errors, such as network issues or invalid URLs
      throw Exception('Failed to download file: $e');
    }
  }

  Future<String> downloadImage(String imageUrl) async {
    var httpClient = http.Client();
    var request = http.Request('GET', Uri.parse(imageUrl));
    var response = await httpClient.send(request);
    var bytes = await response.stream.toBytes();

    // Extract filename from the URL
    Uri uri = Uri.parse(imageUrl);
    String filename = uri.pathSegments.last;

    // Get the app's local directory
    var appDir = await getApplicationDocumentsDirectory();

    // Construct the local file path
    String filePath = '${appDir.path}/$filename';

    // Write the file to the local directory
    File file = File(filePath);
    await file.writeAsBytes(bytes);

    return filePath;
  }

  Widget _buildActivityWidget(Map<String, dynamic> activity) {
    print('currentIndex: $currentIndex'); // Using string interpolation

    switch (activities[currentIndex]['mediaType']) {
      case 'text':
        return _buildTextActivity(activity);
      case 'image':
        return _buildImageActivity(activity);
      case 'video':
        return _buildVideoActivity(activity);
      default:
        return Container(); // Handle other media types as needed
    }
  }

  Widget _buildTextActivity(Map<String, dynamic> activity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // _buildRow('Activity Name:', activity['title'] ?? ''),
        _buildRow('Duration:', activity['time'].toString() + ' Minutes' ?? ''),
        _buildRow("Teacher's Activity:", activity['teacherActivity'] ?? ''),
        _buildRow("Learner's Activity:", activity['studentActivity'] ?? ''),
        _buildRow('Notes:', activity['notes'] ?? ''),
        SizedBox(height: 8),
        // Render other text-specific UI elements
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Html(data: value),
        ],
      ),
    );
  }

  Widget _buildImageActivity(Map<String, dynamic> activity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Activity Name:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 10),
            Text(activity['title'] ?? ''),
            // Replace 'activityName' with the correct key from your activity map
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Image Title:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 10),
            Text(activity['image_title'] ?? ''),
            // Replace 'imageTitle' with the correct key from your activity map
          ],
        ),
        SizedBox(height: 15),
        // Render image-specific UI elements
        Center(
          child: Image.file(
            File(activity['image'] ?? ''),
            // Replace 'image' with the correct key from your activity map
            width: 320, // Adjust the width as needed
            height: 200, // Adjust the height as needed
            fit: BoxFit.cover, // Adjust the fit as needed
          ),
        ),
        SizedBox(height: 8),
        // Render other image-specific UI elements
      ],
    );
  }

  Widget _buildVideoActivity(Map<String, dynamic> activity) {
    String videoFilePath = activity['video'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row(
        //   children: [
        //     Text(
        //       'Activity Name:',
        //       style: TextStyle(fontWeight: FontWeight.bold),
        //     ),
        //     SizedBox(width: 10),
        //     Text(activity['title'] ?? ''),
        //     // Replace 'activityName' with the correct key from your activity map
        //   ],
        // ),
        SizedBox(height: 8),
        Row(
          children: [
            Text(
              '',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 10),
            Text(activity['videoTitle'] ?? ''),
            // Replace 'videoTitle' with the correct key from your activity map
          ],
        ),
        SizedBox(height: 8),
        // Render video-specific UI elements
        // Video player widget directly integrated here
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   'Video:',
              //   style: TextStyle(fontWeight: FontWeight.bold),
              // ),
              SizedBox(height: 8),
              // Render video-specific UI elements
              videoFilePath.isNotEmpty
                  ? VideoPlayerWidget(videoFilePath: videoFilePath)
                  : ElevatedButton(
                onPressed: () async {
                  try {
                    // Call the download function here
                    String filePath = await downloadFile(
                        dataVideoD[currentIndex]['video'],
                            (progress) {
                          print(
                              '${dataVideoD[currentIndex]['video']} Download progress: $progress');
                        });
                    // Once download is complete, update the video file path and start initializing the video player
                    print('after update path $filePath');
                    setState(() {
                      videoFilePath = _videoFilePath;
                      print('setState update path $videoFilePath');
                    });

                    await _initializeVideoPlayerFuture;
                  } catch (error) {
                    // Handle download error if needed
                    print('Download error: $error');
                  }
                },
                child: Text('Download Video'),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        // Render other video-specific UI elements
      ],
    );
  }

  void nextActivity() {
    setState(() {
      if (currentIndex < activities.length - 1) {
        currentIndex++;
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EndOfSessionPage(),
          ),
        );
      }
    });
  }

  void previousActivity() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
      } else {
        currentIndex = activities.length - 1; // Wrap around to the last activity
      }
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
                        '',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue, // Update this color as needed
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      // Display either loading indicator or activity widget
                      activities.isEmpty
                          ? CircularProgressIndicator() // Display loading indicator while fetching data
                          : Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildActivityWidget(
                              activities[currentIndex]), // Replace this with your activity widget
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: previousActivity,
                            child: Text('Previous'),
                          ),
                          ElevatedButton(
                            onPressed: nextActivity,
                            child: Text('Next'),
                          ),
                        ],
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

class EndOfSessionPage extends StatelessWidget {
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
                        'End of Session',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue, // Update this color as needed
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        'Congratulations! You have completed all activities in this session.',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Text('Back to Session'),
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
