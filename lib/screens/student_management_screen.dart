import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() =>
      _StudentManagementScreenState();
}

class _StudentManagementScreenState
    extends State<StudentManagementScreen> {
  final TextEditingController searchController =
      TextEditingController();

  String searchText = '';

  final List<Map<String, dynamic>> students = [
    {
      'name': 'Ahmed Ali',
      'class': 'Grade 5',
      'section': 'Section A',
      'family': 'Ali Family',
      'guardian': 'Muhammad Ali',
      'attendance': 'Present',
      'expanded': false,
    },
    {
      'name': 'Ayesha Ali',
      'class': 'Grade 2',
      'section': 'Section B',
      'family': 'Ali Family',
      'guardian': 'Muhammad Ali',
      'attendance': 'Present',
      'expanded': false,
    },
    {
      'name': 'Hamza Khan',
      'class': 'Grade 7',
      'section': 'Section A',
      'family': 'Khan Family',
      'guardian': 'Usman Khan',
      'attendance': 'Absent',
      'expanded': false,
    },
    {
      'name': 'Fatima Shah',
      'class': 'Grade 4',
      'section': 'Section B',
      'family': 'Shah Family',
      'guardian': 'Imran Shah',
      'attendance': 'Present',
      'expanded': false,
    },
    {
      'name': 'Hassan Shah',
      'class': 'Grade 1',
      'section': 'Section A',
      'family': 'Shah Family',
      'guardian': 'Imran Shah',
      'attendance': 'Late',
      'expanded': false,
    },
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = students.where((student) {
      final name = student['name'].toString().toLowerCase();
      final className = student['class'].toString().toLowerCase();
      final section = student['section'].toString().toLowerCase();
      final family = student['family'].toString().toLowerCase();

      final query = searchText.toLowerCase();

      return name.contains(query) ||
          className.contains(query) ||
          section.contains(query) ||
          family.contains(query);
    }).toList();

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
                            'Student Management',
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
                  // Search Bar
                  // =========================

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      5,
                      20,
                      15,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(15),
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
                          hintText: 'Search students...',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.white60,
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.white70,
                          ),
                          suffixIcon: searchText.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    searchController.clear();

                                    setState(() {
                                      searchText = '';
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.white70,
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

                  // =========================
                  // Student List
                  // =========================

                  Expanded(
                    child: filteredStudents.isEmpty
                        ? Center(
                            child: Text(
                              'No students found',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              20,
                              0,
                              20,
                              25,
                            ),
                            itemCount: filteredStudents.length,
                            itemBuilder: (context, index) {
                              final student =
                                  filteredStudents[index];

                              return _studentCard(
                                student: student,
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

      // =========================
      // Add Student Button
      // =========================

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Add Student - Coming Soon',
              ),
            ),
          );
        },
        backgroundColor: Colors.brown,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  // =========================
  // Student Card
  // =========================

  Widget _studentCard({
    required Map<String, dynamic> student,
  }) {
    final bool isExpanded = student['expanded'] ?? false;

    return GestureDetector(
      onTap: () {
        setState(() {
          student['expanded'] = !isExpanded;
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 15),
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
            // Main Student Row
            // =========================

            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
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
                        student['name'],
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        '${student['class']} • '
                        '${student['section']}',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                _attendanceBadge(
                  student['attendance'],
                ),

                const SizedBox(width: 5),

                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white70,
                ),
              ],
            ),

            // =========================
            // Expanded Details
            // =========================

            if (isExpanded) ...[
              const SizedBox(height: 15),

              const Divider(
                color: Colors.white24,
              ),

              const SizedBox(height: 10),

              _studentDetail(
                Icons.school,
                'Class',
                student['class'],
              ),

              _studentDetail(
                Icons.groups,
                'Section',
                student['section'],
              ),

              _studentDetail(
                Icons.family_restroom,
                'Family',
                student['family'],
              ),

              _studentDetail(
                Icons.person,
                'Guardian',
                student['guardian'],
              ),

              _studentDetail(
                Icons.how_to_reg,
                'Attendance',
                student['attendance'],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =========================
  // Attendance Badge
  // =========================

  Widget _attendanceBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // =========================
  // Student Detail
  // =========================

  Widget _studentDetail(
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