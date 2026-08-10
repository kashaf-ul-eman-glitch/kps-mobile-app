import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  final List<Map<String, dynamic>> teachers = [
    {
      'name': 'Teacher Name',
      'subject': 'Mathematics',
      'class': 'Grade 8',
      'email': 'teacher@example.com',
      'phone': 'Not set',
      'role': 'Class Teacher',
      'expanded': false,
    },
    {
      'name': 'Teacher Name',
      'subject': 'English',
      'class': 'Grade 7',
      'email': 'teacher@example.com',
      'phone': 'Not set',
      'role': 'Subject Teacher',
      'expanded': false,
    },
    {
      'name': 'Teacher Name',
      'subject': 'Science',
      'class': 'Grade 9',
      'email': 'teacher@example.com',
      'phone': 'Not set',
      'role': 'Subject Teacher',
      'expanded': false,
    },
    {
      'name': 'Teacher Name',
      'subject': 'Computer Science',
      'class': 'Grade 10',
      'email': 'teacher@example.com',
      'phone': 'Not set',
      'role': 'Subject Teacher',
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
    final filteredTeachers = teachers.where((teacher) {
      final name = teacher['name'].toString().toLowerCase();
      final subject = teacher['subject'].toString().toLowerCase();
      final className = teacher['class'].toString().toLowerCase();

      return name.contains(searchText.toLowerCase()) ||
          subject.contains(searchText.toLowerCase()) ||
          className.contains(searchText.toLowerCase());
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
                          hintText: 'Search teachers...',
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
                  // Teacher List
                  // =========================

                  Expanded(
                    child: filteredTeachers.isEmpty
                        ? Center(
                            child: Text(
                              'No teachers found',
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
                            itemCount: filteredTeachers.length,
                            itemBuilder: (context, index) {
                              final teacher =
                                  filteredTeachers[index];

                              return _teacherCard(
                                teacher: teacher,
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
      // Add Teacher Button
      // =========================

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Add Teacher - Coming Soon',
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
  // Teacher Card
  // =========================

  Widget _teacherCard({
    required Map<String, dynamic> teacher,
  }) {
    final bool isExpanded = teacher['expanded'] ?? false;

    return GestureDetector(
      onTap: () {
        setState(() {
          teacher['expanded'] = !isExpanded;
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
            // Main Teacher Row
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
                        teacher['name'],
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        '${teacher['subject']} • ${teacher['class']}',
                        style: GoogleFonts.poppins(
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

            // =========================
            // Expanded Details
            // =========================

            if (isExpanded) ...[
              const SizedBox(height: 15),

              const Divider(
                color: Colors.white24,
              ),

              const SizedBox(height: 10),

              _teacherDetail(
                Icons.email,
                'Email',
                teacher['email'],
              ),

              _teacherDetail(
                Icons.phone,
                'Phone',
                teacher['phone'],
              ),

              _teacherDetail(
                Icons.menu_book,
                'Subject',
                teacher['subject'],
              ),

              _teacherDetail(
                Icons.class_,
                'Class',
                teacher['class'],
              ),

              _teacherDetail(
                Icons.badge,
                'Role',
                teacher['role'],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =========================
  // Teacher Detail
  // =========================

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