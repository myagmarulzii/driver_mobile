import 'dart:convert';

class StudentProgress {
  final String studentId;
  final double totalRoadwayDistance; // in km
  final double totalPracticePlaceDistance; // in km
  final double totalClassroomHours;
  final bool examEligible;
  final DateTime? eligibilityDate;

  // Requirements (configurable)
  final double requiredRoadwayDistance;
  final double requiredPracticePlaceDistance;
  final double requiredClassroomHours;

  StudentProgress({
    required this.studentId,
    this.totalRoadwayDistance = 0.0,
    this.totalPracticePlaceDistance = 0.0,
    this.totalClassroomHours = 0.0,
    this.examEligible = false,
    this.eligibilityDate,
    this.requiredRoadwayDistance = 70.0,
    this.requiredPracticePlaceDistance = 30.0,
    this.requiredClassroomHours = 20.0,
  });

  double get totalDistance => totalRoadwayDistance + totalPracticePlaceDistance;

  double get totalRequiredDistance =>
      requiredRoadwayDistance + requiredPracticePlaceDistance;

  double get distanceProgressPercentage =>
      (totalDistance / totalRequiredDistance * 100).clamp(0, 100);

  double get roadwayProgressPercentage =>
      (totalRoadwayDistance / requiredRoadwayDistance * 100).clamp(0, 100);

  double get practicePlaceProgressPercentage =>
      (totalPracticePlaceDistance / requiredPracticePlaceDistance * 100).clamp(0, 100);

  double get classroomProgressPercentage =>
      (totalClassroomHours / requiredClassroomHours * 100).clamp(0, 100);

  bool get meetsRequirements =>
      totalRoadwayDistance >= requiredRoadwayDistance &&
      totalPracticePlaceDistance >= requiredPracticePlaceDistance &&
      totalClassroomHours >= requiredClassroomHours;

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'totalRoadwayDistance': totalRoadwayDistance,
      'totalPracticePlaceDistance': totalPracticePlaceDistance,
      'totalClassroomHours': totalClassroomHours,
      'examEligible': examEligible ? 1 : 0,
      'eligibilityDate': eligibilityDate?.toIso8601String(),
      'requiredRoadwayDistance': requiredRoadwayDistance,
      'requiredPracticePlaceDistance': requiredPracticePlaceDistance,
      'requiredClassroomHours': requiredClassroomHours,
    };
  }

  factory StudentProgress.fromMap(Map<String, dynamic> map) {
    return StudentProgress(
      studentId: map['studentId'],
      totalRoadwayDistance: map['totalRoadwayDistance']?.toDouble() ?? 0.0,
      totalPracticePlaceDistance: map['totalPracticePlaceDistance']?.toDouble() ?? 0.0,
      totalClassroomHours: map['totalClassroomHours']?.toDouble() ?? 0.0,
      examEligible: map['examEligible'] == 1,
      eligibilityDate: map['eligibilityDate'] != null
          ? DateTime.parse(map['eligibilityDate'])
          : null,
      requiredRoadwayDistance: map['requiredRoadwayDistance']?.toDouble() ?? 70.0,
      requiredPracticePlaceDistance: map['requiredPracticePlaceDistance']?.toDouble() ?? 30.0,
      requiredClassroomHours: map['requiredClassroomHours']?.toDouble() ?? 20.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory StudentProgress.fromJson(String source) =>
      StudentProgress.fromMap(json.decode(source));

  StudentProgress copyWith({
    String? studentId,
    double? totalRoadwayDistance,
    double? totalPracticePlaceDistance,
    double? totalClassroomHours,
    bool? examEligible,
    DateTime? eligibilityDate,
    double? requiredRoadwayDistance,
    double? requiredPracticePlaceDistance,
    double? requiredClassroomHours,
  }) {
    return StudentProgress(
      studentId: studentId ?? this.studentId,
      totalRoadwayDistance: totalRoadwayDistance ?? this.totalRoadwayDistance,
      totalPracticePlaceDistance: totalPracticePlaceDistance ?? this.totalPracticePlaceDistance,
      totalClassroomHours: totalClassroomHours ?? this.totalClassroomHours,
      examEligible: examEligible ?? this.examEligible,
      eligibilityDate: eligibilityDate ?? this.eligibilityDate,
      requiredRoadwayDistance: requiredRoadwayDistance ?? this.requiredRoadwayDistance,
      requiredPracticePlaceDistance: requiredPracticePlaceDistance ?? this.requiredPracticePlaceDistance,
      requiredClassroomHours: requiredClassroomHours ?? this.requiredClassroomHours,
    );
  }
}
