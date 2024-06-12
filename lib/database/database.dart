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
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
  @override
  String toString() {
    return 'Activity{id: $id, title: $title, session: $session, teacherActivity: $teacherActivity, studentActivity: $studentActivity, mediaType: $mediaType, time: $time, notes: $notes, image: $image, imageTitle: $imageTitle, video: $video, videoTitle: $videoTitle, createdAt: $createdAt}';
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
}


class DatabaseHelper {
  late Database _database;

  Future<void> initializeDatabase() async {
    // Initialize the database
    WidgetsFlutterBinding.ensureInitialized();
    _database = await openDatabase(
      join(await getDatabasesPath(), 'virtualFundiDb5.db'), //virtualFundiDb.db'
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE topics(id INTEGER PRIMARY KEY, topicName TEXT, topicCode TEXT, term TEXT, cat TEXT, subject TEXT, classTaught TEXT, dateCreated TEXT)',
        );
        db.execute(
          'CREATE TABLE sessions(id INTEGER PRIMARY KEY, sessionName TEXT, topic INTEGER, duration TEXT DEFAULT "60", learningObjective TEXT DEFAULT "", fundibotsResources TEXT DEFAULT "", schoolResources TEXT DEFAULT "", dateCreated TEXT)',
        );
        db.execute(
          'CREATE TABLE activities(id INTEGER PRIMARY KEY, title TEXT DEFAULT "", session INTEGER, teacherActivity TEXT DEFAULT "", studentActivity TEXT DEFAULT "", mediaType TEXT DEFAULT "", time INTEGER, notes TEXT DEFAULT "", image TEXT DEFAULT "", imageTitle TEXT DEFAULT "", video TEXT DEFAULT "", videoTitle TEXT DEFAULT "", createdAt TEXT)',
        );

        db.execute(
          "CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, password TEXT, school TEXT, email TEXT)",
        );
        db.execute(
          "CREATE TABLE class_subjects(id INTEGER PRIMARY KEY AUTOINCREMENT, class_name TEXT, subject_name TEXT, user_id INTEGER, FOREIGN KEY(user_id) REFERENCES users(id))",
        );

      },
      version: 1,
    );
  }


  // User operations
  Future<void> insertUser(User user) async {
    final db = await _database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve a user by email.
  Future<User?> getUser(String email) async {
    final List<Map<String, dynamic>> maps = await _database.query(
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


/*
  Future<User?> getUser(String email) async {
    final db = await _database;
    var result = await db.query(
      'users',
      where: "email = ?",
      whereArgs: [email],
    );

    if (result != null && result.isNotEmpty) {
      return User(
        id: result.first['id'] as int?,
        name: result.first['name'] as String,
        password: result.first['password'] as String,
        school: result.first['school'] as String,
        email: result.first['email'] as String,
      );
    }
    return null;
  }

 */


  Future<void> insertTopic(Topic topic) async {
    try {
      await _database.insert(
        'topics',
        topic.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } on DatabaseException catch (e) {
      if (e.isDuplicateColumnError()) {
        // Handle unique constraint violation
        print('Topic with ID ${topic.id} already exists.');
      } else {
        // Handle other database errors
        print('Database error: $e');
      }
    }
  }


  Future<List<Topic>> retrieveAllTopics() async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query('topics');
    return List.generate(maps.length, (index) {
      return Topic.fromMap(maps[index]);
    });
  }

  Future<int> updateTopic(Topic topic) async {
    final db = await _database;
    return await db.update(
      'topics',
      topic.toMap(),
      where: 'id = ?',
      whereArgs: [topic.id],
    );
  }

  Future<int> deleteTopic(int id) async {
    final db = await _database;
    return await db.delete(
      'topics',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertSession(Session session) async {
    try {
      await _database.insert(
        'sessions',
        session.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } on DatabaseException catch (e) {
      if (e.isDuplicateColumnError()) {
        // Handle unique constraint violation
        print('Session with ID ${session.id} already exists.');
      } else {
        // Handle other database errors
        print('Database error: $e');
      }
    }
  }

  Future<List<Session>> retrieveAllSession(int topicId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sessions',
      where: 'topic = ?',
      whereArgs: [topicId],
    );
    // Convert each map to a Session object
    return maps.map((map) => Session.fromMap(map)).toList();
  }

  // Retrieve a session by ID
  Future<Session?> getSessionById(int sessionId) async {
    final List<Map<String, dynamic>> maps = await _database.query(
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

  Future<int> updateSession(Session session) async {
    final db = await _database;
    return await db.update(
      'Sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<int> deleteSession(int id) async {
    final db = await _database;
    return await db.delete(
      'sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  Future<void> insertActivity(Activity activity) async {
    try {
      await _database.insert(
        'activities',
        activity.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } on DatabaseException catch (e) {
      if (e.isDuplicateColumnError()) {
        // Handle unique constraint violation
        print('Session with ID ${activity.id} already exists.');
      } else {
        // Handle other database errors
        print('Database error: $e');
      }
    }
  }


/*
  // Insert a new activity into the database
  Future<void> insertActivity(Activity activity) async {
    final db = await _database;
    await db.insert(
      'activities',
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

 */

  // Retrieve all activities under a session from the database
  Future<List<Activity>> retrieveActivitiesBySession(int sessionId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
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
        createdAt: DateTime.parse(maps[index]['createdAt']),
      );
    });

  }

  Future<void> updateActivity(Activity activity) async {
    final db = await _database;
    await db.update(
      'activities',
      activity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

}
