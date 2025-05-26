
import 'dart:async';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../theme/theme.dart';
import '../widgets/custom_scaffold.dart';
import 'dart:convert'; // for convert response to json
import 'package:http/http.dart' as http; // Import http package for making api request.
import 'package:video_player/video_player.dart';
import 'package:virtualfundi/widgets/video_player_widget.dart';
//import 'package :flutter_html/flutter_html.dart';
import '../database/database.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utills/animateAButton.dart';
import 'package:disk_space_plus/disk_space_plus.dart';
import 'package:virtualfundi/services/access_token.dart';

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
  late String filePath = "";
  List<dynamic> dataVideoD = [];
  List<Activity> activitiesD = [];
  int sessionProgress = 0;
  int totalActicities = 0;
  int progressValue = 0;
  String network = "Offline";
  late String _videoFilePath;
  Activity? currentActivity;
  double? freeSpace;

  late StreamSubscription<List<ConnectivityResult>> streamSubscription;



  @override
  void initState() {
    super.initState();
    //_checkInternetAndFetchData();
    internet2();
    //fetchData();
    fetchLocalData();
    checkDiskSpace();
  }

  void setActivity(){
    currentActivity = Activity(
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
      video: "",
      videoTitle: activities[currentIndex]['videoTitle'] ?? "",
      realVideo: 'real_video',
      createdAt:
      DateTime.parse(activities[currentIndex]['createdAt']),
    );

    print('Set current activity:  $currentActivity');
  }

  void _checkInternetAndFetchData() {
    streamSubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if(result.contains(ConnectivityResult.mobile) || result.contains(ConnectivityResult.wifi)){
        network = "Online";
        print("Online");
      }else{
        network = "Offline";
        print("Offline");
      }
    });
  }

  Future<void> checkDiskSpace() async {
    try {
      freeSpace = await DiskSpacePlus.getFreeDiskSpace;
      if (freeSpace != null) {
        print('Free disk space: $freeSpace MB');
      } else {
        print('Failed to get free disk space');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  void internet2() async{
    bool result = await InternetConnection().hasInternetAccess;
    if(result == true ){
      network = "Online";
      print("Online");
    }else{
      network = "Offline";
      print("Offline");
    }
    print(result);
  }

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
        'https://fbappliedscience.com/api/viewActivities/${widget.sessionId}'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      dataVideoD = data;

      // Convert JSON data to Session objects and insert into the database
      for (var jsonData in data) {
        // download video here before inserting in the database.

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
        setActivity();
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
      internet2();
      setActivity();
    });
    totalActicities = activities.length;
    //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Disk space: $freeSpace')));
  }


  Future<String> downloadFile(String fileUrl, Function(int) onProgress) async {
    // retrive access token
    String? token = await getToken(); // Retrieve stored token
    try {
      var httpClient = http.Client();
      var request = http.Request('GET', Uri.parse(
          'https://fbappliedscience.com/api${fileUrl}'));
      var response = await httpClient.send(request);

      var activity_response = await http.get(Uri.parse(
          'https://fbappliedscience.com/api/${activities[currentIndex]['id']}'),
        headers: {
          'Authorization': 'Token $token', // Add token to request
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> data = json.decode(activity_response.body);
      print(activity_response.body);

      if(data['real_video'] == "placeholder"){
        return "placeholder video";
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
              // Show progress in a ScaffoldMessenger
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
                internet2();
              });
            },

            onError: (e) {
              throw Exception('Failed to download file: $e');
            },
          );
          return filePath;
        } else {
          // reset the database
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
            video: "",
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
            internet2();
            setActivity();
          });
          // Handle HTTP error response
          throw Exception(
              'Failed to download file: HTTP ${response.statusCode}');
        }
      }

    } catch (e) {
      // Handle other errors, such as network issues or invalid URLs
      setState(() {
        setActivity();
      });
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
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Widget _buildActivityWidget(Map<String, dynamic> activity) {
    print('currentIndex: $currentIndex');
    print(activities[currentIndex]['realVideo']);

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
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    final customLabel = convertToReadableFormat(label);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            customLabel,
            style: TextStyle(
              fontWeight: FontWeight.w700, // Use bolder weight for a stronger presence
              fontSize: 22, // Increase font size for prominence
              color: Colors.black, // Retain beautiful accent color
              letterSpacing: 1.2, // Add letter spacing for a contemporary look
              fontFamily: 'Poppins', // Modern font family (ensure it's included in pubspec.yaml)
              shadows: [
                Shadow(
                  blurRadius: 4.0, // Add subtle shadow for depth
                  offset: Offset(2.0, 2.0), // Light direction for the shadow
                  color: Colors.black26, // Light black shadow for a soft effect
                ),
              ],
            ),
          ),

          SizedBox(height: 8),
          Html(
            data: value,
            style: {
              "body": Style(
                fontSize: FontSize(16), // Slightly larger font size for readability
                lineHeight: LineHeight(1.8), // Increased line height for a cleaner layout
                color: Colors.black87, // Keep standard black for readability
                fontFamily: 'Roboto', // Modern sans-serif font family
                letterSpacing: 0.5, // Add slight letter spacing for a more polished look
                textAlign: TextAlign.justify, // Justify text for cleaner text alignment
                backgroundColor: Colors.white, // Light background for a fresher look
              ),
            },
          ),

        ],
      ),
    );
  }

  Widget _buildImageActivity(Map<String, dynamic> activity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Use a Card with beautiful colors for modern look
        Card(
          elevation: 5.0,
          margin: EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.blueGrey.shade50, // Light background for the card
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Activity Name:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.teal, // Modern accent color
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        activity['title'] ?? '',
                        style: TextStyle(fontSize: 16, color: Colors.indigo), // Indigos for text
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'Image Title:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.teal, // Consistent modern color
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        activity['image_title'] ?? '',
                        style: TextStyle(fontSize: 16, color: Colors.indigo),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(activity['image'] ?? ''),
                      width: 320,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }



  //##################################################################################
  Widget _buildVideoActivity(Map<String, dynamic> activity) {
    // Convert the map to an Activity instance
    Activity currentActivity = Activity.fromMap(activity);

    String videoFilePath = currentActivity.video;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        // Video Title Section
        Row(
          children: [
            const Icon(Icons.play_circle_fill, color: Colors.blueAccent, size: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                currentActivity.videoTitle,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Video or Download Button Section
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.white, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20.0),
          child: videoFilePath.isNotEmpty &&
              activities[currentIndex]['realVideo'] != "placeholder"
              ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: VideoPlayerWidget(
              videoFilePath: videoFilePath,
              activity: currentActivity,
            ),
          )
              : ElevatedButton(
            onPressed: () async {
              try {
                String filePath = await downloadFile(
                  dataVideoD[currentIndex]['video'],
                      (progress) {
                    setState(() {
                      progressD = progress;
                    });
                  },
                );
                setState(() {
                  videoFilePath = filePath;
                });
              } catch (error) {
                print('Download error: $error');
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              backgroundColor: Colors.blueAccent,
              shadowColor: Colors.black38,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.download, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  activities[currentIndex]['realVideo'] == "placeholder"
                      ? 'Update Placeholder Video $progressD%'
                      : 'Download Video $progressD%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }



//#####################################################################

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
      _checkInternetAndFetchData();
      progressD = 0;
      setActivity();
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
      internet2();
      progressD = 0;
      setActivity();
    });
  }

  void nextTextElement() {
    setState(() {
      currentTextIndex++;
      if (currentTextIndex >= textElementsToSkip.length) {
        nextActivity();
      }
      internet2();
    });
  }

  void previousTextElement() {
    setState(() {
      currentTextIndex--;
      if (currentTextIndex < 0) {
        previousActivity();
      }
      _checkInternetAndFetchData();
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
                          IconButton(
                            onPressed: activities[currentIndex]['mediaType'] == "text" ? previousTextElement : previousActivity,
                            icon: Icon(Icons.arrow_back), // Left arrow icon
                            tooltip: 'Previous', // Tooltip for accessibility
                            color: Colors.black, // Customize the color as needed
                          ),
                          IconButton(
                            onPressed: activities[currentIndex]['mediaType'] == "text" ? nextTextElement : nextActivity,
                            icon: Icon(Icons.arrow_forward), // Right arrow icon
                            tooltip: 'Next', // Tooltip for accessibility
                            color: Colors.black, // Customize the color as needed
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
