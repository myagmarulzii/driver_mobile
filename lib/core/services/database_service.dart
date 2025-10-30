import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('driver_monitoring.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';
    const boolType = 'INTEGER NOT NULL';

    // Users table
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        username $textType,
        name $textType,
        email $textType,
        phone $textType,
        schoolId $textType,
        role $textType,
        status $textType,
        createdDate $textType,
        licenseNumber $textTypeNullable,
        idNumber $textTypeNullable,
        enrollmentDate $textTypeNullable,
        emergencyContact $textTypeNullable,
        assignedInstructorId $textTypeNullable,
        totalDistance $textTypeNullable,
        totalSessions $textTypeNullable
      )
    ''');

    // Driving sessions table
    await db.execute('''
      CREATE TABLE driving_sessions (
        sessionId $idType,
        studentId $textType,
        instructorId $textType,
        startTime $textType,
        endTime $textTypeNullable,
        startLocation $textType,
        endLocation $textTypeNullable,
        route $textType,
        distance $realType,
        duration $intType,
        practiceType $textType,
        sessionNotes $textTypeNullable,
        status $textType,
        syncStatus $textType DEFAULT 'pending'
      )
    ''');

    // Student progress table
    await db.execute('''
      CREATE TABLE student_progress (
        studentId $idType,
        totalRoadwayDistance $realType,
        totalPracticePlaceDistance $realType,
        totalClassroomHours $realType,
        examEligible $boolType,
        eligibilityDate $textTypeNullable,
        requiredRoadwayDistance $realType,
        requiredPracticePlaceDistance $realType,
        requiredClassroomHours $realType
      )
    ''');

    // Feedback table
    await db.execute('''
      CREATE TABLE feedback (
        feedbackId $idType,
        studentId $textType,
        instructorId $textType,
        sessionId $textTypeNullable,
        overallRating $realType,
        categoryRatings $textType,
        comments $textTypeNullable,
        date $textType,
        isAnonymous $boolType,
        syncStatus $textType DEFAULT 'pending'
      )
    ''');

    // Complaints table
    await db.execute('''
      CREATE TABLE complaints (
        complaintId $idType,
        studentId $textType,
        instructorId $textTypeNullable,
        category $textType,
        description $textType,
        status $textType,
        submittedDate $textType,
        resolutionDate $textTypeNullable,
        adminNotes $textTypeNullable,
        attachments $textType,
        syncStatus $textType DEFAULT 'pending'
      )
    ''');

    // Classroom sessions table
    await db.execute('''
      CREATE TABLE classroom_sessions (
        sessionId $idType,
        date $textType,
        topic $textType,
        duration $realType,
        instructor $textType,
        attendanceList $textType,
        syncStatus $textType DEFAULT 'pending'
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_sessions_student ON driving_sessions(studentId)');
    await db.execute('CREATE INDEX idx_sessions_instructor ON driving_sessions(instructorId)');
    await db.execute('CREATE INDEX idx_feedback_instructor ON feedback(instructorId)');
    await db.execute('CREATE INDEX idx_complaints_status ON complaints(status)');
  }

  Future<void> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    await db.insert(
      'users',
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUser(String id) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    final db = await database;
    return await db.query(
      'users',
      where: 'role = ?',
      whereArgs: [role],
    );
  }

  Future<int> updateUser(String id, Map<String, dynamic> user) async {
    final db = await database;
    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteUser(String id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Session methods
  Future<void> insertSession(Map<String, dynamic> session) async {
    final db = await database;
    await db.insert(
      'driving_sessions',
      session,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getSession(String sessionId) async {
    final db = await database;
    final results = await db.query(
      'driving_sessions',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> getSessionsByStudent(String studentId) async {
    final db = await database;
    return await db.query(
      'driving_sessions',
      where: 'studentId = ?',
      whereArgs: [studentId],
      orderBy: 'startTime DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getSessionsByInstructor(String instructorId) async {
    final db = await database;
    return await db.query(
      'driving_sessions',
      where: 'instructorId = ?',
      whereArgs: [instructorId],
      orderBy: 'startTime DESC',
    );
  }

  Future<int> updateSession(String sessionId, Map<String, dynamic> session) async {
    final db = await database;
    return await db.update(
      'driving_sessions',
      session,
      where: 'sessionId = ?',
      whereArgs: [sessionId],
    );
  }

  // Progress methods
  Future<void> insertOrUpdateProgress(Map<String, dynamic> progress) async {
    final db = await database;
    await db.insert(
      'student_progress',
      progress,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getProgress(String studentId) async {
    final db = await database;
    final results = await db.query(
      'student_progress',
      where: 'studentId = ?',
      whereArgs: [studentId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Feedback methods
  Future<void> insertFeedback(Map<String, dynamic> feedback) async {
    final db = await database;
    await db.insert(
      'feedback',
      feedback,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getFeedbackByInstructor(String instructorId) async {
    final db = await database;
    return await db.query(
      'feedback',
      where: 'instructorId = ?',
      whereArgs: [instructorId],
      orderBy: 'date DESC',
    );
  }

  // Complaint methods
  Future<void> insertComplaint(Map<String, dynamic> complaint) async {
    final db = await database;
    await db.insert(
      'complaints',
      complaint,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllComplaints() async {
    final db = await database;
    return await db.query(
      'complaints',
      orderBy: 'submittedDate DESC',
    );
  }

  Future<int> updateComplaint(String complaintId, Map<String, dynamic> complaint) async {
    final db = await database;
    return await db.update(
      'complaints',
      complaint,
      where: 'complaintId = ?',
      whereArgs: [complaintId],
    );
  }

  // Get pending sync items
  Future<List<Map<String, dynamic>>> getPendingSyncSessions() async {
    final db = await database;
    return await db.query(
      'driving_sessions',
      where: 'syncStatus = ?',
      whereArgs: ['pending'],
    );
  }

  Future<void> markSessionSynced(String sessionId) async {
    final db = await database;
    await db.update(
      'driving_sessions',
      {'syncStatus': 'synced'},
      where: 'sessionId = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
