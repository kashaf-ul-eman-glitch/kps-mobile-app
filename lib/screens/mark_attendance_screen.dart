import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  // Dummy data — will come from `students` table later.
  final List<Map<String, dynamic>> students = [
    {'name': 'Ali Raza', 'rollNo': '01', 'present': true},
    {'name': 'Sara Khan', 'rollNo': '02', 'present': true},
    {'name': 'Bilal Hussain', 'rollNo': '03', 'present': true},
    {'name': 'Ayesha Malik', 'rollNo': '04', 'present': true},
  ];

  final DateTime today = DateTime.now();

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
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      'Grade 5A  •  ${today.day}/${today.month}/${today.year}',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final s = students[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white.withValues(alpha: 0.25),
                                child: Text(
                                  s['rollNo'],
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  s['name'],
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                              ),
                              ToggleButtons(
                                borderRadius: BorderRadius.circular(8),
                                borderColor: Colors.white.withValues(alpha: 0.3),
                                selectedBorderColor: Colors.white.withValues(alpha: 0.3),
                                isSelected: [s['present'] == true, s['present'] == false],
                                selectedColor: Colors.white,
                                color: Colors.white70,
                                fillColor: s['present'] == true
                                    ? Colors.green.withValues(alpha: 0.6)
                                    : Colors.red.withValues(alpha: 0.6),
                                onPressed: (i) {
                                  setState(() {
                                    s['present'] = i == 0;
                                  });
                                },
                                children: const [
                                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('P')),
                                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('A')),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          // Will insert rows into the `attendance` table via Supabase later.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Attendance submitted (dummy)')),
                          );
                        },
                        child: Text(
                          'Submit Attendance',
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
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
            'Mark Attendance',
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