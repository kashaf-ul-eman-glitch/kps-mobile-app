import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AcademicCalendarAdminScreen extends StatefulWidget {
  const AcademicCalendarAdminScreen({super.key});

  @override
  State<AcademicCalendarAdminScreen> createState() =>
      _AcademicCalendarAdminScreenState();
}

class _AcademicCalendarAdminScreenState
    extends State<AcademicCalendarAdminScreen> {
  // ===============================================================
  // FIRESTORE COLLECTION
  // ===============================================================

  final CollectionReference<Map<String, dynamic>> _calendarCollection =
      FirebaseFirestore.instance.collection('academic_calendar');

  // ===============================================================
  // ACADEMIC YEAR
  // ===============================================================

  final DocumentReference<Map<String, dynamic>> _academicYearDocument =
      FirebaseFirestore.instance
          .collection('school_settings')
          .doc('academic_year');

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(),
        backgroundColor: Colors.white.withValues(alpha: 0.2),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Colors.white24),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
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
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Manage Academic Calendar',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 19,
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

                          // =================================================
                          // ACADEMIC YEAR FROM FIRESTORE
                          // =================================================

                          Expanded(
                            child: StreamBuilder<
                                DocumentSnapshot<Map<String, dynamic>>>(
                              stream: _academicYearDocument.snapshots(),
                              builder: (context, snapshot) {
                                String academicYear = '2026 - 2027';

                                if (snapshot.hasData &&
                                    snapshot.data!.exists) {
                                  final data = snapshot.data!.data();

                                  if (data != null &&
                                      data['academicYear'] != null &&
                                      data['academicYear']
                                          .toString()
                                          .trim()
                                          .isNotEmpty) {
                                    academicYear =
                                        data['academicYear'].toString().trim();
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

                          // =================================================
                          // EVENT COUNT
                          // =================================================

                          StreamBuilder<
                              QuerySnapshot<Map<String, dynamic>>>(
                            stream: _calendarCollection.snapshots(),
                            builder: (context, snapshot) {
                              final count = snapshot.data?.docs.length ?? 0;

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.white24,
                                  ),
                                ),
                                child: Text(
                                  '$count Events',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // =================================================
                  // EVENTS TITLE
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

                        final documents = snapshot.data?.docs ?? [];

                        if (documents.isEmpty) {
                          return Center(
                            child: Text(
                              'No events added yet.\nTap + to add one.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          );
                        }

                        // =================================================
                        // EVENTS
                        // =================================================

                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            0,
                            20,
                            90,
                          ),
                          itemCount: documents.length,
                          itemBuilder: (context, index) {
                            final doc = documents[index];

                            final event =
                                Map<String, dynamic>.from(doc.data());

                            return _calendarEventCard(
                              event,
                              doc.id,
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
    String documentId,
  ) {
    return _FirestoreExpandableEventCard(
      event: event,
      documentId: documentId,
      onEdit: () {
        _showEventDialog(
          existingEvent: event,
          documentId: documentId,
        );
      },
      onDelete: () {
        _confirmDelete(documentId);
      },
    );
  }

  // ===============================================================
  // DELETE CONFIRMATION
  // ===============================================================

  void _confirmDelete(String documentId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 6,
            sigmaY: 6,
          ),
          child: AlertDialog(
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(
                color: Colors.white24,
              ),
            ),
            title: Text(
              'Delete Event?',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Yeh event delete hone ke baad parents ke calendar se bhi hat jaye ga.',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);

                  try {
                    await _calendarCollection
                        .doc(documentId)
                        .delete();

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Event deleted successfully.',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Delete failed: $e',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text(
                  'Delete',
                  style: GoogleFonts.poppins(
                    color: Colors.redAccent.shade100,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===============================================================
  // ADD / EDIT EVENT
  // ===============================================================

  void _showEventDialog({
    Map<String, dynamic>? existingEvent,
    String? documentId,
  }) {
    final bool isEditing = existingEvent != null;

    final titleController = TextEditingController(
      text: existingEvent?['title']?.toString() ?? '',
    );

    final descController = TextEditingController(
      text: existingEvent?['description']?.toString() ?? '',
    );

    final dateController = TextEditingController(
      text: existingEvent?['date']?.toString() ?? '',
    );

    String selectedCategory =
        existingEvent?['category']?.toString() ?? 'Event';

    // Make sure selected category exists.
    if (!CalendarDataHelper.categories.contains(selectedCategory)) {
      selectedCategory = CalendarDataHelper.categories.first;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 6,
                sigmaY: 6,
              ),
              child: Dialog(
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(
                    color: Colors.white24,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing
                              ? 'Edit Event'
                              : 'Add New Event',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // =================================================
                        // DATE
                        // =================================================

                        _glassField(
                          controller: dateController,
                          hint: 'Date (e.g. 20 Sep 2026)',
                          icon: Icons.calendar_today_outlined,
                        ),

                        const SizedBox(height: 12),

                        // =================================================
                        // TITLE
                        // =================================================

                        _glassField(
                          controller: titleController,
                          hint: 'Event Title',
                          icon: Icons.title_outlined,
                        ),

                        const SizedBox(height: 12),

                        // =================================================
                        // CATEGORY
                        // =================================================

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white24,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedCategory,
                              isExpanded: true,
                              dropdownColor:
                                  const Color(0xFF2C2C3A),
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white70,
                              ),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              items: CalendarDataHelper.categories
                                  .map(
                                    (category) =>
                                        DropdownMenuItem<String>(
                                      value: category,
                                      child: Text(category),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;

                                setDialogState(() {
                                  selectedCategory = value;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // =================================================
                        // DESCRIPTION
                        // =================================================

                        _glassField(
                          controller: descController,
                          hint: 'Description',
                          icon: Icons.notes_outlined,
                          maxLines: 3,
                        ),

                        const SizedBox(height: 20),

                        // =================================================
                        // BUTTONS
                        // =================================================

                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      Colors.white.withValues(
                                    alpha: 0.08,
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14),
                                    side: const BorderSide(
                                      color: Colors.white24,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: TextButton(
                                onPressed: () async {
                                  final title =
                                      titleController.text.trim();

                                  final date =
                                      dateController.text.trim();

                                  final description =
                                      descController.text.trim();

                                  if (title.isEmpty ||
                                      date.isEmpty) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please enter date and event title.',
                                        ),
                                        backgroundColor:
                                            Colors.orange,
                                      ),
                                    );
                                    return;
                                  }

                                  // =================================================
                                  // FIRESTORE DATA
                                  // =================================================

                                  final Map<String, dynamic>
                                      eventData = {
                                    'date': date,
                                    'title': title,
                                    'category':
                                        selectedCategory,
                                    'description':
                                        description,
                                  };

                                  try {
                                    if (isEditing &&
                                        documentId != null) {
                                      // ==============================
                                      // UPDATE
                                      // ==============================

                                      await _calendarCollection
                                          .doc(documentId)
                                          .update(eventData);
                                    } else {
                                      // ==============================
                                      // ADD
                                      // ==============================

                                      eventData['createdAt'] =
                                          FieldValue.serverTimestamp();

                                      await _calendarCollection
                                          .add(eventData);
                                    }

                                    if (!context.mounted) return;

                                    Navigator.pop(dialogContext);

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isEditing
                                              ? 'Event updated successfully.'
                                              : 'Event added successfully.',
                                        ),
                                        backgroundColor:
                                            Colors.green,
                                      ),
                                    );
                                  } catch (e) {
                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Operation failed: $e',
                                        ),
                                        backgroundColor:
                                            Colors.red,
                                      ),
                                    );
                                  }
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      Colors.white.withValues(
                                    alpha: 0.18,
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14),
                                    side: const BorderSide(
                                      color: Colors.white24,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  isEditing ? 'Update' : 'Add',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ===============================================================
  // GLASS TEXT FIELD
  // ===============================================================

  Widget _glassField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white24,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 13,
        ),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Colors.white70,
            size: 20,
          ),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: Colors.white54,
            fontSize: 13,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 14,
          ),
        ),
      ),
    );
  }
}

// ===================================================================
// FIRESTORE EXPANDABLE EVENT CARD
// ===================================================================

class _FirestoreExpandableEventCard extends StatefulWidget {
  final Map<String, dynamic> event;
  final String documentId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FirestoreExpandableEventCard({
    required this.event,
    required this.documentId,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_FirestoreExpandableEventCard> createState() =>
      _FirestoreExpandableEventCardState();
}

class _FirestoreExpandableEventCardState
    extends State<_FirestoreExpandableEventCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final String date =
        widget.event['date']?.toString() ?? '';

    final String title =
        widget.event['title']?.toString() ?? 'Academic Event';

    final String category =
        widget.event['category']?.toString() ?? 'Event';

    final String description =
        widget.event['description']?.toString() ??
            'No description available.';

    final List<String> dateParts =
        date.trim().split(RegExp(r'\s+'));

    final String day =
        dateParts.isNotEmpty && dateParts[0].isNotEmpty
            ? dateParts[0]
            : '--';

    final String month =
        dateParts.length > 1 && dateParts[1].isNotEmpty
            ? dateParts[1]
            : 'DATE';

    final IconData icon =
        CalendarDataHelper.getIcon(category);

    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
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
            // =========================================================
            // MAIN ROW
            // =========================================================

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
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        day,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        month,
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
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                  icon,
                  color: Colors.white,
                  size: 22,
                ),

                const SizedBox(width: 5),

                // =================================================
                // EDIT
                // =================================================

                InkWell(
                  onTap: widget.onEdit,
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.edit_outlined,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                ),

                // =================================================
                // DELETE
                // =================================================

                InkWell(
                  onTap: widget.onDelete,
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                ),

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

            // =========================================================
            // DESCRIPTION
            // =========================================================

            if (isExpanded) ...[
              const SizedBox(height: 14),

              const Divider(
                color: Colors.white24,
              ),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  description,
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

// ===================================================================
// CALENDAR HELPER
// ===================================================================

class CalendarDataHelper {
  static const List<String> categories = [
    'Holiday',
    'Exam',
    'Result',
    'Meeting',
    'Sports',
    'Event',
    'Vacation',
    'Class',
  ];

  static IconData getIcon(String category) {
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