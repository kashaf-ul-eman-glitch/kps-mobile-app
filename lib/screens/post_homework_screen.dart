import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PostHomeworkScreen extends StatefulWidget {
  const PostHomeworkScreen({super.key});

  @override
  State<PostHomeworkScreen> createState() => _PostHomeworkScreenState();
}

class _PostHomeworkScreenState extends State<PostHomeworkScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String _selectedSubject = 'Mathematics';
  String _selectedClass = 'Grade 1';
  String _selectedSection = 'All Sections';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _isPosting = false;

  // Filled in from the 'teachers' collection so parents see a real name
  // (the parent Homework screen shows this under "Teacher").
  String _teacherName = 'Teacher';

  final List<String> subjects = ['Mathematics', 'Science', 'Computer Science','Pak Study','English','Urdu','Islamiat','M.Q','Biology','Physics','Chemistry'];

  // Must match the class doc ids used by the Admission Form screen, since
  // students live at classes/{className}/students.
  final List<String> classes = [
    'Play Group',
    'Reception 1',
    'Reception 2',
    'Grade 1',
    'Grade 2',
    'Grade 3',
    'Grade 4',
    'Grade 5',
    'Grade 6',
    'Grade 7',
    'Grade 8',
    'Grade 9',
    'Grade 10',
    'Grade 11',
    'Grade 12',
  ];

  final List<String> sections = ['All Sections', 'Green', 'Blue', 'Red'];

  @override
  void initState() {
    super.initState();
    _loadTeacherName();
  }

  Future<void> _loadTeacherName() async {
    try {
      final String? email = _auth.currentUser?.email?.trim().toLowerCase();
      if (email == null || email.isEmpty) return;
      final snap = await _firestore.collection('teachers').where('email', isEqualTo: email).limit(1).get();
      if (snap.docs.isEmpty || !mounted) return;
      final data = snap.docs.first.data();
      final String name = (data['fullName'] ?? data['name'] ?? '').toString().trim();
      if (name.isNotEmpty) setState(() => _teacherName = name);
    } catch (_) {
      // Non-critical — falls back to 'Teacher' if this lookup fails.
    }
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  String _formatDueDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _postHomework() async {
    final String title = _titleController.text.trim();
    final String desc = _descController.text.trim();

    if (title.isEmpty) {
      _showSnack('Please enter a title');
      return;
    }

    setState(() => _isPosting = true);

    try {
      final String teacherUid = _auth.currentUser?.uid ?? '';

      // The parent-side Homework screen reads homework by matching
      // `parentUid` on each document (collection('homework').where(
      // 'parentUid', isEqualTo: <parent's uid>)). A teacher only picks a
      // class (+ optional section), so we look up every student under
      // classes/{selectedClass}/students — the exact path the Admission
      // Form screen writes to — collect their parents' uids, and write
      // one homework doc per parent. That's what actually makes a
      // class-level post show up for each parent.
      Query studentsQuery = _firestore.collection('classes').doc(_selectedClass).collection('students');
      if (_selectedSection != 'All Sections') {
        studentsQuery = studentsQuery.where('section', isEqualTo: _selectedSection);
      }
      final QuerySnapshot studentsSnap = await studentsQuery.get();

      final Set<String> parentUids = {};
      for (final doc in studentsSnap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String parentUid = (data['parentUid'] ?? '').toString().trim();
        if (parentUid.isNotEmpty) parentUids.add(parentUid);
      }

      if (parentUids.isEmpty) {
        if (!mounted) return;
        setState(() => _isPosting = false);
        _showSnack(
          'No students found in $_selectedClass'
          '${_selectedSection == 'All Sections' ? '' : ' ($_selectedSection)'} — homework was not sent.',
        );
        return;
      }

      final WriteBatch batch = _firestore.batch();
      for (final parentUid in parentUids) {
        final docRef = _firestore.collection('homework').doc();
        batch.set(docRef, {
          'title': title,
          'description': desc,
          'subject': _selectedSubject,
          'class': _selectedClass,
          'section': _selectedSection,
          'teacherId': teacherUid,
          'teacherName': _teacherName,
          'parentUid': parentUid,
          'dueDate': Timestamp.fromDate(_dueDate),
          'completed': false,
          'postedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();

      _titleController.clear();
      _descController.clear();

      if (!mounted) return;
      _showSnack('Homework sent to ${parentUids.length} parent(s) in $_selectedClass!');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed to post homework: $e');
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

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
                  const _TopBar(),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedClass,
                                      dropdownColor: Colors.brown[900],
                                      style: GoogleFonts.poppins(color: Colors.white),
                                      isExpanded: true,
                                      decoration: _fieldDecoration('Class'),
                                      items: classes
                                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                          .toList(),
                                      onChanged: (val) => setState(() => _selectedClass = val!),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedSection,
                                      dropdownColor: Colors.brown[900],
                                      style: GoogleFonts.poppins(color: Colors.white),
                                      isExpanded: true,
                                      decoration: _fieldDecoration('Section'),
                                      items: sections
                                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                          .toList(),
                                      onChanged: (val) => setState(() => _selectedSection = val!),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              DropdownButtonFormField<String>(
                                value: _selectedSubject,
                                dropdownColor: Colors.brown[900],
                                style: GoogleFonts.poppins(color: Colors.white),
                                isExpanded: true,
                                decoration: _fieldDecoration('Subject'),
                                items: subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                onChanged: (val) => setState(() => _selectedSubject = val!),
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: _titleController,
                                style: GoogleFonts.poppins(color: Colors.white),
                                decoration: _fieldDecoration('Title'),
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: _descController,
                                maxLines: 3,
                                style: GoogleFonts.poppins(color: Colors.white),
                                decoration: _fieldDecoration('Description'),
                              ),
                              const SizedBox(height: 14),
                              // Due date — the parent screen calculates
                              // Pending / Overdue / Completed from this.
                              InkWell(
                                onTap: _pickDueDate,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_month_rounded, color: Colors.white70, size: 20),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Due Date: ${_formatDueDate(_dueDate)}',
                                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.brown,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _isPosting ? null : _postHomework,
                                  child: _isPosting
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : Text(
                                          'Post Homework',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Recently Posted',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Stream real-time homework entries from Firestore
                        StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('homework')
                              .where('teacherId', isEqualTo: _auth.currentUser?.uid ?? '')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              );
                            }

                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Text(
                                  'No homework posted yet.',
                                  style: GoogleFonts.poppins(color: Colors.white70),
                                ),
                              );
                            }

                            // A class post now creates one doc per parent —
                            // group them back into a single card per
                            // title+class+subject+postedAt so the teacher
                            // still sees one entry per post, not one per
                            // parent.
                            final docs = snapshot.data!.docs;
                            final Map<String, Map<String, dynamic>> grouped = {};
                            final Map<String, int> parentCounts = {};
                            for (final doc in docs) {
                              final h = doc.data() as Map<String, dynamic>;
                              final Timestamp? ts = h['postedAt'] as Timestamp?;
                              final String key =
                                  '${h['title']}|${h['class']}|${h['subject']}|${ts?.millisecondsSinceEpoch ?? doc.id}';
                              grouped[key] = h;
                              parentCounts[key] = (parentCounts[key] ?? 0) + 1;
                            }

                            final entries = grouped.entries.toList()
                              ..sort((a, b) {
                                final tsA = a.value['postedAt'] as Timestamp?;
                                final tsB = b.value['postedAt'] as Timestamp?;
                                if (tsA == null || tsB == null) return 0;
                                return tsB.compareTo(tsA);
                              });

                            return Column(
                              children: entries.map((entry) {
                                final h = entry.value;
                                final int parentCount = parentCounts[entry.key] ?? 1;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.menu_book, color: Colors.white),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              h['title'] ?? 'No Title',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              '${h['class']}'
                                              '${(h['section'] != null && h['section'] != 'All Sections') ? ' (${h['section']})' : ''}'
                                              ' • ${h['subject']}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.white70,
                                              ),
                                            ),
                                            if (h['dueDate'] != null)
                                              Text(
                                                'Due ${_formatDueDate((h['dueDate'] as Timestamp).toDate())}  •  Sent to $parentCount parent(s)',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color: Colors.white54,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
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

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Text(
            'Post Homework',
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