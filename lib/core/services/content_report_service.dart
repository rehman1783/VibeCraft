import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/report_content_model.dart';

abstract class ContentReportService {
  Future<bool> submitReport({
    required String contentId,
    required String contentType,
    required String contentUrlOrText,
    required String reason,
    String? details,
  });

  bool isContentReported(String contentId);
  Set<String> getReportedContentIds();
  Future<void> blockContentLocally(String contentId);
}

class ContentReportServiceImpl implements ContentReportService {
  final FirebaseFirestore? _customFirestore;
  final FirebaseAuth? _customFirebaseAuth;
  final SharedPreferences _sharedPreferences;

  static const String _reportedIdsKey = 'reported_content_ids';

  ContentReportServiceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
    required SharedPreferences sharedPreferences,
  })  : _customFirestore = firestore,
        _customFirebaseAuth = firebaseAuth,
        _sharedPreferences = sharedPreferences;

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseAuth? get _firebaseAuth {
    if (_customFirebaseAuth != null) return _customFirebaseAuth;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> submitReport({
    required String contentId,
    required String contentType,
    required String contentUrlOrText,
    required String reason,
    String? details,
  }) async {
    final currentUserId = _firebaseAuth?.currentUser?.uid ?? 'anonymous';
    final report = ContentReportModel(
      contentId: contentId,
      contentType: contentType,
      contentUrlOrText: contentUrlOrText,
      reason: reason,
      details: details,
      reporterUserId: currentUserId,
      timestamp: DateTime.now(),
    );

    // 1. Immediately cache the contentId locally as reported/blocked
    await blockContentLocally(contentId);

    // 2. Submit report to Firebase Firestore
    final firestore = _firestore;
    if (firestore != null) {
      try {
        await firestore
            .collection('content_reports')
            .add(report.toMap())
            .timeout(const Duration(seconds: 10));
        developer.log(
            'Content report successfully submitted to Firestore for ID: $contentId',
            name: 'ContentReportService');
        return true;
      } catch (e, stackTrace) {
        developer.log(
          'Failed to upload report to Firestore, cached locally: $e',
          name: 'ContentReportService',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }
    return true;
  }

  @override
  bool isContentReported(String contentId) {
    if (contentId.isEmpty) return false;
    final reportedList = _sharedPreferences.getStringList(_reportedIdsKey) ?? [];
    return reportedList.contains(contentId);
  }

  @override
  Set<String> getReportedContentIds() {
    final reportedList = _sharedPreferences.getStringList(_reportedIdsKey) ?? [];
    return reportedList.toSet();
  }

  @override
  Future<void> blockContentLocally(String contentId) async {
    if (contentId.isEmpty) return;
    final reportedList = _sharedPreferences.getStringList(_reportedIdsKey) ?? [];
    if (!reportedList.contains(contentId)) {
      reportedList.add(contentId);
      await _sharedPreferences.setStringList(_reportedIdsKey, reportedList);
    }
  }
}
