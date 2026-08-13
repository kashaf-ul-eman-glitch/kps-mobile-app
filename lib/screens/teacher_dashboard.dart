import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'teacher_profile_screen.dart';
import 'teacher_timetable_screen.dart';
import 'view_students_screen.dart';
import 'mark_attendance_screen.dart';
import 'post_homework_screen.dart';
import 'upload_marks_screen.dart';
import 'post_announcement_screen.dart';
import 'submit_complaint_screen.dart';
import 'users_list_screen.dart';

class TeacherDashboardScreen extends StatefulWidget {
  final String teacherName;
  final String designation;

  const TeacherDashboardScreen({
    super.key,
    this.teacherName = 'Mr . Ahmad',
    this.designation = 'Senior Science Teacher',
  });

  @override
  State<TeacherDashboardScreen> createState() =>
      _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context),
      // Transparent AppBar matching the background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Row(
          children: [
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 26),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ],
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white24,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.school, color: Colors.white, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Text(
                  'Teacher Dashboard',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white, size: 26),
                onPressed: () {
                  _showNotificationsDialog(context);
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      extendBodyBehindAppBar: true,
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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    _buildWelcomeHeader(),
                    const SizedBox(height: 15),
                    _buildTeacherStatusSection(),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.brown.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Overview',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 15),
                          _buildInfoCard(
                            icon: Icons.class_outlined,
                            title: 'Today\'s Classes',
                            subtitle: '4 Classes Scheduled (Grade 5A, 6B, 8C)',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            icon: Icons.assignment_outlined,
                            title: 'Upcoming Mid-Term Exams',
                            subtitle:
                                'Mathematics Test scheduled for Grade 5A on Friday',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            icon: Icons.notifications_active_outlined,
                            title: 'Staff Circular',
                            subtitle:
                                'Monthly faculty meeting at 02:00 PM in Conference Room',
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

  Widget _buildWelcomeHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const ClipOval(
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 38,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${widget.teacherName}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.designation,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherStatusSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Role: Secondary Educator',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'On Duty (08:00 AM - 02:00 PM)',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Today\'s Assigned Lectures & Tasks:',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildScheduleTile(
                time: '08:30 AM - 09:15 AM',
                subject: 'Mathematics',
                grade: 'Grade 5A (Room 12)'),
            _buildScheduleTile(
                time: '09:45 AM - 10:30 AM',
                subject: 'Computer Science',
                grade: 'Grade 6B (Lab 2)'),
            _buildScheduleTile(
                time: '11:15 AM - 12:00 PM',
                subject: 'Physics Lecture',
                grade: 'Grade 8C (Room 04)'),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleTile({
    required String time,
    required String subject,
    required String grade,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          Text(
            '$time  •  ',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              '$subject ($grade)',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
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
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.brown.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNotificationItem('New homework submission from Grade 5A'),
            const Divider(color: Colors.white24),
            _buildNotificationItem('Principal posted a new announcement'),
            const Divider(color: Colors.white24),
            _buildNotificationItem('Timetable updated for Friday session'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.amber),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: Colors.black.withValues(alpha: 0.35),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person,
                            color: Colors.white, size: 34),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.teacherName,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.designation,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  title: 'My Profile',
                  onTap: () => _navigateTo(context, const MyProfileScreen()),
                ),
                _buildDrawerItem(
                  icon: Icons.schedule_outlined,
                  title: 'Classes & Timetable',
                  onTap: () =>
                      _navigateTo(context, const TeacherTimetableScreen()),
                ),
                _buildDrawerItem(
                  icon: Icons.groups_outlined,
                  title: 'View Students',
                  onTap: () =>
                      _navigateTo(context, const ViewStudentsScreen()),
                ),
                _buildDrawerItem(
                  icon: Icons.fact_check_outlined,
                  title: 'Mark Attendance',
                  onTap: () =>
                      _navigateTo(context, const MarkAttendanceScreen()),
                ),
                _buildDrawerItem(
                  icon: Icons.menu_book_outlined,
                  title: 'Post Homework',
                  onTap: () =>
                      _navigateTo(context, const PostHomeworkScreen()),
                ),
                _buildDrawerItem(
                  icon: Icons.grade_outlined,
                  title: 'Upload Marks',
                  onTap: () =>
                      _navigateTo(context, const UploadMarksScreen()),
                ),
                _buildDrawerItem(
                  icon: Icons.campaign_outlined,
                  title: 'Post Announcement',
                  onTap: () =>
                      _navigateTo(context, const PostAnnouncementScreen()),
                ),
                _buildDrawerItem(
                  icon: Icons.report_problem_outlined,
                  title: 'Submit Complaint',
                  onTap: () =>
                      _navigateTo(context, const SubmitComplaintScreen()),
                ),
                _buildDrawerItem(
                  icon: Icons.people_outline,
                  title: 'View Users',
                  onTap: () => _navigateTo(context, const UsersListScreen()),
                ),
                const Divider(color: Colors.white24),
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
      ),
      onTap: onTap,
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}