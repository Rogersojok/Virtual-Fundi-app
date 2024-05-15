
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoFilePath;

  const VideoPlayerWidget({Key? key, required this.videoFilePath}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late ChewieController _chewieController;
  late VideoPlayerController videoPlayerController;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayerFuture = _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    videoPlayerController = VideoPlayerController.file(File(widget.videoFilePath));
    await videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: false, // Adjust as needed
      looping: false, // Adjust as needed
      // Other ChewieController configurations can be added here
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
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
                  : SizedBox.shrink(), // This ensures Chewie is still there to maintain layout
              if (_chewieController != null &&
                  !_chewieController.videoPlayerController.value.isInitialized)
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

