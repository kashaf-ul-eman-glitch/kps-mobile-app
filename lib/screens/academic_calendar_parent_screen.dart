import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AcademicCalendarScreen extends StatelessWidget {
  const AcademicCalendarScreen({super.key});

  // ===============================================================
  // FIRESTORE COLLECTION
  // ===============================================================

  CollectionReference<Map<String, dynamic>> get _calendarCollection =>
      FirebaseFirestore.instance.collection('academic_calendar');

  // ===============================================================
  // ACADEMIC YEAR DOCUMENT
  // ===============================================================

  DocumentReference<Map<String, dynamic>> get _academicYearDocument =>
      FirebaseFirestore.instance
          .collection('school_settings')
          .doc('academic_year');

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
          filter: ImageFilter.blur(
            sigmaX: 5,
            sigmaY: 5,
          ),
          child: Container(
            color: Colors.black.withValues(alpha: 0.25),
            child: SafeArea(
              child: Column(
                children: [
                  // =================================================
                  // TOP BAR
                  // =================================================

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
                            'Academic Calendar',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // =================================================
                  // ACADEMIC YEAR
                  // =================================================

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      5,
                      20,
                      18,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white24,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.calendar_month_outlined,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: StreamBuilder<
                                DocumentSnapshot<Map<String, dynamic>>>(
                              stream:
                                  _academicYearDocument.snapshots(),
                              builder: (context, snapshot) {
                                String academicYear =
                                    '2026 - 2027';

                                if (snapshot.hasData &&
                                    snapshot.data!.exists) {
                                  final data =
                                      snapshot.data!.data();

                                  if (data != null &&
                                      data['academicYear'] != null &&
                                      data['academicYear']
                                          .toString()
                                          .trim()
                                          .isNotEmpty) {
                                    academicYear =
                                        data['academicYear']
                                            .toString()
                                            .trim();
                                  }
                                }

                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Academic Year',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),

                                    const SizedBox(height: 2),

                                    Text(
                                      academicYear,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
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

                  // =================================================
                  // IMPORTANT DATES
                  // =================================================

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
                        'Important Dates',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // =================================================
                  // FIRESTORE EVENTS
                  // =================================================

                  Expanded(
                    child: StreamBuilder<
                        QuerySnapshot<Map<String, dynamic>>>(
                      stream: _calendarCollection.snapshots(),
                      builder: (context, snapshot) {
                        // =================================================
                        // LOADING
                        // =================================================

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        }

                        // =================================================
                        // ERROR
                        // =================================================

                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(25),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: Colors.white70,
                                    size: 48,
                                  ),

                                  const SizedBox(height: 12),

                                  Text(
                                    'Unable to load academic calendar.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    snapshot.error.toString(),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white54,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // =================================================
                        // DOCUMENTS
                        // =================================================

                        final documents =
                            snapshot.data?.docs ?? [];

                        // =================================================
                        // NO EVENTS
                        // =================================================

                        if (documents.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(25),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.event_busy_outlined,
                                    color: Colors.white60,
                                    size: 50,
                                  ),

                                  const SizedBox(height: 12),

                                  Text(
                                    'No events available yet.',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    'Academic calendar events added by the school will appear here.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white54,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // =================================================
                        // EVENTS LIST
                        // =================================================

                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            0,
                            20,
                            25,
                          ),
                          itemCount: documents.length,
                          itemBuilder: (context, index) {
                            final doc = documents[index];

                            final event =
                                Map<String, dynamic>.from(
                              doc.data(),
                            );

                            return _calendarEventCard(
                              event,
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

  // ===============================================================
  // EVENT CARD
  // ===============================================================

  Widget _calendarEventCard(
    Map<String, dynamic> event,
  ) {
    final String date = _getString(
      event,
      [
        'date',
        'eventDate',
        'event_date',
      ],
    );

    final String title = _getString(
      event,
      [
        'title',
        'eventTitle',
        'eventName',
        'name',
      ],
      fallback: 'Academic Event',
    );

    final String category = _getString(
      event,
      [
        'category',
        'type',
        'eventType',
      ],
      fallback: 'Event',
    );

    final String description = _getString(
      event,
      [
        'description',
        'details',
        'remarks',
      ],
      fallback: 'No description available.',
    );

    // ===============================================================
    // DATE
    // ===============================================================

    String day = '';
    String month = '';

    if (date.isNotEmpty) {
      final List<String> dateParts =
          date.trim().split(RegExp(r'\s+'));

      if (dateParts.isNotEmpty) {
        day = dateParts[0];
      }

      if (dateParts.length > 1) {
        month = dateParts[1];
      }
    }

    if (day.isEmpty) {
      day = '--';
    }

    if (month.isEmpty) {
      month = 'DATE';
    }

    // ===============================================================
    // ICON
    // ===============================================================

    final IconData icon =
        _getIcon(category);

    return _ExpandableEventCard(
      day: day,
      month: month,
      title: title,
      category: category,
      description: description,
      icon: icon,
    );
  }

  // ===============================================================
  // GET STRING
  // ===============================================================

  String _getString(
    Map<String, dynamic> data,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = data[key];

      if (value != null &&
          value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return fallback;
  }

  // ===============================================================
  // EVENT ICON
  // ===============================================================

  IconData _getIcon(String category) {
    final String value = category.toLowerCase();

    if (value.contains('holiday')) {
      return Icons.beach_access_outlined;
    }

    if (value.contains('exam')) {
      return Icons.assignment_outlined;
    }

    if (value.contains('result')) {
      return Icons.emoji_events_outlined;
    }

    if (value.contains('meeting')) {
      return Icons.groups_outlined;
    }

    if (value.contains('sports')) {
      return Icons.sports_soccer_outlined;
    }

    if (value.contains('event')) {
      return Icons.event_outlined;
    }

    if (value.contains('vacation')) {
      return Icons.luggage_outlined;
    }

    if (value.contains('class')) {
      return Icons.school_outlined;
    }

    return Icons.calendar_month_outlined;
  }
}

// ===================================================================
// EXPANDABLE EVENT CARD
// ===================================================================

class _ExpandableEventCard extends StatefulWidget {
  final String day;
  final String month;
  final String title;
  final String category;
  final String description;
  final IconData icon;

  const _ExpandableEventCard({
    required this.day,
    required this.month,
    required this.title,
    required this.category,
    required this.description,
    required this.icon,
  });

  @override
  State<_ExpandableEventCard> createState() =>
      _ExpandableEventCardState();
}

class _ExpandableEventCardState
    extends State<_ExpandableEventCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 250,
        ),
        width: double.infinity,
        margin: const EdgeInsets.only(
          bottom: 14,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white24,
          ),
        ),
        child: Column(
          children: [
            // =======================================================
            // MAIN ROW
            // =======================================================

            Row(
              children: [
                // =================================================
                // DATE
                // =================================================

                Container(
                  width: 58,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.day,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        widget.month,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // =================================================
                // EVENT INFO
                // =================================================

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        widget.category,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // =================================================
                // ICON
                // =================================================

                Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 25,
                ),

                const SizedBox(width: 3),

                // =================================================
                // ARROW
                // =================================================

                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white70,
                ),
              ],
            ),

            // =======================================================
            // DESCRIPTION
            // =======================================================

            if (isExpanded) ...[
              const SizedBox(height: 14),

              Divider(
                color: Colors.white.withValues(
                  alpha: 0.20,
                ),
              ),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.description,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}