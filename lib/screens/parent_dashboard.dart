import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  final Color primaryBrown = const Color(0xFF8D6E63);
  final Color darkBrown = const Color(0xFF4E342E);

  final List<Map<String, dynamic>> subjects = [
    {
      'name': 'Mathematics',
      'teacher': 'Mr. Asif Raza',
      'icon': Icons.calculate_outlined,
      'assignments': ['Algebra Worksheet #3', 'Geometry Quiz Preparation'],
      'teacherComplaint': 'Homework is not being submitted on time.',
      'marks': {'1st Term': '88/100', '2nd Term': '92/100', 'Final Term': 'Pending'}
    },
    {
      'name': 'English',
      'teacher': 'Ms. Ayesha Malik',
      'icon': Icons.menu_book_outlined,
      'assignments': ['Essay Writing', 'Grammar Unit 4 Exercises'],
      'teacherComplaint': 'Needs more attention during class tests.',
      'marks': {'1st Term': '78/100', '2nd Term': '85/100', 'Final Term': 'Pending'}
    },
    {
      'name': 'Science',
      'teacher': 'Dr. Tariq Mahmood',
      'icon': Icons.science_outlined,
      'assignments': ['Biology Model Chart Project'],
      'teacherComplaint': 'Doing very well overall.',
      'marks': {'1st Term': '90/100', '2nd Term': '88/100', 'Final Term': 'Pending'}
    },
    {
      'name': 'Urdu',
      'teacher': 'Mrs. Farhana Shah',
      'icon': Icons.history_edu_outlined,
      'assignments': ['Lesson #5 Explanation', 'Letter Writing'],
      'teacherComplaint': 'Needs to work on spelling.',
      'marks': {'1st Term': '82/100', '2nd Term': '80/100', 'Final Term': 'Pending'}
    },
    {
      'name': 'Computer',
      'teacher': 'Engr. Bilal Hassan',
      'icon': Icons.computer_outlined,
      'assignments': ['Scratch Programming Task'],
      'teacherComplaint': 'Excellent performance in lab practicals.',
      'marks': {'1st Term': '95/100', '2nd Term': '96/100', 'Final Term': 'Pending'}
    },
    {
      'name': 'Islamiyat',
      'teacher': 'Qari Abdul Rehman',
      'icon': Icons.mosque_outlined,
      'assignments': ['Surah Memorization Revision'],
      'teacherComplaint': 'Excellent academic performance, well done.',
      'marks': {'1st Term': '98/100', '2nd Term': '95/100', 'Final Term': 'Pending'}
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EB),
      drawer: _buildSideBar(context),
      body: Stack(
        children: [
          // Background image (blurred)
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Image.asset(
                'assets/images/background.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color.fromARGB(64, 245, 242, 235),
                ),
              ),
            ),
          ),

          // Dark overlay for readability (replaces previous white overlay
          // and the brown gradient header block)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.45),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: menu + logo + school name (left) ... notification bell (right)
                  Row(
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      const SizedBox(width: 5),
                      ClipOval(
                        child: Image.asset(
                          'assets/images/logo.jpg',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const CircleAvatar(
                            backgroundColor: Colors.white24,
                            child: Icon(Icons.school, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Khyber Public School",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Parent Portal Dashboard",
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.notifications_active, color: Colors.white, size: 24),
                        onPressed: _showEventsDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Student Profile Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Color(0xFFD7CCC8),
                          child: Icon(Icons.person, size: 36, color: Color(0xFF4E342E)),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Muhammad Hamza",
                                style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: darkBrown,
                                ),
                              ),
                              Text(
                                "Class: Grade 5A | Roll No: 18",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Subjects Grid
                  Text(
                    "Subjects & Class Teachers",
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: subjects.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.05,
                    ),
                    itemBuilder: (context, index) {
                      final item = subjects[index];
                      return InkWell(
                        onTap: () => _showSubjectDetailsModal(item),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.white.withValues(alpha: 0.25),
                                child: Icon(item['icon'], color: Colors.white, size: 26),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['name'],
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item['teacher'],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 25),

                  // Admin Complaint Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryBrown, darkBrown],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lock, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Private Complaint to School Admin",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "This complaint goes directly to Principal/Admin only.",
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: darkBrown,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _showAdminComplaintDialog,
                            child: const Text("Submit Direct Complaint", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- SIDEBAR (DRAWER) ---
  Widget _buildSideBar(BuildContext context) {
    return Drawer(
     backgroundColor: const Color(0xFF2B211D),
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [darkBrown, primaryBrown],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                _showProfileDialog();
              },
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, size: 32, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Muhammad Hamza",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "View Profile",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white70),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _buildDrawerTile(
                  icon: Icons.person_outline,
                  title: "My Profile",
                  subtitle: "Student & Parent Info",
                  onTap: () {
                    Navigator.pop(context);
                    _showProfileDialog();
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.receipt_long_outlined,
                  title: "Fee Details & Late Charges",
                  subtitle: "Challan status & Deadlines",
                  onTap: () {
                    Navigator.pop(context);
                    _showFeeDetailsDialog();
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.calendar_month_outlined,
                  title: "Weekly Time Table",
                  subtitle: "Days, Subjects & Class Teachers",
                  onTap: () {
                    Navigator.pop(context);
                    _showTimeTableDialog();
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.article_outlined,
                  title: "Exams Date Sheet",
                  subtitle: "Upcoming Examination Schedule",
                  onTap: () {
                    Navigator.pop(context);
                    _showDateSheetDialog();
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.rate_review_outlined,
                  title: "Teacher Review & Behavior",
                  subtitle: "Class Participation & Activity Report",
                  onTap: () {
                    Navigator.pop(context);
                    _showTeacherReviewDialog();
                  },
                ),
              ],
            ),
          ),
         const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: Text("Logout", style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: primaryBrown,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.white70,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.white70),
        onTap: onTap,
      ),
    );
  }

  // --- DIALOGS ---

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Student Profile", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: darkBrown)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: primaryBrown.withValues(alpha: 0.15),
              child: Icon(Icons.person, size: 40, color: darkBrown),
            ),
            const SizedBox(height: 14),
            Text("Muhammad Hamza", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: darkBrown)),
            const SizedBox(height: 4),
            Text("Class: Grade 5A | Roll No: 18", style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87)),
            const Divider(height: 24),
            const ListTile(
              dense: true,
              leading: Icon(Icons.badge_outlined),
              title: Text("Admission No."),
              trailing: Text("KPS-2021-118"),
            ),
            const ListTile(
              dense: true,
              leading: Icon(Icons.family_restroom_outlined),
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
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
      ),
    );
  }

  void _showEventsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Notifications & Activities", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: darkBrown)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNotificationItem("Annual Picnic Trip", "Trip to Khanpur Dam on 25th Oct. Ticket Rs. 1500.", Icons.directions_bus),
            _buildNotificationItem("Sports Week 2026", "Inter-house sports competitions starting next Monday.", Icons.sports_cricket),
            _buildNotificationItem("Quiz Competition", "Science & Math quiz for Grade 5 on Friday.", Icons.emoji_events),
            _buildNotificationItem("PTM Meeting", "Parent-Teacher meeting scheduled for 30th of this month.", Icons.groups),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
      ),
    );
  }

  void _showFeeDetailsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Fee Schedule & Notifications", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: darkBrown)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.orange)),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text("Due Date: 10th of every month. Rs. 500 Late Fee applies after deadline.", style: GoogleFonts.poppins(fontSize: 11, color: Colors.orange.shade900)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const ListTile(title: Text("Monthly Tuition Fee"), trailing: Text("Rs. 6,500", style: TextStyle(fontWeight: FontWeight.bold))),
            const ListTile(title: Text("Computer & Lab Charges"), trailing: Text("Rs. 800", style: TextStyle(fontWeight: FontWeight.bold))),
            const Divider(),
            const ListTile(title: Text("Total Payable", style: TextStyle(fontWeight: FontWeight.bold)), trailing: Text("Rs. 7,300", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown))),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
      ),
    );
  }

  void _showTimeTableDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Weekly Time Table", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: darkBrown)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: const [
              ListTile(leading: CircleAvatar(child: Text("Mon")), title: Text("Maths, English, Science"), subtitle: Text("Teachers: Mr. Asif, Ms. Ayesha")),
              ListTile(leading: CircleAvatar(child: Text("Tue")), title: Text("Urdu, Computer, Islamiyat"), subtitle: Text("Teachers: Mrs. Farhana, Engr. Bilal")),
              ListTile(leading: CircleAvatar(child: Text("Wed")), title: Text("Science Lab & Mathematics"), subtitle: Text("Teachers: Dr. Tariq, Mr. Asif")),
              ListTile(leading: CircleAvatar(child: Text("Thu")), title: Text("English Grammar & Urdu"), subtitle: Text("Teachers: Ms. Ayesha, Mrs. Farhana")),
              ListTile(leading: CircleAvatar(child: Text("Fri")), title: Text("Computer Lab & Sports Activity"), subtitle: Text("Teachers: Engr. Bilal, Sports Dept")),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
      ),
    );
  }

  void _showDateSheetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Mid-Term Exam Date Sheet", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: darkBrown)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            ListTile(title: Text("Mathematics"), subtitle: Text("Monday, 10th Nov | 09:00 AM")),
            ListTile(title: Text("English Paper"), subtitle: Text("Wednesday, 12th Nov | 09:00 AM")),
            ListTile(title: Text("General Science"), subtitle: Text("Friday, 14th Nov | 09:00 AM")),
            ListTile(title: Text("Computer Studies"), subtitle: Text("Monday, 17th Nov | 09:00 AM")),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
      ),
    );
  }

  void _showTeacherReviewDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Teacher Performance Review", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: darkBrown)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Class Participation: Excellent (85%)", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 5),
            Text("Behavior & Discipline: Good & Respectful", style: GoogleFonts.poppins(fontSize: 12, color: Colors.green[800])),
            const SizedBox(height: 10),
            Text("Overall Teacher Review:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
              child: Text(
                "Hamza is active in practical sessions, especially Computer and Science. Homework submission speed needs a little improvement in Mathematics.",
                style: GoogleFonts.poppins(fontSize: 11),
              ),
            )
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
      ),
    );
  }

  Widget _buildNotificationItem(String title, String desc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: darkBrown, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(desc, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[700])),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showSubjectDetailsModal(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: primaryBrown.withValues(alpha: 0.15),
                    child: Icon(item['icon'], color: darkBrown),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: darkBrown),
                      ),
                      Text("Teacher: ${item['teacher']}", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  )
                ],
              ),
              const Divider(height: 30),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Assignments", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: darkBrown)),
                      const SizedBox(height: 8),
                      ...(item['assignments'] as List<String>).map((task) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: Colors.brown, size: 16),
                            const SizedBox(width: 8),
                            Text(task, style: GoogleFonts.poppins(fontSize: 13)),
                          ],
                        ),
                      )),
                      const SizedBox(height: 20),
                      Text("Teacher Remarks", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: darkBrown)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Text(item['teacherComplaint'], style: GoogleFonts.poppins(fontSize: 12)),
                      ),
                      const SizedBox(height: 20),
                      Text("Term-Wise Examination Marks", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: darkBrown)),
                      const SizedBox(height: 10),
                      Row(
                        children: (item['marks'] as Map<String, String>).entries.map((e) {
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAF8F5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: primaryBrown.withValues(alpha: 0.2)),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    e.key,
                                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: primaryBrown),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    e.value,
                                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: darkBrown),
                                  )
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _showAdminComplaintDialog() {
    final TextEditingController complaintController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Private Complaint to Admin", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: darkBrown)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("This will be sent directly to Admin (Teachers cannot see this).", style: TextStyle(fontSize: 12, color: Colors.grey[700])),
              const SizedBox(height: 12),
              TextField(
                controller: complaintController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Enter complaint detail...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryBrown),
              onPressed: () {
                if (complaintController.text.isNotEmpty) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Submitted directly to Admin!"), backgroundColor: Colors.green),
                  );
                }
              },
              child: const Text("Send", style: TextStyle(color: Colors.white)),
            )
          ],
        );
      },
    );
  }
}