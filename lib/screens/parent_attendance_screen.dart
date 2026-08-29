import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ================================================================
// ATTENDANCE SCREEN (PARENT SIDE)
// ================================================================
//
// Shows the day-by-day attendance history for ONE selected child,
// read live from Firestore:
//
//   classes/{className}/students/{studentId}/attendance/{yyyy-MM-dd}
//     - status: "Present" | "Absent" | "Leave"
//     - markedAt: serverTimestamp() (when the record was written)
//
// The document ID for each day is the date itself in
// "yyyy-MM-dd" format (e.g. "2026-08-29"). This lets us:
//   1) Avoid duplicate records for the same day (writing again
//      with .set() on the same doc ID just overwrites it).
//   2) Sort attendance by date using FieldPath.documentId,
//      without needing any extra Firestore index.
//
// IMPORTANT: This screen only READS attendance. Marking
// attendance (writing into this subcollection) needs to happen
// from a teacher/admin-side screen — whenever that screen calls:
//
//   FirebaseFirestore.instance
//       .collection('classes').doc(className)
//       .collection('students').doc(studentId)
//       .collection('attendance').doc('2026-08-29')
//       .set({'status': 'Present', 'markedAt': FieldValue.serverTimestamp()});
//
// ...it will show up here automatically and instantly, because
// this screen listens with .snapshots() (a live stream), not a
// one-time .get().
// ================================================================

class ParentAttendanceScreen extends StatelessWidget {
  final String studentId;
  final String className;
  final String studentName;

  const ParentAttendanceScreen({
    super.key,
    required this.studentId,
    required this.className,
    required this.studentName,
  });

  Stream<QuerySnapshot<Map<String, dynamic>>> _attendanceStream() {
    // NOTE: We deliberately do NOT use .orderBy() here. Firestore
    // indexes are defined per collection GROUP, not per specific
    // subcollection path — so if any other screen in this app runs
    // a query on a collection also named "attendance" (e.g. via
    // collectionGroup('attendance')), Firestore may require a
    // manual composite index before this simple query will run,
    // even though it has no `where` clause of its own.
    //
    // To avoid needing any Firestore index at all, we just fetch
    // every document here and sort it by date in Dart instead
    // (see the sort in the StreamBuilder below).
    return FirebaseFirestore.instance
        .collection('classes')
        .doc(className)
        .collection('students')
        .doc(studentId)
        .collection('attendance')
        .snapshots();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'Absent':
        return Colors.red;
      case 'Leave':
        return Colors.orange;
      default:
        return Colors.white54;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Present':
        return Icons.check_circle_outline;
      case 'Absent':
        return Icons.cancel_outlined;
      case 'Leave':
        return Icons.event_busy_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(String docId) {
    try {
      final DateTime date = DateTime.parse(docId);

      const List<String> months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      const List<String> weekdays = [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ];

      final String weekday = weekdays[date.weekday - 1];

      return '$weekday, ${date.day.toString().padLeft(2, '0')} '
          '${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return docId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/background.jpg',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.black.withValues(alpha: 0.25),
            child: SafeArea(
              child: Column(
                children: [
                  // =========================
                  // Top Bar
                  // =========================

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
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
                            size: 28,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Attendance',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                studentName,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // =========================
                  // FIRESTORE DATA
                  // =========================

                  Expanded(
                    child: StreamBuilder<
                        QuerySnapshot<Map<String, dynamic>>>(
                      stream: _attendanceStream(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'Could not load attendance.\n\n${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        }

                        final List<QueryDocumentSnapshot<
                            Map<String, dynamic>>> docs =
                            (snapshot.data?.docs ?? []).toList();

                        // Sort newest date first (doc ID is
                        // "yyyy-MM-dd", so plain string comparison
                        // sorts correctly). Done here in Dart
                        // instead of via Firestore orderBy() to
                        // avoid needing a composite index.
                        docs.sort((a, b) => b.id.compareTo(a.id));

                        if (docs.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.event_note_outlined,
                                    color: Colors.white70,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No attendance records yet.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // ==================================================
                        // SUMMARY COUNTS
                        // ==================================================

                        int presentCount = 0;
                        int absentCount = 0;
                        int leaveCount = 0;

                        for (final doc in docs) {
                          final String status =
                              (doc.data()['status'] ?? '').toString();

                          if (status == 'Present') presentCount++;
                          if (status == 'Absent') absentCount++;
                          if (status == 'Leave') leaveCount++;
                        }

                        final int totalMarked = docs.length;

                        final double percentage = totalMarked > 0
                            ? (presentCount / totalMarked * 100)
                            : 0.0;

                        return Column(
                          children: [
                            // =========================
                            // Summary Card
                            // =========================

                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                5,
                                20,
                                18,
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withValues(alpha: 0.15),
                                  borderRadius:
                                      BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.white24,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceAround,
                                      children: [
                                        _summaryItem(
                                          'Present',
                                          presentCount,
                                          Colors.green,
                                        ),
                                        _summaryItem(
                                          'Absent',
                                          absentCount,
                                          Colors.red,
                                        ),
                                        _summaryItem(
                                          'Leave',
                                          leaveCount,
                                          Colors.orange,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    const Divider(
                                      color: Colors.white24,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Attendance Rate: ${percentage.toStringAsFixed(1)}%',
                                      style: GoogleFonts.poppins(
                                        color: Colors.amber,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Based on $totalMarked recorded day${totalMarked == 1 ? '' : 's'}',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white54,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // =========================
                            // Section Title
                            // =========================

                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                0,
                                20,
                                12,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Daily Record',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            // =========================
                            // Daily List
                            // =========================

                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  0,
                                  20,
                                  25,
                                ),
                                itemCount: docs.length,
                                itemBuilder: (context, index) {
                                  final doc = docs[index];

                                  final String status =
                                      (doc.data()['status'] ?? '')
                                          .toString();

                                  return Container(
                                    margin: const EdgeInsets.only(
                                      bottom: 10,
                                    ),
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withValues(alpha: 0.12),
                                      borderRadius:
                                          BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Colors.white24,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _statusIcon(status),
                                          color: _statusColor(status),
                                          size: 22,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _formatDate(doc.id),
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight:
                                                  FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _statusColor(
                                              status,
                                            ).withValues(alpha: 0.6),
                                            borderRadius:
                                                BorderRadius.circular(
                                              9,
                                            ),
                                          ),
                                          child: Text(
                                            status.isEmpty
                                                ? 'Unknown'
                                                : status,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight:
                                                  FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
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

  Widget _summaryItem(String title, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}