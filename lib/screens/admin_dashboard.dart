import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'notifications_screen.dart';
import 'admin_profile_screen.dart';
import '../widgets/admin_drawer.dart';

// ================================================================
// ADMIN DASHBOARD
// ================================================================

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================================================================
  // STUDENTS COUNT
  // ================================================================

  Stream<int> _studentsCountStream() {
    return _firestore.collectionGroup('students').snapshots().map((snapshot) {
      return snapshot.docs.length;
    });
  }

  // ================================================================
  // TEACHERS COUNT
  // ================================================================

  Stream<int> _teachersCountStream() {
    return _firestore.collection('teachers').snapshots().map((snapshot) {
      return snapshot.docs.length;
    });
  }

  // ================================================================
  // CLASSES COUNT
  //
  // A class + section is counted as one class.
  //
  // Example:
  // Grade 1 + Pink
  // Grade 1 + Blue
  //
  // Total = 2
  // ================================================================

  Stream<int> _classesCountStream() {
    return _firestore.collectionGroup('students').snapshots().map((snapshot) {
      final Set<String> classSections = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();

        final String className =
            data['class']?.toString().trim() ?? '';

        final String section =
            data['section']?.toString().trim() ?? '';

        if (className.isNotEmpty && section.isNotEmpty) {
          classSections.add(
            '${className.toLowerCase()}|${section.toLowerCase()}',
          );
        }
      }

      return classSections.length;
    });
  }

  // ================================================================
  // ATTENDANCE
  //
  // IMPORTANT:
  // The AttendanceScreen provided currently contains a hard-coded
  // attendanceRecords list and does not save attendance to Firestore.
  //
  // Therefore there is no confirmed Firestore attendance path yet.
  // This returns 0/0 instead of inventing a collection/schema.
  // ================================================================

  Stream<String> _attendanceCountStream() {
    return Stream.value('0/0');
  }

  // ================================================================
  // GENERIC LIVE VALUE BUILDER
  // ================================================================

  Widget _liveValue({
    required Stream<String> stream,
  }) {
    return StreamBuilder<String>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            '...',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          );
        }

        return Text(
          snapshot.data ?? '0',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }

  Widget _liveIntValue({
    required Stream<int> stream,
  }) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            '...',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          );
        }

        return Text(
          '${snapshot.data ?? 0}',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(),
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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
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
                          Builder(
                            builder: (context) {
                              return IconButton(
                                onPressed: () {
                                  Scaffold.of(context).openDrawer();
                                },
                                icon: const Icon(
                                  Icons.menu,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              );
                            },
                          ),

                          Expanded(
                            child: Text(
                              'Dashboard',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const NotificationsScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.notifications_active,
                              color: Colors.amber,
                              size: 26,
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const AdminProfileScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.account_circle,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ==================================================
                    // WELCOME CARD
                    // ==================================================

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white24,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/logo.jpg',
                                  fit: BoxFit.cover,
                                  errorBuilder: (
                                    context,
                                    error,
                                    stackTrace,
                                  ) {
                                    return const Icon(
                                      Icons.school,
                                      color: Colors.white,
                                      size: 40,
                                    );
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome, Administrator',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Khyber Public School & College',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ==================================================
                    // TODAY'S OVERVIEW
                    // ==================================================

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Today's Overview",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ==================================================
                    // FIRST ROW
                    // ==================================================

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: Row(
                        children: [
                          // STUDENTS
                          Expanded(
                            child: _dashboardCard(
                              icon: Icons.school,
                              title: 'Students',
                              valueWidget: _liveIntValue(
                                stream: _studentsCountStream(),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // TEACHERS
                          Expanded(
                            child: _dashboardCard(
                              icon: Icons.person,
                              title: 'Teachers',
                              valueWidget: _liveIntValue(
                                stream: _teachersCountStream(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ==================================================
                    // SECOND ROW
                    // ==================================================

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: Row(
                        children: [
                          // ATTENDANCE
                          Expanded(
                            child: _dashboardCard(
                              icon: Icons.fact_check,
                              title: 'Attendance',
                              valueWidget: _liveValue(
                                stream: _attendanceCountStream(),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // CLASSES
                          Expanded(
                            child: _dashboardCard(
                              icon: Icons.class_,
                              title: 'Classes',
                              valueWidget: _liveIntValue(
                                stream: _classesCountStream(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // DASHBOARD CARD
  // ================================================================

  Widget _dashboardCard({
    required IconData icon,
    required String title,
    required Widget valueWidget,
  }) {
    return Container(
      height: 135,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white24,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ),

          const Spacer(),

          valueWidget,

          const SizedBox(height: 2),

          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}