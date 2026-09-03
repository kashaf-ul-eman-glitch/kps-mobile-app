import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ParentNotificationsScreen extends StatefulWidget {
  const ParentNotificationsScreen({super.key});

  @override
  State<ParentNotificationsScreen> createState() =>
      _ParentNotificationsScreenState();
}

class _ParentNotificationsScreenState
    extends State<ParentNotificationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String selectedCategory = 'all';

  // ============================================================
  // CATEGORIES
  // ============================================================

  final List<Map<String, dynamic>> categories = [
    {
      'id': 'all',
      'name': 'All',
      'icon': Icons.notifications_outlined,
    },
    {
      'id': 'general',
      'name': 'General',
      'icon': Icons.campaign_outlined,
    },
    {
      'id': 'academic',
      'name': 'Academic',
      'icon': Icons.menu_book_outlined,
    },
    {
      'id': 'examination',
      'name': 'Exams',
      'icon': Icons.assignment_outlined,
    },
    {
      'id': 'fee',
      'name': 'Fees',
      'icon': Icons.payment_outlined,
    },
    {
      'id': 'events',
      'name': 'Events',
      'icon': Icons.event_outlined,
    },
    {
      'id': 'school_notice',
      'name': 'School',
      'icon': Icons.school_outlined,
    },
    {
      'id': 'parent_meeting',
      'name': 'Meeting',
      'icon': Icons.groups_outlined,
    },
    {
      'id': 'urgent',
      'name': 'Urgent',
      'icon': Icons.warning_amber_outlined,
    },
  ];

  // ============================================================
  // CURRENT PARENT UID & DATA STREAMS
  // ============================================================

  String? get _parentUid => _auth.currentUser?.uid;

  Stream<DocumentSnapshot<Map<String, dynamic>>> _parentDataStream() {
    final uid = _parentUid;
    if (uid == null || uid.isEmpty) {
      return const Stream.empty();
    }
    return _firestore.collection('users').doc(uid).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _notificationsStream() {
    return _firestore.collection('notifications').snapshots();
  }

  // ============================================================
  // CHECK WHETHER NOTIFICATION IS FOR CURRENT PARENT
  // ============================================================

  bool _isNotificationForParent(
    Map<String, dynamic> data,
    Map<String, dynamic> parentProfile,
  ) {
    final String targetRole =
        data['targetRole']?.toString().toLowerCase().trim() ?? '';

    final String uid = (_parentUid ?? '').toLowerCase().trim();
    final String email =
        (parentProfile['email'] ?? _auth.currentUser?.email ?? '')
            .toString()
            .toLowerCase()
            .trim();
    final String fatherName =
        (parentProfile['fatherName'] ?? parentProfile['father_name'] ?? '')
            .toString()
            .toLowerCase()
            .trim();
    final String rollNo = (parentProfile['rollNo'] ??
            parentProfile['rollNumber'] ??
            parentProfile['roll_no'] ??
            '')
        .toString()
        .toLowerCase()
        .trim();
    final String studentName = (parentProfile['studentName'] ??
            parentProfile['name'] ??
            parentProfile['childName'] ??
            '')
        .toString()
        .toLowerCase()
        .trim();

    // 1. ALL / PUBLIC NOTIFICATIONS
    if (targetRole == 'all' ||
        targetRole == 'all_parents' ||
        targetRole == 'parents') {
      return true;
    }

    // Check helper for single field vs multiple parent identifiers
    bool matchesValue(dynamic value) {
      if (value == null) return false;
      final valStr = value.toString().toLowerCase().trim();
      if (valStr.isEmpty) return false;

      // Check UID
      if (uid.isNotEmpty && valStr == uid) return true;
      // Check Email
      if (email.isNotEmpty && valStr == email) return true;
      // Check Roll Number
      if (rollNo.isNotEmpty && valStr == rollNo) return true;
      // Check Father Name
      if (fatherName.isNotEmpty && valStr == fatherName) return true;
      // Check Student Name
      if (studentName.isNotEmpty && valStr == studentName) return true;

      return false;
    }

    bool matchesMap(Map map) {
      final mapUid = (map['uid'] ?? map['parentUid'] ?? map['userUid'] ?? '')
          .toString()
          .toLowerCase()
          .trim();
      final mapEmail = (map['email'] ?? '').toString().toLowerCase().trim();
      final mapFather = (map['fatherName'] ?? map['father_name'] ?? '')
          .toString()
          .toLowerCase()
          .trim();
      final mapRoll = (map['rollNo'] ?? map['rollNumber'] ?? map['roll_no'] ?? '')
          .toString()
          .toLowerCase()
          .trim();
      final mapStudent = (map['studentName'] ?? map['name'] ?? map['childName'] ?? '')
          .toString()
          .toLowerCase()
          .trim();

      if (uid.isNotEmpty && mapUid.isNotEmpty && mapUid == uid) return true;
      if (email.isNotEmpty && mapEmail.isNotEmpty && mapEmail == email) return true;
      if (rollNo.isNotEmpty && mapRoll.isNotEmpty && mapRoll == rollNo) return true;
      if (fatherName.isNotEmpty && mapFather.isNotEmpty && mapFather == fatherName) {
        return true;
      }
      if (studentName.isNotEmpty &&
          mapStudent.isNotEmpty &&
          mapStudent == studentName) {
        return true;
      }

      // Deep value check in map
      for (var entry in map.entries) {
        if (matchesValue(entry.value)) return true;
      }

      return false;
    }

    // 2. CHECK DIRECT SINGLE FIELDS
    final List<String> directFields = [
      'parentUid',
      'parentUID',
      'recipientUid',
      'recipientEmail',
      'email',
      'fatherName',
      'father_name',
      'rollNo',
      'rollNumber',
      'roll_no',
      'studentName',
      'student_name',
      'targetUid',
      'userUid',
    ];

    for (final field in directFields) {
      if (matchesValue(data[field])) {
        return true;
      }
    }

    // 3. CHECK LISTS / COLLECTIONS (selectedParents, parentUids, recipients etc.)
    final List<String> collectionFields = [
      'parentUids',
      'parentUIDs',
      'selectedParents',
      'parents',
      'recipients',
      'selectedRecipients',
      'targetUsers',
      'targetUids',
      'selectedUsers',
    ];

    for (final field in collectionFields) {
      final dynamic value = data[field];

      if (value is List) {
        for (final item in value) {
          if (item is Map) {
            if (matchesMap(item)) return true;
          } else {
            if (matchesValue(item)) return true;
          }
        }
      } else if (value is Map) {
        if (matchesMap(value)) return true;
        // Key checking
        if (uid.isNotEmpty && value.containsKey(uid)) return true;
        if (email.isNotEmpty && value.containsKey(email)) return true;
        if (rollNo.isNotEmpty && value.containsKey(rollNo)) return true;
      }
    }

    return false;
  }

  // ============================================================
  // SORT NOTIFICATIONS
  // ============================================================

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortNotifications(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final sortedDocs =
        List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(docs);

    sortedDocs.sort((a, b) {
      final dynamic aValue = a.data()['createdAt'];
      final dynamic bValue = b.data()['createdAt'];

      DateTime? aTime;
      DateTime? bTime;

      if (aValue is Timestamp) {
        aTime = aValue.toDate();
      }

      if (bValue is Timestamp) {
        bTime = bValue.toDate();
      }

      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;

      return bTime.compareTo(aTime);
    });

    return sortedDocs;
  }

  // ============================================================
  // MARK AS READ
  // ============================================================

  Future<void> _markAsRead(String notificationId) async {
    final String? uid = _parentUid;

    if (uid == null || uid.isEmpty) return;

    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({
        'readBy.$uid': true,
      });
    } catch (e) {
      debugPrint('Mark notification as read error: $e');
    }
  }

  // ============================================================
  // CHECK READ STATUS
  // ============================================================

  bool _isRead(Map<String, dynamic> data) {
    final String? uid = _parentUid;

    if (uid == null || uid.isEmpty) return false;

    final dynamic readBy = data['readBy'];

    if (readBy is Map) {
      return readBy[uid] == true;
    }

    return false;
  }

  // ============================================================
  // MARK ALL AS READ
  // ============================================================

  Future<void> _markAllAsRead(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    Map<String, dynamic> parentProfile,
  ) async {
    final String? uid = _parentUid;

    if (uid == null || uid.isEmpty) return;

    try {
      final WriteBatch batch = _firestore.batch();
      bool hasChanges = false;

      for (final doc in docs) {
        final data = doc.data();

        if (_isNotificationForParent(data, parentProfile) && !_isRead(data)) {
          batch.update(doc.reference, {
            'readBy.$uid': true,
          });
          hasChanges = true;
        }
      }

      if (hasChanges) {
        await batch.commit();
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1E3A5F),
          content: Text(
            'All notifications marked as read',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Mark all as read error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1E3A5F),
          content: Text(
            'Unable to update notifications',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ),
      );
    }
  }

  // ============================================================
  // CATEGORY ICON & NAME
  // ============================================================

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'academic':
        return Icons.menu_book_outlined;
      case 'examination':
        return Icons.assignment_outlined;
      case 'fee':
        return Icons.payment_outlined;
      case 'events':
        return Icons.event_outlined;
      case 'school_notice':
        return Icons.school_outlined;
      case 'parent_meeting':
        return Icons.groups_outlined;
      case 'urgent':
        return Icons.warning_amber_outlined;
      case 'general':
        return Icons.campaign_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'academic':
        return 'Academic';
      case 'examination':
        return 'Examination';
      case 'fee':
        return 'Fee';
      case 'events':
        return 'Events';
      case 'school_notice':
        return 'School Notice';
      case 'parent_meeting':
        return 'Parent Meeting';
      case 'urgent':
        return 'Urgent';
      case 'general':
        return 'General';
      default:
        return 'Notification';
    }
  }

  // ============================================================
  // TIME FORMAT
  // ============================================================

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';

    final DateTime time = timestamp.toDate();
    final Duration difference = DateTime.now().difference(time);

    if (difference.isNegative || difference.inMinutes < 1) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} hour ago';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} day ago';
    }

    return '${time.day}/${time.month}/${time.year}';
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState(String text) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            color: Colors.white.withValues(alpha: 0.45),
            size: 55,
          ),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTIFICATION CARD
  // ============================================================

  Widget _notificationCard(
    String notificationId,
    Map<String, dynamic> data,
  ) {
    final String title = data['title']?.toString() ?? 'Notification';
    final String message = data['message']?.toString() ?? '';
    final String category =
        data['category']?.toString().toLowerCase().trim() ?? 'general';
    final Timestamp? timestamp =
        data['createdAt'] is Timestamp ? data['createdAt'] as Timestamp : null;

    final List<dynamic> details = data['details'] is List
        ? List<dynamic>.from(data['details'] as List)
        : [];

    final bool read = _isRead(data);

    return GestureDetector(
      onTap: () async {
        await _markAsRead(notificationId);

        if (!mounted) return;

        _showNotificationDetails(
          title: title,
          message: message,
          category: category,
          details: details,
          timestamp: timestamp,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: read
              ? Colors.white.withValues(alpha: 0.09)
              : Colors.white.withValues(alpha: 0.17),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: read
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 47,
              height: 47,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.13),
              ),
              child: Icon(
                _getCategoryIcon(category),
                color: Colors.white,
                size: 23,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight:
                                read ? FontWeight.w500 : FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!read)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.11),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _getCategoryName(category),
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(timestamp),
                        style: GoogleFonts.poppins(
                          color: Colors.white38,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DETAILS DIALOG
  // ============================================================

  void _showNotificationDetails({
    required String title,
    required String message,
    required String category,
    required List<dynamic> details,
    required Timestamp? timestamp,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF102A43),
          elevation: 18,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
                child: Icon(
                  _getCategoryIcon(category),
                  color: Colors.white,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getCategoryName(category),
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Details',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...details.map(
                    (detail) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: Text(
                          '• ${detail.toString()}',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  _formatTime(timestamp),
                  style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Close',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: const Color(0xFF0B1F33).withValues(alpha: 0.30),
            child: SafeArea(
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: _parentDataStream(),
                builder: (context, userSnapshot) {
                  final parentProfile =
                      userSnapshot.data?.data() ?? <String, dynamic>{};

                  return Column(
                    children: [
                      // APP BAR
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 27,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Notifications',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            StreamBuilder<
                                QuerySnapshot<Map<String, dynamic>>>(
                              stream: _notificationsStream(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const SizedBox(width: 48);
                                }

                                final docs = _sortNotifications(
                                  snapshot.data!.docs
                                      .where(
                                        (doc) => _isNotificationForParent(
                                          doc.data(),
                                          parentProfile,
                                        ),
                                      )
                                      .toList(),
                                );

                                final bool hasUnread = docs.any(
                                  (doc) => !_isRead(doc.data()),
                                );

                                if (!hasUnread) {
                                  return const SizedBox(width: 48);
                                }

                                return IconButton(
                                  tooltip: 'Mark all as read',
                                  onPressed: () =>
                                      _markAllAsRead(docs, parentProfile),
                                  icon: const Icon(
                                    Icons.done_all,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // CATEGORY FILTER
                      SizedBox(
                        height: 48,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final bool selected =
                                selectedCategory == category['id'];

                            return Padding(
                              padding: const EdgeInsets.only(right: 9),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedCategory =
                                        category['id'] as String;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? Colors.white.withValues(alpha: 0.25)
                                        : Colors.white.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: selected
                                          ? Colors.white54
                                          : Colors.white24,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        category['icon'] as IconData,
                                        color: Colors.white,
                                        size: 17,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        category['name'] as String,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: selected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 8),

                      // NOTIFICATIONS STREAM
                      Expanded(
                        child: StreamBuilder<
                            QuerySnapshot<Map<String, dynamic>>>(
                          stream: _notificationsStream(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(25),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: Colors.white70,
                                        size: 45,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Unable to load notifications',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            if (!snapshot.hasData) {
                              return _emptyState('No notifications yet');
                            }

                            // FILTER FOR CURRENT PARENT DETAILS
                            final allDocs = snapshot.data!.docs
                                .where(
                                  (doc) => _isNotificationForParent(
                                    doc.data(),
                                    parentProfile,
                                  ),
                                )
                                .toList();

                            final sortedDocs = _sortNotifications(allDocs);

                            final filteredDocs = selectedCategory == 'all'
                                ? sortedDocs
                                : sortedDocs.where((doc) {
                                    final String category = doc
                                            .data()['category']
                                            ?.toString()
                                            .toLowerCase()
                                            .trim() ??
                                        'general';
                                    return category == selectedCategory;
                                  }).toList();

                            if (filteredDocs.isEmpty) {
                              return _emptyState(
                                selectedCategory == 'all'
                                    ? 'No notifications yet'
                                    : 'No ${_getCategoryName(selectedCategory)} notifications',
                              );
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                18,
                                8,
                                18,
                                25,
                              ),
                              itemCount: filteredDocs.length,
                              itemBuilder: (context, index) {
                                final doc = filteredDocs[index];
                                return _notificationCard(
                                  doc.id,
                                  doc.data(),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}