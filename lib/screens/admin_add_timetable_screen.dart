import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminAddTimetableScreen extends StatefulWidget {
  const AdminAddTimetableScreen({super.key});

  @override
  State<AdminAddTimetableScreen> createState() =>
      _AdminAddTimetableScreenState();
}

class _AdminAddTimetableScreenState extends State<AdminAddTimetableScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final TabController _tabController;

  // ============================================================
  // THEME (single accent color used everywhere = Colors.brown,
  // matching Teacher Management / Add Teacher screens)
  // ============================================================
  static const Color _accent = Colors.brown;
  static const Color _onGlass = Colors.white;
  static const Color _onGlassMuted = Colors.white70;

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  // FIXED LISTS (base options — admin can still add more on the fly)
  final List<String> _classesList = [
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

  final List<String> _defaultSections = [
    'Red',
    'Blue',
    'Pink',
    'Green',
  ];

  final List<String> _defaultSubjects = [
    'English',
    'Urdu',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Pakistan Studies',
    'Islamiat',
    'MQ',
    'Computer Science',
    'Other',
  ];

  String? _selectedTeacherEmail;
  String? _selectedTeacherName;

  bool _isLoadingSchedule = false;
  bool _isSaving = false;

  Map<String, List<Map<String, dynamic>>> _weeklySchedule = _emptyWeek();

  static Map<String, List<Map<String, dynamic>>> _emptyWeek() => {
        'Monday': [],
        'Tuesday': [],
        'Wednesday': [],
        'Thursday': [],
        'Friday': [],
        'Saturday': [],
      };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _days.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _dedupeTeachers(
    List<QueryDocumentSnapshot> docs,
  ) {
    final Map<String, Map<String, String>> unique = {};

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final String email =
          (data['email'] ?? doc.id).toString().trim().toLowerCase();

      if (email.isEmpty) continue;

      final String name =
          (data['fullName'] ?? data['name'] ?? 'Unknown Teacher')
              .toString()
              .trim();

      unique[email] = {
        'email': email,
        'name': name.isEmpty ? 'Unknown Teacher' : name,
      };
    }

    final list = unique.values.toList();
    list.sort(
      (a, b) => a['name']!.toLowerCase().compareTo(
            b['name']!.toLowerCase(),
          ),
    );

    return list;
  }

  Future<void> _selectTeacher(
    String email,
    String name,
  ) async {
    if (!mounted) return;
    setState(() {
      _selectedTeacherEmail = email;
      _selectedTeacherName = name;
      _isLoadingSchedule = true;
      _weeklySchedule = _emptyWeek();
    });

    try {
      final doc = await _firestore.collection('timetables').doc(email).get();

      final rawData = doc.data();
      final data =
          rawData is Map ? Map<String, dynamic>.from(rawData as Map) : null;

      final Map<String, dynamic> scheduleData =
          (data != null && data.containsKey('weeklySchedule') && data['weeklySchedule'] is Map)
              ? Map<String, dynamic>.from(data['weeklySchedule'] as Map)
              : {};

      final Map<String, List<Map<String, dynamic>>> loaded = _emptyWeek();

      for (final day in _days) {
        final raw = scheduleData[day];

        if (raw is List) {
          loaded[day] = raw
              .map(
                (e) => Map<String, dynamic>.from(
                  e as Map,
                ),
              )
              .toList();

          loaded[day]!.sort(
            (a, b) => ((a['startMinutes'] ?? 0) as int).compareTo(
              (b['startMinutes'] ?? 0) as int,
            ),
          );
        }
      }

      if (!mounted) return;

      setState(() {
        _weeklySchedule = loaded;
        _isLoadingSchedule = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingSchedule = false;
      });

      _showSnackBar(
        'Failed to load existing timetable.',
      );
    }
  }

  // ============================================================
  // GENERIC "ADD NEW OPTION" DIALOG
  // Used for both Subjects and Sections so admin/teacher can
  // type their own value instead of being stuck with the fixed
  // list.
  // ============================================================

  Future<void> _addCustomOptionDialog({
    required BuildContext parentContext,
    required String title,
    required String hint,
    required String firestoreField,
    required Function(String) onSuccess,
  }) async {
    final controller = TextEditingController();

    await showDialog(
      context: parentContext,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: _accent),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              final val = controller.text.trim();
              if (val.isNotEmpty) {
                try {
                  await _firestore
                      .collection('config')
                      .doc('timetableOptions')
                      .set(
                    {
                      firestoreField: FieldValue.arrayUnion([val]),
                    },
                    SetOptions(merge: true),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  onSuccess(val);
                } catch (_) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Failed to add. Try again.')),
                    );
                  }
                }
              }
            },
            child: Text(
              'Add',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  TimeOfDay _minsToTime(int mins) {
    return TimeOfDay(
      hour: mins ~/ 60,
      minute: mins % 60,
    );
  }

  Future<void> _periodDialog(
    String day, {
    int? editIndex,
  }) async {
    final existing =
        editIndex != null ? _weeklySchedule[day]![editIndex] : null;

    String? selectedSubject = existing?['subject'] as String?;
    String? selectedClass = existing?['class'] as String?;
    String? selectedSection = existing?['section'] as String?;

    TimeOfDay startTime = existing != null
        ? _minsToTime(existing['startMinutes'] as int? ?? 480)
        : const TimeOfDay(hour: 8, minute: 0);

    TimeOfDay endTime = existing != null
        ? _minsToTime(
            existing['endMinutes'] as int? ??
                ((existing['startMinutes'] as int? ?? 480) + 45),
          )
        : const TimeOfDay(hour: 8, minute: 45);

    bool hasLecture = existing?['hasLecture'] ?? true;

    Set<String> subjectsSet = Set<String>.from(_defaultSubjects);
    Set<String> sectionsSet = Set<String>.from(_defaultSections);

    try {
      final doc =
          await _firestore.collection('config').doc('timetableOptions').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        subjectsSet.addAll(List<String>.from(data['subjects'] ?? []));
        sectionsSet.addAll(List<String>.from(data['sections'] ?? []));
      }
    } catch (_) {}

    if (selectedSubject != null && selectedSubject.isNotEmpty) {
      subjectsSet.add(selectedSubject);
    }
    if (selectedSection != null && selectedSection.isNotEmpty) {
      sectionsSet.add(selectedSection);
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final List<String> subjectsList = subjectsSet.toList()..sort();
            final List<String> sectionsList = sectionsSet.toList()..sort();

            final String? safeSubject =
                subjectsList.contains(selectedSubject) ? selectedSubject : null;
            final String? safeClass =
                _classesList.contains(selectedClass) ? selectedClass : null;
            final String? safeSection =
                sectionsList.contains(selectedSection) ? selectedSection : null;

            InputDecoration fieldDecoration(String label) {
              return InputDecoration(
                labelText: label,
                labelStyle: GoogleFonts.poppins(color: Colors.brown.shade400),
                filled: true,
                fillColor: Colors.brown.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.brown.shade100),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.brown.shade100),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _accent, width: 1.5),
                ),
              );
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                editIndex != null ? 'Edit Period — $day' : 'Add Period — $day',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SUBJECT (with + Add option)
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: safeSubject,
                            isExpanded: true,
                            decoration: fieldDecoration('Subject'),
                            items: subjectsList
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setDialogState(() => selectedSubject = val);
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: _accent),
                          tooltip: 'Add new subject',
                          onPressed: () {
                            _addCustomOptionDialog(
                              parentContext: dialogContext,
                              title: 'Add New Subject',
                              hint: 'e.g. History',
                              firestoreField: 'subjects',
                              onSuccess: (newVal) {
                                setDialogState(() {
                                  subjectsSet.add(newVal);
                                  selectedSubject = newVal;
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // CLASS (fixed list)
                    DropdownButtonFormField<String>(
                      value: safeClass,
                      isExpanded: true,
                      decoration: fieldDecoration('Class'),
                      items: _classesList
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setDialogState(() => selectedClass = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // SECTION (with + Add option — admin can type their own,
                    // e.g. Pink, Blue or anything custom)
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: safeSection,
                            isExpanded: true,
                            decoration: fieldDecoration('Section'),
                            items: sectionsList
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setDialogState(() => selectedSection = val);
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: _accent),
                          tooltip: 'Add new section',
                          onPressed: () {
                            _addCustomOptionDialog(
                              parentContext: dialogContext,
                              title: 'Add New Section',
                              hint: 'e.g. Yellow, D, Falcon',
                              firestoreField: 'sections',
                              onSuccess: (newVal) {
                                setDialogState(() {
                                  sectionsSet.add(newVal);
                                  selectedSection = newVal;
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // TIME
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: _accent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: dialogContext,
                                initialTime: startTime,
                              );
                              if (picked != null) {
                                setDialogState(() => startTime = picked);
                              }
                            },
                            child: Text(
                              'Start: ${startTime.format(dialogContext)}',
                              style: GoogleFonts.poppins(
                                color: _accent,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: _accent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: dialogContext,
                                initialTime: endTime,
                              );
                              if (picked != null) {
                                setDialogState(() => endTime = picked);
                              }
                            },
                            child: Text(
                              'End: ${endTime.format(dialogContext)}',
                              style: GoogleFonts.poppins(
                                color: _accent,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // SWITCH
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: _accent,
                      title: Text(
                        'Class is happening (ON)',
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                      subtitle: Text(
                        'Turn OFF if this period is cancelled',
                        style: GoogleFonts.poppins(fontSize: 11),
                      ),
                      value: hasLecture,
                      onChanged: (val) {
                        setDialogState(() => hasLecture = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(color: Colors.grey.shade600),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (selectedSubject == null ||
                        selectedClass == null ||
                        selectedSection == null) {
                      _showSnackBar('Please select subject, class and section.');
                      return;
                    }

                    final int startMins = startTime.hour * 60 + startTime.minute;
                    final int endMins = endTime.hour * 60 + endTime.minute;
                    final String timeSlot =
                        '${startTime.format(dialogContext)} - ${endTime.format(dialogContext)}';

                    final Map<String, dynamic> entry = {
                      'time': timeSlot,
                      'class': selectedClass,
                      'section': selectedSection,
                      'subject': selectedSubject,
                      'hasLecture': hasLecture,
                      'startMinutes': startMins,
                      'endMinutes': endMins,
                    };

                    setState(() {
                      if (editIndex != null) {
                        _weeklySchedule[day]![editIndex] = entry;
                      } else {
                        _weeklySchedule[day]!.add(entry);
                      }
                      _weeklySchedule[day]!.sort(
                        (a, b) => ((a['startMinutes'] ?? 0) as int).compareTo(
                          (b['startMinutes'] ?? 0) as int,
                        ),
                      );
                    });

                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    editIndex != null ? 'Update' : 'Add',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveTimetable() async {
    if (_selectedTeacherEmail == null) {
      _showSnackBar('Please select a teacher first.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _firestore.collection('timetables').doc(_selectedTeacherEmail).set({
        'teacherEmail': _selectedTeacherEmail,
        'teacherName': _selectedTeacherName,
        'weeklySchedule': _weeklySchedule,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _showSnackBar('Timetable saved successfully!');
    } catch (e) {
      _showSnackBar('Failed to save timetable.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _onGlass),
        title: Text(
          'Manage Timetable',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: _onGlass,
          ),
        ),
      ),
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
          // Slightly darker overlay than a plain screen so text
          // stays crisp and readable over any background photo.
          child: Container(
            color: Colors.black.withValues(alpha: 0.45),
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).padding.top > 0 ? 8 : kToolbarHeight,
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildTeacherDropdown(),
                  ),

                  const SizedBox(height: 12),

                  // ==========================================
                  // TAB BAR — wrapped in its own glass pill
                  // ==========================================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        physics: const BouncingScrollPhysics(),
                        indicator: BoxDecoration(
                          color: _accent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        labelColor: _onGlass,
                        unselectedLabelColor: _onGlassMuted,
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        tabs: _days
                            .map(
                              (d) => Tab(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Text(d),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: _selectedTeacherEmail == null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30),
                              child: Text(
                                'Select a teacher to build their weekly timetable.',
                                style: GoogleFonts.poppins(
                                  color: _onGlassMuted,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : _isLoadingSchedule
                            ? const Center(
                                child: CircularProgressIndicator(color: _onGlass),
                              )
                            : TabBarView(
                                controller: _tabController,
                                children:
                                    _days.map((day) => _buildDayScheduleList(day)).toList(),
                              ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 3,
                        ),
                        onPressed:
                            (_isSaving || _selectedTeacherEmail == null) ? null : _saveTimetable,
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Save Full Week Timetable',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
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

  // ============================================================
  // TEACHER PICKER (glass pill, matching Add Teacher screen style)
  // ============================================================

  Widget _buildTeacherDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('teachers').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white24),
            ),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: _onGlass,
                strokeWidth: 2,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              'Failed to load teachers.',
              style: GoogleFonts.poppins(color: Colors.redAccent),
            ),
          );
        }

        final teachers = _dedupeTeachers(snapshot.data?.docs ?? []);

        if (teachers.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              'No teachers found.',
              style: GoogleFonts.poppins(color: _onGlassMuted),
            ),
          );
        }

        final bool isValid = teachers.any((t) => t['email'] == _selectedTeacherEmail);

        return InkWell(
          onTap: () => _showTeacherSearchDialog(teachers),
          borderRadius: BorderRadius.circular(15),
          child: Container(
            height: 55,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_search, color: _onGlassMuted, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isValid
                        ? '${_selectedTeacherName ?? 'Unknown Teacher'} (${_selectedTeacherEmail ?? ''})'
                        : 'Select Teacher or type to search',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: isValid ? _onGlass : _onGlassMuted,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: _onGlass),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTeacherSearchDialog(List<Map<String, String>> teachers) {
    final searchController = TextEditingController();
    List<Map<String, String>> filteredTeachers = List.from(teachers);

    showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                'Select Teacher',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 420,
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Type teacher name...',
                        prefixIcon: const Icon(Icons.search, color: _accent),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  searchController.clear();
                                  setDialogState(() => filteredTeachers = List.from(teachers));
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _accent, width: 1.5),
                        ),
                      ),
                      onChanged: (value) {
                        final query = value.trim().toLowerCase();
                        setDialogState(() {
                          if (query.isEmpty) {
                            filteredTeachers = List.from(teachers);
                          } else {
                            filteredTeachers = teachers.where((teacher) {
                              final name = teacher['name']!.toLowerCase();
                              final email = teacher['email']!.toLowerCase();
                              return name.contains(query) || email.contains(query);
                            }).toList();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filteredTeachers.isEmpty
                          ? Center(
                              child: Text(
                                'No teacher found.',
                                style: GoogleFonts.poppins(),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredTeachers.length,
                              itemBuilder: (context, index) {
                                final teacher = filteredTeachers[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.brown.shade100,
                                    child: const Icon(Icons.person, color: _accent),
                                  ),
                                  title: Text(
                                    teacher['name']!,
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    teacher['email']!,
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                                  onTap: () => Navigator.pop(dialogContext, teacher),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(color: Colors.grey.shade600),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((selectedTeacher) {
      if (selectedTeacher != null && mounted) {
        _selectTeacher(selectedTeacher['email']!, selectedTeacher['name']!);
      }
    });
  }

  // ============================================================
  // DAY SCHEDULE LIST (pretty glass container + clean period cards)
  // ============================================================

  Widget _buildDayScheduleList(String day) {
    final periods = _weeklySchedule[day] ?? [];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$day (${periods.length})',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _onGlass,
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _periodDialog(day),
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: Text(
                  'Add Period',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: periods.isEmpty
                ? Center(
                    child: Text(
                      'No classes added for $day',
                      style: GoogleFonts.poppins(color: _onGlassMuted),
                    ),
                  )
                : ListView.builder(
                    itemCount: periods.length,
                    itemBuilder: (context, index) {
                      final item = periods[index];
                      final bool hasLecture = item['hasLecture'] ?? true;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: hasLecture
                                ? Colors.brown.withValues(alpha: 0.15)
                                : Colors.redAccent.withValues(alpha: 0.25),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          onTap: () => _periodDialog(day, editIndex: index),
                          leading: CircleAvatar(
                            backgroundColor: hasLecture
                                ? _accent
                                : Colors.redAccent.withValues(alpha: 0.85),
                            child: Icon(
                              hasLecture ? Icons.check : Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            '${item['subject']} - ${item['class']} ${item['section'] ?? ''}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            'Time: ${item['time']}${hasLecture ? '' : '  •  OFF'}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: hasLecture ? Colors.black54 : Colors.redAccent,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: hasLecture,
                                activeThumbColor: _accent,
                                onChanged: (val) {
                                  setState(() {
                                    _weeklySchedule[day]![index]['hasLecture'] = val;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: _accent),
                                onPressed: () => _periodDialog(day, editIndex: index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () {
                                  setState(() {
                                    periods.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 