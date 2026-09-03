import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Teacher-side screen to leave a subject remark on a student.
///
/// Writes to: classes/{className}/students/{studentId}/teacherReviews/{autoId}
///   - teacherName
///   - teacherId
///   - subject
///   - comment
///   - rating
///   - createdAt
///
/// This is the exact path & field set that ParentTeacherReviewScreen reads
/// under "Subject Teacher Reviews" — nothing on the parent side changes.
class TeacherRemarksScreen extends StatefulWidget {
  const TeacherRemarksScreen({super.key});

  @override
  State<TeacherRemarksScreen> createState() => _TeacherRemarksScreenState();
}

class _TeacherRemarksScreenState extends State<TeacherRemarksScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _remarkController = TextEditingController();

  // Each entry: {id, name, className, ref} where ref is the actual
  // DocumentReference at classes/{className}/students/{studentId} —
  // that reference is what we write the review under.
  List<Map<String, dynamic>> _studentsList = [];

  String? _selectedStudentId;
  String? _selectedStudentName;
  DocumentReference<Map<String, dynamic>>? _selectedStudentRef;

  String _selectedSubject = 'Mathematics';
  int _rating = 5;

  final List<String> subjects = ['Mathematics', 'Science', 'Computer Science', 'English', 'Pak Study', 'English', 'Urdu', 'Islamiat', 'M.Q','Biology', 'Physics', 'Chemistry'];

  // Filled in from the 'teachers' collection so parents see a real name.
  String _teacherName = 'Teacher';

  bool _isLoadingStudents = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
    _loadTeacherName();
  }

  Future<void> _loadTeacherName() async {
    try {
      final String? email = _auth.currentUser?.email?.trim().toLowerCase();
      if (email == null || email.isEmpty) return;
      final snap = await _firestore.collection('teachers').where('email', isEqualTo: email).limit(1).get();
      if (snap.docs.isEmpty || !mounted) return;
      final data = snap.docs.first.data();
      final String name = (data['fullName'] ?? data['name'] ?? '').toString().trim();
      if (name.isNotEmpty) setState(() => _teacherName = name);
    } catch (_) {
      // Non-critical — falls back to 'Teacher' if this lookup fails.
    }
  }

  Future<void> _fetchStudents() async {
    try {
      // Students live nested at classes/{className}/students/{studentId}
      // (same structure the Admission Form writes to and the parent
      // review screen reads from). A collectionGroup query reaches every
      // student across every class in one call without needing the
      // teacher to pick a class first.
      final snapshot = await _firestore.collectionGroup('students').get();

      if (snapshot.docs.isNotEmpty) {
        final loaded = snapshot.docs.map((doc) {
          final data = doc.data();
          final String className = (data['class'] ?? doc.reference.parent.parent?.id ?? 'Unknown Class').toString();
          final String name = (data['studentName'] ?? data['name'] ?? 'Student').toString();
          return {
            'id': doc.id,
            'name': name,
            'className': className,
            'ref': doc.reference,
          };
        }).toList();

        loaded.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));

        if (!mounted) return;
        setState(() {
          _studentsList = loaded;
          _selectedStudentId = loaded.first['id'] as String;
          _selectedStudentName = loaded.first['name'] as String;
          _selectedStudentRef = loaded.first['ref'] as DocumentReference<Map<String, dynamic>>;
        });
      }
    } catch (e) {
      debugPrint('Error fetching students: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingStudents = false);
      }
    }
  }

  InputDecoration _customInputDecoration(
    String label, {
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        color: Colors.white60,
        fontSize: 13,
      ),
      labelStyle: GoogleFonts.poppins(
        color: Colors.white70,
        fontSize: 13,
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.white70,
        ),
      ),
    );
  }

  Future<void> _submitRemark() async {
    final String comment = _remarkController.text.trim();

    if (comment.isEmpty || _selectedStudentRef == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a student and enter a remark'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final String teacherUid = _auth.currentUser?.uid ?? '';

      // Written straight into the student's teacherReviews subcollection —
      // this is what makes it show up on the parent's review screen.
      await _selectedStudentRef!.collection('teacherReviews').add({
        'teacherName': _teacherName,
        'teacherId': teacherUid,
        'subject': _selectedSubject,
        'comment': comment,
        'rating': _rating,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _remarkController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Teacher remark submitted successfully!'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit teacher remark: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _ratingPicker() {
    return Row(
      children: [
        Text('Rating:', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
        const SizedBox(width: 10),
        Row(
          children: List.generate(5, (index) {
            final int starValue = index + 1;
            return IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
              onPressed: () => setState(() => _rating = starValue),
              icon: Icon(
                starValue <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                color: Colors.amber.shade300,
                size: 26,
              ),
            );
          }),
        ),
      ],
    );
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
          filter: ImageFilter.blur(
            sigmaX: 5,
            sigmaY: 5,
          ),
          child: Container(
            color: Colors.black.withValues(alpha: 0.25),
            child: SafeArea(
              child: Column(
                children: [
                  const _TopBar(),

                  Expanded(
                    child: _isLoadingStudents
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_studentsList.isNotEmpty)
                                  DropdownButtonFormField<String>(
                                    value: _selectedStudentId,
                                    dropdownColor: Colors.brown[300],
                                    isExpanded: true,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                    decoration:
                                        _customInputDecoration(
                                      'Select Student',
                                    ),
                                    items: _studentsList
                                        .map(
                                          (student) =>
                                              DropdownMenuItem<String>(
                                            value: student['id'] as String,
                                            child: Text(
                                              '${student['name']} (${student['className']})',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      if (value == null) return;
                                      final match = _studentsList.firstWhere(
                                        (student) => student['id'] == value,
                                      );
                                      setState(() {
                                        _selectedStudentId = value;
                                        _selectedStudentName = match['name'] as String;
                                        _selectedStudentRef =
                                            match['ref'] as DocumentReference<Map<String, dynamic>>;
                                      });
                                    },
                                  )
                                else
                                  Text(
                                    'No students available.',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                    ),
                                  ),

                                const SizedBox(height: 16),

                                DropdownButtonFormField<String>(
                                  value: _selectedSubject,
                                  dropdownColor: Colors.brown[300],
                                  isExpanded: true,
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                                  decoration: _customInputDecoration('Subject'),
                                  items: subjects
                                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                      .toList(),
                                  onChanged: (val) => setState(() => _selectedSubject = val!),
                                ),

                                const SizedBox(height: 16),

                                _ratingPicker(),

                                const SizedBox(height: 16),

                                TextField(
                                  controller: _remarkController,
                                  maxLines: 6,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                  decoration: _customInputDecoration(
                                    'Teacher Remark',
                                    hint:
                                        'Write your remark about the student...',
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed:
                            _isSubmitting ? null : _submitRemark,
                        child: _isSubmitting
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Submit Remark',
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

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
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
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          Text(
            'Teacher Remarks',
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