import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/about_app_screen.dart';
import '../screens/admin_profile_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/school_setup_screen.dart';
import '../screens/teacher_management_screen.dart';
import '../screens/attendance_screen.dart';
import '../screens/complaints_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/academic_calendar_screen.dart';
import '../screens/fee_management_screen.dart';
import '../screens/admission_form_screen.dart'; // Fixed missing semicolon

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5,
          sigmaY: 5,
        ),
        child: Container(
          color: Colors.black.withValues(alpha: 0.25),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.jpg',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        "Administrator",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 23),

                      const Divider(
                        color: Colors.white38,
                        thickness: 1,
                      ),

                      const SizedBox(height: 10),

                      ListTile(
                        leading: const Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                        title: Text(
                          "My Profile",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminProfileScreen(),
                            ),
                          );
                        },
                      ),

                      ListTile(
                        leading: const Icon(
                          Icons.dashboard,
                          color: Colors.white,
                        ),
                        title: Text(
                          "Dashboard",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),

                      ListTile(
                        leading: const Icon(
                          Icons.business,
                          color: Colors.white,
                        ),
                        title: Text(
                          "School Setup",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SchoolSetupScreen(),
                            ),
                          );
                        },
                      ),

                      ListTile(
                        leading: const Icon(
                          Icons.co_present,
                          color: Colors.white,
                        ),
                        title: Text(
                          "Teacher Management",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TeacherManagementScreen(),
                            ),
                          );
                        },
                      ),

                      // =========================
                      // Admission Form
                      // =========================
                      ListTile(
                        leading: const Icon(
                          Icons.assignment_ind,
                          color: Colors.white,
                        ),
                        title: Text(
                          "Admission Form",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                        onTap: () {
                          Navigator.pop(context); // Drawer ko pehle close karein
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdmissionFormScreen(),
                            ),
                          );
                        },
                      ),

                      ListTile(
                        leading: const Icon(
                          Icons.payments_outlined,
                          color: Colors.white,
                        ),
                        title: Text(
                          "Fee Management",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FeeManagementScreen(),
                            ),
                          );
                        },
                      ),

                      ListTile(
                        leading: const Icon(
                          Icons.how_to_reg,
                          color: Colors.white,
                        ),
                        title: Text(
                          "Attendance",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AttendanceScreen(),
                            ),
                          );
                        },
                      ),

                      ListTile(
                        leading: const Icon(
                          Icons.calendar_month_outlined,
                          color: Colors.white,
                        ),
                        title: Text(
                          "Academic Calendar",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AcademicCalendarScreen(),
                            ),
                          );
                        },
                      ),

                      ListTile(
                        leading: const Icon(
                          Icons.notification_add,
                          color: Colors.white,
                        ),
                        title: Text(
                          "Notifications",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationsScreen(),
                            ),
                          );
                        },
                      ),

                      ListTile(
                        leading: const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white,
                        ),
                        title: Text(
                          "Complaints",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ComplaintsScreen(),
                            ),
                          );
                        },
                      ),

                      ListTile(
                        leading: const Icon(
                          Icons.bar_chart,
                          color: Colors.white,
                        ),
                        title: Text(
                          "Reports",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReportsScreen(),
                            ),
                          );
                        },
                      ),

                      // =========================
                      // Settings
                      // =========================
                      ListTile(
                        leading: const Icon(
                          Icons.settings,
                          color: Colors.white,
                        ),
                        title: Text(
                          "Settings",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),

                      // =========================
                      // Divider
                      // =========================
                      const Divider(
                        color: Colors.white38,
                        thickness: 1,
                      ),

                      // =========================
                      // About App
                      // =========================
                      ListTile(
                        leading: const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                        ),
                        title: Text(
                          "About App",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AboutAppScreen(),
                            ),
                          );
                        },
                      ),

                      // =========================
                      // Logout
                      // =========================
                      ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: Colors.white,
                        ),
                        title: Text(
                          "Logout",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Logout - Coming Soon"),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}