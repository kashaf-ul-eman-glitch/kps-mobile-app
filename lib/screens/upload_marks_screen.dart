import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UploadMarksScreen extends StatefulWidget {
  const UploadMarksScreen({super.key});

  @override
  State<UploadMarksScreen> createState() => _UploadMarksScreenState();
}

class _UploadMarksScreenState extends State<UploadMarksScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String selectedClass = 'Grade 5';
  String selectedSubject = 'Mathematics';

  // Map to hold student marks: {studentId: markValue}
  final Map<String, String> _marksData = {};
  bool _isSaving = false;

  // ==============================================================
  // VALIDATE MARKS
  //
  // Ensures every entered mark is a real number between 0 and 100
  // before anything is written to Firestore. Bad values here would
  // silently break the parent-side total/percentage/position
  // calculations later, so we catch them at the source instead.
  // ==============================================================
  String? _validateMarks() {
    for (final entry in _marksData.entries) {
      final String raw = entry.value.trim();

      if (raw.isEmpty) {
        continue;
      }

      final double? value = double.tryParse(raw);

      if (value == null) {
        return 'Marks must be numbers only (found "$raw").';
      }

      if (value < 0 || value > 100) {
        return 'Marks must be between 0 and 100 (found "$raw").';
      }
    }

    return null;
  }

  Future<void> _saveMarksToFirebase() async {
    if (_marksData.isEmpty ||
        _marksData.values.every((v) => v.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter marks before submitting.'),
        ),
      );
      return;
    }

    final String? validationError = _validateMarks();

    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final String teacherUid = _auth.currentUser?.uid ?? '';

      // ============================================================
      // FIND THE SUBJECT DOCUMENT USED BY PARENT RESULT SCREEN
      // Parent screen reads:
      // classes/{className}/subjects/{subjectId}
      // ============================================================

      final QuerySnapshot<Map<String, dynamic>> subjectsSnap =
          await _firestore
              .collection('classes')
              .doc(selectedClass)
              .collection('subjects')
              .get();

      String? subjectId;

      for (final subjectDoc in subjectsSnap.docs) {
        final data = subjectDoc.data();

        final String docId = subjectDoc.id;

        final String? name = data['name']?.toString();
        final String? subjectName = data['subjectName']?.toString();
        final String? title = data['title']?.toString();
        final String? subject = data['subject']?.toString();

        if (docId == selectedSubject ||
            name == selectedSubject ||
            subjectName == selectedSubject ||
            title == selectedSubject ||
            subject == selectedSubject) {
          subjectId = docId;
          break;
        }
      }

      if (subjectId == null) {
        throw Exception(
          'Subject "$selectedSubject" was not found in '
          'classes/$selectedClass/subjects.',
        );
      }

      // ============================================================
      // SAVE EACH STUDENT'S FINAL TERM MARKS
      //
      // Parent Result Screen reads:
      //
      // classes/{className}/students/{studentId}/subjectRecords/{subjectId}
      //
      // and inside that document:
      // marks: {
      //   "Final Term": "78"
      // }
      // ============================================================

      final WriteBatch batch = _firestore.batch();

      for (final entry in _marksData.entries) {
        final String studentId = entry.key;
        final String mark = entry.value.trim();

        if (mark.isEmpty) {
          continue;
        }

        final DocumentReference<Map<String, dynamic>> recordRef =
            _firestore
                .collection('classes')
                .doc(selectedClass)
                .collection('students')
                .doc(studentId)
                .collection('subjectRecords')
                .doc(subjectId);

        batch.set(
          recordRef,
          {
            'marks': {
              'Final Term': mark,
            },
            'subjectId': subjectId,
            'subject': selectedSubject,
            'class': selectedClass,
            'teacherId': teacherUid,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      await batch.commit();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marks uploaded successfully!'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload marks: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown.shade800,
        elevation: 4,
        title: Text(
          'Upload Marks',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.black.withValues(alpha: 0.25),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // Class & Subject Selectors
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.brown.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: selectedClass,
                                    isExpanded: true,
                                    dropdownColor: Colors.brown.shade900,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Class',
                                      labelStyle: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.white30,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                    ),
                                    items: [
                                      'Play Group',
                                      'Reception 1',
                                      'Reception 2',
                                      'Grade 1',
                                       'Grade 2',
                                        'Grade 3',
                                         'Grade 4',
                                       'Grade 5',
                                        'Grade 6',
                                        'Grade 7',
                                       'Grade 8',
                                       'Grade 9',
                                       'Grade 10',
                                      'Grade 11',
                                     'Grade 12',

                                    ]
                                        .map(
                                          (c) => DropdownMenuItem(
                                            value: c,
                                            child: Text(
                                              c,
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          selectedClass = value;
                                          _marksData.clear();
                                        });
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: selectedSubject,
                                    isExpanded: true,
                                    dropdownColor: Colors.brown.shade900,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Subject',
                                      labelStyle: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.white30,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                    ),
                                    items: [
                                      'Mathematics',
                                      'Computer Science',
                                      'Physics',
                                      'Science',
                                      'Pak Study',
                                      'English',
                                      'Urdu',
                                      'Islamiat',
                                      'M.Q',
                                      'Biology',
                                      'Physics',
                                      'Chemistry'
                                    ]
                                        .map(
                                          (subject) => DropdownMenuItem(
                                            value: subject,
                                            child: Text(
                                              subject,
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          selectedSubject = value;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Real-time Student List for Marks Input
                          StreamBuilder<QuerySnapshot>(
                            stream: _firestore
                                .collection('students')
                                .where(
                                  'class',
                                  isEqualTo: selectedClass,
                                )
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator(
                                  color: Colors.white,
                                );
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No students found for $selectedClass',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                    ),
                                  ),
                                );
                              }

                              final studentDocs = snapshot.data!.docs;

                              return ListView.builder(
                                shrinkWrap: true,
                                physics:
                                    const NeverScrollableScrollPhysics(),
                                itemCount: studentDocs.length,
                                itemBuilder: (context, index) {
                                  final doc = studentDocs[index];

                                  final student =
                                      doc.data() as Map<String, dynamic>;

                                  final studentId = doc.id;

                                  return _buildStudentMarkTile(
                                    studentId: studentId,
                                    name: student['name'] ?? 'Unknown',
                                    rollNo: student['rollNo']?.toString() ??
                                        'N/A',
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Submit Button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed:
                            _isSaving ? null : _saveMarksToFirebase,
                        child: _isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Save & Upload Marks',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
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

  Widget _buildStudentMarkTile({
    required String studentId,
    required String name,
    required String rollNo,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'Roll No: $rollNo',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: TextField(
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(
                color: Colors.white,
              ),
              onChanged: (val) {
                _marksData[studentId] = val.trim();
              },
              decoration: InputDecoration(
                hintText: 'Marks',
                hintStyle: const TextStyle(
                  color: Colors.white54,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.white30,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}