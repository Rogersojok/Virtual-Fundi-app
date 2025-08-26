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


  const HomeScreen({super.key, required this.userId});


  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> scienceTopics = [];
  List<Map<String, dynamic>> filteredTopics = [];
  final TextEditingController _searchController = TextEditingController();
  
  late AnimationController _animationController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = true;
  bool _isSearching = false;


  @override
  void initState() {
    super.initState();

    fetchData();
    fetchLocalData();


    
    // Initialize animation controllers
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    

    // Add a listener to the search controller
    _searchController.addListener(_filterTopics);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    _staggerController.dispose();

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
        //changes

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

      _isLoading = false;
    });
    
    // Start animations after data is loaded
    _animationController.forward();
    _staggerController.forward();
    
    // loop through topics and get sessions under each topic

  }

  void _filterTopics() {
    final query = _searchController.text.toLowerCase();

    setState(() {

      _isSearching = query.isNotEmpty;
      filteredTopics = scienceTopics.where((topic) {
        final topicName = topic['topicName'].toLowerCase();
        final subject = topic['subject']?.toLowerCase() ?? '';
        final classTaught = topic['classTaught']?.toLowerCase() ?? '';
        return topicName.contains(query) || 
               subject.contains(query) || 
               classTaught.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScaffold(
        title: 'Learning Topics',
        child: _isLoading
            ? _buildLoadingState()
            : Column(
                children: [
                  _buildSearchBar(),
                  _buildTopicCounter(),
                  _buildTopicList(),
                ],
              ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
  
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading your topics...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeaderSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade600, Colors.indigo.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ready to explore your learning topics?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FeedbackScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.feedback_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Feedback'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search topics, subjects, or classes...',
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: const Icon(Icons.search, color: Colors.indigo),
            suffixIcon: _isSearching
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[600]),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.indigo, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTopicCounter() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.topic_outlined, color: Colors.indigo, size: 20),
            const SizedBox(width: 8),
            Text(
              '${filteredTopics.length} ${filteredTopics.length == 1 ? 'Topic' : 'Topics'} Available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            if (_isSearching) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Filtered',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.indigo,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildTopicList() {
    if (filteredTopics.isEmpty && !_isLoading) {
      return _buildEmptyState();
    }
    
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        itemCount: filteredTopics.length,
        itemBuilder: (context, index) {
          final topic = filteredTopics[index];
          final backgroundColor = _getRowColor(index);
          final icon = _getIconForIndex(index);
          
          return AnimatedBuilder(
            animation: _staggerController,
            builder: (context, child) {
              final animationValue = Curves.easeOutCubic.transform(
                (_staggerController.value - (index * 0.1)).clamp(0.0, 1.0),
              );
              
              return FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _staggerController,
                    curve: Interval(
                      (index * 0.1).clamp(0.0, 1.0),
                      ((index * 0.1) + 0.5).clamp(0.0, 1.0),
                      curve: Curves.easeOut,
                    ),
                  ),
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _staggerController,
                      curve: Interval(
                        (index * 0.1).clamp(0.0, 1.0),
                        ((index * 0.1) + 0.5).clamp(0.0, 1.0),
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          backgroundColor,
                          backgroundColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: backgroundColor.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 0,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.all(20.0),
                          leading: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              icon,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          title: Text(
                            topic['topicName']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.school_outlined, color: Colors.white, size: 14),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Class: ${topic['classTaught']}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.schedule_outlined, color: Colors.white, size: 14),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Term: ${topic['term']}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.subject_outlined, color: Colors.white, size: 14),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Subject: ${topic['subject'] ?? 'General'}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          trailing: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
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
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.25),
                                        Colors.white.withOpacity(0.15),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: ElevatedButton(
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
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.menu_book_outlined, color: Colors.white, size: 20),
                                        SizedBox(width: 10),
                                        Text(
                                          'Prepare',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            fontSize: 15,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 10,
                                        spreadRadius: 0,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
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
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.play_circle_outline_rounded, color: backgroundColor, size: 20),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Start Class',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: backgroundColor,
                                            fontSize: 15,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.topic_outlined,
                  size: 64,
                  color: Colors.indigo.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _isSearching ? 'No topics found' : 'No topics available',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _isSearching 
                    ? 'Try adjusting your search terms\nor clear the search to see all topics'
                    : 'Add your first topic to get started\nwith your learning journey',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              if (!_isSearching) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Add_Subject_Class(userId: widget.userId),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Topic'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Add_Subject_Class(userId: widget.userId),
          ),
        );
      },
      icon: const Icon(Icons.add_rounded),
      label: const Text('Add Topic'),
      backgroundColor: Colors.indigo,
      foregroundColor: Colors.white,
      elevation: 8,
      tooltip: 'Add Subject and Class',
    );
  }

  IconData _getIconForIndex(int index) {
    final icons = [
      Icons.science_outlined,
      Icons.calculate_outlined,
      Icons.language_outlined,
      Icons.history_edu_outlined,
      Icons.palette_outlined,
      Icons.sports_soccer_outlined,
      Icons.computer_outlined,
      Icons.biotech_outlined,
    ];
    return icons[index % icons.length];
  }

  Color _getRowColor(int index) {
    final colors = [

      Colors.indigo,
      Colors.teal,
      Colors.purple,
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.pink,
      Colors.cyan,
    ];
    return colors[index % colors.length].withOpacity(0.85);
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
              const SnackBar(content: Text('Failed to download file')));

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