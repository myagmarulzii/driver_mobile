import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/driving_session.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class SessionProvider with ChangeNotifier {
  DrivingSession? _activeSession;
  List<DrivingSession> _sessions = [];
  final _dbService = DatabaseService.instance;
  final _uuid = const Uuid();

  DrivingSession? get activeSession => _activeSession;
  List<DrivingSession> get sessions => _sessions;
  bool get hasActiveSession => _activeSession != null;

  // Start a new driving session
  Future<bool> startSession({
    required String studentId,
    required String instructorId,
    required Location startLocation,
    required PracticeType practiceType,
  }) async {
    try {
      if (_activeSession != null) {
        debugPrint('Cannot start session: Active session already exists');
        return false;
      }

      final session = DrivingSession(
        sessionId: _uuid.v4(),
        studentId: studentId,
        instructorId: instructorId,
        startTime: DateTime.now(),
        startLocation: startLocation,
        practiceType: practiceType,
        status: SessionStatus.active,
      );

      await _dbService.insertSession(session.toMap());
      _activeSession = session;
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Start session error: $e');
      return false;
    }
  }

  // Update session with new location point
  Future<void> updateSessionLocation(Location location) async {
    if (_activeSession == null) return;

    try {
      final updatedRoute = [..._activeSession!.route, location];
      final newDistance = _calculateDistance(_activeSession!.route, location);

      _activeSession = _activeSession!.copyWith(
        route: updatedRoute,
        distance: _activeSession!.distance + newDistance,
        duration: DateTime.now().difference(_activeSession!.startTime).inMinutes,
      );

      await _dbService.updateSession(_activeSession!.sessionId, _activeSession!.toMap());
      notifyListeners();
    } catch (e) {
      debugPrint('Update location error: $e');
    }
  }

  // End active session
  Future<bool> endSession({Location? endLocation, String? notes}) async {
    if (_activeSession == null) return false;

    try {
      final finalEndLocation = endLocation ?? _activeSession!.route.last;

      _activeSession = _activeSession!.copyWith(
        endTime: DateTime.now(),
        endLocation: finalEndLocation,
        sessionNotes: notes,
        status: SessionStatus.completed,
        duration: DateTime.now().difference(_activeSession!.startTime).inMinutes,
      );

      await _dbService.updateSession(_activeSession!.sessionId, _activeSession!.toMap());

      // Add to sessions list
      _sessions.insert(0, _activeSession!);

      // Clear active session
      _activeSession = null;
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('End session error: $e');
      return false;
    }
  }

  // Pause session
  Future<void> pauseSession() async {
    if (_activeSession == null) return;

    _activeSession = _activeSession!.copyWith(status: SessionStatus.paused);
    await _dbService.updateSession(_activeSession!.sessionId, _activeSession!.toMap());
    notifyListeners();
  }

  // Resume session
  Future<void> resumeSession() async {
    if (_activeSession == null) return;

    _activeSession = _activeSession!.copyWith(status: SessionStatus.active);
    await _dbService.updateSession(_activeSession!.sessionId, _activeSession!.toMap());
    notifyListeners();
  }

  // Load sessions for a user
  Future<void> loadSessionsForStudent(String studentId) async {
    try {
      final sessionMaps = await _dbService.getSessionsByStudent(studentId);
      _sessions = sessionMaps.map((map) => DrivingSession.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Load sessions error: $e');
    }
  }

  Future<void> loadSessionsForInstructor(String instructorId) async {
    try {
      final sessionMaps = await _dbService.getSessionsByInstructor(instructorId);
      _sessions = sessionMaps.map((map) => DrivingSession.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Load sessions error: $e');
    }
  }

  // Calculate distance between two GPS points using Haversine formula
  double _calculateDistance(List<Location> route, Location newLocation) {
    if (route.isEmpty) return 0.0;

    final lastLocation = route.last;
    const earthRadius = 6371.0; // Earth's radius in kilometers

    final lat1 = lastLocation.latitude * (3.14159265359 / 180.0);
    final lon1 = lastLocation.longitude * (3.14159265359 / 180.0);
    final lat2 = newLocation.latitude * (3.14159265359 / 180.0);
    final lon2 = newLocation.longitude * (3.14159265359 / 180.0);

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a = (dLat / 2).sin() * (dLat / 2).sin() +
        lat1.cos() * lat2.cos() * (dLon / 2).sin() * (dLon / 2).sin();

    final c = 2 * (a.sqrt()).asin();
    return earthRadius * c;
  }

  // Get session statistics
  Map<String, dynamic> getSessionStats(List<DrivingSession> sessions) {
    double totalDistance = 0;
    double roadwayDistance = 0;
    double practicePlaceDistance = 0;
    int totalDuration = 0;

    for (var session in sessions) {
      totalDistance += session.distance;
      totalDuration += session.duration;

      if (session.practiceType == PracticeType.roadway) {
        roadwayDistance += session.distance;
      } else {
        practicePlaceDistance += session.distance;
      }
    }

    return {
      'totalDistance': totalDistance,
      'roadwayDistance': roadwayDistance,
      'practicePlaceDistance': practicePlaceDistance,
      'totalDuration': totalDuration,
      'totalSessions': sessions.length,
    };
  }
}
