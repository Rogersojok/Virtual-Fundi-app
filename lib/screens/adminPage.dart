import 'package:flutter/material.dart';
import '../widgets/custom_scaffold.dart';
import 'package:virtualfundi/services/access_token.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:virtualfundi/database/database.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  void initState() {
    super.initState();
    fetchLocalData();
  }

  List<Activity> videoActivities = [];

  Future<void> fetchLocalData() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initializeDatabase();

    //Retrive all the activities from the database which has got mediatype == video
    videoActivities = await dbHelper.retrieveVideoActivities();
    List<Activity> videoActivities1 = await dbHelper.retrieveVideoActivities();

    setState(() {
      //Retrive all the activities from the database which has got mediatype == video
      videoActivities = videoActivities1;
    });
  }

  Future<String> downloadFile(Activity activity, Function(int) onProgress) async {
    // retrive access token
    String? token = await getToken(); // Retrieve stored token
    try {
      var httpClient = http.Client();

      var activity_response = await http.get(
        Uri.parse('https://fbappliedscience.com/api/getActivity/${activity.id}'),
        headers: {
          'Authorization': 'Token $token', // Add token to request
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> data = json.decode(activity_response.body);
      print(activity_response.body);

      String fileUrl = data['video'];

      print(fileUrl);

      var request =
          http.Request('GET', Uri.parse('https://fbappliedscience.com/api${fileUrl}'));
      var response = await httpClient.send(request);

      print("resquest---> $request");

      print("response-------------   $response");

      if (data['real_video'] == "placeholder") {
        return "placeholder video";
      } else {
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
              setState(() {});
            },
            onDone: () async {
              // When download completes, write the file to local storage
              var appDir = await getApplicationDocumentsDirectory();
              filePath = '${appDir.path}/$fileName';
              File file = File(filePath);
              //deleteVideo(filePath);
              await file.writeAsBytes(bytes);
              print('filePath in download function: $filePath');

              setState(() {});

              // update the database
              final dbHelper = DatabaseHelper();
              await dbHelper.initializeDatabase();

              final UpdateActivity = Activity(
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
                video: filePath ?? "",
                videoTitle: activity.videoTitle,
                realVideo: activity.realVideo,
                createdAt: activity.createdAt,
              );
              // Update the activity in the database
              await dbHelper.updateActivity(UpdateActivity);

              //Retrive all the activities from the database which has got mediatype == video
              videoActivities = await dbHelper.retrieveVideoActivities();
              List<Activity> videoActivities1 =
                  await dbHelper.retrieveVideoActivities();

              setState(() {
                //Retrive all the activities from the database which has got mediatype == video
                videoActivities = videoActivities1;
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
    } catch (error) {
      throw Exception('Failed to download file: $error');
    }
  }

  // Function to check if the video file exists
  Future<bool> isValidVideoPath(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activities List'),
      ),
      body: ActivityWidget(activities: videoActivities),
    );
  }

  // Widget to display the list of activities
  Widget ActivityWidget({required List<Activity> activities}) {
    return ListView.builder(
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];

        return FutureBuilder<bool>(
          future:
              isValidVideoPath(activity.video), // Check if video file exists
          builder: (context, snapshot) {
            String videoStatus = "No"; // Default message
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListTile(
                title: Text("Loading..."),
              );
            }

            if (snapshot.hasData && snapshot.data == true) {
              videoStatus = "Yes"; // If the video exists
            }

            return ListTile(
              title: Text(activity.videoTitle),
              subtitle: Text('Video Exists: $videoStatus'),
              trailing:
                  snapshot.hasData && !snapshot.data! // If video does not exist
                      ? IconButton(
                          icon: Icon(Icons.download),
                          onPressed: () {
                            // Trigger the video download logic here
                            downloadFile(activity, (progress){});
                          },
                        )
                      : null, // No download button if video exists
            );
          },
        );
      },
    );
  }
}
