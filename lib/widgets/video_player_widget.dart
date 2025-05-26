
import 'dart:io';
//import 'dart:js_util';

import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import '../database/database.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http; // Import http package for making api request.
import 'package:virtualfundi/services/access_token.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoFilePath;
  final Activity? activity;

  const VideoPlayerWidget({Key? key, required this.videoFilePath, required this.activity}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late ChewieController _chewieController;
  late VideoPlayerController videoPlayerController;
  late Future<void> _initializeVideoPlayerFuture;
  List<Activity> activitiesD = [];
  late String _videoFilePath;
  int progressD = 0;
  String path = "";

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayerFuture = _initializeVideoPlayer(widget.videoFilePath);
  }

  Future<void> _initializeVideoPlayer(videoFilePath) async {
    videoPlayerController = VideoPlayerController.file(File(videoFilePath));
    await videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: false, // Adjust as needed
      looping: false, // Adjust as needed
      // Other ChewieController configurations can be added here
    );
  }


  Future<void> deleteVideo(String filePath) async {
    try {
      final file = File(filePath);

      // Check if the file exists before trying to delete it
      if (await file.exists()) {
        await file.delete();
        print('Video file deleted successfully.');
      } else {
        print('Video file does not exist.');
      }
    } catch (e) {
      print('Error deleting video file: $e');
    }
  }


  Future<String> downloadFile(Function(int) onProgress) async {
    // retrive access token
    String? token = await getToken(); // Retrieve stored token
    try {
      var httpClient = http.Client();

      var activity_response = await http.get(Uri.parse(
          'http://161.97.81.168:8080/getActivity/${widget.activity!.id}'),
        headers: {
          'Authorization': 'Token $token', // Add token to request
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> data = json.decode(activity_response.body);
      print(activity_response.body);

      String fileUrl = data['video'];

      print(fileUrl);

      var request = http.Request('GET', Uri.parse(
          'http://161.97.81.168:8080${fileUrl}'));
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
            },
            onDone: () async {
              // When download completes, write the file to local storage
              var appDir = await getApplicationDocumentsDirectory();
              filePath = '${appDir.path}/$fileName';
              File file = File(filePath);
              //deleteVideo(filePath);
              await file.writeAsBytes(bytes);
              print('filePath in download function: $filePath');

              setState(() {
                _videoFilePath = filePath;
                _initializeVideoPlayerFuture = _initializeVideoPlayer(filePath);
              });

              _videoFilePath = filePath;
              print('onDone _videofilepath ${_videoFilePath}');

              // update the database
              final dbHelper = DatabaseHelper();
              await dbHelper.initializeDatabase();

              final UpdateActivity = Activity(
                id: widget.activity!.id,
                title: widget.activity!.title,
                session: widget.activity!.session,
                teacherActivity: widget.activity!.teacherActivity,
                studentActivity: widget.activity!.studentActivity,
                mediaType: widget.activity!.mediaType,
                time: widget.activity!.time ?? 5,
                notes: widget.activity!.notes,
                image: widget.activity!.image ?? "",
                imageTitle: widget.activity!.imageTitle ?? "",
                video: filePath ?? "",
                videoTitle: widget.activity!.videoTitle,
                realVideo: widget.activity!.realVideo,
                createdAt: widget.activity!.createdAt,
              );
              // Update the activity in the database
              await dbHelper.updateActivity(UpdateActivity);

              setState(() {
                _initializeVideoPlayer(filePath);
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        try {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                _chewieController != null &&
                    _chewieController.videoPlayerController.value.isInitialized
                    ? AspectRatio(
                  aspectRatio: _chewieController
                      .videoPlayerController.value.aspectRatio,
                  child: Chewie(
                    controller: _chewieController,
                  ),
                )
                    : SizedBox.shrink(),
                // This ensures Chewie is still there to maintain layout
                if (_chewieController != null &&
                    !_chewieController.videoPlayerController.value
                        .isInitialized)
                  Center(
                    child: CircularProgressIndicator(), // Show loading indicator
                  ),
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        }catch(error){
          //deleteVideo(widget.videoFilePath);
          return ElevatedButton(
            onPressed: () {
              downloadFile( (progress) {
                setState(() {
                  progressD = progress;

                });

              });
            },
            child: Text("Failed: Retry:$progressD",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
          );
        }
      },
    );

  }

  @override
  void dispose() {
    super.dispose();
    _chewieController.dispose();
    videoPlayerController.dispose();
  }

}

