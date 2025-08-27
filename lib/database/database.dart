import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';

class Topic {
  final int id;
  final String topicName;
  final String topicCode;
  final String term;
  final String cat;
  final String subject;
  final String classTaught;
  final DateTime dateCreated;

  Topic({
    required this.id,
    required this.topicName,
    required this.topicCode,
    required this.term,
    required this.cat,
    required this.subject,
    required this.classTaught,
    required this.dateCreated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topicName': topicName,
      'topicCode': topicCode,
      'term': term,
      'cat': cat,
      'subject': subject,
      'classTaught': classTaught,
      'dateCreated': dateCreated.toIso8601String(),
    };
  }

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      id: map['id'],
      topicName: map['topicName'],
      topicCode: map['topicCode'],
      term: map['term'],
      cat: map['cat'],
      subject: map['subject'],
      classTaught: map['classTaught'],
      dateCreated: DateTime.parse(map['dateCreated']),
    );
  }
  @override
  String toString() {
    return 'Topic(id: $id, topicName: $topicName, topicCode: $topicCode, term: $term, cat: $cat, subject: $subject, classTaught: $classTaught, dateCreated: $dateCreated)';
  }
}

class Session {
  final int id;
  final String sessionName;
  final int topic;
  final String duration;
  final String learningObjective;
  final String fundibotsResources;
  final String schoolResources;
  final DateTime dateCreated;

  Session({
    required this.id,
    required this.sessionName,
    required this.topic,
    required this.duration,
    required this.learningObjective,
    required this.fundibotsResources,
    required this.schoolResources,
    required this.dateCreated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionName': sessionName,
      'topic': topic,
      'duration': duration,
      'learningObjective': learningObjective,
      'fundibotsResources': fundibotsResources,
      'schoolResources': schoolResources,
      'dateCreated': dateCreated.toIso8601String(),
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'],
      sessionName: map['sessionName'],
      topic: map['topic'],
      duration: map['duration'],
      learningObjective: map['learningObjective'],
      fundibotsResources: map['fundibotsResources'],
      schoolResources: map['schoolResources'],
      dateCreated: DateTime.parse(map['dateCreated']),
    );
  }

  @override
  String toString() {
    return 'Session{id: $id, sessionName: $sessionName, topic: $topic, duration: $duration, learningObjective: $learningObjective, fundibotsResources: $fundibotsResources, schoolResources: $schoolResources, dateCreated: $dateCreated}';
  }
}


class Activity {
  final int id;
  final String title;
  final int session;
  final String teacherActivity;
  final String studentActivity;
  final String mediaType;
  final int time;
  final String notes;
  final String image;
  final String imageTitle;
  final String video;
  final String videoTitle;
  final String realVideo;
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.title,
    required this.session,
    required this.teacherActivity,
    required this.studentActivity,
    required this.mediaType,
    required this.time,
    required this.notes,
    required this.image,
    required this.imageTitle,
    required this.video,
    required this.videoTitle,
    required this.realVideo,
    required this.createdAt,
  });

  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'session': session,
      'teacherActivity': teacherActivity,
      'studentActivity': studentActivity,
      'mediaType': mediaType,
      'time': time,
      'notes': notes,
      'image': image,
      'imageTitle': imageTitle,
      'video': video,
      'videoTitle': videoTitle,
      'realVideo': realVideo,
      'createdAt': createdAt.toIso8601String(),
    };
  }


  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      title: map['title'],
      session: map['session'],
      teacherActivity: map['teacherActivity'],
      studentActivity: map['studentActivity'],
      mediaType: map['mediaType'],
      time: map['time'],
      notes: map['notes'],
      image: map['image'],
      imageTitle: map['imageTitle'],
      video: map['video'],
      videoTitle: map['videoTitle'],
      realVideo: map['realVideo'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
  @override
  String toString() {
    return 'Activity{id: $id, title: $title, session: $session, teacherActivity: $teacherActivity, studentActivity: $studentActivity, mediaType: $mediaType, time: $time, notes: $notes, image: $image, imageTitle: $imageTitle, video: $video, videoTitle: $videoTitle, realVideo: $realVideo, createdAt: $createdAt}';
  }

}


class User {
  final int? id;
  final String name;
  final String password;
  final String school;
  final String email;

  User({
    this.id,
    required this.name,
    required this.password,
    required this.school,
    required this.email
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'password': password,
      'school': school,
      'email': email,
    };
  }

  factory User.fromMap(Map<String, dynamic> map){
    return User(
      id: map['id'],
      name: map['name'],
      password: map['password'],
      school: map['school'],
      email: map['email'],
    );
  }

}


class ClassSubject {
  final int? id;
  final String className;
  final String subjectName;
  final int userId;

  ClassSubject({this.id, required this.className, required this.subjectName, required this.userId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'class_name': className,
      'subject_name': subjectName,
      'user_id': userId,
    };
  }
  factory ClassSubject.fromMap(Map<String, dynamic> map){
    return ClassSubject(
      id: map['id'],
      className: map['class_name'],
      subjectName: map['subject_name'],
      userId: map['user_id'],

    );
  }
}

class TeacherData {
  final int? teacherId;
  final String teacherName;
  final String schoolName;
  final String classStream;
  final String topicCovered;
  final String sessionCovered;

  // TabUsage Fields
  final String? frequency;
  final String? easeOfUse;
  final String? digitalContentUsefulnes;
  final String? prepTimeSaved;
  final String? effectivenessOfIntruc;

  // VideoContent Fields
  // VideoContent Fields as a Key-Value Pair
  final Map<String, int> videoContentRatings;
  final String? escVideoHelpfulness;
  final String? confidenceInESC;
  final String? escVideoPreparation;


  // Evaluation Fields
  final int? overallSatisfaction;
  final List<String>? challenges;
  final String? improvements;
  final String? additionalComments;
  final DateTime? evaluationDate;

  TeacherData({
    this.teacherId,
    required this.teacherName,
    required this.schoolName,
    required this.classStream,
    required this.topicCovered,
    required this.sessionCovered,
    this.frequency,
    this.easeOfUse,
    required this.digitalContentUsefulnes,
    required this.prepTimeSaved,
    required this.effectivenessOfIntruc,
    required this.videoContentRatings,
    required this.escVideoHelpfulness,
    required this.confidenceInESC,
    required this.escVideoPreparation,
    this.overallSatisfaction,
    this.challenges,
    this.improvements,
    this.additionalComments,
    this.evaluationDate,
  });

  // Convert to Map for Database
  Map<String, dynamic> toMap() {
    return {
      'teacherId': teacherId,
      'teacherName': teacherName,
      'schoolName': schoolName,
      'classStream': classStream,
      'topicCovered': topicCovered,
      'sessionCovered': sessionCovered,
      'frequency': frequency,
      'easeOfUse': easeOfUse,
      'digitalContentUsefulnes': digitalContentUsefulnes,
      'prepTimeSaved':prepTimeSaved,
      'effectivenessOfIntruc': effectivenessOfIntruc,
      'videoContentRatings': videoContentRatings.entries
          .map((entry) => '${entry.key}:${entry.value}')
          .join(','), // Store as a single string of key-value pairs
      'escVideoHelpfulness':escVideoHelpfulness,
      'confidenceInESC':confidenceInESC,
      'escVideoPreparation':escVideoPreparation,
      'overallSatisfaction': overallSatisfaction,
      'challenges': challenges?.join(','),
      'improvements': improvements,
      'additionalComments': additionalComments,
      'evaluationDate': evaluationDate?.toIso8601String(),
    };
  }

  factory TeacherData.fromMap(Map<String, dynamic> map) {

    Map<String, int> videoContentRatings = {};

    if (map['videoContentRatings'] != null) {
      var ratings = map['videoContentRatings'].split(',');
      for (var rating in ratings) {
        var parts = rating.split(':');
        if (parts.length == 2) {
          videoContentRatings[parts[0]] = int.tryParse(parts[1]) ?? 0;
        }
      }
    }

    List<String> challenges = [];
    if (map['challenges'] != null) {
      challenges = map['challenges'].split(',');  // Split the string back into a list
    }

    return TeacherData(
      teacherId: map['teacherId'],
      teacherName: map['teacherName'],
      schoolName: map['schoolName'],
      classStream: map['classStream'],
      topicCovered: map['topicCovered'],
      sessionCovered: map['sessionCovered'],
      frequency: map['frequency'],
      easeOfUse: map['easeOfUse'],
      digitalContentUsefulnes: map['digitalContentUsefulnes'],
      prepTimeSaved: map['prepTimeSaved'],
      effectivenessOfIntruc: map['effectivenessOfIntruc'],
      videoContentRatings: videoContentRatings,
      escVideoHelpfulness: map['escVideoHelpfulness'],
      confidenceInESC:map['confidenceInESC'],
      escVideoPreparation: map['escVideoPreparation'],
      overallSatisfaction: map['overallSatisfaction'],
      challenges: challenges.isNotEmpty ? challenges : null,
      improvements: map['improvements'],
      additionalComments: map['additionalComments'],
      evaluationDate: map['evaluationDate'] != null
          ? DateTime.parse(map['evaluationDate'])
          : null,
    );
  }
}



class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Database? _database;

  Future<void> initializeDatabase() async {
    // Initialize the database
    WidgetsFlutterBinding.ensureInitialized();
    _database = await openDatabase(
      join(await getDatabasesPath(), 'virtual_Fundi.db'), //virtualFundiDb.db'
      version: 15, // Increment the version number
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE topics(id INTEGER PRIMARY KEY, topicName TEXT, topicCode TEXT, term TEXT, cat TEXT, subject TEXT, classTaught TEXT, dateCreated TEXT)',
        );
        db.execute(
          'CREATE TABLE sessions(id INTEGER PRIMARY KEY, sessionName TEXT, topic INTEGER, duration TEXT DEFAULT "60", learningObjective TEXT DEFAULT "", fundibotsResources TEXT DEFAULT "", schoolResources TEXT DEFAULT "", dateCreated TEXT)',
        );
        db.execute(
          'CREATE TABLE activities(id INTEGER PRIMARY KEY, title TEXT DEFAULT "", session INTEGER, teacherActivity TEXT DEFAULT "", studentActivity TEXT DEFAULT "", mediaType TEXT DEFAULT "", time INTEGER, notes TEXT DEFAULT "", image TEXT DEFAULT "", imageTitle TEXT DEFAULT "", video TEXT DEFAULT "", videoTitle TEXT DEFAULT "", realVideo TEXT, createdAt TEXT)',
        );

        db.execute(
          "CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, password TEXT, school TEXT, email TEXT)",
        );
        db.execute(
          "CREATE TABLE class_subjects(id INTEGER PRIMARY KEY AUTOINCREMENT, class_name TEXT, subject_name TEXT, user_id INTEGER, FOREIGN KEY(user_id) REFERENCES users(id), UNIQUE(class_name, subject_name, user_id))",
        );
        db.execute(
          'CREATE TABLE teacherData(teacherId INTEGER PRIMARY KEY AUTOINCREMENT, teacherName TEXT, schoolName TEXT,classStream TEXT,topicCovered TEXT,sessionCovered TEXT,frequency TEXT,easeOfUse TEXT, digitalContentUsefulnes TEXT, prepTimeSaved TEXT, effectivenessOfIntruc TEXT, videoContentRatings TEXT, escVideoHelpfulness TEXT, confidenceInESC TEXT, escVideoPreparation TEXT, overallSatisfaction INTEGER, challenges TEXT, improvements TEXT, additionalComments TEXT, evaluationDate TEXT)',
        );

      },
      onUpgrade: (db, oldVersion, newVersion) async {
          if(oldVersion < 15){
            db.execute(
              'CREATE TABLE IF NOT EXISTS teacherData(teacherId INTEGER PRIMARY KEY AUTOINCREMENT, teacherName TEXT, schoolName TEXT,classStream TEXT,topicCovered TEXT,sessionCovered TEXT,frequency TEXT,easeOfUse TEXT, digitalContentUsefulnes TEXT, prepTimeSaved TEXT, effectivenessOfIntruc TEXT, videoContentRatings TEXT, escVideoHelpfulness TEXT, confidenceInESC TEXT, escVideoPreparation TEXT, overallSatisfaction INTEGER, challenges TEXT, improvements TEXT, additionalComments TEXT, evaluationDate TEXT)',
            );
          }
      },
    );
  }


  Future<void> runInTransaction(Future<void> Function(Transaction txn) action) async {
    final db = await _database;
    await db!.transaction(action);
  }


  // User operations
  Future<void> insertUser(User user) async {
    final db = await _database;
    await db?.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve a user by email.
  Future<User?> getUser(String email) async {
    final List<Map<String, dynamic>> maps = await _database!.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    // Check if session with given ID exists
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null; // User not found
    }
  }

  // Retrieve a user by email.
  Future<int?> getUserId(String email) async {
    final List<Map<String, dynamic>> maps = await _database!.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    // Check if session with given ID exists
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first).id;
    } else {
      return null; // User not found
    }
  }

  Future<int> addUserSubjectClass(int? userId, String subject, String className) async {
    final db = await _database;
    return await db!.insert('class_subjects', {
      'user_id': userId,
      'subject_name': subject,
      'class_name': className,
    });
  }

  Future<List<ClassSubject>> getClassSubjectsForUser(int? userId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'class_subjects',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (index) {
      return ClassSubject.fromMap(maps[index]);
    });
  }


  Future<bool> insertTopic(Topic topic, {Transaction? txn}) async {
    final db = txn ?? _database;
    try {
      await db!.insert(
        'topics',
        topic.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return true;
    } on DatabaseException catch (e) {
      if (e.isDuplicateColumnError()) {
        // Handle unique constraint violation
        print('Topic with ID ${topic.id} already exists.');
      } else {
        // Handle other database errors
        print('Database error: $e');
      }
      return false;
    }
  }

/*
  Future<List<Topic>> retrieveAllTopics() async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db!.query('topics');
    return List.generate(maps.length, (index) {
      return Topic.fromMap(maps[index]);
    });
  }

 */

  Future<Map<int, String>> retrieveTopicTimestamps() async {
    final db = await _database;
    final List<Map<String, dynamic>> localData =
    await db!.query('topics', columns: ['id', 'dateCreated']);

    return {
      for (var row in localData)
        row['id'] as int: row['dateCreated'].toString()
    };
  }




  Future<List<Topic>> getTopicsForUser(int userId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db!.rawQuery('''
    SELECT DISTINCT topics.* FROM topics
    INNER JOIN class_subjects ON topics.subject = class_subjects.subject_name AND topics.classTaught = class_subjects.class_name
    WHERE class_subjects.user_id = ?
  ''', [userId]);

    return List.generate(maps.length, (index) {
      return Topic.fromMap(maps[index]);
    });
  }

  Future<bool> updateTopic(Topic topic, {Transaction? txn}) async {
    final db = txn ?? await _database;
    try {
      await db!.update(
        'topics',
        topic.toMap(),
        where: 'id = ?',
        whereArgs: [topic.id],
      );
      return true;
    }catch(e){
      print('Update topic failed: $e');
      return false;
    }
  }

  Future<int> deleteTopic(int id) async {
    final db = await _database;
    return await db!.delete(
      'topics',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> insertSession(Session session, {Transaction? txn}) async {
    final db = txn ?? _database;
    try {
      await db!.insert(
        'sessions',
        session.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return true;
    } on DatabaseException catch (e) {
      if (e.isDuplicateColumnError()) {
        // Handle unique constraint violation
        print('Session with ID ${session.id} already exists.');
      } else {
        // Handle other database errors
        print('Database error: $e');
      }
      return false;
    }
  }

  Future<Map<int, String>> retrieveSessionTimestamps() async {
    final db = await _database;
    final List<Map<String, dynamic>> localData =
    await db!.query('sessions', columns: ['id', 'dateCreated']);

    return {
      for (var row in localData)
        row['id'] as int: row['dateCreated'].toString()
    };
  }

  Future<List<Session>> retrieveAllSession(int topicId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'sessions',
      where: 'topic = ?',
      whereArgs: [topicId],
    );
    // Convert each map to a Session object
    return maps.map((map) => Session.fromMap(map)).toList();
  }

  // Retrieve a session by ID
  Future<Session?> getSessionById(int sessionId) async {
    final List<Map<String, dynamic>> maps = await _database!.query(
      'sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );

    // Check if session with given ID exists
    if (maps.isNotEmpty) {
      return Session.fromMap(maps.first);
    } else {
      return null; // Session not found
    }
  }

  Future<bool> updateSession(Session session, {Transaction? txn}) async {
    final db = txn ?? await _database;
    try {
      await db!.update(
        'Sessions',
        session.toMap(),
        where: 'id = ?',
        whereArgs: [session.id],
      );
      return true;
    }catch(e){
      print('Update session failed: $e');
      return false;
    }
  }

  Future<int> deleteSession(int id) async {
    final db = await _database;
    return await db!.delete(
      'sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  Future<bool> insertActivity(Activity activity, {Transaction? txn}) async {
    final db = txn ?? await _database;
    try {
      await db!.insert(
        'activities',
        activity.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return true;
    } on DatabaseException catch (e) {
      if (e.isDuplicateColumnError()) {
        // Handle unique constraint violation
        print('Session with ID ${activity.id} already exists.');
      } else {
        // Handle other database errors
        print('Database error: $e');
      }
      return false;
    }
  }

  Future<Map<int, String>> retrieveActivitiesTimestamps() async {
    final db = await _database;
    final List<Map<String, dynamic>> localData =
    await db!.query('activities', columns: ['id', 'createdAt']);

    return {
      for (var row in localData)
        row['id'] as int: row['createdAt'].toString()
    };
  }

  // Retrieve all activities under a session from the database
  Future<List<Activity>> retrieveActivitiesBySession(int sessionId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'activities',
      where: 'session = ?',
      whereArgs: [sessionId],
    );
    return List.generate(maps.length, (index) {
      return Activity(
        id: maps[index]['id'],
        title: maps[index]['title'],
        session: maps[index]['session'],
        teacherActivity: maps[index]['teacherActivity'],
        studentActivity: maps[index]['studentActivity'],
        mediaType: maps[index]['mediaType'],
        time: maps[index]['time'],
        notes: maps[index]['notes'],
        image: maps[index]['image'],
        imageTitle: maps[index]['imageTitle'],
        video: maps[index]['video'],
        videoTitle: maps[index]['videoTitle'],
        realVideo: maps[index]['realVideo'],
        createdAt: DateTime.parse(maps[index]['createdAt']),
      );
    });

  }

  // Retrieve all activities with mediaType == 'video' and realVideo != 'placeholder'
  Future<List<Activity>> retrieveVideoActivities() async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'activities',
      where: 'mediaType = ?',
      whereArgs: ['video'],
    );

    return List.generate(maps.length, (index) {
      return Activity(
        id: maps[index]['id'],
        title: maps[index]['title'],
        session: maps[index]['session'],
        teacherActivity: maps[index]['teacherActivity'],
        studentActivity: maps[index]['studentActivity'],
        mediaType: maps[index]['mediaType'],
        time: maps[index]['time'],
        notes: maps[index]['notes'],
        image: maps[index]['image'],
        imageTitle: maps[index]['imageTitle'],
        video: maps[index]['video'],
        videoTitle: maps[index]['videoTitle'],
        realVideo: maps[index]['realVideo'],
        createdAt: DateTime.parse(maps[index]['createdAt']),
      );
    });
  }


  Future<bool> updateActivity(Activity activity, {Transaction? txn}) async {
    final db = txn ?? await _database;

    try {
      await db!.update(
        'activities',
        activity.toMap(),
        where: 'id = ?',
        whereArgs: [activity.id],
      );
      return true;
    }catch (e){
      print('Update topic failed: $e');
      return false;
    }
  }

  // Feedback
  Future<int> insertTeacherData(TeacherData teacherData) async {
    final db = await _database;
    return await db!.insert(
      'teacherData',
      teacherData.toMap(), // Convert TeacherData to a map for the database
      conflictAlgorithm: ConflictAlgorithm.abort, // Replace if there's a conflict (optional)
    );
  }

  Future<List<TeacherData>> getAllTeacherData() async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db!.query('teacherData');

    // Convert each map to a Session object
    return maps.map((map) => TeacherData.fromMap(map)).toList();
  }

}

/// Future<List<Session>> retrieveAllSession(int topicId) async {
//     final db = await _database;
//     final List<Map<String, dynamic>> maps = await db!.query(
//       'sessions',
//       where: 'topic = ?',
//       whereArgs: [topicId],
//     );
//     // Convert each map to a Session object
//     return maps.map((map) => Session.fromMap(map)).toList();
//   }

