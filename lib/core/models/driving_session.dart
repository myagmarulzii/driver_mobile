import 'dart:convert';

enum SessionStatus { active, completed, paused, cancelled }

enum PracticeType { roadway, practicePlace }

class Location {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  Location({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      latitude: map['latitude'].toDouble(),
      longitude: map['longitude'].toDouble(),
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

class DrivingSession {
  final String sessionId;
  final String studentId;
  final String instructorId;
  final DateTime startTime;
  final DateTime? endTime;
  final Location startLocation;
  final Location? endLocation;
  final List<Location> route;
  final double distance; // in kilometers
  final int duration; // in minutes
  final PracticeType practiceType;
  final String? sessionNotes;
  final SessionStatus status;

  DrivingSession({
    required this.sessionId,
    required this.studentId,
    required this.instructorId,
    required this.startTime,
    this.endTime,
    required this.startLocation,
    this.endLocation,
    this.route = const [],
    this.distance = 0.0,
    this.duration = 0,
    required this.practiceType,
    this.sessionNotes,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'studentId': studentId,
      'instructorId': instructorId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'startLocation': jsonEncode(startLocation.toMap()),
      'endLocation': endLocation != null ? jsonEncode(endLocation!.toMap()) : null,
      'route': jsonEncode(route.map((loc) => loc.toMap()).toList()),
      'distance': distance,
      'duration': duration,
      'practiceType': practiceType.name,
      'sessionNotes': sessionNotes,
      'status': status.name,
    };
  }

  factory DrivingSession.fromMap(Map<String, dynamic> map) {
    return DrivingSession(
      sessionId: map['sessionId'],
      studentId: map['studentId'],
      instructorId: map['instructorId'],
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      startLocation: Location.fromMap(jsonDecode(map['startLocation'])),
      endLocation: map['endLocation'] != null
          ? Location.fromMap(jsonDecode(map['endLocation']))
          : null,
      route: map['route'] != null
          ? (jsonDecode(map['route']) as List)
              .map((loc) => Location.fromMap(loc))
              .toList()
          : [],
      distance: map['distance'].toDouble(),
      duration: map['duration'],
      practiceType: PracticeType.values.firstWhere((e) => e.name == map['practiceType']),
      sessionNotes: map['sessionNotes'],
      status: SessionStatus.values.firstWhere((e) => e.name == map['status']),
    );
  }

  String toJson() => json.encode(toMap());

  factory DrivingSession.fromJson(String source) =>
      DrivingSession.fromMap(json.decode(source));

  DrivingSession copyWith({
    String? sessionId,
    String? studentId,
    String? instructorId,
    DateTime? startTime,
    DateTime? endTime,
    Location? startLocation,
    Location? endLocation,
    List<Location>? route,
    double? distance,
    int? duration,
    PracticeType? practiceType,
    String? sessionNotes,
    SessionStatus? status,
  }) {
    return DrivingSession(
      sessionId: sessionId ?? this.sessionId,
      studentId: studentId ?? this.studentId,
      instructorId: instructorId ?? this.instructorId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      startLocation: startLocation ?? this.startLocation,
      endLocation: endLocation ?? this.endLocation,
      route: route ?? this.route,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      practiceType: practiceType ?? this.practiceType,
      sessionNotes: sessionNotes ?? this.sessionNotes,
      status: status ?? this.status,
    );
  }
}
