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
            builder: (context) => HomeScreen(userId: widget.userId),
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    spreadRadius: 0,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),

              child: SingleChildScrollView(
                // get started form
                child: Form(
                  key: _formSignupKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Title with gradient text
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            AppColors.primaryOrange,
                            AppColors.primaryOrange.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Text(
                          'Add Subject and Class',
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      showSubjectClass(userId: widget.userId,),
                      const SizedBox(
                        height: 40.0,
                      ),
                      // Subject dropdown with improved styling
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Subject',
                            labelStyle: TextStyle(color: AppColors.textSecondary),
                            prefixIcon: Icon(Icons.book, color: AppColors.primaryOrange),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          value: _selectedSubject,
                          icon: Icon(Icons.arrow_drop_down_rounded, color: AppColors.primaryOrange),
                          dropdownColor: Colors.white,
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
                      ),
                      // Class dropdown with improved styling
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Class',
                            labelStyle: TextStyle(color: AppColors.textSecondary),
                            prefixIcon: Icon(Icons.school, color: AppColors.primaryOrange),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          value: _selectedClass,
                          icon: Icon(Icons.arrow_drop_down_rounded, color: AppColors.primaryOrange),
                          dropdownColor: Colors.white,
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
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),

                      // Modern save button
                      Container(
                        width: double.infinity,
                        height: 50,
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryOrange,
                              AppColors.primaryOrange.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryOrange.withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _add_subject_class,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Save",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
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
                                color: AppColors.primaryOrange,
                                fontSize: 14,
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
    return Container(
      height: 120.0,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(Icons.list_alt_rounded, color: AppColors.primaryOrange, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Your Subjects & Classes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ClassSubject>>(
              future: dbHelper.getClassSubjectsForUser(widget.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: AppColors.primaryOrange));
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No subjects or classes added yet',
                      style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      var classSubject = snapshot.data![index];
                      return Card(
                        elevation: 0,
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryOrange.withOpacity(0.1),
                            child: Icon(
                              Icons.book_outlined,
                              color: AppColors.primaryOrange,
                              size: 18,
                            ),
                          ),
                          title: Text(
                            classSubject.subjectName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            'Class: ${classSubject.className}',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
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
