import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  final List<Map<String, dynamic>> complaints = [
    {
      'title': 'Attendance Issue',
      'category': 'Attendance',
      'parent': 'Muhammad Ali',
      'family': 'Ali Family',
      'child': 'Ahmed Ali',
      'class': 'Grade 5 • Section A',
      'date': '03 Aug 2026',
      'status': 'Pending',
      'description':
          'Ahmed was marked absent on Monday, but he attended school that day.',
      'expanded': false,
    },
    {
      'title': 'Homework Concern',
      'category': 'Homework',
      'parent': 'Usman Khan',
      'family': 'Khan Family',
      'child': 'Hamza Khan',
      'class': 'Grade 7 • Section A',
      'date': '02 Aug 2026',
      'status': 'In Review',
      'description':
          'The parent would like clarification about the homework assigned to Hamza.',
      'expanded': false,
    },
    {
      'title': 'Academic Concern',
      'category': 'Academic',
      'parent': 'Imran Shah',
      'family': 'Shah Family',
      'child': 'Fatima Shah',
      'class': 'Grade 4 • Section B',
      'date': '01 Aug 2026',
      'status': 'Resolved',
      'description':
          'The parent requested information about Fatima\'s recent academic performance.',
      'expanded': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final int totalComplaints = complaints.length;

    final int pendingComplaints = complaints
        .where((item) => item['status'] == 'Pending')
        .length;

    final int reviewComplaints = complaints
        .where((item) => item['status'] == 'In Review')
        .length;

    final int resolvedComplaints = complaints
        .where((item) => item['status'] == 'Resolved')
        .length;

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
                            'Parent Complaints',
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
                  // Summary
                  // =========================

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      5,
                      20,
                      18,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white24,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceAround,
                        children: [
                          _summaryItem(
                            'Total',
                            totalComplaints,
                          ),
                          _summaryItem(
                            'Pending',
                            pendingComplaints,
                          ),
                          _summaryItem(
                            'Review',
                            reviewComplaints,
                          ),
                          _summaryItem(
                            'Resolved',
                            resolvedComplaints,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // =========================
                  // Section Title
                  // =========================

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      12,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Complaints from Families',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // =========================
                  // Complaints List
                  // =========================

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        0,
                        20,
                        25,
                      ),
                      itemCount: complaints.length,
                      itemBuilder: (context, index) {
                        return _complaintCard(
                          complaints[index],
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
  // Summary Item
  // =========================

  Widget _summaryItem(
    String title,
    int value,
  ) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // =========================
  // Complaint Card
  // =========================

  Widget _complaintCard(
    Map<String, dynamic> complaint,
  ) {
    final bool isExpanded = complaint['expanded'] ?? false;

    return GestureDetector(
      onTap: () {
        setState(() {
          complaint['expanded'] = !isExpanded;
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
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
            // Complaint Header
            // =========================

            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.report_problem_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        complaint['title'],
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${complaint['child']} • '
                        '${complaint['class']}',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                _statusBadge(
                  complaint['status'],
                ),

                const SizedBox(width: 4),

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
              const SizedBox(height: 14),

              const Divider(
                color: Colors.white24,
              ),

              const SizedBox(height: 10),

              _detailRow(
                Icons.person,
                'Parent',
                complaint['parent'],
              ),

              _detailRow(
                Icons.family_restroom,
                'Family',
                complaint['family'],
              ),

              _detailRow(
                Icons.child_care,
                'Child',
                complaint['child'],
              ),

              _detailRow(
                Icons.school,
                'Class',
                complaint['class'],
              ),

              _detailRow(
                Icons.category_outlined,
                'Category',
                complaint['category'],
              ),

              _detailRow(
                Icons.calendar_today,
                'Date',
                complaint['date'],
              ),

              _detailRow(
                Icons.info_outline,
                'Status',
                complaint['status'],
              ),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Complaint',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  complaint['description'],
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =========================
  // Detail Row
  // =========================

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white70,
            size: 18,
          ),
          const SizedBox(width: 9),
          Text(
            '$title: ',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // Status Badge
  // =========================

  Widget _statusBadge(
    String status,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}