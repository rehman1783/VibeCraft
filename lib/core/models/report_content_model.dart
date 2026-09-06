import 'package:cloud_firestore/cloud_firestore.dart';

/// Categories of inappropriate / offensive content reports.
enum ReportReason {
  nsfwSexual('Sexual or Inappropriate Content (NSFW)'),
  violenceGore('Violence, Gore, or Dangerous Activities'),
  hateSpeech('Hate Speech, Harassment, or Bullying'),
  selfHarmIllegal('Self-Harm or Illegal Content'),
  copyrightInfringement('Copyright or Intellectual Property Infringement'),
  spamMisleading('Spam, Misleading, or Low Quality Output'),
  other('Other Policy Violation');

  final String label;
  const ReportReason(this.label);
}

/// Represents a user report for AI-generated or uploaded content.
class ContentReportModel {
  final String? id;
  final String contentId;
  final String contentType; // 'ai_generated_wallpaper', 'ai_chat_response', 'wallpaper'
  final String contentUrlOrText;
  final String reason;
  final String? details;
  final String? reporterUserId;
  final DateTime timestamp;
  final String status; // 'pending_review', 'reviewed', 'removed'

  ContentReportModel({
    this.id,
    required this.contentId,
    required this.contentType,
    required this.contentUrlOrText,
    required this.reason,
    this.details,
    this.reporterUserId,
    DateTime? timestamp,
    this.status = 'pending_review',
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'contentId': contentId,
      'contentType': contentType,
      'contentUrlOrText': contentUrlOrText,
      'reason': reason,
      'details': details ?? '',
      'reporterUserId': reporterUserId ?? 'anonymous',
      'timestamp': FieldValue.serverTimestamp(),
      'status': status,
      'appVersion': '1.0.3+4',
      'reportedAtIso': timestamp.toIso8601String(),
    };
  }

  factory ContentReportModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedTime;
    if (map['timestamp'] is Timestamp) {
      parsedTime = (map['timestamp'] as Timestamp).toDate();
    } else if (map['reportedAtIso'] != null) {
      parsedTime = DateTime.tryParse(map['reportedAtIso']) ?? DateTime.now();
    } else {
      parsedTime = DateTime.now();
    }

    return ContentReportModel(
      id: docId,
      contentId: map['contentId'] ?? '',
      contentType: map['contentType'] ?? 'wallpaper',
      contentUrlOrText: map['contentUrlOrText'] ?? '',
      reason: map['reason'] ?? 'Other Policy Violation',
      details: map['details'],
      reporterUserId: map['reporterUserId'],
      timestamp: parsedTime,
      status: map['status'] ?? 'pending_review',
    );
  }
}
