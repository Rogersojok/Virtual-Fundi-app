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
import '../utills/animateAButton.dart';

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
  int currentTextIndex = 0;
  int progressD = 0;
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  late String filePath = "";
  List<dynamic> dataVideoD = [];
  List<Activity> activitiesD = [];
  int sessionProgress = 0;
  int totalActicities = 0;
  int progressValue = 0;

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

  String convertToReadableFormat(String text) {
    if (text.isEmpty) return text;

    final buffer = StringBuffer();
    buffer.write(text[0].toUpperCase()); // Capitalize the first letter

    for (int i = 1; i < text.length; i++) {
      if (text[i].toUpperCase() == text[i]) {
        buffer.write(' '); // Add a space before uppercase letters
      }
      buffer.write(text[i]);
    }

    return buffer.toString();
  }


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
          realVideo: jsonData['real_video'],
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

    print("""""");
    print( 'from database $activitiesD'); // Handle null items in the list
    print("""""");

    setState(() {
      activities =
          activitiesD.map((activity) => activity.toMap()).toList();
      print("""""");
      print('inside set state $activities'); // Handle null items in the list
      print("""""");
    });
    totalActicities = activities.length;
  }

  Future<String> downloadFile(

      String fileUrl, Function(int) onProgress) async {
    try {
      var httpClient = http.Client();
      var request = http.Request('GET', Uri.parse(
          'http://161.97.81.168:8080${fileUrl}'));
      var response = await httpClient.send(request);

      var activity_response = await http.get(Uri.parse(
          'http://161.97.81.168:8080/getActivity/${activities[currentIndex]['id']}'));

      final Map<String, dynamic> data = json.decode(activity_response.body);


      if(data['real_video'] == "placeholder"){
        return "placehoder video";
      }else {
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
                realVideo: data['real_video'],
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
    print(activities[currentIndex]['realVideo']); // Using string interpolation

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

  // List of keys or values to be skipped in each activity
  List<String> textElementsToSkip = ['teacherActivity', 'studentActivity', 'notes'];

  Widget _buildTextActivity(Map<String, dynamic> activity) {
    // Convert the map entries to a list and filter them
    List<MapEntry<String, dynamic>> activityEntries = activity.entries
        .where((entry) => textElementsToSkip.contains(entry.key))
        .toList();
    print(activityEntries);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (activityEntries.isNotEmpty)
          _buildRow(activityEntries[currentTextIndex].key, activityEntries[currentTextIndex].value.toString()),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    final customLabel = convertToReadableFormat(label);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            customLabel,
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
              videoFilePath.isNotEmpty && activities[currentIndex]['realVideo'] != "placeholder"
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
                child:  activities[currentIndex]['realVideo'] == "placeholder" ? Text('Update placeholder video') :  Text('Download Video'),
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
      currentTextIndex = 0; // Reset text index for the new activity
      if (currentIndex < activities.length - 1) {
        currentIndex++;
        progressValue = currentIndex + 1;
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EndOfSessionPage(totalActivity: totalActicities,),
          ),
        );
      }
    });
  }

  void previousActivity() {
    setState(() {
      currentTextIndex = textElementsToSkip.length - 1; // Reset text index for the new activity
      if (currentIndex > 0) {
        currentIndex--;
        progressValue = currentIndex + 1;
      } else {
        currentIndex = activities.length - 1; // Wrap around to the last activity
        // to move back to the session details
      }
    });
  }

  void nextTextElement() {
    setState(() {
      currentTextIndex++;
      if (currentTextIndex >= textElementsToSkip.length) {
        nextActivity();
      }
    });
  }

  void previousTextElement() {
    setState(() {
      currentTextIndex--;
      if (currentTextIndex < 0) {
        previousActivity();
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

                      LinearProgressWidget(value: progressValue, total: totalActicities,),
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
                          AnimatedElevatedButton(
                            onPressed: activities[currentIndex]['mediaType'] == "text" ? previousTextElement : previousActivity,
                            text: 'Previous',
                          ),
                          AnimatedElevatedButton(
                            onPressed: activities[currentIndex]['mediaType'] == "text" ? nextTextElement : nextActivity,
                            text: 'Next',
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
  final int totalActivity;
  EndOfSessionPage({required this.totalActivity});

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
                      LinearProgressWidget(value: totalActivity, total: totalActivity,),
                      const SizedBox(height: 20.0),
                      Text(
                        'Congratulations! You have completed all activities in this session.',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      AnimatedElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        text: 'Back',
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



class LinearProgressWidget extends StatelessWidget {
  final int value;
  final int total;

  LinearProgressWidget({required this.value, required this.total});

  double mapValueToProgress(int value, int t) {
    print('value $value');
    print('total $t');
    if (value < 0 || value > t) {
      throw RangeError('Value must be between 1 and 5');
    }
    return (value) / t;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Progress: $value/$total'),
        SizedBox(height: 10),
        LinearProgressIndicator(
          value: mapValueToProgress(value, total),
          backgroundColor: Colors.grey[200],
          color: Colors.blue,
          minHeight: 10,
        ),
      ],
    );
  }
}
