import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ================================================================
// PARENT DATE SHEET SCREEN
// ================================================================
//
// FIRESTORE STRUCTURE:
//
// classes/{className}/datesheet/{autoId}
//
// Fields:
//
// subject      -> String
// date         -> Timestamp
// startTime    -> String
// endTime      -> String
// time         -> String
// examTitle    -> String
// order        -> number
//
// The screen automatically shows the date sheet of the class
// passed through:
//
// ParentDateSheetScreen(className: parentClass)
//
// Background:
// assets/images/background.jpg
// ================================================================

class ParentDateSheetScreen extends StatelessWidget {
  final String className;

  const ParentDateSheetScreen({
    super.key,
    required this.className,
  });

  // ==============================================================
  // FIRESTORE STREAM
  // ==============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> _stream() {
    return FirebaseFirestore.instance
        .collection('classes')
        .doc(className)
        .collection('datesheet')
        .snapshots();
  }

  // ==============================================================
  // SORT DATE SHEET
  // ==============================================================

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sorted(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final list =
        List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(docs);

    list.sort((a, b) {
      final dynamic rawDateA = a.data()['date'];
      final dynamic rawDateB = b.data()['date'];

      final Timestamp? dateA =
          rawDateA is Timestamp ? rawDateA : null;

      final Timestamp? dateB =
          rawDateB is Timestamp ? rawDateB : null;

      if (dateA != null && dateB != null) {
        final dateCompare = dateA.compareTo(dateB);

        if (dateCompare != 0) {
          return dateCompare;
        }
      }

      if (dateA != null && dateB == null) {
        return -1;
      }

      if (dateA == null && dateB != null) {
        return 1;
      }

      final num orderA =
          (a.data()['order'] as num?) ?? 0;

      final num orderB =
          (b.data()['order'] as num?) ?? 0;

      return orderA.compareTo(orderB);
    });

    return list;
  }

  // ==============================================================
  // FORMAT DATE
  // ==============================================================

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '';

    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final date = timestamp.toDate();

    return '${weekdays[date.weekday - 1]}, '
        '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // ==============================================================
  // DATE NUMBER
  // ==============================================================

  String _dateNumber(Timestamp? timestamp) {
    if (timestamp == null) return '--';

    return timestamp.toDate().day.toString();
  }

  // ==============================================================
  // MONTH
  // ==============================================================

  String _monthName(Timestamp? timestamp) {
    if (timestamp == null) return '';

    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];

    return months[timestamp.toDate().month - 1];
  }

  // ==============================================================
  // WEEKDAY
  // ==============================================================

  String _weekday(Timestamp? timestamp) {
    if (timestamp == null) return '';

    const weekdays = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return weekdays[timestamp.toDate().weekday - 1];
  }

  // ==============================================================
  // GET TIME
  // ==============================================================

  String _getTime(Map<String, dynamic> data) {
    final String time =
        (data['time'] ?? '').toString().trim();

    if (time.isNotEmpty) {
      return time;
    }

    final String start =
        (data['startTime'] ?? '').toString().trim();

    final String end =
        (data['endTime'] ?? '').toString().trim();

    if (start.isNotEmpty && end.isNotEmpty) {
      return '$start - $end';
    }

    if (start.isNotEmpty) {
      return start;
    }

    if (end.isNotEmpty) {
      return end;
    }

    return '';
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [
          // ========================================================
          // BACKGROUND IMAGE
          // ========================================================

          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return Container(
                  color: Colors.black,
                );
              },
            ),
          ),

          // ========================================================
          // DARK OVERLAY
          // ========================================================

          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.72),
            ),
          ),

          // ========================================================
          // SLIGHT BLUR
          // ========================================================

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 3,
                sigmaY: 3,
              ),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

          // ========================================================
          // CONTENT
          // ========================================================

          SafeArea(
            child: Column(
              children: [
                _topBar(context),

                const SizedBox(height: 4),

                // ==================================================
                // CLASS INFORMATION
                // ==================================================

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),
                  child: _glassContainer(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color:
                                Colors.white.withOpacity(0.10),
                            borderRadius:
                                BorderRadius.circular(13),
                            border: Border.all(
                              color:
                                  Colors.white.withOpacity(0.18),
                            ),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
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
                                'Class',
                                style:
                                    GoogleFonts.poppins(
                                  color: Colors.white
                                      .withOpacity(0.55),
                                  fontSize: 10,
                                  fontWeight:
                                      FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 1),

                              Text(
                                className,
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style:
                                    GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Colors.white.withOpacity(0.08),
                            borderRadius:
                                BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  Colors.white.withOpacity(0.14),
                            ),
                          ),
                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.event_available_rounded,
                                color: Colors.white,
                                size: 15,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Schedule',
                                style:
                                    GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // ==================================================
                // FIRESTORE
                // ==================================================

                Expanded(
                  child: StreamBuilder<
                      QuerySnapshot<
                          Map<String, dynamic>>>(
                    stream: _stream(),
                    builder: (
                      context,
                      snapshot,
                    ) {
                      // ==================================================
                      // LOADING
                      // ==================================================

                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return _loadingState();
                      }

                      // ==================================================
                      // ERROR
                      // ==================================================

                      if (snapshot.hasError) {
                        return _errorState(
                          snapshot.error.toString(),
                        );
                      }

                      final docs = _sorted(
                        snapshot.data?.docs ?? [],
                      );

                      // ==================================================
                      // EMPTY
                      // ==================================================

                      if (docs.isEmpty) {
                        return _emptyState();
                      }

                      // ==================================================
                      // LIST
                      // ==================================================

                      return ListView.builder(
                        physics:
                            const BouncingScrollPhysics(),

                        padding:
                            const EdgeInsets.fromLTRB(
                          18,
                          2,
                          18,
                          30,
                        ),

                        itemCount: docs.length,

                        itemBuilder:
                            (context, index) {
                          final data =
                              docs[index].data();

                          final String subject =
                              (data['subject'] ??
                                      'Subject')
                                  .toString();

                          final String time =
                              _getTime(data);

                          final dynamic rawDate =
                              data['date'];

                          final Timestamp? timestamp =
                              rawDate is Timestamp
                                  ? rawDate
                                  : null;

                          final String dateLabel =
                              timestamp != null
                                  ? _formatDate(
                                      timestamp,
                                    )
                                  : (data['dateLabel'] ??
                                          '')
                                      .toString();

                          final String examTitle =
                              (data['examTitle'] ??
                                      'Examination')
                                  .toString();

                          return _examCard(
                            index: index,
                            subject: subject,
                            time: time,
                            dateLabel: dateLabel,
                            timestamp: timestamp,
                            examTitle: examTitle,
                          );
                        },
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

  // ==============================================================
  // TOP BAR
  // ==============================================================

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        10,
        8,
        10,
        8,
      ),
      child: Row(
        children: [
          // BACK BUTTON
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.18),
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 23,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // TITLE
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Exam Date Sheet',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Your child’s examination schedule',
                  style: GoogleFonts.poppins(
                    color:
                        Colors.white.withOpacity(0.58),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // ICON
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.17),
              ),
            ),
            child: const Icon(
              Icons.edit_calendar_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // EXAM CARD
  // ==============================================================

  Widget _examCard({
    required int index,
    required String subject,
    required String time,
    required String dateLabel,
    required Timestamp? timestamp,
    required String examTitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.085),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.17),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor:
                Colors.white.withOpacity(0.06),
            highlightColor:
                Colors.white.withOpacity(0.03),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // ==================================================
                  // DATE
                  // ==================================================

                  Container(
                    width: 64,
                    height: 76,
                    decoration: BoxDecoration(
                      color:
                          Colors.black.withOpacity(0.24),
                      borderRadius:
                          BorderRadius.circular(17),
                      border: Border.all(
                        color:
                            Colors.white.withOpacity(0.18),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          _monthName(timestamp),
                          style:
                              GoogleFonts.poppins(
                            color: Colors.white
                                .withOpacity(0.62),
                            fontSize: 9,
                            fontWeight:
                                FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),

                        const SizedBox(height: 1),

                        Text(
                          _dateNumber(timestamp),
                          style:
                              GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 23,
                            height: 1,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),

                        if (timestamp != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            _weekday(timestamp),
                            style:
                                GoogleFonts.poppins(
                              color: Colors.white
                                  .withOpacity(0.58),
                              fontSize: 8.5,
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 14),

                  // ==================================================
                  // DETAILS
                  // ==================================================

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // EXAM NUMBER
                        Text(
                          'EXAM ${index + 1}',
                          style:
                              GoogleFonts.poppins(
                            color: Colors.white
                                .withOpacity(0.43),
                            fontSize: 8.5,
                            fontWeight:
                                FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),

                        const SizedBox(height: 2),

                        // SUBJECT
                        Text(
                          subject,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 7),

                        // DATE
                        if (dateLabel.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons
                                    .calendar_month_rounded,
                                size: 14,
                                color: Colors.white
                                    .withOpacity(0.58),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  dateLabel,
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style:
                                      GoogleFonts.poppins(
                                    color: Colors.white
                                        .withOpacity(
                                            0.66),
                                    fontSize: 10,
                                    fontWeight:
                                        FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        // TIME
                        if (time.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons
                                    .access_time_rounded,
                                size: 14,
                                color: Colors.white
                                    .withOpacity(0.58),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  time,
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style:
                                      GoogleFonts.poppins(
                                    color: Colors.white
                                        .withOpacity(
                                            0.66),
                                    fontSize: 10,
                                    fontWeight:
                                        FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 5),

                        // EXAM TITLE
                        Text(
                          examTitle,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              GoogleFonts.poppins(
                            color: Colors.white
                                .withOpacity(0.42),
                            fontSize: 8.5,
                            fontWeight:
                                FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ==================================================
                  // ARROW
                  // ==================================================

                  Container(
                    width: 31,
                    height: 31,
                    decoration: BoxDecoration(
                      color:
                          Colors.white.withOpacity(0.065),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            Colors.white.withOpacity(0.10),
                      ),
                    ),
                    child: Icon(
                      Icons
                          .arrow_forward_ios_rounded,
                      color:
                          Colors.white.withOpacity(0.48),
                      size: 11,
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

  // ==============================================================
  // GLASS CONTAINER
  // ==============================================================

  Widget _glassContainer({
    required Widget child,
    EdgeInsetsGeometry padding =
        const EdgeInsets.all(16),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color:
                Colors.white.withOpacity(0.075),
            borderRadius:
                BorderRadius.circular(20),
            border: Border.all(
              color:
                  Colors.white.withOpacity(0.15),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  // ==============================================================
  // LOADING
  // ==============================================================

  Widget _loadingState() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color:
                  Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    Colors.white.withOpacity(0.15),
              ),
            ),
            child:
                const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading Date Sheet...',
            style: GoogleFonts.poppins(
              color:
                  Colors.white.withOpacity(0.70),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // EMPTY STATE
  // ==============================================================

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: _glassContainer(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 34,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color:
                      Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        Colors.white.withOpacity(0.15),
                  ),
                ),
                child: const Icon(
                  Icons.event_note_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'No Date Sheet Yet',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'The examination schedule for $className has not been published yet.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white
                      .withOpacity(0.58),
                  fontSize: 11,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // ERROR STATE
  // ==============================================================

  Widget _errorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: _glassContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 48,
              ),

              const SizedBox(height: 14),

              Text(
                'Unable to Load Date Sheet',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Please check your internet connection or Firestore permissions.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white
                      .withOpacity(0.58),
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}