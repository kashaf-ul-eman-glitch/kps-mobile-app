import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewStudentsScreen extends StatefulWidget {
  const ViewStudentsScreen({super.key});

  @override
  State<ViewStudentsScreen> createState() => _ViewStudentsScreenState();
}

class _ViewStudentsScreenState extends State<ViewStudentsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _assignedClass = 'Grade 5';
  bool _isLoadingClass = true;

  @override
  void initState() {
    super.initState();
    _fetchTeacherAssignedClass();
  }

  // ================================================================
  // GET TEACHER'S ASSIGNED CLASS
  // ================================================================

  Future<void> _fetchTeacherAssignedClass() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      try {
        final DocumentSnapshot<Map<String, dynamic>> userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists && userDoc.data() != null) {
          final Map<String, dynamic> data = userDoc.data()!;

          // Teacher data may contain assignedClasses as a List
          if (data['assignedClasses'] is List &&
              (data['assignedClasses'] as List).isNotEmpty) {
            final List assignedClasses =
                data['assignedClasses'] as List;

            setState(() {
              _assignedClass = assignedClasses.first.toString();
            });
          }

          // Fallback if teacher has a single assignedClass field
          else if (data['assignedClass'] != null &&
              data['assignedClass'].toString().trim().isNotEmpty) {
            setState(() {
              _assignedClass = data['assignedClass'].toString();
            });
          }
        }
      } catch (e) {
        debugPrint('Error fetching teacher class: $e');
      }
    }

    if (mounted) {
      setState(() {
        _isLoadingClass = false;
      });
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
          filter: ImageFilter.blur(
            sigmaX: 5,
            sigmaY: 5,
          ),
          child: Container(
            color: Colors.black.withValues(alpha: 0.25),
            child: SafeArea(
              child: Column(
                children: [
                  _TopBar(
                    className: _assignedClass,
                  ),

                  Expanded(
                    child: _isLoadingClass
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : StreamBuilder<
                            QuerySnapshot<Map<String, dynamic>>
                          >(
                            // ==================================================
                            // IMPORTANT:
                            //
                            // Admission Form saves students here:
                            //
                            // classes
                            //   └── Grade 5
                            //       └── students
                            //
                            // So we read the SAME path here.
                            // ==================================================

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
                                    color: Colors.white,
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                debugPrint(
                                  'Error fetching students: ${snapshot.error}',
                                );

                                return Center(
                                  child: Text(
                                    'Error fetching students',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No students found for $_assignedClass',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                    ),
                                  ),
                                );
                              }

                              final List<
                                  QueryDocumentSnapshot<
                                      Map<String, dynamic>>> studentDocs =
                                  snapshot.data!.docs;

                              return ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: studentDocs.length,

                                itemBuilder: (context, index) {
                                  final Map<String, dynamic> s =
                                      studentDocs[index].data();

                                  return Container(
                                    margin: const EdgeInsets.only(
                                      bottom: 12,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // ==================================================
                                        // ROLL NUMBER
                                        // ==================================================

                                        CircleAvatar(
                                          backgroundColor:
                                              Colors.white.withValues(
                                            alpha: 0.25,
                                          ),
                                          child: Text(
                                            s['rollNo']?.toString() ??
                                                'N/A',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 14),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // ==================================================
                                              // STUDENT NAME
                                              // Admission Form uses:
                                              // studentName
                                              // ==================================================

                                              Text(
                                                s['studentName']
                                                        ?.toString() ??
                                                    'Unknown',
                                                style:
                                                    GoogleFonts.poppins(
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),

                                              const SizedBox(height: 4),

                                              // ==================================================
                                              // ADMISSION NUMBER
                                              // ==================================================

                                              Text(
                                                'Admission No: ${s['admissionNo'] ?? 'N/A'}',
                                                style:
                                                    GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Colors.white70,
                                                ),
                                              ),

                                              // ==================================================
                                              // PARENT
                                              //
                                              // Admission Form has fatherName,
                                              // so show father's name here.
                                              // ==================================================

                                              Text(
                                                'Parent: ${s['fatherName'] ?? 'N/A'}',
                                                style:
                                                    GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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
}

// =====================================================================
// TOP BAR
// =====================================================================

class _TopBar extends StatelessWidget {
  final String className;

  const _TopBar({
    required this.className,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        12,
        4,
        20,
        0,
      ),
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
            'Students - $className',
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