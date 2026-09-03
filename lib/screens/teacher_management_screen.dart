import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'add_teacher_screen.dart';

class TeacherManagementScreen extends StatefulWidget {
  const TeacherManagementScreen({super.key});

  @override
  State<TeacherManagementScreen> createState() =>
      _TeacherManagementScreenState();
}

class _TeacherManagementScreenState
    extends State<TeacherManagementScreen> {
  final TextEditingController searchController =
      TextEditingController();

  String searchText = '';
  String? expandedTeacherId;

  final CollectionReference teachersCollection =
      FirebaseFirestore.instance.collection('teachers');

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // ADD TEACHER
  // ============================================================

  Future<void> _addTeacher() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTeacherScreen(),
      ),
    );
  }

  // ============================================================
  // EDIT TEACHER
  // ============================================================

  Future<void> _editTeacher(
    String teacherId,
    Map<String, dynamic> teacher,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTeacherScreen(
          teacherId: teacherId,
          existingTeacher: teacher,
        ),
      ),
    );
  }

  // ============================================================
  // DELETE TEACHER
  // ============================================================

  Future<void> _deleteTeacher(
    String teacherId,
    String teacherName,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Delete Teacher?',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete $teacherName?\n\n'
            'The teacher profile will be removed from Teacher Management.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.brown,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await teachersCollection.doc(teacherId).delete();

      if (!mounted) return;

      setState(() {
        if (expandedTeacherId == teacherId) {
          expandedTeacherId = null;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Teacher deleted successfully.'),
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete teacher: ${e.message}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete teacher: $e',
          ),
        ),
      );
    }
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
                  // ==================================================
                  // TOP BAR
                  // ==================================================

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
                            'Teacher Management',
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

                  // ==================================================
                  // SEARCH
                  // ==================================================

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      5,
                      20,
                      15,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.15,
                        ),
                        borderRadius:
                            BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white24,
                        ),
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            searchText = value;
                          });
                        },
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Search teachers...',
                          hintStyle:
                              GoogleFonts.poppins(
                            color: Colors.white60,
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.white70,
                          ),
                          suffixIcon:
                              searchText.isNotEmpty
                                  ? IconButton(
                                      onPressed: () {
                                        searchController
                                            .clear();

                                        setState(() {
                                          searchText = '';
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.clear,
                                        color:
                                            Colors.white70,
                                      ),
                                    )
                                  : null,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ==================================================
                  // TEACHER LIST
                  // ==================================================

                  Expanded(
                    child:
                        StreamBuilder<QuerySnapshot>(
                      stream: teachersCollection
                          .orderBy(
                            'createdAt',
                            descending: true,
                          )
                          .snapshots(),
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
                                  const EdgeInsets.all(20),
                              child: Text(
                                'Error loading teachers:\n'
                                '${snapshot.error}',
                                textAlign:
                                    TextAlign.center,
                                style:
                                    GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        }

                        if (!snapshot.hasData ||
                            snapshot
                                .data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              'No teachers added yet',
                              style:
                                  GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        final teachers =
                            snapshot.data!.docs
                                .map((doc) {
                          final data =
                              doc.data()
                                  as Map<String,
                                      dynamic>;

                          return {
                            'id': doc.id,
                            'fullName':
                                data['fullName'] ?? '',
                            'employeeId':
                                data['employeeId'] ?? '',
                            'email':
                                data['email'] ?? '',
                            'phone':
                                data['phone'] ?? '',
                            'gender':
                                data['gender'] ?? '',
                            'qualification':
                                data['qualification'] ??
                                    '',
                            'subject':
                                data['subject'] ?? '',
                            'className':
                                data['className'] ?? '',
                            'role':
                                data['role'] ?? '',
                          };
                        }).toList();

                        // ===============================
                        // SEARCH
                        // ===============================

                        final search =
                            searchText
                                .trim()
                                .toLowerCase();

                        final filteredTeachers =
                            teachers.where((teacher) {
                          final name =
                              teacher['fullName']
                                  .toString()
                                  .toLowerCase();

                          final subject =
                              teacher['subject']
                                  .toString()
                                  .toLowerCase();

                          final className =
                              teacher['className']
                                  .toString()
                                  .toLowerCase();

                          final employeeId =
                              teacher['employeeId']
                                  .toString()
                                  .toLowerCase();

                          final email =
                              teacher['email']
                                  .toString()
                                  .toLowerCase();

                          return name.contains(search) ||
                              subject.contains(search) ||
                              className.contains(search) ||
                              employeeId.contains(search) ||
                              email.contains(search);
                        }).toList();

                        if (filteredTeachers.isEmpty) {
                          return Center(
                            child: Text(
                              'No teachers found',
                              style:
                                  GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(
                            20,
                            0,
                            20,
                            25,
                          ),
                          itemCount:
                              filteredTeachers.length,
                          itemBuilder:
                              (context, index) {
                            final teacher =
                                filteredTeachers[index];

                            return _teacherCard(
                              teacher: teacher,
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

      // ==========================================================
      // ADD TEACHER BUTTON
      // ==========================================================

      floatingActionButton:
          FloatingActionButton(
        onPressed: _addTeacher,
        backgroundColor: Colors.brown,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  // ============================================================
  // TEACHER CARD
  // ============================================================

  Widget _teacherCard({
    required Map<String, dynamic> teacher,
  }) {
    final String teacherId =
        teacher['id'].toString();

    final bool isExpanded =
        expandedTeacherId == teacherId;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 15,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.15,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white24,
        ),
      ),
      child: Column(
        children: [
          // ========================================================
          // MAIN ROW
          // ========================================================

          GestureDetector(
            onTap: () {
              setState(() {
                if (expandedTeacherId ==
                    teacherId) {
                  expandedTeacherId = null;
                } else {
                  expandedTeacherId = teacherId;
                }
              });
            },
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
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
                        teacher['fullName']
                            .toString(),
                        style:
                            GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${teacher['subject']} • '
                        '${teacher['className']}',
                        style:
                            GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white70,
                ),
              ],
            ),
          ),

          // ========================================================
          // DETAILS
          // ========================================================

          if (isExpanded) ...[
            const SizedBox(height: 15),

            const Divider(
              color: Colors.white24,
            ),

            const SizedBox(height: 10),

            _teacherDetail(
              Icons.email,
              'Email',
              teacher['email'].toString(),
            ),

            _teacherDetail(
              Icons.phone,
              'Phone',
              teacher['phone'].toString(),
            ),

            _teacherDetail(
              Icons.badge,
              'Employee ID',
              teacher['employeeId'].toString(),
            ),

            _teacherDetail(
              Icons.person,
              'Gender',
              teacher['gender'].toString(),
            ),

            _teacherDetail(
              Icons.school,
              'Qualification',
              teacher['qualification']
                  .toString(),
            ),

            _teacherDetail(
              Icons.menu_book,
              'Subject',
              teacher['subject'].toString(),
            ),

            _teacherDetail(
              Icons.class_,
              'Class',
              teacher['className'].toString(),
            ),

            _teacherDetail(
              Icons.badge_outlined,
              'Role',
              teacher['role'].toString(),
            ),

            const SizedBox(height: 10),

            // ======================================================
            // EDIT + DELETE BUTTONS
            // ======================================================

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _editTeacher(
                        teacherId,
                        teacher,
                      );
                    },
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Edit',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    style:
                        OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.white70,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _deleteTeacher(
                        teacherId,
                        teacher['fullName']
                            .toString(),
                      );
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Delete',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // TEACHER DETAIL
  // ============================================================

  Widget _teacherDetail(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 9,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white70,
            size: 19,
          ),
          const SizedBox(width: 10),
          Text(
            '$title: ',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}