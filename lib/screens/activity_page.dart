
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
  const ActivityPage({super.key, required this.sessionId});

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
          'https://fbappliedscience.com/api$fileUrl'));
      var response = await httpClient.send(request);

      var activityResponse = await http.get(Uri.parse(
          'https://fbappliedscience.com/api/${activities[currentIndex]['id']}'),
        headers: {
          'Authorization': 'Token $token', // Add token to request
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> data = json.decode(activityResponse.body);
      print(activityResponse.body);

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
              print('onDone _videofilepath $_videoFilePath');

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
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    final customLabel = convertToReadableFormat(label);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.indigo.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconForLabel(label),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  customLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Colors.blue.shade800,
                    letterSpacing: 0.8,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Html(
              data: value,
              style: {
                "body": Style(
                  fontSize: FontSize(16),
                  lineHeight: const LineHeight(1.6),
                  color: Colors.grey.shade800,
                  fontFamily: 'Roboto',
                  letterSpacing: 0.3,
                  textAlign: TextAlign.left,
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                ),
                "p": Style(
                  margin: Margins.only(bottom: 8),
                ),
                "h1, h2, h3, h4, h5, h6": Style(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'teacheractivity':
        return Icons.school;
      case 'studentactivity':
        return Icons.person;
      case 'notes':
        return Icons.note;
      default:
        return Icons.info;
    }
  }

  Widget _buildImageActivity(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.pink.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.image,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Image Activity',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Activity details
            _buildInfoRow('Activity Name', activity['title'] ?? '', Icons.title),
            const SizedBox(height: 16),
            _buildInfoRow('Image Title', activity['imageTitle'] ?? '', Icons.label),
            const SizedBox(height: 24),
            
            // Image container
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(activity['image'] ?? ''),
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Image not available',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.purple.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
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
            gradient: LinearGradient(
              colors: [Colors.orange.shade50, Colors.red.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: Colors.orange.withOpacity(0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(24.0),
          child: videoFilePath.isNotEmpty &&
              activities[currentIndex]['realVideo'] != "placeholder"
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: VideoPlayerWidget(
                      videoFilePath: videoFilePath,
                      activity: currentActivity,
                    ),
                  ),
                )
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
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
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: Colors.orange.withOpacity(0.4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.download,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                activities[currentIndex]['realVideo'] == "placeholder"
                                    ? 'Update Placeholder Video'
                                    : 'Download Video',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (progressD > 0)
                                Text(
                                  '$progressD% completed',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (progressD > 0)
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              value: progressD / 100,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 3,
                            ),
                          ),
                      ],
                    ),
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
            builder: (context) => EndOfSessionPage(totalActivity: totalActicities, activities: activities),
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

  Widget _buildNavigationButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isEnabled,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isEnabled 
              ? [Colors.blue.shade600, Colors.indigo.shade600]
              : [Colors.grey.shade300, Colors.grey.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isEnabled ? [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScaffold(
        title: activities.isNotEmpty ? activities[currentIndex]['title'] ?? 'Activity' : 'Loading...',
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
                      LinearProgressWidget(value: progressValue, total: totalActicities),
                      const SizedBox(height: 12.0),
                      // Display either loading indicator or activity widget
                      activities.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Loading activities...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: _buildActivityWidget(activities[currentIndex]),
                              ),
                            ),
                      const SizedBox(height: 20.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade50, Colors.indigo.shade50],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildNavigationButton(
                              onPressed: activities[currentIndex]['mediaType'] == "text" ? previousTextElement : previousActivity,
                              icon: Icons.arrow_back_ios,
                              label: 'Previous',
                              isEnabled: currentIndex > 0 || (activities[currentIndex]['mediaType'] == "text" && currentTextIndex > 0),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade600,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${currentIndex + 1} of ${activities.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            _buildNavigationButton(
                              onPressed: activities[currentIndex]['mediaType'] == "text" ? nextTextElement : nextActivity,
                              icon: (currentIndex == activities.length - 1 && activities[currentIndex]['mediaType'] != "text") || 
                                    (activities[currentIndex]['mediaType'] == "text" && currentTextIndex == textElementsToSkip.length - 1 && textElementsToSkip[currentTextIndex] != 'notes') 
                                    ? Icons.flag : Icons.arrow_forward_ios,
                              label: (currentIndex == activities.length - 1 && activities[currentIndex]['mediaType'] != "text") || 
                                     (activities[currentIndex]['mediaType'] == "text" && currentTextIndex == textElementsToSkip.length - 1 && textElementsToSkip[currentTextIndex] != 'notes') 
                                     ? 'End of Session' : 'Next',
                              isEnabled: true,
                            ),
                          ],
                        ),
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

  IconData _getActivityIcon(String mediaType) {
    switch (mediaType.toLowerCase()) {
      case 'video':
        return Icons.play_circle_fill;
      case 'image':
        return Icons.image;
      case 'text':
        return Icons.article;
      default:
        return Icons.assignment;
    }
  }
}

class EndOfSessionPage extends StatefulWidget {
  final int totalActivity;
  final List<Map<String, dynamic>> activities;
  const EndOfSessionPage({super.key, required this.totalActivity, required this.activities});

  @override
  _EndOfSessionPageState createState() => _EndOfSessionPageState();
}

class _EndOfSessionPageState extends State<EndOfSessionPage> {
  int _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _feedbackSubmitted = false;
  
  // Attendance tracking variables
  final TextEditingController _girlsCountController = TextEditingController();
  final TextEditingController _totalGirlsController = TextEditingController();
  final TextEditingController _boysCountController = TextEditingController();
  final TextEditingController _totalBoysController = TextEditingController();
  bool _attendanceSubmitted = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    _girlsCountController.dispose();
    _totalGirlsController.dispose();
    _boysCountController.dispose();
    _totalBoysController.dispose();
    super.dispose();
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = index + 1;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            child: Icon(
              index < _rating ? Icons.star : Icons.star_border,
              color: index < _rating ? Colors.amber.shade600 : Colors.grey.shade400,
              size: 40,
            ),
          ),
        );
      }),
    );
  }

  void _submitFeedback() {
    if (_rating > 0) {
      // Here you would typically save the rating and feedback to your database
      setState(() {
        _feedbackSubmitted = true;
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Thank you for your feedback!'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Show attendance tracking modal after feedback submission
      _showAttendanceModal();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please provide a rating before submitting'),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  
  void _showAttendanceModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 16,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.indigo.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.purple.shade600, Colors.indigo.shade600],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.people,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Track Attendance',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Girls Section
                    _buildAttendanceSection(
                      'Girls',
                      Icons.female,
                      Colors.pink,
                      _girlsCountController,
                      _totalGirlsController,
                    ),
                    const SizedBox(height: 20),
                    
                    // Boys Section
                    _buildAttendanceSection(
                      'Boys',
                      Icons.male,
                      Colors.blue,
                      _boysCountController,
                      _totalBoysController,
                    ),
                    const SizedBox(height: 24),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.grey.shade300,
                              foregroundColor: Colors.grey.shade700,
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                           child: ElevatedButton(
                             onPressed: () {
                               if (_validateAttendanceInput()) {
                                 _submitAttendance();
                                 Navigator.of(context).pop();
                               }
                             },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.purple.shade600,
                              foregroundColor: Colors.white,
                              elevation: 4,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
   
   Widget _buildAttendanceSection(
     String title,
     IconData icon,
     MaterialColor color,
     TextEditingController presentController,
     TextEditingController totalController,
   ) {
     return Container(
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(12),
         border: Border.all(
           color: color.withOpacity(0.3),
           width: 1,
         ),
         boxShadow: [
           BoxShadow(
             color: Colors.black.withOpacity(0.05),
             blurRadius: 8,
             offset: const Offset(0, 2),
           ),
         ],
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Row(
             children: [
               Container(
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(
                   color: color.shade100,
                   borderRadius: BorderRadius.circular(8),
                 ),
                 child: Icon(
                   icon,
                   color: color.shade600,
                   size: 20,
                 ),
               ),
               const SizedBox(width: 12),
               Text(
                 title,
                 style: TextStyle(
                   fontSize: 16,
                   fontWeight: FontWeight.w600,
                   color: color.shade700,
                 ),
               ),
             ],
           ),
           const SizedBox(height: 16),
           Row(
             children: [
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       'Present',
                       style: TextStyle(
                         fontSize: 12,
                         fontWeight: FontWeight.w500,
                         color: Colors.grey.shade600,
                       ),
                     ),
                     const SizedBox(height: 4),
                     TextField(
                       controller: presentController,
                       keyboardType: TextInputType.number,
                       decoration: InputDecoration(
                         hintText: '0',
                         border: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(8),
                           borderSide: BorderSide(color: Colors.grey.shade300),
                         ),
                         focusedBorder: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(8),
                           borderSide: BorderSide(color: color.shade400, width: 2),
                         ),
                         contentPadding: const EdgeInsets.symmetric(
                           horizontal: 12,
                           vertical: 8,
                         ),
                       ),
                     ),
                   ],
                 ),
               ),
               const SizedBox(width: 16),
               const Text(
                 'out of',
                 style: TextStyle(
                   fontSize: 14,
                   color: Colors.grey,
                   fontWeight: FontWeight.w500,
                 ),
               ),
               const SizedBox(width: 16),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       'Total',
                       style: TextStyle(
                         fontSize: 12,
                         fontWeight: FontWeight.w500,
                         color: Colors.grey.shade600,
                       ),
                     ),
                     const SizedBox(height: 4),
                     TextField(
                       controller: totalController,
                       keyboardType: TextInputType.number,
                       decoration: InputDecoration(
                         hintText: '0',
                         border: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(8),
                           borderSide: BorderSide(color: Colors.grey.shade300),
                         ),
                         focusedBorder: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(8),
                           borderSide: BorderSide(color: color.shade400, width: 2),
                         ),
                         contentPadding: const EdgeInsets.symmetric(
                           horizontal: 12,
                           vertical: 8,
                         ),
                       ),
                     ),
                   ],
                 ),
               ),
             ],
           ),
         ],
       ),
     );
   }
   
   bool _validateAttendanceInput() {
      // Validate girls attendance
      int? girlsPresent = int.tryParse(_girlsCountController.text);
      int? totalGirls = int.tryParse(_totalGirlsController.text);
      int? boysPresent = int.tryParse(_boysCountController.text);
      int? totalBoys = int.tryParse(_totalBoysController.text);
      
      // Check if all fields have valid numbers
      if (girlsPresent == null || totalGirls == null || boysPresent == null || totalBoys == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter valid numbers for all fields'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
      
      // Check if present count doesn't exceed total
      if (girlsPresent > totalGirls) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Girls present cannot exceed total girls'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
      
      if (boysPresent > totalBoys) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Boys present cannot exceed total boys'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
      
      // Check for negative numbers
      if (girlsPresent < 0 || totalGirls < 0 || boysPresent < 0 || totalBoys < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Attendance numbers cannot be negative'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
      
      return true;
    }
    
    void _submitAttendance() {
      // Get the attendance data
      int girlsPresent = int.tryParse(_girlsCountController.text) ?? 0;
      int totalGirls = int.tryParse(_totalGirlsController.text) ?? 0;
      int boysPresent = int.tryParse(_boysCountController.text) ?? 0;
      int totalBoys = int.tryParse(_totalBoysController.text) ?? 0;
     
     // Here you would typically save the attendance data to your database
     setState(() {
       _attendanceSubmitted = true;
     });
     
     // Show success message with attendance summary
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
         content: Text(
           'Attendance recorded: Girls $girlsPresent/$totalGirls, Boys $boysPresent/$totalBoys',
         ),
         backgroundColor: Colors.green.shade600,
         behavior: SnackBarBehavior.floating,
         duration: const Duration(seconds: 4),
       ),
     );
     
     // Clear the controllers for next use
     _girlsCountController.clear();
     _totalGirlsController.clear();
     _boysCountController.clear();
     _totalBoysController.clear();
   }

  Widget _buildTeacherFeedbackSection() {
    // Filter activities that have teacher feedback
    List<Map<String, dynamic>> activitiesWithFeedback = widget.activities
        .where((activity) => activity['teacherActivity'] != null && 
                            activity['teacherActivity'].toString().trim().isNotEmpty)
        .toList();

    if (activitiesWithFeedback.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.indigo.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.blue.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Teacher\'s Feedback',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'No teacher feedback available for this session.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.indigo.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Teacher\'s Feedback',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...activitiesWithFeedback.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> activity = entry.value;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Activity ${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          activity['title'] ?? 'Untitled Activity',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Html(
                    data: activity['teacherActivity'],
                    style: {
                      "body": Style(
                        fontSize: FontSize(14),
                        lineHeight: const LineHeight(1.5),
                        color: Colors.grey.shade800,
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                      ),
                      "p": Style(
                        margin: Margins.only(bottom: 8),
                      ),
                      "h1, h2, h3, h4, h5, h6": Style(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40.0),
                      
                      LinearProgressWidget(value: widget.totalActivity, total: widget.totalActivity),
                      
                      const SizedBox(height: 32),
                      
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade50, Colors.indigo.shade50],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'You have successfully completed all ${widget.totalActivity} activities in this session. Great job on your learning journey!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Rating Section
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.amber.shade50, Colors.orange.shade50],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.amber.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade600,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Rate This Session',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'How would you rate your learning experience?',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            _buildStarRating(),
                            if (_rating > 0) ...[
                              const SizedBox(height: 8),
                              Text(
                                _rating == 1 ? 'Poor' :
                                _rating == 2 ? 'Fair' :
                                _rating == 3 ? 'Good' :
                                _rating == 4 ? 'Very Good' : 'Excellent',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber.shade700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // User Feedback Section
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple.shade50, Colors.indigo.shade50],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.purple.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade600,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.rate_review,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Your Feedback',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Would you feel the need to adjust anything?',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              child: TextField(
                                controller: _feedbackController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText: 'Share your thoughts, suggestions, or areas for improvement...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _feedbackSubmitted ? null : _submitFeedback,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: _feedbackSubmitted 
                                      ? Colors.green.shade600 
                                      : Colors.purple.shade600,
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _feedbackSubmitted ? Icons.check_circle : Icons.send,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _feedbackSubmitted ? 'Feedback Submitted' : 'Submit Feedback',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Teacher Feedback Section
                      _buildTeacherFeedbackSection(),
                      
                      const SizedBox(height: 40),
                      
                      SizedBox(
                        width: double.infinity,
                        child: AnimatedElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          text: 'Back to Sessions',
                        ),
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

  const LinearProgressWidget({super.key, required this.value, required this.total});

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
    final progress = mapValueToProgress(value, total);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.teal.shade50],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.trending_up,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$value/$total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.grey.shade200,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress < 0.5 ? Colors.orange.shade600 : Colors.green.shade600,
                ),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toInt()}% Complete',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
