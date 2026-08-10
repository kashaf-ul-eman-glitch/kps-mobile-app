import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final List<Map<String, dynamic>> reportCategories = [
    {
      'title': 'Attendance Reports',
      'icon': Icons.how_to_reg,
      'expanded': false,
      'reports': [
        'Daily Attendance',
        'Monthly Attendance',
        'Class Attendance',
      ],
    },
    {
      'title': 'Student Reports',
      'icon': Icons.school,
      'expanded': false,
      'reports': [
        'Student List',
        'Student Performance',
        'Student Attendance',
      ],
    },
    {
      'title': 'Teacher Reports',
      'icon': Icons.person,
      'expanded': false,
      'reports': [
        'Teacher List',
        'Teacher Attendance',
        'Teacher Assignments',
      ],
    },
    {
      'title': 'Family Reports',
      'icon': Icons.family_restroom,
      'expanded': false,
      'reports': [
        'Family List',
        'Children by Family',
        'Family Contact List',
      ],
    },
    {
      'title': 'Notification Reports',
      'icon': Icons.notifications_none,
      'expanded': false,
      'reports': [
        'School Announcements',
        'Academic Notifications',
        'General Notifications',
      ],
    },
    {
      'title': 'Complaint Reports',
      'icon': Icons.report_problem_outlined,
      'expanded': false,
      'reports': [
        'Pending Complaints',
        'Complaints in Review',
        'Resolved Complaints',
      ],
    },
  ];

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
                            'Reports',
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
                  // Description
                  // =========================

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      5,
                      20,
                      18,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'View and manage school reports',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  // =========================
                  // Report Categories
                  // =========================

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        0,
                        20,
                        25,
                      ),
                      itemCount: reportCategories.length,
                      itemBuilder: (context, index) {
                        final category =
                            reportCategories[index];

                        return _reportCategory(
                          category,
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

  // =========================
  // Report Category
  // =========================

  Widget _reportCategory(
    Map<String, dynamic> category,
  ) {
    final bool isExpanded =
        category['expanded'] ?? false;

    final List<dynamic> reports =
        category['reports'] ?? [];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
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
          // Category Header
          // =========================

          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              setState(() {
                category['expanded'] =
                    !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category['icon'],
                      color: Colors.white,
                      size: 25,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Text(
                      category['title'],
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
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
          ),

          // =========================
          // Report Items
          // =========================

          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                12,
              ),
              child: Column(
                children: reports.map<Widget>(
                  (report) {
                    return Material(
  color: Colors.black.withValues(alpha: 0.12),
  borderRadius: BorderRadius.circular(12),
  
                      child: ListTile(
                        dense: true,
                        leading: const Icon(
                          Icons.description_outlined,
                          color: Colors.white70,
                          size: 20,
                        ),
                        title: Text(
                          report.toString(),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white54,
                          size: 20,
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            SnackBar(
                              content: Text(
                                '$report - Coming Soon',
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
        ],
      ),
    );
  }
}