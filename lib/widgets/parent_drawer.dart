import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/academic_calendar_parent_screen.dart';
import '../screens/homework_screen.dart';
import '../screens/my_complaints_screen.dart';
import '../screens/parent_about_app_screen.dart';
import '../screens/parent_admin_complaint_screen.dart';
import '../screens/parent_attendance_screen.dart';
import '../screens/parent_datesheet_screen.dart';
import '../screens/parent_fee_details_screen.dart';
import '../screens/parent_notifications_screen.dart';
import '../screens/parent_profile_screen.dart';
import '../screens/parent_result_screen.dart';
import '../screens/parent_teacher_review_screen.dart';

class ParentDrawer extends StatelessWidget {
  final List<Map<String, dynamic>> familyChildren;
  final int selectedChildIndex;

  const ParentDrawer({
    super.key,
    required this.familyChildren,
    required this.selectedChildIndex,
  });

  Map<String, dynamic> get _child {
    if (familyChildren.isEmpty) {
      return <String, dynamic>{};
    }

    if (selectedChildIndex < 0 ||
        selectedChildIndex >= familyChildren.length) {
      return familyChildren.first;
    }

    return familyChildren[selectedChildIndex];
  }

  String get _studentId {
    return (_child['studentId'] ?? '').toString();
  }

  String get _className {
    return (_child['className'] ?? '').toString();
  }

  String get _studentName {
    return (_child['name'] ?? '').toString();
  }

  bool _requireChild(BuildContext context) {
    if (_studentId.isEmpty || _className.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No child record found yet.'),
          backgroundColor: Colors.orange,
        ),
      );

      return false;
    }

    return true;
  }

  Future<void> _logout(BuildContext context) async {
    try {
      Navigator.pop(context);

      await FirebaseAuth.instance.signOut();

      if (!context.mounted) return;
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.88),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // ==================================================
              // HEADER
              // ==================================================
              Container(
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 13),
                    Text(
                      'Khyber Public School',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _studentName.isNotEmpty
                          ? 'Parent Menu • $_studentName'
                          : 'Parent Quick Menu',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ==================================================
              // MY PROFILE
              // ==================================================
              _buildDrawerItem(
                icon: Icons.person_outline_rounded,
                title: 'My Profile',
                iconColor: const Color(0xFFDDE4FF),
                onTap: () {
                  Navigator.pop(context);

                  if (!_requireChild(context)) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ParentProfileScreen(
                        studentId: _studentId,
                        className: _className,
                        fallbackChild: _child,
                      ),
                    ),
                  );
                },
              ),

              // ==================================================
              // ATTENDANCE
              // ==================================================
              _buildDrawerItem(
                icon: Icons.event_available_outlined,
                title: 'Attendance',
                iconColor: const Color(0xFFB8F2E6),
                onTap: () {
                  Navigator.pop(context);

                  if (!_requireChild(context)) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ParentAttendanceScreen(
                        studentId: _studentId,
                        className: _className,
                        studentName: _studentName,
                      ),
                    ),
                  );
                },
              ),

              // ==================================================
              // ACADEMIC CALENDAR
              // ==================================================
              _buildDrawerItem(
                icon: Icons.calendar_month_outlined,
                title: 'Academic Calendar',
                iconColor: Colors.white,
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const AcademicCalendarScreen(),
                    ),
                  );
                },
              ),

              // ==================================================
              // HOMEWORK
              // ==================================================
              _buildDrawerItem(
                icon: Icons.assignment_rounded,
                title: 'Homework',
                iconColor: Colors.white,
                iconBackground: const Color(0xFF7C83FD),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeworkScreen(),
                    ),
                  );
                },
              ),
              // ==================================================
              // FEE DETAILS
              // ==================================================
              _buildDrawerItem(
                icon: Icons.receipt_long_outlined,
                title: 'Fee Details & Late Charges',
                iconColor: const Color(0xFFFFE1A8),
                onTap: () {
                  Navigator.pop(context);

                  if (!_requireChild(context)) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ParentFeeDetailsScreen(
                        studentId: _studentId,
                        className: _className,
                      ),
                    ),
                  );
                },
              ),

              // ==================================================
              // EXAMS DATE SHEET
              // ==================================================
              _buildDrawerItem(
                icon: Icons.article_outlined,
                title: 'Exams Date Sheet',
                iconColor: const Color(0xFFE2D9F3),
                onTap: () {
                  Navigator.pop(context);

                  if (!_requireChild(context)) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ParentDateSheetScreen(
                        className: _className,
                      ),
                    ),
                  );
                },
              ),

              // ==================================================
              // TEACHER REVIEW
              // ==================================================
              _buildDrawerItem(
                icon: Icons.rate_review_outlined,
                title: 'Teacher Review & Behavior',
                iconColor: const Color(0xFFFFD6E0),
                onTap: () {
                  Navigator.pop(context);

                  if (!_requireChild(context)) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ParentTeacherReviewScreen(
                        studentId: _studentId,
                        className: _className,
                      ),
                    ),
                  );
                },
              ),

              // ==================================================
              // RESULT
              // ==================================================
              _buildDrawerItem(
                icon: Icons.emoji_events_outlined,
                title: 'Result & Class Position',
                iconColor: const Color(0xFFFFE8A3),
                onTap: () {
                  Navigator.pop(context);

                  if (!_requireChild(context)) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ParentResultScreen(
                        studentId: _studentId,
                        className: _className,
                      ),
                    ),
                  );
                },
              ),

              // ==================================================
              // SUBMIT COMPLAINT
              // ==================================================
              _buildDrawerItem(
                icon: Icons.report_problem_outlined,
                title: 'Submit Complaint to Admin',
                iconColor: const Color(0xFFFFC4D6),
                onTap: () {
                  Navigator.pop(context);

                  if (!_requireChild(context)) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ParentAdminComplaintScreen(
                        child: _child,
                      ),
                    ),
                  );
                },
              ),

              // ==================================================
              // MY COMPLAINTS
              // ==================================================
              _buildDrawerItem(
                icon: Icons.mark_email_read_outlined,
                title: 'My Complaints & Replies',
                iconColor: const Color(0xFFCDE7FF),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyComplaintsScreen(),
                    ),
                  );
                },
              ),

              // ==================================================
              // NOTIFICATIONS
              // ==================================================
              _buildDrawerItem(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                iconColor: const Color(0xFFFFE29A),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const ParentNotificationsScreen(),
                    ),
                  );
                },
              ),

              // ==================================================
              // ABOUT APP
              // ==================================================
              _buildDrawerItem(
                icon: Icons.info_outline,
                title: 'About App',
                iconColor: Colors.white,
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const ParentAboutAppScreen(),
                    ),
                  );
                },
              ),

              // ==================================================
              // DIVIDER
              // ==================================================
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                child: Divider(
                  color: Colors.white.withValues(alpha: 0.20),
                  height: 1,
                ),
              ),

              // ==================================================
              // LOGOUT
              // ==================================================
              _buildDrawerItem(
                icon: Icons.logout_rounded,
                title: 'Logout',
                iconColor: const Color(0xFFFFB4C0),
                onTap: () => _logout(context),
              ),

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // DRAWER ITEM
  // ==============================================================
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
    Color? iconBackground,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 2,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBackground ??
                Colors.white.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 21,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.white38,
          size: 13,
        ),
        onTap: onTap,
      ),
    );
  }
}