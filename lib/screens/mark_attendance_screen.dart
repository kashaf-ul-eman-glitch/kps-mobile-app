import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _assignedClass = 'Grade 5';
  bool _isLoadingClass = true;
  bool _isSaving = false;

  // Stores attendance state: {studentDocId: true/false}
  final Map<String, bool> _attendanceState = {};
  final DateTime today = DateTime.now();

  // Latest roster from the live stream below, kept here so the Submit
  // button (which lives outside the StreamBuilder) always has access
  // to exactly the students currently on screen.
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _currentStudentDocs = [];

  @override
  void initState() {
    super.initState();
    _fetchTeacherAssignedClass();
  }

  // ==================================================================
  // GET TEACHER'S ASSIGNED CLASS
  //
  // Same lookup ViewStudentsScreen uses, so both screens always agree
  // on which class this teacher is looking at:
  //   users/{uid} -> assignedClasses (List) or assignedClass (String)
  // ==================================================================
  Future<void> _fetchTeacherAssignedClass() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      try {
        final DocumentSnapshot<Map<String, dynamic>> userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists && userDoc.data() != null) {
          final Map<String, dynamic> data = userDoc.data()!;

          if (data['assignedClasses'] is List &&
              (data['assignedClasses'] as List).isNotEmpty) {
            setState(() {
              _assignedClass =
                  (data['assignedClasses'] as List).first.toString();
            });
          } else if (data['assignedClass'] != null &&
              data['assignedClass'].toString().trim().isNotEmpty) {
            setState(() {
              _assignedClass = data['assignedClass'].toString();
            });
          }
        }
      } catch (e) {
        debugPrint('Error fetching class: $e');
      }
    }

    if (mounted) {
      setState(() {
        _isLoadingClass = false;
      });
    }
  }

  // Zero-padded "yyyy-MM-dd" so this always matches what
  // ParentAttendanceScreen expects (it runs DateTime.parse(docId) on
  // the document ID, which requires zero-padded month/day).
  String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ==================================================================
  // SUBMIT ATTENDANCE
  //
  // Writes to the same path Admission Form / ViewStudentsScreen /
  // ParentAttendanceScreen already agree on:
  //   classes/{className}/students/{studentId}/attendance/{yyyy-MM-dd}
  //
  // One doc per student per day, written together as a single batch
  // so it's all-or-nothing (either every student's mark saves, or
  // none do, instead of a partially-submitted class).
  // ==================================================================
  Future<void> _submitAttendance() async {
    if (_currentStudentDocs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No student records found to submit.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final String dateKey = _dateKey(today);
      final String teacherUid = _auth.currentUser?.uid ?? '';

      final WriteBatch batch = _firestore.batch();

      for (final doc in _currentStudentDocs) {
        final String studentId = doc.id;
        final Map<String, dynamic> s = doc.data();
        final bool isPresent = _attendanceState[studentId] ?? true;

        final DocumentReference<Map<String, dynamic>> attendanceRef =
            _firestore
                .collection('classes')
                .doc(_assignedClass)
                .collection('students')
                .doc(studentId)
                .collection('attendance')
                .doc(dateKey);

        batch.set(attendanceRef, {
          'status': isPresent ? 'Present' : 'Absent',
          'markedAt': FieldValue.serverTimestamp(),
          'markedBy': teacherUid,
          // Plain "date" field alongside the doc ID — collection-group
          // queries (used by the admin Attendance screen) can't filter
          // by document ID across different subcollections, so this
          // gives admin a normal field to query on instead.
          'date': dateKey,
          // Denormalized so the admin Attendance screen can list
          // records straight from a collectionGroup query, without an
          // extra read per student.
          'studentName': s['studentName']?.toString() ?? 'Unknown',
          'rollNo': s['rollNo']?.toString() ?? '',
          'className': _assignedClass,
        });
      }

      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance submitted successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit attendance: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
            image: AssetImage('assets/images/background.jpg'),
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
                  const _TopBar(),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      '$_assignedClass  •  ${today.day}/${today.month}/${today.year}',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: _isLoadingClass
                        ? const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white))
                        : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            // Same path Admission Form / ViewStudentsScreen
                            // already use: classes/{className}/students
                            stream: _firestore
                                .collection('classes')
                                .doc(_assignedClass)
                                .collection('students')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.white));
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                _currentStudentDocs = [];
                                return Center(
                                  child: Text(
                                    'No students found for $_assignedClass',
                                    style:
                                        GoogleFonts.poppins(color: Colors.white70),
                                  ),
                                );
                              }

                              final docs = snapshot.data!.docs;
                              _currentStudentDocs = docs;

                              return ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: docs.length,
                                itemBuilder: (context, index) {
                                  final doc = docs[index];
                                  final s = doc.data();
                                  final studentId = doc.id;

                                  // Initialize present status to true by default
                                  _attendanceState.putIfAbsent(studentId, () => true);
                                  final bool isPresent =
                                      _attendanceState[studentId] ?? true;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.2)),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor:
                                              Colors.white.withValues(alpha: 0.25),
                                          child: Text(
                                            s['rollNo']?.toString() ?? 'N/A',
                                            style: GoogleFonts.poppins(
                                                color: Colors.white, fontSize: 13),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Text(
                                            s['studentName']?.toString() ?? 'Unknown',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        ToggleButtons(
                                          borderRadius: BorderRadius.circular(8),
                                          borderColor:
                                              Colors.white.withValues(alpha: 0.3),
                                          selectedBorderColor:
                                              Colors.white.withValues(alpha: 0.3),
                                          isSelected: [isPresent, !isPresent],
                                          selectedColor: Colors.white,
                                          color: Colors.white70,
                                          fillColor: isPresent
                                              ? Colors.green.withValues(alpha: 0.6)
                                              : Colors.red.withValues(alpha: 0.6),
                                          onPressed: (i) {
                                            setState(() {
                                              _attendanceState[studentId] = (i == 0);
                                            });
                                          },
                                          children: const [
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 12),
                                              child: Text('P'),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 12),
                                              child: Text('A'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _isSaving ? null : _submitAttendance,
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Submit Attendance',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
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

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Text(
            'Mark Attendance',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}