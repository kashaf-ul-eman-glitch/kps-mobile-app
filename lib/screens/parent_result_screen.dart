import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ================================================================
// PARENT RESULT & CLASS POSITION SCREEN
// ================================================================
//
// Background:
//   assets/images/school.jpg
//
// Firestore:
//
// classes/{className}/subjects/{subjectId}
//   - active
//
// classes/{className}/students/{studentId}/subjectRecords/{subjectId}
//   - marks: { 'Final Term': '78', ... }
//
// Class position is calculated using Final Term marks.
// ================================================================

class ParentResultScreen extends StatefulWidget {
  final String studentId;
  final String className;

  const ParentResultScreen({
    super.key,
    required this.studentId,
    required this.className,
  });

  @override
  State<ParentResultScreen> createState() => _ParentResultScreenState();
}

class _ParentResultScreenState extends State<ParentResultScreen> {
  bool _loading = true;
  String? _error;

  double _obtained = 0;
  double _total = 0;
  int _position = 0;
  int _classSize = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  double _parseMark(String? raw) {
    if (raw == null) return -1;

    final double? value = double.tryParse(raw.trim());

    return value ?? -1;
  }

  Future<Map<String, double>> _calculateStudentResult({
    required String studentId,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> subjectDocs,
  }) async {
    double obtained = 0;
    double total = 0;

    for (final subjectDoc in subjectDocs) {
      final DocumentSnapshot<Map<String, dynamic>> recordSnap =
          await FirebaseFirestore.instance
              .collection('classes')
              .doc(widget.className)
              .collection('students')
              .doc(studentId)
              .collection('subjectRecords')
              .doc(subjectDoc.id)
              .get();

      if (recordSnap.exists) {
        final Map? marks = recordSnap.data()?['marks'] as Map?;

        final String? finalTerm =
            marks?['Final Term']?.toString();

        final double value = _parseMark(finalTerm);

        if (value >= 0) {
          obtained += value;
          total += 100;
        }
      }
    }

    return {
      'obtained': obtained,
      'total': total,
    };
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final QuerySnapshot<Map<String, dynamic>> subjectsSnap =
          await FirebaseFirestore.instance
              .collection('classes')
              .doc(widget.className)
              .collection('subjects')
              .get();

      final activeSubjects = subjectsSnap.docs
          .where(
            (doc) => doc.data()['active'] != false,
          )
          .toList();

      final myResult = await _calculateStudentResult(
        studentId: widget.studentId,
        subjectDocs: activeSubjects,
      );

      final QuerySnapshot<Map<String, dynamic>> studentsSnap =
          await FirebaseFirestore.instance
              .collection('classes')
              .doc(widget.className)
              .collection('students')
              .get();

      final List<Map<String, dynamic>> allResults = [];

      for (final studentDoc in studentsSnap.docs) {
        final result = await _calculateStudentResult(
          studentId: studentDoc.id,
          subjectDocs: activeSubjects,
        );

        allResults.add({
          'studentId': studentDoc.id,
          'obtained': result['obtained'] ?? 0,
        });
      }

      allResults.sort(
        (a, b) => (b['obtained'] as double)
            .compareTo(a['obtained'] as double),
      );

      final int position =
          allResults.indexWhere(
                (r) => r['studentId'] == widget.studentId,
              ) +
              1;

      if (!mounted) return;

      setState(() {
        _obtained = myResult['obtained'] ?? 0;
        _total = myResult['total'] ?? 0;
        _position = position;
        _classSize = allResults.length;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Could not calculate result.\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double percentage =
        _total > 0 ? (_obtained / _total * 100) : 0;

    return Scaffold(
      body: Stack(
        children: [
          // ========================================================
          // BACKGROUND IMAGE
          // ========================================================
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // ========================================================
          // DARK OVERLAY
          // ========================================================
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.78),
                    const Color(0xFF171344)
                        .withValues(alpha: 0.82),
                    const Color(0xFF312E81)
                        .withValues(alpha: 0.78),
                    Colors.black.withValues(alpha: 0.82),
                  ],
                ),
              ),
            ),
          ),

          // ========================================================
          // MAIN CONTENT
          // ========================================================
          SafeArea(
            child: Column(
              children: [
                _topBar(
                  context,
                  'Result & Class Position',
                ),

                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : _error != null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Container(
                                  padding: const EdgeInsets.all(22),
                                  decoration: BoxDecoration(
                                    color: Colors.black
                                        .withValues(alpha: 0.35),
                                    borderRadius:
                                        BorderRadius.circular(22),
                                    border: Border.all(
                                      color: Colors.white
                                          .withValues(alpha: 0.15),
                                    ),
                                  ),
                                  child: Text(
                                    _error!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              color: const Color(0xFF4F46E5),
                              onRefresh: _load,
                              child: ListView(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  14,
                                  20,
                                  30,
                                ),
                                children: [
                                  // ==================================================
                                  // CLASS POSITION CARD
                                  // ==================================================
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 28,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withValues(alpha: 0.13),
                                      borderRadius:
                                          BorderRadius.circular(26),
                                      border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.22),
                                        width: 1.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.25),
                                          blurRadius: 25,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        // Trophy circle
                                        Container(
                                          height: 78,
                                          width: 78,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.amber
                                                .withValues(alpha: 0.15),
                                            border: Border.all(
                                              color: Colors.amber
                                                  .withValues(alpha: 0.55),
                                              width: 1.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.amber
                                                    .withValues(alpha: 0.18),
                                                blurRadius: 20,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.emoji_events,
                                            color: Colors.amber,
                                            size: 42,
                                          ),
                                        ),

                                        const SizedBox(height: 16),

                                        Text(
                                          _position > 0
                                              ? '$_position of $_classSize'
                                              : 'Not available',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),

                                        const SizedBox(height: 2),

                                        Text(
                                          'Class Position',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white70,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),

                                        const SizedBox(height: 18),

                                        Container(
                                          height: 1,
                                          width: 100,
                                          color: Colors.white
                                              .withValues(alpha: 0.15),
                                        ),

                                        const SizedBox(height: 12),

                                        Text(
                                          'Final Term Performance',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white60,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                  // ==================================================
                                  // RESULT HEADER
                                  // ==================================================
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 4,
                                      bottom: 10,
                                    ),
                                    child: Text(
                                      'Result Summary',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                  // ==================================================
                                  // TOTAL OBTAINED
                                  // ==================================================
                                  _resultRow(
                                    Icons.assessment_outlined,
                                    'Total Obtained',
                                    '${_obtained.toStringAsFixed(0)} / ${_total.toStringAsFixed(0)}',
                                  ),

                                  // ==================================================
                                  // PERCENTAGE
                                  // ==================================================
                                  _resultRow(
                                    Icons.percent,
                                    'Percentage',
                                    '${percentage.toStringAsFixed(1)}%',
                                  ),

                                  const SizedBox(height: 8),

                                  // ==================================================
                                  // INFORMATION CARD
                                  // ==================================================
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withValues(alpha: 0.08),
                                      borderRadius:
                                          BorderRadius.circular(18),
                                      border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.12),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding:
                                              const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.10),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.info_outline,
                                            color: Colors.white70,
                                            size: 18,
                                          ),
                                        ),

                                        const SizedBox(width: 12),

                                        Expanded(
                                          child: Text(
                                            'Position is calculated from Final Term marks entered in Firestore.',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white60,
                                              fontSize: 10.5,
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // RESULT ROW
  // ================================================================

  Widget _resultRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.13),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: Colors.white70,
              size: 21,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.amberAccent,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // TOP BAR
  // ================================================================

  Widget _topBar(
    BuildContext context,
    String title,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.20),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),

          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(width: 48),
        ],
      ),
    );
  }
}