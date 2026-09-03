import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String selectedFilter = 'All';
  String searchQuery = '';

  // ============================================================
  // GET HOMEWORK
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> _homeworkStream() {
    final user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('homework')
        .where('parentUid', isEqualTo: user.uid)
        .snapshots();
  }

  // ============================================================
  // STATUS
  // ============================================================

  String _getStatus(Map<String, dynamic> data) {
    final completed = data['completed'] == true;

    if (completed) {
      return 'Completed';
    }

    final dueDate = _parseDate(data['dueDate']);

    if (dueDate != null) {
      final today = DateTime.now();

      final todayOnly = DateTime(
        today.year,
        today.month,
        today.day,
      );

      final dueOnly = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
      );

      if (dueOnly.isBefore(todayOnly)) {
        return 'Overdue';
      }
    }

    return 'Pending';
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  // ============================================================
  // FILTER
  // ============================================================

  bool _matchesFilter(Map<String, dynamic> data) {
    final status = _getStatus(data);

    if (selectedFilter == 'All') {
      return true;
    }

    return status == selectedFilter;
  }

  bool _matchesSearch(Map<String, dynamic> data) {
    if (searchQuery.trim().isEmpty) {
      return true;
    }

    final query = searchQuery.toLowerCase();

    final subject =
        (data['subject'] ?? '').toString().toLowerCase();

    final title =
        (data['title'] ?? '').toString().toLowerCase();

    final description =
        (data['description'] ?? '').toString().toLowerCase();

    return subject.contains(query) ||
        title.contains(query) ||
        description.contains(query);
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(dynamic value) {
    final date = _parseDate(value);

    if (date == null) {
      return 'No due date';
    }

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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // ============================================================
  // SUBJECT ICON
  // ============================================================

  IconData _subjectIcon(String subject) {
    final value = subject.toLowerCase();

    if (value.contains('math')) {
      return Icons.calculate_rounded;
    }

    if (value.contains('science')) {
      return Icons.science_rounded;
    }

    if (value.contains('english')) {
      return Icons.menu_book_rounded;
    }

    if (value.contains('computer') || value.contains('ict')) {
      return Icons.computer_rounded;
    }

    if (value.contains('islam')) {
      return Icons.auto_stories_rounded;
    }

    if (value.contains('urdu')) {
      return Icons.translate_rounded;
    }

    if (value.contains('social')) {
      return Icons.public_rounded;
    }

    return Icons.assignment_rounded;
  }

  Color _subjectColor(String subject) {
    final value = subject.toLowerCase();

    if (value.contains('math')) {
      return const Color(0xFF6C63FF);
    }

    if (value.contains('science')) {
      return const Color(0xFF00A896);
    }

    if (value.contains('english')) {
      return const Color(0xFF4A90E2);
    }

    if (value.contains('computer') || value.contains('ict')) {
      return const Color(0xFF7B61FF);
    }

    if (value.contains('islam')) {
      return const Color(0xFF43AA8B);
    }

    if (value.contains('urdu')) {
      return const Color(0xFFE76F51);
    }

    return const Color(0xFF5B5FEF);
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return const Color(0xFF20A464);

      case 'Overdue':
        return const Color(0xFFE85D75);

      default:
        return const Color(0xFFFFA62B);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Completed':
        return Icons.check_circle_rounded;

      case 'Overdue':
        return Icons.warning_rounded;

      default:
        return Icons.access_time_filled_rounded;
    }
  }

  // ============================================================
  // GLASS CONTAINER
  // ============================================================

  Widget _glassContainer({
    required Widget child,
    double radius = 22,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    Color color = Colors.white,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color.withOpacity(.78),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withOpacity(.55),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.10),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // ============================================================
  // HOMEWORK DETAILS
  // ============================================================

  void _showHomeworkDetails(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final subject =
        data['subject']?.toString() ?? 'Subject';

    final title =
        data['title']?.toString() ?? 'Homework';

    final description =
        data['description']?.toString() ??
            'No description available.';

    final teacher =
        data['teacherName']?.toString() ?? 'Teacher';

    final status = _getStatus(data);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final color = _subjectColor(subject);

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            22,
            14,
            22,
            30,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: color.withOpacity(.12),
                          borderRadius:
                              BorderRadius.circular(17),
                        ),
                        child: Icon(
                          _subjectIcon(subject),
                          color: color,
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              subject,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: color,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              title,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.w700,
                                color:
                                    const Color(0xFF20244A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  _detailRow(
                    Icons.person_outline_rounded,
                    'Teacher',
                    teacher,
                    color,
                  ),

                  const SizedBox(height: 15),

                  _detailRow(
                    Icons.calendar_month_rounded,
                    'Due Date',
                    _formatDate(data['dueDate']),
                    color,
                  ),

                  const SizedBox(height: 15),

                  _detailRow(
                    _statusIcon(status),
                    'Status',
                    status,
                    _statusColor(status),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    'Homework Details',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF20244A),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FF),
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                    child: Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        height: 1.7,
                        color: const Color(0xFF62677D),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  if (status != 'Completed')
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);

                          _markAsCompleted(
                            data['id']?.toString() ?? '',
                          );
                        },
                        icon: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Mark as Completed',
                          style: GoogleFonts.poppins(
                            fontWeight:
                                FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          elevation: 0,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: color.withOpacity(.10),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: color,
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
                title,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF30344F),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MARK COMPLETED
  // ============================================================

  Future<void> _markAsCompleted(String id) async {
    if (id.isEmpty) return;

    try {
      await _firestore
          .collection('homework')
          .doc(id)
          .update({
        'completed': true,
        'completedAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Homework marked as completed',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              const Color(0xFF20A464),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to update homework',
            style: GoogleFonts.poppins(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // HOMEWORK CARD
  // ============================================================

  Widget _homeworkCard(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final subject =
        data['subject']?.toString() ?? 'Subject';

    final title =
        data['title']?.toString() ?? 'Homework';

    final description =
        data['description']?.toString() ??
            'No description available.';

    final status = _getStatus(data);

    final subjectColor =
        _subjectColor(subject);

    final statusColor =
        _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 10,
          ),
          child: Material(
            color: Colors.white.withOpacity(.78),
            child: InkWell(
              borderRadius:
                  BorderRadius.circular(23),
              onTap: () {
                _showHomeworkDetails(
                  context,
                  {
                    ...data,
                    'id': data['id'],
                  },
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(23),
                  border: Border.all(
                    color:
                        Colors.white.withOpacity(.65),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(.10),
                      blurRadius: 18,
                      offset:
                          const Offset(0, 7),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration:
                              BoxDecoration(
                            gradient:
                                LinearGradient(
                              begin:
                                  Alignment.topLeft,
                              end:
                                  Alignment.bottomRight,
                              colors: [
                                subjectColor
                                    .withOpacity(.18),
                                subjectColor
                                    .withOpacity(.07),
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(
                                    17),
                          ),
                          child: Icon(
                            _subjectIcon(subject),
                            color:
                                subjectColor,
                            size: 26,
                          ),
                        ),

                        const SizedBox(width: 13),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                subject,
                                style:
                                    GoogleFonts.poppins(
                                  fontSize: 12,
                                  color:
                                      subjectColor,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                title,
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style:
                                    GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.w700,
                                  color:
                                      const Color(
                                          0xFF20244A),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 7),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 6,
                          ),
                          decoration:
                              BoxDecoration(
                            color: statusColor
                                .withOpacity(.11),
                            borderRadius:
                                BorderRadius.circular(
                                    30),
                          ),
                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              Icon(
                                _statusIcon(status),
                                color:
                                    statusColor,
                                size: 14,
                              ),
                              const SizedBox(
                                  width: 4),
                              Text(
                                status,
                                style:
                                    GoogleFonts.poppins(
                                  fontSize: 9.5,
                                  fontWeight:
                                      FontWeight.w600,
                                  color:
                                      statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Text(
                      description,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        height: 1.6,
                        color:
                            const Color(0xFF666B80),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Container(
                          width: 29,
                          height: 29,
                          decoration:
                              BoxDecoration(
                            color: Colors.white
                                .withOpacity(.75),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons
                                .calendar_today_rounded,
                            size: 14,
                            color:
                                Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(width: 7),

                        Text(
                          'Due ${_formatDate(data['dueDate'])}',
                          style:
                              GoogleFonts.poppins(
                            fontSize: 11,
                            color:
                                Colors.grey.shade700,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),

                        const Spacer(),

                        Text(
                          'View Details',
                          style:
                              GoogleFonts.poppins(
                            fontSize: 11.5,
                            color:
                                subjectColor,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),

                        const SizedBox(width: 4),

                        Icon(
                          Icons
                              .arrow_forward_ios_rounded,
                          size: 11,
                          color:
                              subjectColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 65,
          left: 30,
          right: 30,
        ),
        child: _glassContainer(
          radius: 28,
          padding: const EdgeInsets.all(30),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6865E7),
                      Color(0xFF8B5CF6),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          const Color(0xFF6865E7)
                              .withOpacity(.25),
                      blurRadius: 25,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.assignment_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 22),

              Text(
                'No Homework Found',
                style: GoogleFonts.poppins(
                  fontSize: 19,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      const Color(0xFF20244A),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'There is no homework available for your child right now.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  height: 1.6,
                  color:
                      const Color(0xFF81869A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FILTER CHIP
  // ============================================================

  Widget _filterChip(String title) {
    final isSelected =
        selectedFilter == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = title;
        });
      },
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 220),
        margin:
            const EdgeInsets.only(right: 8),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color(0xFF6865E7),
                    Color(0xFF8B5CF6),
                  ],
                )
              : null,
          color: isSelected
              ? null
              : Colors.white.withOpacity(.72),
          borderRadius:
              BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withOpacity(.60),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color:
                        const Color(0xFF6865E7)
                            .withOpacity(.25),
                    blurRadius: 10,
                    offset:
                        const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight:
                FontWeight.w600,
            color: isSelected
                ? Colors.white
                : const Color(0xFF60657B),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      body: Stack(
        children: [
          // ------------------------------------------------------
          // FULL SCREEN BACKGROUND IMAGE
          // ------------------------------------------------------

          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) {
                return Container(
                  decoration:
                      const BoxDecoration(
                    gradient:
                        LinearGradient(
                      begin:
                          Alignment.topLeft,
                      end:
                          Alignment.bottomRight,
                      colors: [
                        Color(0xFF312E81),
                        Color(0xFF6366F1),
                        Color(0xFF7C3AED),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ------------------------------------------------------
          // SOFT DARK OVERLAY
          // ------------------------------------------------------

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient:
                    LinearGradient(
                  begin:
                      Alignment.topCenter,
                  end:
                      Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(.32),
                    Colors.black.withOpacity(.12),
                    Colors.black.withOpacity(.30),
                  ],
                ),
              ),
            ),
          ),

          // ------------------------------------------------------
          // MAIN CONTENT
          // ------------------------------------------------------

          SafeArea(
            child: StreamBuilder<
                QuerySnapshot<
                    Map<String, dynamic>>>(
              stream: _homeworkStream(),

              builder:
                  (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                              25),
                      child: _glassContainer(
                        radius: 25,
                        padding:
                            const EdgeInsets.all(
                                25),
                        child: Column(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons
                                  .error_outline_rounded,
                              size: 55,
                              color:
                                  Color(0xFFE85D75),
                            ),

                            const SizedBox(
                                height: 15),

                            Text(
                              'Unable to load homework',
                              textAlign:
                                  TextAlign.center,
                              style:
                                  GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.w600,
                                color:
                                    const Color(
                                        0xFF20244A),
                              ),
                            ),

                            const SizedBox(
                                height: 6),

                            Text(
                              'Please check your internet connection or Firestore setup.',
                              textAlign:
                                  TextAlign.center,
                              style:
                                  GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors
                                    .grey
                                    .shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final documents =
                    snapshot.data?.docs ??
                        [];

                final homeworkList =
                    documents.map((doc) {
                  final data = doc.data();

                  return {
                    ...data,
                    'id': doc.id,
                  };
                }).where((data) {
                  return _matchesFilter(data) &&
                      _matchesSearch(data);
                }).toList();

                homeworkList.sort((a, b) {
                  final dateA =
                      _parseDate(
                          a['dueDate']);

                  final dateB =
                      _parseDate(
                          b['dueDate']);

                  if (dateA == null &&
                      dateB == null) {
                    return 0;
                  }

                  if (dateA == null) {
                    return 1;
                  }

                  if (dateB == null) {
                    return -1;
                  }

                  return dateA.compareTo(
                      dateB);
                });

                return Column(
                  children: [
                    // ==================================================
                    // CUSTOM TRANSPARENT APP BAR
                    // ==================================================

                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(
                        8,
                        4,
                        15,
                        8,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration:
                                BoxDecoration(
                              color: Colors.white
                                  .withOpacity(.18),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(
                                color: Colors
                                    .white
                                    .withOpacity(
                                        .30),
                              ),
                            ),
                            child:
                                IconButton(
                              onPressed: () =>
                                  Navigator.pop(
                                      context),
                              icon: const Icon(
                                Icons
                                    .arrow_back_rounded,
                                color:
                                    Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(
                              width: 13),

                          Expanded(
                            child: Text(
                              'Homework',
                              style:
                                  GoogleFonts.poppins(
                                color:
                                    Colors.white,
                                fontSize: 21,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ),

                          Container(
                            width: 45,
                            height: 45,
                            decoration:
                                BoxDecoration(
                              color: Colors.white
                                  .withOpacity(.18),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(
                                color: Colors
                                    .white
                                    .withOpacity(
                                        .30),
                              ),
                            ),
                            child: const Icon(
                              Icons
                                  .school_rounded,
                              color:
                                  Colors.white,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ==================================================
                    // HEADER
                    // ==================================================

                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(
                        18,
                        8,
                        18,
                        0,
                      ),
                      child: _glassContainer(
                        radius: 25,
                        padding:
                            const EdgeInsets.fromLTRB(
                          18,
                          18,
                          18,
                          18,
                        ),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 43,
                                  height: 43,
                                  decoration:
                                      BoxDecoration(
                                    gradient:
                                        const LinearGradient(
                                      colors: [
                                        Color(
                                            0xFF6865E7),
                                        Color(
                                            0xFF8B5CF6),
                                      ],
                                    ),
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                14),
                                  ),
                                  child: const Icon(
                                    Icons
                                        .auto_stories_rounded,
                                    color:
                                        Colors.white,
                                    size: 23,
                                  ),
                                ),

                                const SizedBox(
                                    width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        'Your Child’s Homework 📚',
                                        style: GoogleFonts
                                            .poppins(
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight
                                                  .w700,
                                          color:
                                              const Color(
                                                  0xFF20244A),
                                        ),
                                      ),

                                      const SizedBox(
                                          height: 3),

                                      Text(
                                        'Stay updated with daily assignments',
                                        style:
                                            GoogleFonts
                                                .poppins(
                                          fontSize:
                                              11.5,
                                          color:
                                              const Color(
                                                  0xFF85899C),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                                height: 16),

                            // SEARCH
                            Container(
                              height: 48,
                              decoration:
                                  BoxDecoration(
                                color: Colors
                                    .white
                                    .withOpacity(
                                        .72),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            15),
                                border:
                                    Border.all(
                                  color: Colors
                                      .white
                                      .withOpacity(
                                          .75),
                                ),
                              ),
                              child:
                                  TextField(
                                onChanged:
                                    (value) {
                                  setState(() {
                                    searchQuery =
                                        value;
                                  });
                                },
                                style:
                                    GoogleFonts
                                        .poppins(
                                  fontSize: 13,
                                  color:
                                      const Color(
                                          0xFF20244A),
                                ),
                                decoration:
                                    InputDecoration(
                                  hintText:
                                      'Search homework...',
                                  hintStyle:
                                      GoogleFonts
                                          .poppins(
                                    fontSize:
                                        12,
                                    color: Colors
                                        .grey
                                        .shade500,
                                  ),
                                  prefixIcon:
                                      const Icon(
                                    Icons
                                        .search_rounded,
                                    color:
                                        Color(
                                            0xFF6865E7),
                                  ),
                                  border:
                                      InputBorder
                                          .none,
                                  contentPadding:
                                      const EdgeInsets
                                          .symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                                height: 14),

                            // FILTERS
                            SingleChildScrollView(
                              scrollDirection:
                                  Axis.horizontal,
                              child: Row(
                                children: [
                                  _filterChip(
                                      'All'),
                                  _filterChip(
                                      'Pending'),
                                  _filterChip(
                                      'Completed'),
                                  _filterChip(
                                      'Overdue'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ==================================================
                    // HOMEWORK LIST
                    // ==================================================

                    Expanded(
                      child:
                          homeworkList.isEmpty
                              ? _emptyState()
                              : ListView
                                  .builder(
                                  padding:
                                      const EdgeInsets
                                          .fromLTRB(
                                    18,
                                    20,
                                    18,
                                    30,
                                  ),
                                  itemCount:
                                      homeworkList
                                          .length,
                                  itemBuilder:
                                      (context,
                                          index) {
                                    return _homeworkCard(
                                      context,
                                      homeworkList[
                                          index],
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
    );
  }
}