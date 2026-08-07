import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TeacherTimetableScreen extends StatelessWidget {
  const TeacherTimetableScreen({super.key});

  // Dummy data — will come from `teacher_subject_assignments` table later.
  final List<Map<String, String>> assignedClasses = const [
    {'class': 'Grade 5', 'section': 'A', 'subject': 'Mathematics', 'role': 'Class Teacher'},
    {'class': 'Grade 5', 'section': 'A', 'subject': 'Science', 'role': 'Subject Teacher'},
    {'class': 'Grade 6', 'section': 'B', 'subject': 'Mathematics', 'role': 'Subject Teacher'},
  ];

  // Dummy weekly timetable — will come from a `timetable` table later.
  final Map<String, List<Map<String, String>>> weeklyTimetable = const {
    'Monday': [
      {'period': '1', 'time': '8:00 - 8:40', 'class': '5A', 'subject': 'Mathematics'},
      {'period': '3', 'time': '9:30 - 10:10', 'class': '6B', 'subject': 'Mathematics'},
    ],
    'Tuesday': [
      {'period': '2', 'time': '8:40 - 9:20', 'class': '5A', 'subject': 'Science'},
    ],
    'Wednesday': [
      {'period': '1', 'time': '8:00 - 8:40', 'class': '5A', 'subject': 'Mathematics'},
    ],
    'Thursday': [
      {'period': '4', 'time': '10:10 - 10:50', 'class': '6B', 'subject': 'Mathematics'},
    ],
    'Friday': [
      {'period': '1', 'time': '8:00 - 8:40', 'class': '5A', 'subject': 'Science'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
                    _TopBar(),
                    TabBar(
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white60,
                      labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                      tabs: const [
                        Tab(text: 'Assigned Classes'),
                        Tab(text: 'Weekly Timetable'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildClassesList(),
                          _buildTimetable(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClassesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: assignedClasses.length,
      itemBuilder: (context, index) {
        final item = assignedClasses[index];
        final bool isClassTeacher = item['role'] == 'Class Teacher';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: isClassTeacher ? 0.3 : 0.15),
                child: Icon(
                  isClassTeacher ? Icons.star : Icons.book,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item['class']} - ${item['section']}',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    Text(
                      item['subject']!,
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              if (isClassTeacher)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Class Teacher',
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.white),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimetable() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: weeklyTimetable.entries.map((day) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                day.key,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.2)),
              ...day.value.map(
                (period) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'P${period['period']}',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        period['time']!,
                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
                      ),
                      const Spacer(),
                      Text(
                        '${period['class']} - ${period['subject']}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Simple top bar with the screen title, styled the same way as
/// the rest of the app (Poppins, white text over the blurred image).
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 20, 0),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          Text(
            'Classes & Timetable',
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