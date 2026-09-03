import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'teacher_profile_screen.dart';
import 'view_students_screen.dart';
import 'mark_attendance_screen.dart';
import 'post_homework_screen.dart';
import 'upload_marks_screen.dart';
import 'teacher_remarks_screen.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const List<String> _weekDayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  String _teacherName = 'Teacher';
  String _designation = 'Teacher';
  String _teacherEmail = '';
  bool _isLoadingTeacher = true;

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null || user.email == null || user.email!.isEmpty) {
        if (!mounted) return;
        setState(() => _isLoadingTeacher = false);
        return;
      }

      final String loginEmail = user.email!.trim().toLowerCase();
      final QuerySnapshot teacherQuery = await _firestore
          .collection('teachers')
          .where('email', isEqualTo: loginEmail)
          .limit(1)
          .get();

      if (teacherQuery.docs.isEmpty) {
        if (!mounted) return;
        setState(() {
          _teacherEmail = loginEmail;
          _isLoadingTeacher = false;
        });
        return;
      }

      final Map<String, dynamic> teacherData = teacherQuery.docs.first.data() as Map<String, dynamic>;
      final String name = teacherData['fullName']?.toString().trim().isNotEmpty == true
          ? teacherData['fullName'].toString().trim()
          : teacherData['name']?.toString().trim() ?? '';
      final String designation = teacherData['role']?.toString().trim().isNotEmpty == true
          ? teacherData['role'].toString().trim()
          : teacherData['designation']?.toString().trim() ?? 'Teacher';

      if (!mounted) return;
      setState(() {
        _teacherName = name.isNotEmpty ? name : 'Teacher';
        _designation = designation.isNotEmpty ? designation : 'Teacher';
        _teacherEmail = teacherData['email']?.toString().trim() ?? loginEmail;
        _isLoadingTeacher = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingTeacher = false);
    }
  }

  /// Notifications don't carry a per-teacher read state (isRead is shared
  /// across everyone the notification was sent to), so each teacher's
  /// "seen up to" time is tracked separately here.
  String _teacherReadDocId(String teacherEmailKey) =>
      teacherEmailKey.isEmpty ? 'unknown' : teacherEmailKey;

  Future<void> _markNotificationsSeen(String teacherEmailKey) async {
    try {
      await _firestore
          .collection('teacher_notification_reads')
          .doc(_teacherReadDocId(teacherEmailKey))
          .set({'lastSeenAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    } catch (_) {
      // Ignore — badge just won't clear until the next successful attempt.
    }
  }

  bool _notificationTargetsTeacher(Map<String, dynamic> data, String teacherEmailKey) {
    final String targetRole = data['targetRole']?.toString() ?? 'all';
    if (targetRole == 'all' || targetRole == 'teacher') {
      return true;
    }
    if (targetRole == 'specific') {
      final List<dynamic> recipientEmails = data['recipientEmails'] is List
          ? data['recipientEmails'] as List<dynamic>
          : [];
      return recipientEmails
          .map((e) => e.toString().toLowerCase())
          .contains(teacherEmailKey);
    }
    return false;
  }

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.85),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Notifications',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('notifications')
                .orderBy('createdAt', descending: true)
                .limit(30)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator(color: Colors.white)),
                );
              }
              final String teacherEmailKey =
                  (_auth.currentUser?.email ?? _teacherEmail).trim().toLowerCase();
              final List<QueryDocumentSnapshot> allDocs = snapshot.data?.docs ?? [];
              final List<QueryDocumentSnapshot> docs = allDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _notificationTargetsTeacher(data, teacherEmailKey);
              }).take(5).toList();
              if (docs.isEmpty) {
                return Text(
                  'No new notifications.',
                  style: GoogleFonts.poppins(color: Colors.white70),
                );
              }
              return SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.white24),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.campaign, color: Colors.amber),
                      title: Text(
                        data['title']?.toString() ?? 'Notification',
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        data['message']?.toString() ?? '',
                        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: GoogleFonts.poppins(color: Colors.amber)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 28),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white24),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.school, color: Colors.white, size: 22),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Teacher Portal',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) {
              final String teacherEmailKey =
                  (_auth.currentUser?.email ?? _teacherEmail).trim().toLowerCase();
              final String readDocId = _teacherReadDocId(teacherEmailKey);

              return StreamBuilder<DocumentSnapshot>(
                stream: _firestore
                    .collection('teacher_notification_reads')
                    .doc(readDocId)
                    .snapshots(),
                builder: (context, readSnapshot) {
                  Timestamp? lastSeenAt;
                  if (readSnapshot.data != null && readSnapshot.data!.exists) {
                    final readData = readSnapshot.data!.data() as Map<String, dynamic>?;
                    lastSeenAt = readData?['lastSeenAt'] is Timestamp
                        ? readData!['lastSeenAt'] as Timestamp
                        : null;
                  }

                  return StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('notifications')
                        .orderBy('createdAt', descending: true)
                        .limit(30)
                        .snapshots(),
                    builder: (context, snapshot) {
                      final int unseenCount = (snapshot.data?.docs ?? []).where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        if (!_notificationTargetsTeacher(data, teacherEmailKey)) {
                          return false;
                        }
                        final dynamic createdAtValue = data['createdAt'];
                        if (createdAtValue is! Timestamp) return false;
                        if (lastSeenAt == null) return true;
                        return createdAtValue.compareTo(lastSeenAt) > 0;
                      }).length;

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_active, color: Colors.amber, size: 26),
                            onPressed: () {
                              _markNotificationsSeen(teacherEmailKey);
                              _showNotificationsDialog();
                            },
                          ),
                          if (unseenCount > 0)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                child: Text(
                                  unseenCount > 9 ? '9+' : '$unseenCount',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/background.jpg'), fit: BoxFit.cover),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.black.withOpacity(0.25),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeHeader(),
                      const SizedBox(height: 20),
                      _buildTeacherStatusSection(),
                      const SizedBox(height: 20),
                      _buildFullWeekSection(),
                      const SizedBox(height: 20),
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

  Widget _buildWelcomeHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.white.withOpacity(0.2),
          child: const Icon(Icons.person, color: Colors.white, size: 34),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isLoadingTeacher ? 'Loading...' : 'Welcome, $_teacherName',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                _designation,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeacherStatusSection() {
    final String teacherEmailKey = (_auth.currentUser?.email ?? '').trim().toLowerCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Classes",
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.8), borderRadius: BorderRadius.circular(8)),
                child: Text('On Duty', style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 16),
          // Live stream: any admin edit (including turning a period OFF)
          // reflects here immediately without the teacher refreshing.
          StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('timetables').doc(teacherEmailKey).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Text('No schedule configured for this account.', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13));
              }

              final data = snapshot.data!.data() as Map<String, dynamic>?;
              final Map<String, dynamic> weeklySchedule = data?['weeklySchedule'] ?? {};

              final String todayName = _weekDayNames[DateTime.now().weekday - 1];

              final List<Map<String, dynamic>> periods = List<Map<String, dynamic>>.from(
                ((weeklySchedule[todayName] as List?) ?? []).map((e) => Map<String, dynamic>.from(e)),
              );

              periods.sort((a, b) => ((a['startMinutes'] ?? 0) as int).compareTo((b['startMinutes'] ?? 0) as int));

              if (periods.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('No classes scheduled for today ($todayName).', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 18,
                  headingRowHeight: 42,
                  dataRowMinHeight: 48,
                  dataRowMaxHeight: 56,
                  columns: [
                    DataColumn(label: Text('Time', style: GoogleFonts.poppins(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13))),
                    DataColumn(label: Text('Subject & Class', style: GoogleFonts.poppins(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13))),
                    DataColumn(label: Text('Status', style: GoogleFonts.poppins(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13))),
                  ],
                  rows: periods.map((item) {
                    final bool hasLecture = item['hasLecture'] ?? true;
                    return DataRow(
                      cells: [
                        DataCell(Text(item['time']?.toString() ?? '', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12))),
                        DataCell(Text('${item['subject']} (${item['class']})', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12))),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (hasLecture ? Colors.green : Colors.redAccent).withOpacity(0.85),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              hasLecture ? 'Active' : 'OFF',
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Read-only view of the whole week (Mon–Sat) so the teacher can check
  /// ahead, not just today. Same live Firestore stream as above.
  Widget _buildFullWeekSection() {
    final String teacherEmailKey = (_auth.currentUser?.email ?? '').trim().toLowerCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: DefaultTabController(
        length: _weekDayNames.length,
        initialIndex: DateTime.now().weekday - 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Full Week Timetable',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TabBar(
              isScrollable: true,
              labelColor: Colors.amber,
              unselectedLabelColor: Colors.white60,
              indicatorColor: Colors.amber,
              tabs: _weekDayNames.map((d) => Tab(text: d.substring(0, 3))).toList(),
            ),
            SizedBox(
              height: 260,
              child: StreamBuilder<DocumentSnapshot>(
                stream: _firestore.collection('timetables').doc(teacherEmailKey).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Center(
                      child: Text('No schedule configured yet.', style: GoogleFonts.poppins(color: Colors.white70)),
                    );
                  }
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  final Map<String, dynamic> weeklySchedule = data?['weeklySchedule'] ?? {};

                  return TabBarView(
                    children: _weekDayNames.map((day) {
                      final periods = List<Map<String, dynamic>>.from(
                        ((weeklySchedule[day] as List?) ?? []).map((e) => Map<String, dynamic>.from(e)),
                      )..sort((a, b) => ((a['startMinutes'] ?? 0) as int).compareTo((b['startMinutes'] ?? 0) as int));

                      if (periods.isEmpty) {
                        return Center(
                          child: Text('No classes on $day.', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                        );
                      }
                      return ListView.builder(
                        itemCount: periods.length,
                        itemBuilder: (context, i) {
                          final item = periods[i];
                          final bool hasLecture = item['hasLecture'] ?? true;
                          return Card(
                            color: Colors.white.withOpacity(0.92),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                backgroundColor: hasLecture ? Colors.green : Colors.red,
                                child: Icon(hasLecture ? Icons.check : Icons.close, color: Colors.white, size: 18),
                              ),
                              title: Text(
                                '${item['subject']} (${item['class']})',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              subtitle: Text(
                                '${item['time']}${hasLecture ? '' : '  •  Class OFF'}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: hasLecture ? Colors.black87 : Colors.redAccent,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    // Drawer stays transparent with a frosted-glass blur, but no longer has
    // a black tint over it — a soft indigo tint is used instead so text
    // stays readable without darkening the screen.
    return Drawer(
      backgroundColor: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.18),
            border: Border(right: BorderSide(color: Colors.white.withOpacity(0.15))),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.transparent),
                accountName: Text(_teacherName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                accountEmail: Text(_teacherEmail, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.school, color: Colors.white, size: 30),
                    ),
                  ),
                ),
              ),
              const Divider(color: Colors.white24, height: 1),
              _drawerItem(Icons.person, 'My Profile', () => _navigateTo(context, const MyProfileScreen())),
              _drawerItem(Icons.groups, 'View Students', () => _navigateTo(context, const ViewStudentsScreen())),
              _drawerItem(Icons.fact_check, 'Mark Attendance', () => _navigateTo(context, const MarkAttendanceScreen())),
              _drawerItem(Icons.menu_book, 'Post Homework', () => _navigateTo(context, const PostHomeworkScreen())),
              _drawerItem(Icons.grade, 'Upload Marks', () => _navigateTo(context, const UploadMarksScreen())),
              _drawerItem(Icons.report, 'Teacher Remarks', () => _navigateTo(context, const TeacherRemarksScreen())),
              const Divider(color: Colors.white24, height: 1),
              _drawerItem(Icons.logout, 'Logout', () {
                _auth.signOut().then((_) => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false));
              }, textColor: Colors.redAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap, {Color textColor = Colors.white}) {
    return ListTile(
      leading: Icon(icon, color: textColor, size: 22),
      title: Text(title, style: GoogleFonts.poppins(color: textColor, fontSize: 14)),
      onTap: onTap,
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}