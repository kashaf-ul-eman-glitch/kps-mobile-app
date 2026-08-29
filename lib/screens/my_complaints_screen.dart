import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ================================================================
// MY COMPLAINTS SCREEN (PARENT SIDE)
// ================================================================
//
// Shows only the complaints submitted by the currently logged-in
// parent (filtered by parentUid), along with the live status and
// the admin's reply (from the `adminReply` field written by the
// admin-side ComplaintsScreen).
//
// NOTE: We deliberately do NOT use `.where('parentUid', ...)`
// combined with `.orderBy('createdAt', ...)` in the same query,
// because that combination needs a Firestore composite index.
// Instead we filter by parentUid only, then sort the results in
// Dart — same pattern already used elsewhere in this app.
// ================================================================

class MyComplaintsScreen extends StatefulWidget {
  const MyComplaintsScreen({super.key});

  @override
  State<MyComplaintsScreen> createState() =>
      _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends State<MyComplaintsScreen> {
  Stream<QuerySnapshot<Map<String, dynamic>>>? _stream;

  @override
  void initState() {
    super.initState();

    final String uid =
        FirebaseAuth.instance.currentUser?.uid ?? '';

    _stream = FirebaseFirestore.instance
        .collection('complaints')
        .where('parentUid', isEqualTo: uid)
        .snapshots();
  }

  String _formatDate(DateTime date) {
    const months = [
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

    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} ${date.year}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Resolved':
        return Colors.green;
      case 'In Review':
        return Colors.orange;
      default:
        return Colors.white54;
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
                          child: Text(
                            'My Complaints',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
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
                      stream: _stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'Could not load your complaints.\n\n${snapshot.error}',
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

                        // Sort newest first in Dart (avoids needing
                        // a composite Firestore index).
                        docs.sort((a, b) {
                          final Timestamp? tsA =
                              a.data()['createdAt'] as Timestamp?;
                          final Timestamp? tsB =
                              b.data()['createdAt'] as Timestamp?;

                          if (tsA == null || tsB == null) return 0;

                          return tsB.compareTo(tsA);
                        });

                        if (docs.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.mark_email_read_outlined,
                                    color: Colors.white70,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'You haven\'t submitted any complaints yet.',
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

                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            0,
                            20,
                            25,
                          ),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data = docs[index].data();

                            final String complaint =
                                (data['complaint'] ?? '')
                                    .toString();

                            final String status =
                                (data['status'] ?? 'Pending')
                                    .toString();

                            final String adminReply =
                                (data['adminReply'] ?? '')
                                    .toString();

                            final Timestamp? timestamp =
                                data['createdAt'] as Timestamp?;

                            final String date = timestamp != null
                                ? _formatDate(timestamp.toDate())
                                : 'Recently submitted';

                            return Container(
                              width: double.infinity,
                              margin:
                                  const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withValues(alpha: 0.15),
                                borderRadius:
                                    BorderRadius.circular(18),
                                border:
                                    Border.all(color: Colors.white24),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          date,
                                          style: GoogleFonts.poppins(
                                            color: Colors.white70,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _statusColor(status)
                                              .withValues(alpha: 0.6),
                                          borderRadius:
                                              BorderRadius.circular(9),
                                        ),
                                        child: Text(
                                          status,
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight:
                                                FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    complaint,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                  if (adminReply.isNotEmpty) ...[
                                    const SizedBox(height: 14),
                                    Text(
                                      'Admin Response',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      width: double.infinity,
                                      padding:
                                          const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green
                                            .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.green
                                              .withValues(alpha: 0.4),
                                        ),
                                      ),
                                      child: Text(
                                        adminReply,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ] else ...[
                                    const SizedBox(height: 10),
                                    Text(
                                      'Waiting for admin response...',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white54,
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
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