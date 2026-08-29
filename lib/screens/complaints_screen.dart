import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // FIRESTORE COMPLAINTS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      _complaintsStream() {
    return _firestore
        .collection('complaints')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
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
                            'Parent Complaints',
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
                      stream: _complaintsStream(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(20),
                              child: Text(
                                'Could not load complaints.\n\n${snapshot.error}',
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

                        final docs =
                            snapshot.data?.docs ?? [];

                        final int totalComplaints =
                            docs.length;

                        final int pendingComplaints =
                            docs.where((doc) {
                          return doc.data()['status'] ==
                              'Pending';
                        }).length;

                        final int reviewComplaints =
                            docs.where((doc) {
                          return doc.data()['status'] ==
                              'In Review';
                        }).length;

                        final int resolvedComplaints =
                            docs.where((doc) {
                          return doc.data()['status'] ==
                              'Resolved';
                        }).length;

                        return Column(
                          children: [
                            // =========================
                            // Summary
                            // =========================

                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(
                                20,
                                5,
                                20,
                                18,
                              ),
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                    18,
                                  ),
                                  border: Border.all(
                                    color: Colors.white24,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceAround,
                                  children: [
                                    _summaryItem(
                                      'Total',
                                      totalComplaints,
                                    ),
                                    _summaryItem(
                                      'Pending',
                                      pendingComplaints,
                                    ),
                                    _summaryItem(
                                      'Review',
                                      reviewComplaints,
                                    ),
                                    _summaryItem(
                                      'Resolved',
                                      resolvedComplaints,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // =========================
                            // Section Title
                            // =========================

                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(
                                20,
                                0,
                                20,
                                12,
                              ),
                              child: Align(
                                alignment:
                                    Alignment.centerLeft,
                                child: Text(
                                  'Complaints from Families',
                                  style:
                                      GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            // =========================
                            // Complaints List
                            // =========================

                            Expanded(
                              child: docs.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No complaints submitted yet.',
                                        style:
                                            GoogleFonts.poppins(
                                          color:
                                              Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      padding:
                                          const EdgeInsets
                                              .fromLTRB(
                                        20,
                                        0,
                                        20,
                                        25,
                                      ),
                                      itemCount:
                                          docs.length,
                                      itemBuilder:
                                          (context, index) {
                                        final doc =
                                            docs[index];

                                        final data =
                                            doc.data();

                                        return _complaintCard(
                                          doc.id,
                                          data,
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

  // ============================================================
  // SUMMARY ITEM
  // ============================================================

  Widget _summaryItem(
    String title,
    int value,
  ) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: GoogleFonts.poppins(
            color: Colors.white,
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

  // ============================================================
  // COMPLAINT CARD
  // ============================================================

  Widget _complaintCard(
    String complaintId,
    Map<String, dynamic> complaint,
  ) {
    final String title =
        (complaint['title'] ?? 'Complaint').toString();

    final String category =
        (complaint['category'] ?? 'General').toString();

    final String parent =
        (complaint['parentName'] ?? 'Unknown').toString();

    final String child =
        (complaint['studentName'] ??
                complaint['childName'] ??
                'Unknown')
            .toString();

    final String className =
        (complaint['className'] ?? '').toString();

    final String section =
        (complaint['section'] ?? '').toString();

    final String description =
        (complaint['complaint'] ??
                complaint['description'] ??
                '')
            .toString();

    final String status =
        (complaint['status'] ?? 'Pending').toString();

    final String parentId =
        (complaint['parentId'] ?? '').toString();

    final String studentId =
        (complaint['studentId'] ?? '').toString();

    final String admissionNo =
        (complaint['admissionNo'] ?? '').toString();

    final String rollNo =
        (complaint['rollNo'] ?? '').toString();

    final String parentEmail =
        (complaint['parentEmail'] ?? '').toString();

    // FIX: the Parent Dashboard writes the admin's reply into the
    // `adminReply` field (see parent_dashboard.dart complaint
    // submission code). This screen was previously reading
    // `adminResponse`, a field that is never written, so the
    // admin's reply never appeared. Reading `adminReply` here
    // (with `adminResponse` kept as a fallback for any old docs)
    // fixes that mismatch.
    final String adminResponse =
        (complaint['adminReply'] ??
                complaint['adminResponse'] ??
                '')
            .toString();

    final Timestamp? timestamp =
        complaint['createdAt'] as Timestamp?;

    final String date =
        timestamp != null
            ? _formatDate(timestamp.toDate())
            : 'Recently submitted';

    final String classLine = [
      if (className.isNotEmpty) className,
      if (section.isNotEmpty) section,
    ].join(' • ');

    return _ComplaintCard(
      complaintId: complaintId,
      title: title,
      category: category,
      parent: parent,
      child: child,
      classLine: classLine,
      date: date,
      status: status,
      description: description,
      parentId: parentId,
      studentId: studentId,
      admissionNo: admissionNo,
      rollNo: rollNo,
      parentEmail: parentEmail,
      adminResponse: adminResponse,
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

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
}

// ================================================================
// COMPLAINT CARD STATE
// ================================================================

class _ComplaintCard extends StatefulWidget {
  final String complaintId;
  final String title;
  final String category;
  final String parent;
  final String child;
  final String classLine;
  final String date;
  final String status;
  final String description;
  final String parentId;
  final String studentId;
  final String admissionNo;
  final String rollNo;
  final String parentEmail;
  final String adminResponse;

  const _ComplaintCard({
    required this.complaintId,
    required this.title,
    required this.category,
    required this.parent,
    required this.child,
    required this.classLine,
    required this.date,
    required this.status,
    required this.description,
    required this.parentId,
    required this.studentId,
    required this.admissionNo,
    required this.rollNo,
    required this.parentEmail,
    required this.adminResponse,
  });

  @override
  State<_ComplaintCard> createState() =>
      _ComplaintCardState();
}

class _ComplaintCardState extends State<_ComplaintCard> {
  bool expanded = false;

  late final TextEditingController _replyController;

  late String _selectedStatus;

  bool _isSaving = false;

  static const List<String> _statusOptions = [
    'Pending',
    'In Review',
    'Resolved',
  ];

  @override
  void initState() {
    super.initState();
    _replyController =
        TextEditingController(text: widget.adminResponse);
    _selectedStatus = _statusOptions.contains(widget.status)
        ? widget.status
        : 'Pending';
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  // ============================================================
  // SEND / UPDATE ADMIN REPLY
  // ============================================================
  //
  // Writes into the SAME `adminReply` field that the Parent
  // Dashboard reads back on the parent's side, so whatever the
  // admin types here shows up for the parent automatically.
  // ============================================================

  Future<void> _sendReply() async {
    final String reply = _replyController.text.trim();

    final ScaffoldMessengerState messenger =
        ScaffoldMessenger.of(context);

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(widget.complaintId)
          .update({
        'adminReply': reply,
        'status': _selectedStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Response sent to parent.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text('Could not send response.\n$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          expanded = !expanded;
        });
      },
      child: Container(
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
            // =========================
            // Complaint Header
            // =========================

            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color:
                        Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.report_problem_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${widget.child} • '
                        '${widget.classLine}',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                _statusBadge(_selectedStatus),

                const SizedBox(width: 4),

                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white70,
                ),
              ],
            ),

            // =========================
            // Expanded Details
            // =========================

            if (expanded) ...[
              const SizedBox(height: 14),

              const Divider(
                color: Colors.white24,
              ),

              const SizedBox(height: 10),

              _detailRow(
                Icons.person,
                'Parent',
                widget.parent,
              ),

              _detailRow(
                Icons.family_restroom,
                'Parent ID',
                widget.parentId,
              ),

              _detailRow(
                Icons.email_outlined,
                'Email',
                widget.parentEmail,
              ),

              _detailRow(
                Icons.child_care,
                'Child',
                widget.child,
              ),

              _detailRow(
                Icons.school,
                'Class',
                widget.classLine,
              ),

              _detailRow(
                Icons.badge_outlined,
                'Admission No.',
                widget.admissionNo,
              ),

              _detailRow(
                Icons.numbers,
                'Roll No.',
                widget.rollNo,
              ),

              _detailRow(
                Icons.category_outlined,
                'Category',
                widget.category,
              ),

              _detailRow(
                Icons.calendar_today,
                'Date',
                widget.date,
              ),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Complaint',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 5),

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

              // =========================
              // ADMIN: STATUS + REPLY FORM
              // =========================

              const SizedBox(height: 18),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Update Status',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white38),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    isExpanded: true,
                    dropdownColor: Colors.brown.shade900,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white70,
                    ),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    items: _statusOptions
                        .map(
                          (option) => DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          ),
                        )
                        .toList(),
                    onChanged: _isSaving
                        ? null
                        : (value) {
                            if (value == null) return;
                            setState(() {
                              _selectedStatus = value;
                            });
                          },
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.adminResponse.isNotEmpty
                      ? 'Edit Response'
                      : 'Write a Response',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _replyController,
                enabled: !_isSaving,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText:
                      'Type your response to the parent here...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.white38,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.white38,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _sendReply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.brown.shade900,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.brown,
                          ),
                        )
                      : const Icon(Icons.send_outlined),
                  label: Text(
                    widget.adminResponse.isNotEmpty
                        ? 'Update Response'
                        : 'Send Response to Parent',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    if (value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white70,
            size: 18,
          ),
          const SizedBox(width: 9),
          Text(
            '$title: ',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge(
    String status,
  ) {
    Color badgeColor;

    switch (status) {
      case 'Resolved':
        badgeColor = Colors.green;
        break;
      case 'In Review':
        badgeColor = Colors.orange;
        break;
      default:
        badgeColor = Colors.white.withValues(alpha: 0.12);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}