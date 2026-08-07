import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewStudentsScreen extends StatelessWidget {
  const ViewStudentsScreen({super.key});

  // Dummy data — will come from `students` table (filtered by class_id) later.
  final List<Map<String, String>> students = const [
    {'name': 'Ali Raza', 'rollNo': '01', 'admissionNo': 'ADM-1001', 'parent': 'Raza Ahmed'},
    {'name': 'Sara Khan', 'rollNo': '02', 'admissionNo': 'ADM-1002', 'parent': 'Imran Khan'},
    {'name': 'Bilal Hussain', 'rollNo': '03', 'admissionNo': 'ADM-1003', 'parent': 'Hussain Ali'},
    {'name': 'Ayesha Malik', 'rollNo': '04', 'admissionNo': 'ADM-1004', 'parent': 'Tariq Malik'},
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
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.black.withValues(alpha: 0.25),
            child: SafeArea(
              child: Column(
                children: [
                  _TopBar(),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final s = students[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white.withValues(alpha: 0.25),
                                child: Text(
                                  s['rollNo']!,
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s['name']!,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Admission No: ${s['admissionNo']}',
                                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
                                    ),
                                    Text(
                                      'Parent: ${s['parent']}',
                                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
            'Students - Grade 5A',
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