import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String selectedCategory = 'all';

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

  Stream<QuerySnapshot<Map<String, dynamic>>> _notificationsStream() {
    return _firestore.collection('notifications').snapshots();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortNotifications(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final sorted = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(docs);

    sorted.sort((a, b) {
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

      if (aTime == null && bTime == null) {
        return 0;
      }

      if (aTime == null) {
        return 1;
      }

      if (bTime == null) {
        return -1;
      }

      return bTime.compareTo(aTime);
    });

    return sorted;
  }

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

  String _shareWithName(String value) {
    switch (value) {
      case 'all':
        return 'Everyone';
      case 'parents':
        return 'All Parents';
      case 'teachers':
        return 'All Teachers';
      case 'specific':
        return 'Specific';
      default:
        return value;
    }
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Just now';
    }

    final DateTime time = timestamp.toDate();
    final Duration difference = DateTime.now().difference(time);

    if (difference.inMinutes < 1) {
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

  void _showMessage(String message) {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF20252D),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text(
            message,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 11,
            ),
          ),
        ),
      );
    });
  }

  Future<void> _showAddNotificationDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _CreateNotificationDialog(
          firestore: _firestore,
          categories: categories,
          showMessage: _showMessage,
        );
      },
    );
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();

      if (!mounted) return;

      _showMessage('Notification deleted.');
    } catch (e) {
      debugPrint('Delete notification error: $e');

      if (!mounted) return;

      _showMessage('Unable to delete notification.');
    }
  }

  Future<void> _showDeleteConfirmation(String notificationId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF171C23),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white70,
                    size: 25,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Delete Notification?',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Are you sure you want to delete this notification?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext, false);
                        },
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext, true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF171C23),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                        child: Text(
                          'Delete',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      await _deleteNotification(notificationId);
    }
  }

  Future<void> _showNotificationDetails(
    String notificationId,
    Map<String, dynamic> data,
  ) async {
    final String title = data['title']?.toString() ?? 'Notification';
    final String message = data['message']?.toString() ?? '';
    final String category = data['category']?.toString().toLowerCase() ?? 'general';
    final String shareWith = data['shareWith']?.toString() ?? 'all';

    final Timestamp? timestamp = data['createdAt'] is Timestamp ? data['createdAt'] as Timestamp : null;
    final List<dynamic> details = data['details'] is List ? data['details'] as List<dynamic> : [];
    final List<dynamic> recipients = data['recipients'] is List ? data['recipients'] as List<dynamic> : [];

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 500,
              maxHeight: 700,
            ),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF171C23),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 30,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _getCategoryIcon(category),
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 12),
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
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _infoChip('Category: ${_getCategoryName(category)}'),
                      _infoChip('Shared: ${_shareWithName(shareWith)}'),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    message,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  if (recipients.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Specific Recipients',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...recipients.map(
                      (recipient) {
                        if (recipient is! Map) return const SizedBox.shrink();

                        final bool isParent = recipient['type'] == 'parent';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 7),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipient['name']?.toString() ?? '',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                recipient['email']?.toString() ?? '',
                                style: GoogleFonts.poppins(
                                  color: Colors.white54,
                                  fontSize: 9,
                                ),
                              ),
                              if (isParent)
                                Text(
                                  '${recipient['studentName'] ?? ''} • Roll No: ${recipient['rollNumber'] ?? ''}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white38,
                                    fontSize: 8,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 15),
                    Text(
                      'Details',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 7),
                    ...details.map(
                      (detail) => Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          '• ${detail.toString()}',
                          style: GoogleFonts.poppins(
                            color: Colors.white60,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 15),
                  Text(
                    _formatTime(timestamp),
                    style: GoogleFonts.poppins(
                      color: Colors.white30,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        child: Text(
                          'Close',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          await _showDeleteConfirmation(notificationId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF171C23),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                        child: Text(
                          'Delete',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white60,
          fontSize: 9,
        ),
      ),
    );
  }

  Widget _emptyState(String text) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
            ),
            child: const Icon(
              Icons.notifications_none_outlined,
              color: Colors.white38,
              size: 34,
            ),
          ),
          const SizedBox(height: 13),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _notificationCard(
    String notificationId,
    Map<String, dynamic> data,
  ) {
    final String title = data['title']?.toString() ?? 'Notification';
    final String message = data['message']?.toString() ?? '';
    final String category = data['category']?.toString().toLowerCase() ?? 'general';
    final String shareWith = data['shareWith']?.toString() ?? 'all';

    final Timestamp? timestamp = data['createdAt'] is Timestamp ? data['createdAt'] as Timestamp : null;
    final List<dynamic> recipients = data['recipients'] is List ? data['recipients'] as List<dynamic> : [];

    return GestureDetector(
      onTap: () {
        _showNotificationDetails(notificationId, data);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 14,
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
                color: Colors.white.withValues(alpha: 0.08),
              ),
              child: Icon(
                _getCategoryIcon(category),
                color: Colors.white70,
                size: 22,
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
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.white54,
                          size: 20,
                        ),
                        color: const Color(0xFF1B2027),
                        onSelected: (value) {
                          if (value == 'delete') {
                            _showDeleteConfirmation(notificationId);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Text(
                              'Delete',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 7,
                    runSpacing: 5,
                    children: [
                      _smallChip(_getCategoryName(category)),
                      _smallChip(_shareWithName(shareWith)),
                      if (recipients.isNotEmpty)
                        _smallChip('${recipients.length} selected'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(timestamp),
                    style: GoogleFonts.poppins(
                      color: Colors.white30,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white54,
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddNotificationDialog,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF151A21),
        elevation: 8,
        icon: const Icon(Icons.add_alert_outlined),
        label: Text(
          'Share Notification',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
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
          filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
          child: Container(
            color: Colors.black.withValues(alpha: 0.58),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Notifications',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Refresh',
                          onPressed: () {
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final bool selected = selectedCategory == category['id'];

                        return Padding(
                          padding: const EdgeInsets.only(right: 9),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCategory = category['id'];
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? Colors.white.withValues(alpha: 0.18)
                                    : Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: selected ? Colors.white38 : Colors.white10,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    category['icon'] as IconData,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    category['name'] as String,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
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
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _notificationsStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          debugPrint(
                            'ADMIN NOTIFICATION ERROR: ${snapshot.error}',
                          );

                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(25),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.white54,
                                    size: 45,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Unable to load notifications',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Please check your Firebase connection.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white38,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return _emptyState('No notifications yet');
                        }

                        final sortedDocs = _sortNotifications(snapshot.data!.docs);

                        final filteredDocs = selectedCategory == 'all'
                            ? sortedDocs
                            : sortedDocs.where((doc) {
                                final String category = doc.data()['category']?.toString().toLowerCase() ?? 'general';
                                return category == selectedCategory;
                              }).toList();

                        if (filteredDocs.isEmpty) {
                          return _emptyState(
                            'No ${_getCategoryName(selectedCategory)} notifications',
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateNotificationDialog extends StatefulWidget {
  final FirebaseFirestore firestore;
  final List<Map<String, dynamic>> categories;
  final Function(String) showMessage;

  const _CreateNotificationDialog({
    required this.firestore,
    required this.categories,
    required this.showMessage,
  });

  @override
  State<_CreateNotificationDialog> createState() => _CreateNotificationDialogState();
}

class _CreateNotificationDialogState extends State<_CreateNotificationDialog> {
  late final TextEditingController titleController;
  late final TextEditingController messageController;
  late final TextEditingController detailsController;

  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController studentNameController;
  late final TextEditingController rollNumberController;

  String shareWith = 'all';
  String specificType = 'parent';
  String category = 'general';

  final List<Map<String, dynamic>> selectedRecipients = [];
  bool isSaving = false;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    messageController = TextEditingController();
    detailsController = TextEditingController();

    nameController = TextEditingController();
    emailController = TextEditingController();
    studentNameController = TextEditingController();
    rollNumberController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    messageController.dispose();
    detailsController.dispose();

    nameController.dispose();
    emailController.dispose();
    studentNameController.dispose();
    rollNumberController.dispose();
    super.dispose();
  }

  Future<bool> _addRecipientToList() async {
    final bool isParent = specificType == 'parent';
    final String name = nameController.text.trim();
    final String email = emailController.text.trim().toLowerCase();
    final String studentName = studentNameController.text.trim();
    final String rollNumber = rollNumberController.text.trim();

    if (name.isEmpty) {
      widget.showMessage(isParent ? 'Please enter parent name.' : 'Please enter teacher name.');
      return false;
    }

    if (email.isEmpty) {
      widget.showMessage(isParent ? 'Please enter parent Gmail.' : 'Please enter teacher Gmail.');
      return false;
    }

    if (!email.contains('@') || !email.contains('.')) {
      widget.showMessage('Please enter a valid Gmail address.');
      return false;
    }

    if (isParent) {
      if (studentName.isEmpty) {
        widget.showMessage('Please enter student name.');
        return false;
      }

      if (rollNumber.isEmpty) {
        widget.showMessage('Please enter roll number.');
        return false;
      }
    }

    setState(() {
      isSearching = true;
    });

    try {
      final QuerySnapshot<Map<String, dynamic>> result = await widget.firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(5)
          .get();

      String foundUid = '';

      if (result.docs.isNotEmpty) {
        for (final doc in result.docs) {
          final data = doc.data();
          final String role = data['role']?.toString().toLowerCase() ?? '';

          if (role == specificType) {
            foundUid = doc.id;
            break;
          }
        }
      }

      final String finalUid = foundUid.isNotEmpty ? foundUid : DateTime.now().millisecondsSinceEpoch.toString();

      final bool alreadySelected = selectedRecipients.any(
        (recipient) => recipient['email']?.toString().toLowerCase() == email,
      );

      if (alreadySelected) {
        setState(() {
          isSearching = false;
        });
        return true;
      }

      final Map<String, dynamic> recipient = {
        'uid': finalUid,
        'type': specificType,
        'name': name,
        'email': email,
      };

      if (isParent) {
        recipient['studentName'] = studentName;
        recipient['rollNumber'] = rollNumber;
      }

      setState(() {
        selectedRecipients.add(recipient);
        isSearching = false;
      });

      nameController.clear();
      emailController.clear();
      studentNameController.clear();
      rollNumberController.clear();

      return true;
    } catch (e) {
      debugPrint('RECIPIENT ADD ERROR: $e');
      setState(() {
        isSearching = false;
      });
      widget.showMessage('Error adding recipient. Please try again.');
      return false;
    }
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _shareOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required bool selected,
    required VoidCallback? onTap,
    bool fullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withValues(alpha: 0.13)
              : Colors.white.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? Colors.white.withValues(alpha: 0.38)
                : Colors.white.withValues(alpha: 0.09),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white70,
                size: 19,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  Widget _typeButton({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withValues(alpha: 0.13)
              : Colors.white.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected ? Colors.white38 : Colors.white10,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white70,
              size: 17,
            ),
            const SizedBox(width: 7),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _darkDropdown({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        dropdownColor: const Color(0xFF1D232B),
        iconEnabledColor: Colors.white60,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 11,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 4,
          ),
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _darkTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool enabled = true,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 11,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: Colors.white30,
          fontSize: 10,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.white38,
          size: 18,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.055),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.10),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.10),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.30),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 10,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: Colors.white30,
          fontSize: 9,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.white38,
          size: 17,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.045),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.25),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isParent = specificType == 'parent';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 25,
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 560,
          maxHeight: 760,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF151A21).withValues(alpha: 0.97),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 35,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.notifications_active_outlined,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Notification',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Choose who should receive it',
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: isSaving
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Share With',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _shareOption(
                      icon: Icons.public_outlined,
                      title: 'All',
                      subtitle: 'Everyone',
                      value: 'all',
                      selected: shareWith == 'all',
                      onTap: isSaving
                          ? null
                          : () {
                              setState(() {
                                shareWith = 'all';
                                selectedRecipients.clear();
                              });
                            },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _shareOption(
                      icon: Icons.family_restroom_outlined,
                      title: 'Parents',
                      subtitle: 'All parents',
                      value: 'parents',
                      selected: shareWith == 'parents',
                      onTap: isSaving
                          ? null
                          : () {
                              setState(() {
                                shareWith = 'parents';
                                selectedRecipients.clear();
                              });
                            },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _shareOption(
                      icon: Icons.school_outlined,
                      title: 'Teachers',
                      subtitle: 'All teachers',
                      value: 'teachers',
                      selected: shareWith == 'teachers',
                      onTap: isSaving
                          ? null
                          : () {
                              setState(() {
                                shareWith = 'teachers';
                                selectedRecipients.clear();
                              });
                            },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _shareOption(
                icon: Icons.person_search_outlined,
                title: 'Share With Only',
                subtitle: 'Choose specific parents or teachers',
                value: 'specific',
                selected: shareWith == 'specific',
                fullWidth: true,
                onTap: isSaving
                    ? null
                    : () {
                        setState(() {
                          shareWith = 'specific';
                        });
                      },
              ),
              if (shareWith == 'specific') ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.055),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.tune_outlined,
                            color: Colors.white70,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Specific Recipients',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 13),
                      Row(
                        children: [
                          Expanded(
                            child: _typeButton(
                              title: 'Parent',
                              icon: Icons.person_outline,
                              selected: specificType == 'parent',
                              onTap: () {
                                setState(() {
                                  specificType = 'parent';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _typeButton(
                              title: 'Teacher',
                              icon: Icons.person_pin_outlined,
                              selected: specificType == 'teacher',
                              onTap: () {
                                setState(() {
                                  specificType = 'teacher';
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _field(
                        controller: nameController,
                        hint: isParent ? 'Parent Name' : 'Teacher Name',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 9),
                      _field(
                        controller: emailController,
                        hint: isParent ? 'Parent Gmail' : 'Teacher Gmail',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      if (isParent) ...[
                        const SizedBox(height: 9),
                        _field(
                          controller: studentNameController,
                          hint: 'Student Name',
                          icon: Icons.school_outlined,
                        ),
                        const SizedBox(height: 9),
                        _field(
                          controller: rollNumberController,
                          hint: 'Student Roll Number',
                          icon: Icons.numbers_outlined,
                        ),
                      ],
                      const SizedBox(height: 11),
                      SizedBox(
                        width: double.infinity,
                        height: 43,
                        child: OutlinedButton.icon(
                          onPressed: isSearching ? null : () => _addRecipientToList(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.16),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: isSearching
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.add,
                                  size: 17,
                                ),
                          label: Text(
                            isSearching
                                ? 'Adding...'
                                : 'Add ${isParent ? 'Parent' : 'Teacher'}',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      if (selectedRecipients.isNotEmpty) ...[
                        const SizedBox(height: 15),
                        Text(
                          'Selected Recipients (${selectedRecipients.length})',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(
                          selectedRecipients.length,
                          (index) {
                            final recipient = selectedRecipients[index];
                            final bool itemIsParent = recipient['type'] == 'parent';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 7),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(alpha: 0.08),
                                    ),
                                    child: Icon(
                                      itemIsParent
                                          ? Icons.person_outline
                                          : Icons.school_outlined,
                                      color: Colors.white70,
                                      size: 17,
                                    ),
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          recipient['name']?.toString() ?? '',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          recipient['email']?.toString() ?? '',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white54,
                                            fontSize: 9,
                                          ),
                                        ),
                                        if (itemIsParent)
                                          Text(
                                            '${recipient['studentName'] ?? ''} • Roll No: ${recipient['rollNumber'] ?? ''}',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white38,
                                              fontSize: 8,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: isSaving
                                        ? null
                                        : () {
                                            setState(() {
                                              selectedRecipients.removeAt(index);
                                            });
                                          },
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white38,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              _sectionLabel('Category'),
              const SizedBox(height: 8),
              _darkDropdown(
                value: category,
                items: widget.categories
                    .where((item) => item['id'] != 'all')
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item['id'] as String,
                        child: Text(item['name'] as String),
                      ),
                    )
                    .toList(),
                onChanged: isSaving
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() {
                          category = value;
                        });
                      },
              ),
              const SizedBox(height: 16),
              _sectionLabel('Notification Title'),
              const SizedBox(height: 8),
              _darkTextField(
                controller: titleController,
                hint: 'Enter notification title',
                icon: Icons.title_outlined,
                enabled: !isSaving,
              ),
              const SizedBox(height: 14),
              _sectionLabel('Message'),
              const SizedBox(height: 8),
              _darkTextField(
                controller: messageController,
                hint: 'Write your notification...',
                icon: Icons.message_outlined,
                maxLines: 4,
                enabled: !isSaving,
              ),
              const SizedBox(height: 14),
              _sectionLabel('Details (Optional)'),
              const SizedBox(height: 8),
              _darkTextField(
                controller: detailsController,
                hint: 'One detail per line',
                icon: Icons.notes_outlined,
                maxLines: 3,
                enabled: !isSaving,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: isSaving
                      ? null
                      : () async {
                        // Auto-add recipient if form inputs were filled but "Add" was missed
                          if (shareWith == 'specific' && selectedRecipients.isEmpty) {
                            final String name = nameController.text.trim();
                            final String email = emailController.text.trim();

                            if (name.isNotEmpty && email.isNotEmpty) {
                              final bool added = await _addRecipientToList();
                              if (!added) return;
                            }
                          }

                          final String title = titleController.text.trim();
                          final String message = messageController.text.trim();

                          if (title.isEmpty) {
                            widget.showMessage('Please enter notification title.');
                            return;
                          }

                          if (message.isEmpty) {
                            widget.showMessage('Please enter notification message.');
                            return;
                          }

                          if (shareWith == 'specific' && selectedRecipients.isEmpty) {
                            widget.showMessage('Please add at least one parent or teacher.');
                            return;
                          }

                          setState(() {
                            isSaving = true;
                          });

                          try {
                            final List<Map<String, dynamic>> cleanRecipients =
                                selectedRecipients.map((recipient) {
                              return {
                                'uid': recipient['uid'],
                                'type': recipient['type'],
                                'name': recipient['name'],
                                'email': recipient['email'],
                                if (recipient['type'] == 'parent') ...{
                                  'studentName': recipient['studentName'],
                                  'rollNumber': recipient['rollNumber'],
                                },
                              };
                            }).toList();

                            final List<String> recipientUids = cleanRecipients
                                .map((item) => item['uid'].toString())
                                .where((uid) => uid.isNotEmpty)
                                .toList();

                            final List<String> recipientEmails = cleanRecipients
                                .map((item) => item['email'].toString().toLowerCase())
                                .where((email) => email.isNotEmpty)
                                .toList();

                            final List<String> details = detailsController.text
                                    .trim()
                                    .isEmpty
                                ? []
                                : detailsController.text
                                    .trim()
                                    .split('\n')
                                    .map((e) => e.trim())
                                    .where((e) => e.isNotEmpty)
                                    .toList();

                            String? targetUid;
                            if (shareWith == 'specific' && recipientUids.length == 1) {
                              targetUid = recipientUids.first;
                            }

                            final Map<String, dynamic> notificationData = {
                              'title': title,
                              'message': message,
                              'category': category,
                              'shareWith': shareWith,
                              'targetRole': shareWith == 'all'
                                  ? 'all'
                                  : shareWith == 'parents'
                                      ? 'parent'
                                      : shareWith == 'teachers'
                                          ? 'teacher'
                                          : 'specific',
                              if (targetUid != null) 'targetUid': targetUid,
                              'recipients': shareWith == 'specific' ? cleanRecipients : [],
                              'recipientUids': shareWith == 'specific' ? recipientUids : [],
                              'recipientEmails': shareWith == 'specific' ? recipientEmails : [],
                              'isSpecific': shareWith == 'specific',
                              'details': details,
                              'isRead': false,
                              'createdAt': FieldValue.serverTimestamp(),
                            };

                            await widget.firestore.collection('notifications').add(notificationData);

                            if (!mounted) return;

                            Navigator.pop(context);
                            widget.showMessage('Notification shared successfully.');
                          } catch (e) {
                            debugPrint('ADD NOTIFICATION ERROR: $e');

                            setState(() {
                              isSaving = false;
                            });

                            widget.showMessage(
                              'Unable to save notification. Please check Firebase.',
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF151A21),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          size: 19,
                        ),
                  label: Text(
                    isSaving ? 'Sharing...' : 'Share Notification',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}