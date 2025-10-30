import 'dart:convert';

enum UserRole { superAdmin, admin, instructor, student }

enum UserStatus { active, inactive, graduated }

class User {
  final String id;
  final String username;
  final String name;
  final String email;
  final String phone;
  final String schoolId;
  final UserRole role;
  final UserStatus status;
  final DateTime createdDate;
  final String? licenseNumber; // For instructors
  final String? idNumber; // For students
  final DateTime? enrollmentDate; // For students
  final String? emergencyContact; // For students
  final String? assignedInstructorId; // For students
  final double? totalDistance; // For instructors
  final int? totalSessions; // For instructors

  User({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.phone,
    required this.schoolId,
    required this.role,
    required this.status,
    required this.createdDate,
    this.licenseNumber,
    this.idNumber,
    this.enrollmentDate,
    this.emergencyContact,
    this.assignedInstructorId,
    this.totalDistance,
    this.totalSessions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'phone': phone,
      'schoolId': schoolId,
      'role': role.name,
      'status': status.name,
      'createdDate': createdDate.toIso8601String(),
      'licenseNumber': licenseNumber,
      'idNumber': idNumber,
      'enrollmentDate': enrollmentDate?.toIso8601String(),
      'emergencyContact': emergencyContact,
      'assignedInstructorId': assignedInstructorId,
      'totalDistance': totalDistance,
      'totalSessions': totalSessions,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      schoolId: map['schoolId'],
      role: UserRole.values.firstWhere((e) => e.name == map['role']),
      status: UserStatus.values.firstWhere((e) => e.name == map['status']),
      createdDate: DateTime.parse(map['createdDate']),
      licenseNumber: map['licenseNumber'],
      idNumber: map['idNumber'],
      enrollmentDate: map['enrollmentDate'] != null
          ? DateTime.parse(map['enrollmentDate'])
          : null,
      emergencyContact: map['emergencyContact'],
      assignedInstructorId: map['assignedInstructorId'],
      totalDistance: map['totalDistance']?.toDouble(),
      totalSessions: map['totalSessions'],
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  User copyWith({
    String? id,
    String? username,
    String? name,
    String? email,
    String? phone,
    String? schoolId,
    UserRole? role,
    UserStatus? status,
    DateTime? createdDate,
    String? licenseNumber,
    String? idNumber,
    DateTime? enrollmentDate,
    String? emergencyContact,
    String? assignedInstructorId,
    double? totalDistance,
    int? totalSessions,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      schoolId: schoolId ?? this.schoolId,
      role: role ?? this.role,
      status: status ?? this.status,
      createdDate: createdDate ?? this.createdDate,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      idNumber: idNumber ?? this.idNumber,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      assignedInstructorId: assignedInstructorId ?? this.assignedInstructorId,
      totalDistance: totalDistance ?? this.totalDistance,
      totalSessions: totalSessions ?? this.totalSessions,
    );
  }
}
