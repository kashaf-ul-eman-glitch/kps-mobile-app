import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ================================================================
// PARENT TEACHER REVIEW & BEHAVIOR SCREEN
// ================================================================
//
// Firestore:
//
// classes/{className}/students/{studentId}
//   - behaviorRating
//   - disciplineRemarks
//
// classes/{className}/students/{studentId}/teacherReviews/{autoId}
//   - teacherName
//   - subject
//   - rating
//   - comment
//   - createdAt
//
// ================================================================

class ParentTeacherReviewScreen extends StatelessWidget {
  final String studentId;
  final String className;

  const ParentTeacherReviewScreen({
    super.key,
    required this.studentId,
    required this.className,
  });

  // ------------------------------------------------------------
  // STUDENT DOCUMENT
  // ------------------------------------------------------------

  DocumentReference<Map<String, dynamic>> get _studentDoc =>
      FirebaseFirestore.instance
          .collection('classes')
          .doc(className)
          .collection('students')
          .doc(studentId);

  // ------------------------------------------------------------
  // REVIEWS STREAM
  // ------------------------------------------------------------

  Stream<QuerySnapshot<Map<String, dynamic>>> _reviewsStream() {
    return _studentDoc.collection('teacherReviews').snapshots();
  }

  // ------------------------------------------------------------
  // SORT REVIEWS
  // ------------------------------------------------------------

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sorted(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final list =
        List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(docs);

    list.sort((a, b) {
      final dynamic rawA = a.data()['createdAt'];
      final dynamic rawB = b.data()['createdAt'];

      Timestamp? tsA;
      Timestamp? tsB;

      if (rawA is Timestamp) {
        tsA = rawA;
      }

      if (rawB is Timestamp) {
        tsB = rawB;
      }

      if (tsA == null && tsB == null) {
        return 0;
      }

      if (tsA == null) {
        return 1;
      }

      if (tsB == null) {
        return -1;
      }

      return tsB.compareTo(tsA);
    });

    return list;
  }

  // ------------------------------------------------------------
  // STAR RATING
  // ------------------------------------------------------------

  Widget _stars(
    num rating, {
    double size = 19,
  }) {
    final int full = rating.clamp(0, 5).round();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) {
          return Icon(
            index < full
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: Colors.amber.shade400,
            size: size,
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // RATING TEXT
  // ------------------------------------------------------------

  String _ratingText(num rating) {
    final value = rating.toDouble();

    if (value >= 5) {
      return 'Excellent';
    }

    if (value >= 4) {
      return 'Very Good';
    }

    if (value >= 3) {
      return 'Good';
    }

    if (value >= 2) {
      return 'Needs Improvement';
    }

    return 'Needs Attention';
  }

  // ------------------------------------------------------------
  // GLASS CONTAINER
  // ------------------------------------------------------------

  Widget _glassCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
    double radius = 22,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF111827),
      body: Stack(
        children: [
          // ------------------------------------------------------
          // FULL SCREEN BACKGROUND IMAGE
          // ------------------------------------------------------

          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF172554),
                        Color(0xFF312E81),
                        Color(0xFF4C1D95),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ------------------------------------------------------
          // DARK OVERLAY
          // ------------------------------------------------------

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.60),
                    const Color(0xFF111827).withValues(alpha: 0.72),
                    const Color(0xFF111827).withValues(alpha: 0.86),
                  ],
                ),
              ),
            ),
          ),

          // ------------------------------------------------------
          // CONTENT
          // ------------------------------------------------------

          SafeArea(
            child: Column(
              children: [
                _topBar(
                  context,
                  'Teacher Review & Behavior',
                ),

                Expanded(
                  child: StreamBuilder<
                      DocumentSnapshot<Map<String, dynamic>>>(
                    stream: _studentDoc.snapshots(),
                    builder: (context, studentSnap) {
                      final Map<String, dynamic> studentData =
                          studentSnap.data?.data() ?? {};

                      final num behaviorRating =
                          studentData['behaviorRating'] is num
                              ? studentData['behaviorRating'] as num
                              : 5;

                      final String disciplineRemarks =
                          (studentData['disciplineRemarks'] ??
                                  'No remarks added yet.')
                              .toString();

                      return ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          8,
                          20,
                          35,
                        ),
                        children: [
                          // ------------------------------------------------
                          // STUDENT HEADER
                          // ------------------------------------------------

                          _glassCard(
                            radius: 24,
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(
                                      alpha: 0.16,
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.30,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: Colors.white,
                                    size: 31,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Student Performance',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white70,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Behavior & Teacher Reviews',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ------------------------------------------------
                          // OVERALL BEHAVIOR
                          // ------------------------------------------------

                          _glassCard(
                            radius: 24,
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(15),
                                      ),
                                      child: Icon(
                                        Icons.emoji_emotions_rounded,
                                        color: Colors.amber.shade300,
                                        size: 25,
                                      ),
                                    ),
                                    const SizedBox(width: 13),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Overall Behavior',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight:
                                                  FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _ratingText(
                                              behaviorRating,
                                            ),
                                            style: GoogleFonts.poppins(
                                              color: Colors.amber.shade300,
                                              fontSize: 11,
                                              fontWeight:
                                                  FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.amber.withValues(
                                          alpha: 0.13,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${behaviorRating.toStringAsFixed(0)}/5',
                                        style: GoogleFonts.poppins(
                                          color: Colors.amber.shade300,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 17),

                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      _stars(
                                        behaviorRating,
                                        size: 21,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        _ratingText(behaviorRating),
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 15),

                                Text(
                                  disciplineRemarks,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withValues(
                                      alpha: 0.82,
                                    ),
                                    fontSize: 12.5,
                                    height: 1.65,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ------------------------------------------------
                          // SECTION TITLE
                          // ------------------------------------------------

                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(
                                    alpha: 0.13,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(13),
                                ),
                                child: const Icon(
                                  Icons.rate_review_rounded,
                                  color: Colors.white,
                                  size: 21,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Subject Teacher Reviews',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Feedback from your child\'s teachers',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white60,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // ------------------------------------------------
                          // TEACHER REVIEWS
                          // ------------------------------------------------

                          StreamBuilder<
                              QuerySnapshot<Map<String, dynamic>>>(
                            stream: _reviewsStream(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 40,
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return _glassCard(
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.error_outline_rounded,
                                        color: Colors.white70,
                                        size: 40,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Unable to load teacher reviews.',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              final docs = _sorted(
                                snapshot.data?.docs ?? [],
                              );

                              if (docs.isEmpty) {
                                return _glassCard(
                                  radius: 20,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 65,
                                        height: 65,
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.10),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.rate_review_outlined,
                                          color: Colors.white70,
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        'No Teacher Reviews Yet',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight:
                                              FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Teacher feedback will appear here once it is added.',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white60,
                                          fontSize: 11,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return Column(
                                children: docs.map((doc) {
                                  final data = doc.data();

                                  final String teacher =
                                      (data['teacherName'] ??
                                              'Teacher')
                                          .toString();

                                  final String subject =
                                      (data['subject'] ?? '')
                                          .toString();

                                  final String comment =
                                      (data['comment'] ?? '')
                                          .toString();

                                  final num rating =
                                      data['rating'] is num
                                          ? data['rating'] as num
                                          : 0;

                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(
                                      bottom: 13,
                                    ),
                                    child: _teacherReviewCard(
                                      teacher: teacher,
                                      subject: subject,
                                      comment: comment,
                                      rating: rating,
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // TEACHER REVIEW CARD
  // ------------------------------------------------------------

  Widget _teacherReviewCard({
    required String teacher,
    required String subject,
    required String comment,
    required num rating,
  }) {
    return _glassCard(
      radius: 21,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF818CF8),
                      Color(0xFF6366F1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1)
                          .withValues(alpha: 0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    if (subject.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.menu_book_rounded,
                            color: Colors.white60,
                            size: 13,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              subject,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: Colors.white60,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '${rating.toStringAsFixed(0)}/5',
                      style: GoogleFonts.poppins(
                        color: Colors.amber.shade300,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 1),
                    _stars(
                      rating,
                      size: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (comment.isNotEmpty) ...[
            const SizedBox(height: 15),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.format_quote_rounded,
                    color: Colors.white.withValues(alpha: 0.40),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      comment,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.80),
                        fontSize: 11.5,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // TOP BAR
  // ------------------------------------------------------------

  Widget _topBar(
    BuildContext context,
    String title,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        8,
        6,
        8,
        10,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 22,
              ),
              padding: EdgeInsets.zero,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                shadows: [
                  const Shadow(
                    color: Colors.black54,
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 56),
        ],
      ),
    );
  }
}
