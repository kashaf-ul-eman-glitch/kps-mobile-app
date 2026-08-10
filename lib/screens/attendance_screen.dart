import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String selectedClass = 'All Classes';
  DateTime selectedDate = DateTime.now();

  final List<Map<String, dynamic>> attendanceRecords = [
    {
      'name': 'Ahmed Ali',
      'class': 'Grade 5',
      'section': 'Section A',
      'status': 'Present',
      'expanded': false,
    },
    {
      'name': 'Ayesha Ali',
      'class': 'Grade 2',
      'section': 'Section B',
      'status': 'Present',
      'expanded': false,
    },
    {
      'name': 'Hamza Khan',
      'class': 'Grade 7',
      'section': 'Section A',
      'status': 'Absent',
      'expanded': false,
    },
    {
      'name': 'Fatima Shah',
      'class': 'Grade 4',
      'section': 'Section B',
      'status': 'Present',
      'expanded': false,
    },
    {
      'name': 'Hassan Shah',
      'class': 'Grade 1',
      'section': 'Section A',
      'status': 'Late',
      'expanded': false,
    },
  ];

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  String _formattedDate() {
    return '${selectedDate.day.toString().padLeft(2, '0')}/'
        '${selectedDate.month.toString().padLeft(2, '0')}/'
        '${selectedDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecords = selectedClass == 'All Classes'
        ? attendanceRecords
        : attendanceRecords
            .where(
              (student) => student['class'] == selectedClass,
            )
            .toList();

    final int presentCount = filteredRecords
        .where((student) => student['status'] == 'Present')
        .length;

    final int absentCount = filteredRecords
        .where((student) => student['status'] == 'Absent')
        .length;

    final int lateCount = filteredRecords
        .where((student) => student['status'] == 'Late')
        .length;

    final int leaveCount = filteredRecords
        .where((student) => student['status'] == 'Leave')
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
                            'Attendance',
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
                  // Date and Class Filters
                  // =========================

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      5,
                      20,
                      15,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _selectDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withValues(alpha: 0.15),
                                borderRadius:
                                    BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white24,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _formattedDate(),
                                      style:
                                          GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white24,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedClass,
                                dropdownColor: Colors.brown.shade800,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white70,
                                ),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'All Classes',
                                    child: Text('All Classes'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Grade 1',
                                    child: Text('Grade 1'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Grade 2',
                                    child: Text('Grade 2'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Grade 4',
                                    child: Text('Grade 4'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Grade 5',
                                    child: Text('Grade 5'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Grade 7',
                                    child: Text('Grade 7'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedClass = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // =========================
                  // Attendance Summary
                  // =========================

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white24,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Attendance Summary',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _summaryItem(
                                  'Present',
                                  presentCount,
                                ),
                              ),
                              Expanded(
                                child: _summaryItem(
                                  'Absent',
                                  absentCount,
                                ),
                              ),
                              Expanded(
                                child: _summaryItem(
                                  'Late',
                                  lateCount,
                                ),
                              ),
                              Expanded(
                                child: _summaryItem(
                                  'Leave',
                                  leaveCount,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // =========================
                  // Student Attendance List
                  // =========================

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        0,
                        20,
                        25,
                      ),
                      itemCount: filteredRecords.length,
                      itemBuilder: (context, index) {
                        final student =
                            filteredRecords[index];

                        return _attendanceCard(
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
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // =========================
  // Attendance Card
  // =========================

  Widget _attendanceCard({
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: Colors.white24,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
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
                        student['name'],
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${student['class']} • '
                        '${student['section']}',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusBadge(student['status']),
                const SizedBox(width: 4),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white70,
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 12),
              const Divider(
                color: Colors.white24,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 9),
                  Text(
                    'Date: ${_formattedDate()}',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.how_to_reg,
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 9),
                  Text(
                    'Status: ${student['status']}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =========================
  // Status Badge
  // =========================

  Widget _statusBadge(String status) {
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
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}