import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/custom_scaffold.dart';
import '../database/database.dart';
import 'session_details_page.dart';
import 'home_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SessionsPage extends StatefulWidget {
  final String topic;
  final int topicId;

  const SessionsPage({super.key, required this.topic, required this.topicId});

  @override
  _SessionsPageState createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> with TickerProviderStateMixin {
  List<Map<String, dynamic>> sessions = [];
  List<Map<String, dynamic>> filteredSessions = [];
  late final Connectivity _connectivity;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    //fetchData();
    fetchLocalData();
    _searchController.addListener(_filterSessions);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initializeDatabase();

    final response = await http.get(
      Uri.parse('http://161.97.81.168:8080/viewSessions/${widget.topicId}'),
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
      }

      final sessionsData = await dbHelper.retrieveAllSession(widget.topicId);

      setState(() {
        sessions = sessionsData.map((session) => session.toMap()).toList();
        filteredSessions = List.from(sessions);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchLocalData() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initializeDatabase();

    final sessionsData = await dbHelper.retrieveAllSession(widget.topicId);

    setState(() {
      sessions = sessionsData.map((session) => session.toMap()).toList();
      filteredSessions = List.from(sessions);
      _isLoading = false;
    });
    
    // Start animations after data is loaded
    _animationController.forward();
  }

  void _filterSessions() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredSessions = sessions
          .where((session) =>
          session['sessionName']!.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return CustomScaffold(
      title: 'Sessions',
      onBackPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(userId: 1),
          ),
        );
      },
      child: SafeArea(
        child: Container(
          // Enhanced gradient background with more subtle colors
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.indigo.shade50,
                Colors.indigo.shade100.withOpacity(0.7),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.indigo.shade600,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading sessions...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.indigo.shade700,
                        ),
                      ),
                    ],
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Enhanced Title Banner with modern design
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 22,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.indigo.shade500,
                                  Colors.indigo.shade700,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.indigo.shade300.withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  widget.topic,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Available Sessions',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white.withOpacity(0.9),
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Enhanced Search Bar with animation
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                hintText: 'Search sessions...',
                                hintStyle: TextStyle(color: Colors.grey.shade600),
                                prefixIcon: Icon(Icons.search, color: Colors.indigo.shade400, size: 22),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(Icons.clear, color: Colors.grey.shade600, size: 20),
                                        onPressed: () {
                                          _searchController.clear();
                                          _filterSessions();
                                        },
                                      )
                                    : null,
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Colors.transparent),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.indigo.shade300, width: 1.5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Sessions Count
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                            child: Text(
                              '${filteredSessions.length} ${filteredSessions.length == 1 ? 'Session' : 'Sessions'} Found',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          // Enhanced Sessions List
                          Expanded(
                            child: filteredSessions.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.search_off_rounded,
                                          size: 60,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No sessions found',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade700,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Try adjusting your search',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.grey.shade600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: filteredSessions.length,
                                    itemBuilder: (context, index) {
                                      final session = filteredSessions[index];
                                      // Calculate animation delay based on index
                                      final itemAnimation = Tween<double>(
                                        begin: 0.0,
                                        end: 1.0,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: _animationController,
                                          curve: Interval(
                                            0.1 * (index / filteredSessions.length),
                                            0.6 + 0.4 * (index / filteredSessions.length),
                                            curve: Curves.easeOut,
                                          ),
                                        ),
                                      );
                                      
                                      return FadeTransition(
                                        opacity: itemAnimation,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0, 0.2),
                                            end: Offset.zero,
                                          ).animate(itemAnimation),
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 12.0),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => SessionDetailsPage(
                                                        sessionName: session['sessionName']!,
                                                        sessionId: session['id']!,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                borderRadius: BorderRadius.circular(16),
                                                splashColor: Colors.indigo.shade100.withOpacity(0.3),
                                                highlightColor: Colors.indigo.shade100.withOpacity(0.1),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(16),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withOpacity(0.05),
                                                        blurRadius: 8,
                                                        offset: const Offset(0, 2),
                                                        spreadRadius: 0,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 16,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        // Enhanced leading icon with modern design
                                        Container(
                                          width: 64,
                                          height: 64,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.indigo.shade400,
                                                Colors.indigo.shade600,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(18),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.indigo.shade300.withOpacity(0.4),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                                spreadRadius: 1,
                                              ),
                                              BoxShadow(
                                                color: Colors.indigo.shade200.withOpacity(0.2),
                                                blurRadius: 20,
                                                offset: const Offset(0, 8),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.school_rounded,
                                            color: Colors.white,
                                            size: 32,
                                          ),
                                         ),
                                                         const SizedBox(width: 16),
                                                        // Session details
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                session['sessionName']!,
                                                                style: const TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.w600,
                                                                  color: Colors.black87,
                                                                  letterSpacing: 0.2,
                                                                ),
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                              const SizedBox(height: 4),
                                                              Text(
                                                                'Duration: ${session['duration'] ?? 'Not specified'}',
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors.grey.shade600,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        // Enhanced trailing icon
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            color: Colors.indigo.shade50,
                                                            borderRadius: BorderRadius.circular(30),
                                                          ),
                                                          padding: const EdgeInsets.all(8),
                                                          child: Icon(
                                                            Icons.arrow_forward_ios_rounded,
                                                            color: Colors.indigo.shade500,
                                                            size: 16,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
