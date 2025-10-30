import 'dart:convert';

class Feedback {
  final String feedbackId;
  final String studentId;
  final String instructorId;
  final String? sessionId;
  final double overallRating; // 1-5
  final Map<String, double> categoryRatings; // professionalism, teaching, communication, safety
  final String? comments;
  final DateTime date;
  final bool isAnonymous;

  Feedback({
    required this.feedbackId,
    required this.studentId,
    required this.instructorId,
    this.sessionId,
    required this.overallRating,
    required this.categoryRatings,
    this.comments,
    required this.date,
    this.isAnonymous = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'feedbackId': feedbackId,
      'studentId': studentId,
      'instructorId': instructorId,
      'sessionId': sessionId,
      'overallRating': overallRating,
      'categoryRatings': jsonEncode(categoryRatings),
      'comments': comments,
      'date': date.toIso8601String(),
      'isAnonymous': isAnonymous ? 1 : 0,
    };
  }

  factory Feedback.fromMap(Map<String, dynamic> map) {
    return Feedback(
      feedbackId: map['feedbackId'],
      studentId: map['studentId'],
      instructorId: map['instructorId'],
      sessionId: map['sessionId'],
      overallRating: map['overallRating'].toDouble(),
      categoryRatings: Map<String, double>.from(jsonDecode(map['categoryRatings'])),
      comments: map['comments'],
      date: DateTime.parse(map['date']),
      isAnonymous: map['isAnonymous'] == 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory Feedback.fromJson(String source) => Feedback.fromMap(json.decode(source));
}

enum ComplaintStatus { submitted, underReview, resolved }

enum ComplaintCategory {
  safetyConcern,
  unprofessionalBehavior,
  schedulingIssue,
  equipmentProblem,
  other
}

class Complaint {
  final String complaintId;
  final String studentId;
  final String? instructorId;
  final ComplaintCategory category;
  final String description;
  final ComplaintStatus status;
  final DateTime submittedDate;
  final DateTime? resolutionDate;
  final String? adminNotes;
  final List<String> attachments; // File paths or URLs

  Complaint({
    required this.complaintId,
    required this.studentId,
    this.instructorId,
    required this.category,
    required this.description,
    required this.status,
    required this.submittedDate,
    this.resolutionDate,
    this.adminNotes,
    this.attachments = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'complaintId': complaintId,
      'studentId': studentId,
      'instructorId': instructorId,
      'category': category.name,
      'description': description,
      'status': status.name,
      'submittedDate': submittedDate.toIso8601String(),
      'resolutionDate': resolutionDate?.toIso8601String(),
      'adminNotes': adminNotes,
      'attachments': jsonEncode(attachments),
    };
  }

  factory Complaint.fromMap(Map<String, dynamic> map) {
    return Complaint(
      complaintId: map['complaintId'],
      studentId: map['studentId'],
      instructorId: map['instructorId'],
      category: ComplaintCategory.values.firstWhere((e) => e.name == map['category']),
      description: map['description'],
      status: ComplaintStatus.values.firstWhere((e) => e.name == map['status']),
      submittedDate: DateTime.parse(map['submittedDate']),
      resolutionDate: map['resolutionDate'] != null
          ? DateTime.parse(map['resolutionDate'])
          : null,
      adminNotes: map['adminNotes'],
      attachments: List<String>.from(jsonDecode(map['attachments'] ?? '[]')),
    );
  }

  String toJson() => json.encode(toMap());

  factory Complaint.fromJson(String source) => Complaint.fromMap(json.decode(source));
}
