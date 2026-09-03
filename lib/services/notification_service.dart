import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // SEND NOTIFICATION
  // ============================================================

  static Future<void> sendNotification({
    required String title,
    required String message,
    required String targetRole,
    String type = 'general',
    List<String> details = const [],
    String? targetUid,
  }) async {
    await _firestore.collection('notifications').add({
      'title': title,
      'message': message,
      'type': type,

      // parent / teacher / all / specific
      'targetRole': targetRole,

      // Used when notification is for one specific user
      'targetUid': targetUid,

      'details': details,

      'unread': true,

      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // PARENT NOTIFICATION
  // ============================================================

  static Future<void> sendToParents({
    required String title,
    required String message,
    String type = 'general',
    List<String> details = const [],
  }) async {
    await sendNotification(
      title: title,
      message: message,
      targetRole: 'parent',
      type: type,
      details: details,
    );
  }

  // ============================================================
  // TEACHER NOTIFICATION
  // ============================================================

  static Future<void> sendToTeachers({
    required String title,
    required String message,
    String type = 'general',
    List<String> details = const [],
  }) async {
    await sendNotification(
      title: title,
      message: message,
      targetRole: 'teacher',
      type: type,
      details: details,
    );
  }

  // ============================================================
  // EVERYONE
  // ============================================================

  static Future<void> sendToEveryone({
    required String title,
    required String message,
    String type = 'general',
    List<String> details = const [],
  }) async {
    await sendNotification(
      title: title,
      message: message,
      targetRole: 'all',
      type: type,
      details: details,
    );
  }

  // ============================================================
  // ONE SPECIFIC USER
  // ============================================================

  static Future<void> sendToUser({
    required String uid,
    required String title,
    required String message,
    String type = 'general',
    List<String> details = const [],
  }) async {
    await sendNotification(
      title: title,
      message: message,
      targetRole: 'specific',
      targetUid: uid,
      type: type,
      details: details,
    );
  }
}