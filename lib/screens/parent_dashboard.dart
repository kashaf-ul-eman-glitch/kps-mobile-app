import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  static const Color darkBrown = Color(0xFF3E2723);
  static const Color primaryBrown = Color(0xFF795548);

  // Family children (same parent account can have more than one child)
  final List<Map<String, String>> familyChildren = [
    {
      'name': 'Muhammad Hamza',
      'className': 'Grade 5A',
      'roll': '18',
    },
    {
      'name': 'Ayesha Hamza',
      'className': 'Grade 3B',
      'roll': '09',
    },
  ];

  int _selectedChildIndex = 0;

  final List<Map<String, dynamic>> subjects = [
    {
      'name': 'Mathematics',
      'teacher': 'Mr. Asif Raza',
      'icon': Icons.calculate_outlined,
      'assignments': [
        'Algebra Worksheet #3',
        'Geometry Quiz Preparation'
      ],
      'teacherComplaint':
          'Homework is not being submitted on time.',
      'marks': {
        '1st Term': '88/100',
        '2nd Term': '92/100',
        'Final Term': 'Pending'
      }
    },
    {
      'name': 'English',
      'teacher': 'Ms. Ayesha Malik',
      'icon': Icons.menu_book_outlined,
      'assignments': [
        'Essay Writing',
        'Grammar Unit 4 Exercises'
      ],
      'teacherComplaint':
          'Needs more attention during class tests.',
      'marks': {
        '1st Term': '78/100',
        '2nd Term': '85/100',
        'Final Term': 'Pending'
      }
    },
    {
      'name': 'Science',
      'teacher': 'Dr. Tariq Mahmood',
      'icon': Icons.science_outlined,
      'assignments': [
        'Biology Model Chart Project'
      ],
      'teacherComplaint':
          'Doing very well overall.',
      'marks': {
        '1st Term': '90/100',
        '2nd Term': '88/100',
        'Final Term': 'Pending'
      }
    },
    {
      'name': 'Urdu',
      'teacher': 'Mrs. Farhana Shah',
      'icon': Icons.history_edu_outlined,
      'assignments': [
        'Lesson #5 Explanation',
        'Letter Writing'
      ],
      'teacherComplaint':
          'Needs to work on spelling.',
      'marks': {
        '1st Term': '82/100',
        '2nd Term': '80/100',
        'Final Term': 'Pending'
      }
    },
    {
      'name': 'Computer',
      'teacher': 'Engr. Bilal Hassan',
      'icon': Icons.computer_outlined,
      'assignments': [
        'Scratch Programming Task'
      ],
      'teacherComplaint':
          'Excellent performance in lab practicals.',
      'marks': {
        '1st Term': '95/100',
        '2nd Term': '96/100',
        'Final Term': 'Pending'
      }
    },
    {
      'name': 'Islamiyat',
      'teacher': 'Qari Abdul Rehman',
      'icon': Icons.mosque_outlined,
      'assignments': [
        'Surah Memorization Revision'
      ],
      'teacherComplaint':
          'Excellent academic performance, well done.',
      'marks': {
        '1st Term': '98/100',
        '2nd Term': '95/100',
        'Final Term': 'Pending'
      }
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context),
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
                size: 26,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
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
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 20,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),

            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Text(
                  'Parent Portal Dashboard',
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
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 26,
                ),
                onPressed: () {
                  _showEventsDialog(context);
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
                    '4',
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

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/background.jpg',
            ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),

                    _buildWelcomeHeader(),

                    const SizedBox(height: 15),

                    _buildStudentStatusSection(),

                    const SizedBox(height: 20),

                    _buildQuickOverviewSection(),

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

  // ------------------------------------------------------------
  // Student Header
  // ------------------------------------------------------------

  Widget _buildWelcomeHeader() {
    final child = familyChildren[_selectedChildIndex];

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
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
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
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        child['name']!,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    if (familyChildren.length > 1)
                      PopupMenuButton<int>(
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                        color: Colors.brown.shade900,
                        onSelected: (index) {
                          setState(() {
                            _selectedChildIndex = index;
                          });
                        },
                        itemBuilder: (context) {
                          return List.generate(
                            familyChildren.length,
                            (index) {
                              return PopupMenuItem<int>(
                                value: index,
                                child: Text(
                                  familyChildren[index]['name']!,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),

                Text(
                  'Class: ${child['className']}  |  Roll No: ${child['roll']}',
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

  // ------------------------------------------------------------
  // Student Status & Subjects
  // ------------------------------------------------------------

  Widget _buildStudentStatusSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Khyber Public School',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Attendance: Present',
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
              'Subjects & Class Teachers:',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ...subjects.map(
              (item) => _buildSubjectTile(item),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectTile(
    Map<String, dynamic> item,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),

      child: InkWell(
        onTap: () {
          _showSubjectDetailsModal(item);
        },

        child: Row(
          children: [
            Icon(
              item['icon'] as IconData,
              color: Colors.white70,
              size: 16,
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Text(
                '${item['name']}  •  ${item['teacher']}',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: Colors.white54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Quick Overview
  // ------------------------------------------------------------

  Widget _buildQuickOverviewSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),

      decoration: BoxDecoration(
        color: Colors.brown.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
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
            icon: Icons.receipt_long_outlined,
            title: 'Fee Due Date',
            subtitle:
                'Rs. 7,300 payable by the 10th of every month',
            onTap: _showFeeDetailsDialog,
          ),

          const SizedBox(height: 12),

          _buildInfoCard(
            icon: Icons.article_outlined,
            title: 'Mid-Term Exams',
            subtitle:
                'Mathematics paper on Monday, 10th Nov',
            onTap: _showDateSheetDialog,
          ),

          const SizedBox(height: 12),

          _buildInfoCard(
            icon: Icons.groups_outlined,
            title: 'PTM Meeting',
            subtitle:
                'Parent-Teacher meeting scheduled for 30th of this month',
            onTap: () {
              _showEventsDialog(context);
            },
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,

            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.brown.shade900,
                padding:
                    const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              onPressed: _showAdminComplaintDialog,

              icon: const Icon(
                Icons.lock_outline,
              ),

              label: const Text(
                'Submit Direct Complaint to Admin',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),

      child: Container(
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

              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
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

            const Icon(
              Icons.chevron_right,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Drawer
  // ------------------------------------------------------------

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,

      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12,
            sigmaY: 12,
          ),

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
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white24,
                        child: Icon(
                          Icons.school,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Khyber Public School',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),

                      Text(
                        'Parent Quick Menu',
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
                  onTap: () {
                    Navigator.pop(context);
                    _showProfileDialog();
                  },
                ),

                _buildDrawerItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'Fee Details & Late Charges',
                  onTap: () {
                    Navigator.pop(context);
                    _showFeeDetailsDialog();
                  },
                ),

                _buildDrawerItem(
                  icon: Icons.calendar_month_outlined,
                  title: 'Weekly Time Table',
                  onTap: () {
                    Navigator.pop(context);
                    _showTimeTableDialog();
                  },
                ),

                _buildDrawerItem(
                  icon: Icons.article_outlined,
                  title: 'Exams Date Sheet',
                  onTap: () {
                    Navigator.pop(context);
                    _showDateSheetDialog();
                  },
                ),

                _buildDrawerItem(
                  icon: Icons.rate_review_outlined,
                  title: 'Teacher Review & Behavior',
                  onTap: () {
                    Navigator.pop(context);
                    _showTeacherReviewDialog();
                  },
                ),

                _buildDrawerItem(
                  icon: Icons.report_problem_outlined,
                  title: 'Submit Complaint to Admin',
                  onTap: () {
                    Navigator.pop(context);
                    _showAdminComplaintDialog();
                  },
                ),

                const Divider(
                  color: Colors.white24,
                ),

                _buildDrawerItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () {
                    Navigator.pop(context);
                  },
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
      leading: Icon(
        icon,
        color: Colors.white,
      ),

      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14,
        ),
      ),

      onTap: onTap,
    );
  }

  // ------------------------------------------------------------
  // Profile Dialog
  // ------------------------------------------------------------

  void _showProfileDialog() {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: Text(
            "Student Profile",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: darkBrown,
            ),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor:
                    primaryBrown.withValues(alpha: 0.15),

                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: darkBrown,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                "Muhammad Hamza",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkBrown,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                "Class: Grade 5A | Roll No: 18",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),

              const Divider(height: 24),

              const ListTile(
                dense: true,
                leading: Icon(Icons.badge_outlined),
                title: Text("Admission No."),
                trailing: Text("KPS-2021-118"),
              ),

              const ListTile(
                dense: true,
                leading: Icon(
                  Icons.family_restroom_outlined,
                ),
                title: Text("Father Name"),
                trailing: Text("Mr. Imran Khan"),
              ),

              const ListTile(
                dense: true,
                leading: Icon(Icons.phone_outlined),
                title: Text("Contact"),
                trailing: Text("+92 300 1234567"),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // Notifications
  // ------------------------------------------------------------

  void _showEventsDialog([BuildContext? dialogContext]) {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.brown.shade900,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: Text(
            'Notifications & Activities',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNotificationItem(
                'Annual Picnic Trip - Khanpur Dam on 25th Oct. Ticket Rs. 1500.',
              ),

              const Divider(
                color: Colors.white24,
              ),

              _buildNotificationItem(
                'Sports Week 2026 - Inter-house sports competitions start next Monday.',
              ),

              const Divider(
                color: Colors.white24,
              ),

              _buildNotificationItem(
                'Quiz Competition - Science & Math quiz for Grade 5 on Friday.',
              ),

              const Divider(
                color: Colors.white24,
              ),

              _buildNotificationItem(
                'PTM Meeting scheduled for the 30th of this month.',
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),

      child: Row(
        children: [
          const Icon(
            Icons.circle,
            size: 8,
            color: Colors.amber,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // Fee Details
  // ------------------------------------------------------------

  void _showFeeDetailsDialog() {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.brown.shade900,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: Text(
            'Fee Schedule & Notifications',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Container(
                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.orange,
                  ),
                ),

                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        'Due Date: 10th of every month. Rs. 500 Late Fee applies after deadline.',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.orange.shade100,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              ListTile(
                title: Text(
                  'Monthly Tuition Fee',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                  ),
                ),

                trailing: Text(
                  'Rs. 6,500',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              ListTile(
                title: Text(
                  'Computer & Lab Charges',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                  ),
                ),

                trailing: Text(
                  'Rs. 800',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Divider(
                color: Colors.white24,
              ),

              ListTile(
                title: Text(
                  'Total Payable',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                trailing: Text(
                  'Rs. 7,300',
                  style: GoogleFonts.poppins(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // Time Table
  // ------------------------------------------------------------

  void _showTimeTableDialog() {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.brown.shade900,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: Text(
            'Weekly Time Table',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          content: SizedBox(
            width: double.maxFinite,

            child: ListView(
              shrinkWrap: true,

              children: [
                _buildTimeTableTile(
                  'Mon',
                  'Maths, English, Science',
                  'Teachers: Mr. Asif, Ms. Ayesha',
                ),

                _buildTimeTableTile(
                  'Tue',
                  'Urdu, Computer, Islamiyat',
                  'Teachers: Mrs. Farhana, Engr. Bilal',
                ),

                _buildTimeTableTile(
                  'Wed',
                  'Science Lab & Mathematics',
                  'Teachers: Dr. Tariq, Mr. Asif',
                ),

                _buildTimeTableTile(
                  'Thu',
                  'English Grammar & Urdu',
                  'Teachers: Ms. Ayesha, Mrs. Farhana',
                ),

                _buildTimeTableTile(
                  'Fri',
                  'Computer Lab & Sports Activity',
                  'Teachers: Engr. Bilal, Sports Dept',
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimeTableTile(
    String day,
    String subjectsText,
    String teachersText,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.white24,

        child: Text(
          day,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
          ),
        ),
      ),

      title: Text(
        subjectsText,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 13,
        ),
      ),

      subtitle: Text(
        teachersText,
        style: GoogleFonts.poppins(
          color: Colors.white70,
          fontSize: 11,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Exam Date Sheet
  // ------------------------------------------------------------

  void _showDateSheetDialog() {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.brown.shade900,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: Text(
            'Mid-Term Exam Date Sheet',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              _buildDateSheetTile(
                'Mathematics',
                'Monday, 10th Nov | 09:00 AM',
              ),

              _buildDateSheetTile(
                'English Paper',
                'Wednesday, 12th Nov | 09:00 AM',
              ),

              _buildDateSheetTile(
                'General Science',
                'Friday, 14th Nov | 09:00 AM',
              ),

              _buildDateSheetTile(
                'Computer Studies',
                'Monday, 17th Nov | 09:00 AM',
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateSheetTile(
    String subject,
    String schedule,
  ) {
    return ListTile(
      title: Text(
        subject,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 13,
        ),
      ),

      subtitle: Text(
        schedule,
        style: GoogleFonts.poppins(
          color: Colors.white70,
          fontSize: 11,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Teacher Review
  // ------------------------------------------------------------

  void _showTeacherReviewDialog() {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.brown.shade900,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: Text(
            'Teacher Performance Review',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                'Class Participation: Excellent (85%)',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Behavior & Discipline: Good & Respectful',
                style: GoogleFonts.poppins(
                  color: Colors.greenAccent,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Overall Teacher Review:',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 5),

              Container(
                padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius:
                      BorderRadius.circular(10),
                ),

                child: Text(
                  'Hamza is active in practical sessions, especially Computer and Science. Homework submission speed needs a little improvement in Mathematics.',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // Subject Details
  // ------------------------------------------------------------

  void _showSubjectDetailsModal(
    Map<String, dynamic> item,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (context) {
        return Container(
          height:
              MediaQuery.of(context).size.height * 0.75,

          decoration: const BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),

          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,

                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        Colors.brown.withValues(
                      alpha: 0.15,
                    ),

                    child: Icon(
                      item['icon'] as IconData,
                      color: Colors.brown.shade800,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Text(
                          item['name'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown.shade800,
                          ),
                        ),

                        Text(
                          "Teacher: ${item['teacher']}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Divider(height: 30),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        'Assignments',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.brown.shade800,
                        ),
                      ),

                      const SizedBox(height: 8),

                      ...(item['assignments'] as List)
                          .map(
                        (task) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom: 6,
                            ),

                            child: Row(
                              children: [
                                const Icon(
                                  Icons
                                      .check_circle_outline,
                                  color: Colors.brown,
                                  size: 16,
                                ),

                                const SizedBox(width: 8),

                                Expanded(
                                  child: Text(
                                    task.toString(),
                                    style:
                                        GoogleFonts.poppins(
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'Teacher Remarks',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.brown.shade800,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius:
                              BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.amber.shade300,
                          ),
                        ),

                        child: Text(
                          item['teacherComplaint']
                              .toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'Term-Wise Examination Marks',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.brown.shade800,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: (item['marks']
                                as Map<String, String>)
                            .entries
                            .map(
                          (e) {
                            return Expanded(
                              child: Container(
                                margin:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 4,
                                ),

                                padding:
                                    const EdgeInsets.all(
                                  10,
                                ),

                                decoration: BoxDecoration(
                                  color:
                                      const Color(
                                    0xFFFAF8F5,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                    12,
                                  ),
                                  border: Border.all(
                                    color: Colors.brown
                                        .withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),

                                child: Column(
                                  children: [
                                    Text(
                                      e.key,
                                      textAlign:
                                          TextAlign.center,
                                      style: GoogleFonts
                                          .poppins(
                                        fontSize: 11,
                                        fontWeight:
                                            FontWeight.bold,
                                        color:
                                            Colors.brown,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 5,
                                    ),

                                    Text(
                                      e.value,
                                      textAlign:
                                          TextAlign.center,
                                      style: GoogleFonts
                                          .poppins(
                                        fontSize: 13,
                                        fontWeight:
                                            FontWeight.bold,
                                        color: Colors.brown
                                            .shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // Admin Complaint
  // ------------------------------------------------------------

  void _showAdminComplaintDialog() {
    final TextEditingController complaintController =
        TextEditingController();

    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.brown.shade900,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: Row(
            children: [
              const Icon(
                Icons.security,
                color: Colors.white,
              ),

              const SizedBox(width: 8),

              Text(
                'Private Complaint',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                'Type your message below. This note is sent directly to school management and remains completely confidential.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: complaintController,
                maxLines: 4,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration: InputDecoration(
                  hintText:
                      'Enter your concern or feedback here...',

                  hintStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white54,
                  ),

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(
                      color: Colors.white38,
                    ),
                  ),

                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                ),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor:
                    Colors.brown.shade900,

                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),

              onPressed: () {
                if (complaintController.text
                    .trim()
                    .isNotEmpty) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Your direct complaint has been submitted securely to the Admin.',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },

              child: const Text(
                'Submit',
              ),
            ),
          ],
        );
      },
    );
  }
}