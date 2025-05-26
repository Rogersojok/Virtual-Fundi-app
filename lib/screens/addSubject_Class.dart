import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../widgets/custom_scaffold.dart';
import 'home_screen.dart';
import 'package:virtualfundi/theme/theme.dart';
import 'package:virtualfundi/utills/animateAButton.dart';
import '../database/database.dart';


class Add_Subject_Class extends StatefulWidget {
  int? userId;
  Add_Subject_Class({super.key, required this.userId});

  @override
  State<Add_Subject_Class> createState() => _Add_Subject_ClassState();
}

class _Add_Subject_ClassState extends State<Add_Subject_Class> {
  final _formSignupKey = GlobalKey<FormState>();

  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    _initDb();
  }

  Future<void> _initDb() async{
    await dbHelper.initializeDatabase();
  }

  final List<String> _subjects = ['Physics', 'Biology', 'Chemistry', 'Science']; // Replace with your subjects
  final List<String> _classes = ['P.4', 'P.5', 'P.6', 'P7', 'S.1', 'S.2', 'S.3','S.4']; // Replace with your classes

  String? _selectedSubject;
  String? _selectedClass;

  Future<void> _add_subject_class() async{
    await dbHelper.initializeDatabase();
    print("................................");
    print(widget.userId);
    print("................................");
    if (_selectedSubject != null && _selectedClass != null) {
      try {
        int result =  await dbHelper.addUserSubjectClass(widget.userId, _selectedSubject!, _selectedClass!);
        if(result > 0){
          // If the result is greater than 0, it means the insertion was successful
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Subject and class added successfully')));
        }else{
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add subject and class')));
        }
      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: Exist')));
      }
    } else {
      // Show an error message if the user didn't select both fields
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select both subject and class')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Add Subject and Class',
      onBackPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userId: 1), // Replace with actual userId
          ),
        );
      },
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
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),

              child: SingleChildScrollView(
                // get started form
                child: Form(
                  key: _formSignupKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // get started text
                      const Text(
                        'Add Subject and class',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      showSubjectClass(userId: widget.userId,),
                      const SizedBox(
                        height: 40.0,
                      ),
                      // full name
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Subject'),
                        value: _selectedSubject,
                        items: _subjects.map((String subject) {
                          return DropdownMenuItem<String>(
                            value: subject,
                            child: Text(subject),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedSubject = newValue;
                          });
                        },
                      ),
                      //School
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Class'),
                        value: _selectedClass,
                        items: _classes.map((String className) {
                          return DropdownMenuItem<String>(
                            value: className,
                            child: Text(className),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedClass = newValue;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),

                      // add button
                      SizedBox(
                        width: double.infinity,
                        child: AnimatedElevatedButton(
                          onPressed: _add_subject_class,
                          text: "Save",
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      // sign up divider

                      const SizedBox(
                        height: 25.0,
                      ),
                      // already have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) =>  HomeScreen(userId: widget.userId,),
                                ),
                              );
                            },
                            child: Text(
                              'Back to Topics',
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
          ),
        ],

      ),

    );
  }
}

class showSubjectClass extends StatefulWidget {
  int? userId;
  showSubjectClass({super.key, required this.userId});

  @override
  State<showSubjectClass> createState() => _showSubjectClassState();
}

class _showSubjectClassState extends State<showSubjectClass> {

  final dbHelper = DatabaseHelper();

  @override
  void initState() {
  _initDb();
  }

  Future<void> _initDb() async{
    await dbHelper.initializeDatabase();
  }

  @override
  void setState(VoidCallback fn) {
    _initDb();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.0,
      child: Scaffold(

        body: FutureBuilder<List<ClassSubject>>(
          future: dbHelper.getClassSubjectsForUser(widget.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print(snapshot);
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No class subjects found for this user.'));
            } else {
              return Column(
                children: [
                  Expanded(

                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var classSubject = snapshot.data![index];
                        return ListTile(
                          title: Text('Subject: ${classSubject.subjectName}'),
                          subtitle: Text('Class: ${classSubject.className}'),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}


/*

class UserClassSubjectsScreen extends StatelessWidget {
  int? userId;

  UserClassSubjectsScreen({required this.userId});

  final dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.0,
      child: Scaffold(

        body: FutureBuilder<List<ClassSubject>>(
          future:  dbHelper.getClassSubjectsForUser(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print(snapshot);
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No class subjects found for this user.'));
            } else {
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var classSubject = snapshot.data![index];
                        return ListTile(
                          title: Text('Subject: ${classSubject.subjectName}'),
                          subtitle: Text('Class: ${classSubject.className}'),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

 */
