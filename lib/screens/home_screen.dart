import 'package:flutter/material.dart';
import '../widgets/custom_scaffold.dart';
import 'package:http/http.dart' as http; // Import http package
import 'dart:convert';
import 'SessionsPage.dart';
import 'addSubject_Class.dart';
import 'signin_screen.dart'; // Import SignInScreen
import 'signup_screen.dart';
import '../theme/theme.dart';
import '../database/database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
//import 'package:login_signup/utils/internet.dart';
import '../utills/animateAButton.dart';


class HomeScreen extends StatefulWidget {

  int? userId;

  HomeScreen({required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> scienceTopics = [];
  List<Map<String, dynamic>> filteredTopics = [];
  //late final Connectivity _connectivity;
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    //_connectivity = Connectivity();
    _connectivity.onConnectivityChanged;
    // _checkInternetAndFetchData();
    fetchData();
    fetchLocalData();
  }

  /*
  Future<void> _checkInternetAndFetchData() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    print(connectivityResult);
    if (connectivityResult.contains(ConnectivityResult.mobile) || connectivityResult.contains(ConnectivityResult.wifi)) {
      fetchData();
      print("-------------------------- internet -------------");
    } else if(connectivityResult.contains(ConnectivityResult.none)) {
      fetchLocalData();
      print("--------------------------no internet -------------");
    }
  }

   */


  Future<void> fetchData() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initializeDatabase();

    final response = await http.get(Uri.parse('http://161.97.81.168:8080/'));


    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      // Convert JSON data to Topic objects and insert into the database
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
      }


      // Retrieve all topics from the database and print them
      final topics = await dbHelper.getTopicsForUser(widget.userId!);


      // Update the state with the retrieved topics
      setState(() {
        // Convert the list of Topic objects to a list of maps
        scienceTopics = topics.map((topic) => topic.toMap()).toList();
        filteredTopics = List.from(scienceTopics);
        print(filteredTopics);
      });

    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchLocalData() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initializeDatabase();
    print(widget.userId);
    // Retrieve all topics from the database and print them
    final topics = await dbHelper.getTopicsForUser(widget.userId!);


    // Update the state with the retrieved topics
    setState(() {
      // Convert the list of Topic objects to a list of maps
      scienceTopics = topics.map((topic) => topic.toMap()).toList();
      filteredTopics = List.from(scienceTopics);
      print(filteredTopics);
    });
  }

  void filterTopics(String query) {
    setState(() {
      filteredTopics = scienceTopics
          .where((topic) =>
          topic['topic']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
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
              child: SizedBox(
                height: 10,
              ),
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
                      const SizedBox(
                        height: 20.0,
                      ),
                      /*
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: DropdownButtonFormField<String>(
                                value: 'Choose Class',
                                onChanged: (String? newValue) {},
                                items: <String>[
                                  // ,
                                  // 'Class 2',
                                  // 'Class 3',
                                  // 'Class 4'0
                                ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: DropdownButtonFormField<String>(
                                value: 'Term 1',
                                onChanged: (String? newValue) {},
                                items: <String>[
                                  'Term 1',
                                  'Term 2',
                                  'Term 3',
                                  // 'Term 4'
                                ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 5),
                              child: TextField(
                                onChanged: filterTopics,
                                decoration: InputDecoration(
                                  labelText: 'Search',
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                       */
                      const SizedBox(
                        height: 20.0,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 11,
                          columns: [
                            DataColumn(label: Text('Topic')),
                            DataColumn(label: Text('Class')),
                            DataColumn(label: Text('Term')),
                            DataColumn(label: Text('Actions')),
                          ],
                            rows:filteredTopics
                              .map(
                                (topic) => DataRow(
                              cells: [
                                DataCell(Container(
                                  width: 120, // Set a specific width for the Container
                                  child: Text(
                                    topic['topicName']!,
                                    overflow: TextOverflow.ellipsis, // Allow text to overflow with ellipsis
                                  ),
                                ),),
                                DataCell(Text(topic['classTaught']!)),
                                DataCell(Text(topic['term']!)),
                                DataCell(Row(
                                  children: [
                                    AnimatedElevatedButton(
                                      onPressed: () {
                                        // Handle Prepare button press
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
                                      text: 'Prepare',
                                    ),
                                    SizedBox(width: 10),
                                    AnimatedElevatedButton(
                                      onPressed: () {

                                        // Handle Start a Lesson button press
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SessionsPage(
                                                  topic: topic['topicName']!,
                                                  topicId: topic['id']!,
                                                ),
                                          ),
                                        );
                                      },
                                      text: 'Start Class',
                                    ),
                                  ],
                                )),
                              ],
                            ),
                          )
                              .toList(),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 10,
                            ),
                            child: Text(
                              '',
                              style: TextStyle(
                                color: Colors.black45,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Icon(Icons.facebook),
                          // Icon(Icons.twitter),
                          // Icon(Icons.google),
                          // Icon(Icons.apple),
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // Don't have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: Text(
                              '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Add_Subject_Class(userId: widget.userId)),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add Subject and Class',
      ),
    );
  }
}
