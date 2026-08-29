import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'my_complaints_screen.dart';
import 'parent_attendance_screen.dart';

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

  // ============================================================
  // PARENT ID
  // ============================================================

  String? _parentId;

  // ============================================================
  // FIXED CLASS LIST
  // ============================================================
  //
  // IMPORTANT FIX:
  // Previously this screen queried
  //   FirebaseFirestore.instance.collection('classes').get()
  // to discover which classes exist, then looped through each
  // class document to read its `students` subcollection.
  //
  // In Firestore, a document that was never directly written
  // (only its subcollections were written, e.g.
  //   classes/{className}/students/{id}
  // via `.collection('students').add(...)`)
  // does NOT appear in a `.collection('classes').get()` query,
  // even though its subcollection has data.
  //
  // Since the Admission Form only ever does:
  //   .collection('classes').doc(selectedClass).collection('students').add(...)
  // the `classes/{className}` parent document itself is never
  // created, so `collection('classes').get()` always returned an
  // EMPTY snapshot -> the loop below never ran -> no children were
  // ever found, even when students existed in Firestore with the
  // correct parentUid.
  //
  // FIX: loop over a known, fixed list of class names (same list
  // used in the Admission Form) instead of relying on the
  // `classes` collection listing itself.
  // ============================================================

  static const List<String> allClasses = [
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

  // ============================================================
  // CHILDREN FROM FIRESTORE
  // ============================================================

  List<Map<String, dynamic>> familyChildren = [];

  bool _isLoadingChildren = true;

  String? _loadError;

  int _selectedChildIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  // ============================================================
  // LOAD CHILDREN USING PARENT UID / EMAIL
  // ============================================================

  Future<void> _loadChildren() async {
    final User? currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      if (!mounted) return;

      setState(() {
        _isLoadingChildren = false;
        _loadError =
            'Please log in to view your dashboard.';
      });

      return;
    }

    final String parentUid = currentUser.uid;

    final String parentEmail =
        (currentUser.email ?? '').trim().toLowerCase();

    if (mounted) {
      setState(() {
        _parentId = parentUid;
        _isLoadingChildren = true;
        _loadError = null;
      });
    }

    try {
      // ========================================================
      // LOAD CHILDREN CLASS-BY-CLASS
      //
      // IMPORTANT:
      // We do NOT use collectionGroup('students') here. That query
      // requires a Collection Group index for parentUid.
      //
      // We also do NOT query collection('classes').get() anymore,
      // because that parent document is never explicitly created
      // (see the big comment above `allClasses`), so it always
      // returned empty. Instead we loop over the fixed `allClasses`
      // list and query each class's `students` subcollection
      // directly. This removes both the index error AND the
      // "always empty classes list" bug.
      // ========================================================

      final List<Map<String, dynamic>> loaded = [];

      // ========================================================
      // FIRST: SEARCH BY PARENT UID
      // ========================================================

      for (final String className in allClasses) {
        final QuerySnapshot<Map<String, dynamic>> studentSnapshot =
            await FirebaseFirestore.instance
                .collection('classes')
                .doc(className)
                .collection('students')
                .where(
                  'parentUid',
                  isEqualTo: parentUid,
                )
                .get();

        for (final studentDoc in studentSnapshot.docs) {
          final Map<String, dynamic> data = studentDoc.data();

          loaded.add({
            'studentId': studentDoc.id,

            'name':
                (data['studentName'] ?? '').toString(),

            // Use the student's saved class first.
            // If it is missing, fall back to the class name we
            // just queried under.
            'className':
                (data['class'] ?? className).toString(),

            'section':
                (data['section'] ?? '').toString(),

            'roll':
                (data['rollNo'] ?? '').toString(),

            'admissionNo':
                (data['admissionNo'] ?? '').toString(),

            'fatherName':
                (data['fatherName'] ?? '').toString(),

            'phone':
                (data['fatherPhone'] ?? '').toString(),

            'photoUrl':
                (data['photoUrl'] ?? '').toString(),

            'parentId':
                (data['parentId'] ??
                        data['parentUid'] ??
                        parentUid)
                    .toString(),

            'parentUid':
                (data['parentUid'] ?? parentUid)
                    .toString(),

            'email':
                (data['email'] ?? parentEmail)
                    .toString(),
          });
        }
      }

      // ========================================================
      // SECOND: IF UID DOES NOT FIND CHILD,
      // SEARCH BY PARENT EMAIL.
      //
      // This also avoids collectionGroup(), so no Collection
      // Group index is required.
      // ========================================================

      if (loaded.isEmpty && parentEmail.isNotEmpty) {
        for (final String className in allClasses) {
          final QuerySnapshot<Map<String, dynamic>> studentSnapshot =
              await FirebaseFirestore.instance
                  .collection('classes')
                  .doc(className)
                  .collection('students')
                  .where(
                    'email',
                    isEqualTo: parentEmail,
                  )
                  .get();

          for (final studentDoc in studentSnapshot.docs) {
            final Map<String, dynamic> data = studentDoc.data();

            loaded.add({
              'studentId': studentDoc.id,

              'name':
                  (data['studentName'] ?? '').toString(),

              'className':
                  (data['class'] ?? className).toString(),

              'section':
                  (data['section'] ?? '').toString(),

              'roll':
                  (data['rollNo'] ?? '').toString(),

              'admissionNo':
                  (data['admissionNo'] ?? '').toString(),

              'fatherName':
                  (data['fatherName'] ?? '').toString(),

              'phone':
                  (data['fatherPhone'] ?? '').toString(),

              'photoUrl':
                  (data['photoUrl'] ?? '').toString(),

              'parentId':
                  (data['parentId'] ??
                          data['parentUid'] ??
                          parentUid)
                      .toString(),

              'parentUid':
                  (data['parentUid'] ?? parentUid)
                      .toString(),

              'email':
                  (data['email'] ?? parentEmail)
                      .toString(),
            });
          }
        }
      }

      // ========================================================
      // UPDATE DASHBOARD
      // ========================================================

      if (!mounted) return;

      setState(() {
        familyChildren = loaded;
        _selectedChildIndex = 0;
        _isLoadingChildren = false;
      });

      // ========================================================
      // NOW LOAD SUBJECTS + MARKS/REMARKS FOR THE SELECTED CHILD
      // ========================================================

      await _loadSubjectsForSelectedChild();

      // ========================================================
      // DEBUG
      // ========================================================

      debugPrint('======================================');
      debugPrint('PARENT UID: $parentUid');
      debugPrint('PARENT EMAIL: $parentEmail');
      debugPrint(
        'CHILDREN FOUND: ${loaded.length}',
      );

      for (final child in loaded) {
        debugPrint(
          'CHILD: ${child['name']} | '
          'CLASS: ${child['className']} | '
          'PARENT UID: ${child['parentUid']}',
        );
      }

      debugPrint('======================================');
    } catch (e) {
      debugPrint(
        'PARENT DASHBOARD ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        _isLoadingChildren = false;
        _loadError =
            'Could not load your child data.\n\n$e';
      });
    }
  }


  // ============================================================
  // SUBJECTS (LOADED LIVE FROM FIRESTORE, PER CLASS)
  // ============================================================
  //
  // Source collections:
  //   classes/{className}/subjects/{subjectId}
  //     -> created/managed from the Subject Management screen
  //   classes/{className}/students/{studentId}/subjectRecords/{subjectId}
  //     -> per-student marks/remarks/assignments for that subject
  //        (a teacher-side screen should write here; until then this
  //         dashboard shows sensible "Pending" / "No remarks yet"
  //         placeholders so nothing crashes).
  // ============================================================

  List<Map<String, dynamic>> subjects = [];

  bool _isLoadingSubjects = false;

  String? _subjectsError;

  Future<void> _loadSubjectsForSelectedChild() async {
    if (familyChildren.isEmpty) {
      if (!mounted) return;

      setState(() {
        subjects = [];
        _isLoadingSubjects = false;
        _subjectsError = null;
      });

      return;
    }

    final Map<String, dynamic> child =
        familyChildren[_selectedChildIndex];

    final String className =
        (child['className'] ?? '').toString();

    final String studentId =
        (child['studentId'] ?? '').toString();

    if (className.isEmpty || studentId.isEmpty) {
      if (!mounted) return;

      setState(() {
        subjects = [];
        _isLoadingSubjects = false;
        _subjectsError =
            'Class information is missing for this student.';
      });

      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingSubjects = true;
        _subjectsError = null;
      });
    }

    try {
      // ========================================================
      // 1) FETCH SUBJECTS FOR THIS CLASS
      // ========================================================

      final QuerySnapshot<Map<String, dynamic>>
          subjectsSnapshot = await FirebaseFirestore.instance
              .collection('classes')
              .doc(className)
              .collection('subjects')
              .get();

      // Filter active subjects and sort them in Dart.
      // This avoids the Firestore composite-index requirement caused by
      // combining where('active') with orderBy('name').
      final List<QueryDocumentSnapshot<Map<String, dynamic>>>
          activeSubjectDocs = subjectsSnapshot.docs.where((doc) {
        final data = doc.data();
        // Treat missing active as active as well, so older subject
        // documents created before the active field was added still show.
        return data['active'] != false;
      }).toList();

      activeSubjectDocs.sort((a, b) {
        final nameA =
            (a.data()['name'] ?? '').toString().toLowerCase();
        final nameB =
            (b.data()['name'] ?? '').toString().toLowerCase();
        return nameA.compareTo(nameB);
      });

      final List<Map<String, dynamic>> loadedSubjects = [];

      // ========================================================
      // 2) FOR EACH SUBJECT, FETCH THIS STUDENT'S RECORD
      //    (marks / remarks / assignments), IF IT EXISTS
      // ========================================================

      for (final subjectDoc in activeSubjectDocs) {
        final Map<String, dynamic> subjectData =
            subjectDoc.data();

        final String subjectName =
            (subjectData['name'] ?? '').toString();

        Map<String, dynamic>? recordData;

        try {
          final DocumentSnapshot<Map<String, dynamic>>
              recordSnapshot = await FirebaseFirestore.instance
                  .collection('classes')
                  .doc(className)
                  .collection('students')
                  .doc(studentId)
                  .collection('subjectRecords')
                  .doc(subjectDoc.id)
                  .get();

          if (recordSnapshot.exists) {
            recordData = recordSnapshot.data();
          }
        } catch (e) {
          debugPrint('Subject record fetch error: $e');
        }

        final List<String> assignments =
            (recordData?['assignments'] as List?)
                    ?.map((e) => e.toString())
                    .toList() ??
                <String>[];

        final Map<String, String> marks =
            (recordData?['marks'] as Map?)?.map(
                  (key, value) => MapEntry(
                    key.toString(),
                    value.toString(),
                  ),
                ) ??
                <String, String>{
                  '1st Term': 'Pending',
                  '2nd Term': 'Pending',
                  'Final Term': 'Pending',
                };

        loadedSubjects.add({
          'name': subjectName,
          'code': (subjectData['code'] ?? '').toString(),
          'group': (subjectData['group'] ?? '').toString(),
          'teacher': (recordData?['teacherName'] ??
                  'Not assigned yet')
              .toString(),
          'icon': _iconForSubject(subjectName),
          'assignments': assignments,
          'teacherComplaint': (recordData?['remarks'] ??
                  'No remarks added yet.')
              .toString(),
          'marks': marks,
        });
      }

      if (!mounted) return;

      setState(() {
        subjects = loadedSubjects;
        _isLoadingSubjects = false;
      });
    } catch (e) {
      debugPrint('Subjects load error: $e');

      if (!mounted) return;

      setState(() {
        _isLoadingSubjects = false;
        _subjectsError =
            'Could not load subjects for this class.\n$e';
      });
    }
  }

  IconData _iconForSubject(String name) {
    final String lower = name.toLowerCase();

    if (lower.contains('math')) {
      return Icons.calculate_outlined;
    }

    if (lower.contains('english')) {
      return Icons.menu_book_outlined;
    }

    if (lower.contains('science')) {
      return Icons.science_outlined;
    }

    if (lower.contains('urdu')) {
      return Icons.history_edu_outlined;
    }

    if (lower.contains('computer')) {
      return Icons.computer_outlined;
    }

    if (lower.contains('islam')) {
      return Icons.mosque_outlined;
    }

    return Icons.book_outlined;
  }

  // ============================================================
  // RESULT SUMMARY & CLASS POSITION (auto-calculated from Firestore)
  // ============================================================
  //
  // Uses the "Final Term" mark of every active subject for a
  // student, sums them up, and compares against every other
  // student in the same class to determine class position.
  // Assumes each subject is out of 100 marks — adjust the
  // `total += 100` line below if your school uses a different
  // maximum per subject.
  // ============================================================

  double _parseMark(String? raw) {
    if (raw == null) return -1;
    final double? value = double.tryParse(raw.trim());
    return value ?? -1;
  }

  Future<Map<String, double>> _calculateStudentResult({
    required String className,
    required String studentId,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>>
        subjectDocs,
  }) async {
    double obtained = 0;
    double total = 0;

    for (final subjectDoc in subjectDocs) {
      final DocumentSnapshot<Map<String, dynamic>> recordSnap =
          await FirebaseFirestore.instance
              .collection('classes')
              .doc(className)
              .collection('students')
              .doc(studentId)
              .collection('subjectRecords')
              .doc(subjectDoc.id)
              .get();

      if (recordSnap.exists) {
        final Map? marks = recordSnap.data()?['marks'] as Map?;
        final String? finalTerm = marks?['Final Term']?.toString();
        final double value = _parseMark(finalTerm);

        if (value >= 0) {
          obtained += value;
          total += 100;
        }
      }
    }

    return {'obtained': obtained, 'total': total};
  }

  Future<void> _showResultAndPositionDialog() async {
    if (familyChildren.isEmpty) return;

    final Map<String, dynamic> child =
        familyChildren[_selectedChildIndex];

    final String className = (child['className'] ?? '').toString();
    final String studentId = (child['studentId'] ?? '').toString();

    if (className.isEmpty || studentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Class information is missing for this student.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    try {
      final QuerySnapshot<Map<String, dynamic>> subjectsSnap =
          await FirebaseFirestore.instance
              .collection('classes')
              .doc(className)
              .collection('subjects')
              .get();

      final List<QueryDocumentSnapshot<Map<String, dynamic>>>
          activeSubjects = subjectsSnap.docs
              .where((doc) => doc.data()['active'] != false)
              .toList();

      // This student's result.
      final Map<String, double> myResult = await _calculateStudentResult(
        className: className,
        studentId: studentId,
        subjectDocs: activeSubjects,
      );

      // Every student in the class, for ranking.
      final QuerySnapshot<Map<String, dynamic>> studentsSnap =
          await FirebaseFirestore.instance
              .collection('classes')
              .doc(className)
              .collection('students')
              .get();

      final List<Map<String, dynamic>> allResults = [];

      for (final studentDoc in studentsSnap.docs) {
        final Map<String, double> result = await _calculateStudentResult(
          className: className,
          studentId: studentDoc.id,
          subjectDocs: activeSubjects,
        );

        allResults.add({
          'studentId': studentDoc.id,
          'obtained': result['obtained'] ?? 0,
        });
      }

      allResults.sort(
        (a, b) =>
            (b['obtained'] as double).compareTo(a['obtained'] as double),
      );

      final int position =
          allResults.indexWhere((r) => r['studentId'] == studentId) + 1;

      final double obtained = myResult['obtained'] ?? 0;
      final double total = myResult['total'] ?? 0;
      final double percentage = total > 0 ? (obtained / total * 100) : 0.0;

      if (!mounted) return;

      Navigator.pop(context); // close loading spinner

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.brown.shade900,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Result & Class Position',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _resultRow(
                  'Total Obtained',
                  '${obtained.toStringAsFixed(0)} / ${total.toStringAsFixed(0)}',
                ),
                _resultRow(
                  'Percentage',
                  '${percentage.toStringAsFixed(1)}%',
                ),
                _resultRow(
                  'Class Position',
                  position > 0
                      ? '$position out of ${allResults.length}'
                      : 'Not available yet',
                ),
                const SizedBox(height: 8),
                Text(
                  'Based on Final Term marks entered so far. Position updates automatically as more results are added.',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                ),
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
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context); // close loading spinner

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not calculate result.\n$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

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
                  errorBuilder:
                      (context, error, stackTrace) {
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
                scrollDirection:
                    Axis.horizontal,
                physics:
                    const BouncingScrollPhysics(),
                child: Text(
                  'Parent Portal Dashboard',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
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
                  padding:
                      const EdgeInsets.all(4),
                  decoration:
                      const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '4',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight:
                          FontWeight.bold,
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
            color: Colors.black.withValues(
              alpha: 0.25,
            ),
            child: SafeArea(
              child: _buildBody(),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_isLoadingChildren) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white70,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                _loadError!,
                style: const TextStyle(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: _loadChildren,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (familyChildren.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline,
                color: Colors.white70,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                'No admission record found yet.\n'
                'Submit the admission form to see your child\'s dashboard here.',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              if (_parentId != null)
                Text(
                  'Parent ID: $_parentId',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics:
          const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
    );
  }

  // ============================================================
  // WELCOME HEADER
  // ============================================================

  Widget _buildWelcomeHeader() {
    final child =
        familyChildren[_selectedChildIndex];

    final String photoUrl =
        (child['photoUrl'] ?? '').toString();

    final String classLine = [
      if ((child['className'] ?? '')
          .toString()
          .isNotEmpty)
        child['className'],
      if ((child['section'] ?? '')
          .toString()
          .isNotEmpty)
        child['section'],
    ].join(' - ');

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(
                alpha: 0.2,
              ),
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: photoUrl.isNotEmpty
                  ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error,
                              stackTrace) {
                        return const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 38,
                        );
                      },
                    )
                  : const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 38,
                    ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        (child['name'] ?? '')
                            .toString(),
                        style:
                            GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                    ),
                    if (familyChildren.length >
                        1)
                      PopupMenuButton<int>(
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                        color:
                            Colors.brown.shade900,
                        onSelected: (index) {
                          setState(() {
                            _selectedChildIndex =
                                index;
                          });

                          // Reload subjects/marks for the newly
                          // selected child.
                          _loadSubjectsForSelectedChild();
                        },
                        itemBuilder: (context) {
                          return List.generate(
                            familyChildren.length,
                            (index) {
                              return PopupMenuItem<
                                  int>(
                                value: index,
                                child: Text(
                                  (familyChildren[
                                                  index]
                                              ['name'] ??
                                          '')
                                      .toString(),
                                  style:
                                      GoogleFonts
                                          .poppins(
                                    color:
                                        Colors.white,
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
                  'Class: $classLine  |  Roll No: ${child['roll'] ?? ''}',
                  style:
                      GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                  overflow:
                      TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Parent ID: ${child['parentId'] ?? _parentId ?? ''}',
                  style:
                      GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white54,
                    fontWeight:
                        FontWeight.w500,
                  ),
                  overflow:
                      TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STUDENT STATUS
  // ============================================================

  Widget _buildStudentStatusSection() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Container(
        padding:
            const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: 0.15,
          ),
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(
              alpha: 0.2,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Khyber Public School',
                    style:
                        GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w500,
                    ),
                    overflow:
                        TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        Colors.green.withValues(
                      alpha: 0.8,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: Text(
                    'Attendance: Present',
                    style:
                        GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subjects & Class Teachers:',
                  style:
                      GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showResultAndPositionDialog,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                  ),
                  icon: const Icon(
                    Icons.emoji_events_outlined,
                    color: Colors.amber,
                    size: 18,
                  ),
                  label: Text(
                    'Result',
                    style: GoogleFonts.poppins(
                      color: Colors.amber,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ========================================================
            // SUBJECTS: LOADING / ERROR / EMPTY / GRID
            // ========================================================

            if (_isLoadingSubjects)
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 10,
                ),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              )
            else if (_subjectsError != null)
              Text(
                _subjectsError!,
                style: GoogleFonts.poppins(
                  color: Colors.orangeAccent,
                  fontSize: 12,
                ),
              )
            else if (subjects.isEmpty)
              Text(
                'No subjects have been added for this class yet.',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: subjects.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.25,
                ),
                itemBuilder: (context, index) {
                  return _buildSubjectBox(subjects[index]);
                },
              ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Pretty subject box shown on the dashboard grid. Tapping it
  // opens the existing subject-details bottom sheet (marks,
  // assignments, teacher remarks).
  // ------------------------------------------------------------

  Widget _buildSubjectBox(Map<String, dynamic> item) {
    return InkWell(
      onTap: () => _showSubjectDetailsModal(item),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.18),
              Colors.brown.withValues(alpha: 0.25),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item['icon'] as IconData,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              (item['name'] ?? '').toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              (item['teacher'] ?? '').toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 11,
              ),
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
      padding:
          const EdgeInsets.only(
        bottom: 8.0,
      ),
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
                style:
                    GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w600,
                ),
                overflow:
                    TextOverflow.ellipsis,
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

  // ============================================================
  // QUICK OVERVIEW
  // ============================================================

  Widget _buildQuickOverviewSection() {
    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.brown.withValues(
          alpha: 0.35,
        ),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.2,
          ),
        ),
      ),
      padding:
          const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Overview',
            style:
                GoogleFonts.poppins(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          _buildInfoCard(
            icon:
                Icons.receipt_long_outlined,
            title: 'Fee Due Date',
            subtitle:
                'Rs. 7,300 payable by the 10th of every month',
            onTap:
                _showFeeDetailsDialog,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon:
                Icons.article_outlined,
            title: 'Mid-Term Exams',
            subtitle:
                'Mathematics paper on Monday, 10th Nov',
            onTap:
                _showDateSheetDialog,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon:
                Icons.groups_outlined,
            title: 'PTM Meeting',
            subtitle:
                'Parent-Teacher meeting scheduled for 30th of this month',
            onTap: () {
              _showEventsDialog(context);
            },
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.emoji_events_outlined,
            title: 'Result & Class Position',
            subtitle:
                'See subject-wise marks, percentage and class rank',
            onTap: _showResultAndPositionDialog,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child:
                ElevatedButton.icon(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.white,
                foregroundColor:
                    Colors.brown.shade900,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 12,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),
              onPressed:
                  _showAdminComplaintDialog,
              icon: const Icon(
                Icons.lock_outline,
              ),
              label: const Text(
                'Submit Direct Complaint to Admin',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
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
      borderRadius:
          BorderRadius.circular(15),
      child: Container(
        padding:
            const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: 0.12,
          ),
          borderRadius:
              BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    Colors.white.withValues(
                  alpha: 0.2,
                ),
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
                    style:
                        GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style:
                        GoogleFonts.poppins(
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

  // ============================================================
  // DRAWER
  // ============================================================

  Widget _buildDrawer(
    BuildContext context,
  ) {
    return Drawer(
      backgroundColor:
          Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12,
            sigmaY: 12,
          ),
          child: Container(
            color: Colors.black.withValues(
              alpha: 0.35,
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white.withValues(
                      alpha: 0.1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor:
                            Colors.white24,
                        child: Icon(
                          Icons.school,
                          color:
                              Colors.white,
                          size: 34,
                        ),
                      ),
                      const SizedBox(
                          height: 10),
                      Text(
                        'Khyber Public School',
                        style:
                            GoogleFonts.poppins(
                          color:
                              Colors.white,
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                      Text(
                        'Parent Quick Menu',
                        style:
                            GoogleFonts.poppins(
                          color:
                              Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      if (_parentId != null)
                        Text(
                          'Parent ID: $_parentId',
                          style:
                              GoogleFonts.poppins(
                            color:
                                Colors.white54,
                            fontSize: 9,
                          ),
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                _buildDrawerItem(
                  icon:
                      Icons.person_outline,
                  title: 'My Profile',
                  onTap: () {
                    Navigator.pop(
                        context);
                    _showProfileDialog();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.event_available_outlined,
                  title: 'Attendance',
                  onTap: () {
                    Navigator.pop(context);

                    if (familyChildren.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'No student record found yet.',
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    final Map<String, dynamic> child =
                        familyChildren[_selectedChildIndex];

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ParentAttendanceScreen(
                          studentId:
                              (child['studentId'] ?? '').toString(),
                          className:
                              (child['className'] ?? '').toString(),
                          studentName:
                              (child['name'] ?? '').toString(),
                        ),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons
                      .receipt_long_outlined,
                  title:
                      'Fee Details & Late Charges',
                  onTap: () {
                    Navigator.pop(
                        context);
                    _showFeeDetailsDialog();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons
                      .calendar_month_outlined,
                  title:
                      'Weekly Time Table',
                  onTap: () {
                    Navigator.pop(
                        context);
                    _showTimeTableDialog();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons
                      .article_outlined,
                  title:
                      'Exams Date Sheet',
                  onTap: () {
                    Navigator.pop(
                        context);
                    _showDateSheetDialog();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons
                      .rate_review_outlined,
                  title:
                      'Teacher Review & Behavior',
                  onTap: () {
                    Navigator.pop(
                        context);
                    _showTeacherReviewDialog();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.emoji_events_outlined,
                  title:
                      'Result & Class Position',
                  onTap: () {
                    Navigator.pop(context);
                    _showResultAndPositionDialog();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons
                      .report_problem_outlined,
                  title:
                      'Submit Complaint to Admin',
                  onTap: () {
                    Navigator.pop(
                        context);
                    _showAdminComplaintDialog();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.mark_email_read_outlined,
                  title: 'My Complaints & Replies',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const MyComplaintsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(
                  color: Colors.white24,
                ),
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () async {
                    Navigator.pop(
                        context);
                    await FirebaseAuth
                        .instance
                        .signOut();
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
        style:
            GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    );
  }

  // ============================================================
  // PROFILE DIALOG
  // ============================================================

  void _showProfileDialog() {
    final child =
        familyChildren.isNotEmpty
            ? familyChildren[
                _selectedChildIndex]
            : <String, dynamic>{};

    final String classLine = [
      if ((child['className'] ?? '')
          .toString()
          .isNotEmpty)
        child['className'],
      if ((child['section'] ?? '')
          .toString()
          .isNotEmpty)
        child['section'],
    ].join(' - ');

    final String parentId =
        (child['parentId'] ??
                _parentId ??
                '')
            .toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          title: Text(
            "Student Profile",
            style:
                GoogleFonts.poppins(
              fontWeight:
                  FontWeight.bold,
              color: darkBrown,
            ),
          ),
          content:
              SingleChildScrollView(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor:
                      primaryBrown.withValues(
                    alpha: 0.15,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: darkBrown,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  (child['name'] ?? '')
                      .toString(),
                  style:
                      GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                    color: darkBrown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Class: $classLine | Roll No: ${child['roll'] ?? ''}",
                  style:
                      GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
                const Divider(height: 24),
                ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons
                        .verified_user_outlined,
                    color: primaryBrown,
                  ),
                  title: const Text(
                    "Parent ID",
                  ),
                  subtitle: const Text(
                    "Firebase Authentication ID",
                  ),
                  trailing: SizedBox(
                    width: 120,
                    child: Text(
                      parentId,
                      textAlign:
                          TextAlign.end,
                      style:
                          const TextStyle(
                        fontSize: 10,
                        fontWeight:
                            FontWeight.bold,
                      ),
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                  ),
                ),
                ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.badge_outlined,
                  ),
                  title: const Text(
                    "Admission No.",
                  ),
                  trailing: Text(
                    (child['admissionNo'] ??
                            '')
                        .toString(),
                  ),
                ),
                ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons
                        .family_restroom_outlined,
                  ),
                  title: const Text(
                    "Father Name",
                  ),
                  trailing: Text(
                    (child['fatherName'] ??
                            '')
                        .toString(),
                  ),
                ),
                ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.phone_outlined,
                  ),
                  title: const Text(
                    "Contact",
                  ),
                  trailing: Text(
                    (child['phone'] ?? '')
                        .toString(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Close",
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  void _showEventsDialog(
      [BuildContext? dialogContext]) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              Colors.brown.shade900,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          title: Text(
            'Notifications & Activities',
            style:
                GoogleFonts.poppins(
              color: Colors.white,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
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
                style:
                    GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationItem(
      String text) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 4,
      ),
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
              style:
                  GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FEE DETAILS
  // ============================================================

  void _showFeeDetailsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              Colors.brown.shade900,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          title: Text(
            'Fee Schedule & Notifications',
            style:
                GoogleFonts.poppins(
              color: Colors.white,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.all(12),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.orange.withValues(
                    alpha: 0.15,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                  border: Border.all(
                    color: Colors.orange,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons
                          .warning_amber_rounded,
                      color:
                          Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Due Date: 10th of every month. Rs. 500 Late Fee applies after deadline.',
                        style:
                            GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors
                              .orange
                              .shade100,
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
                  style:
                      GoogleFonts.poppins(
                    color: Colors.white,
                  ),
                ),
                trailing: Text(
                  'Rs. 6,500',
                  style:
                      GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  'Computer & Lab Charges',
                  style:
                      GoogleFonts.poppins(
                    color: Colors.white,
                  ),
                ),
                trailing: Text(
                  'Rs. 800',
                  style:
                      GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
              const Divider(
                color: Colors.white24,
              ),
              ListTile(
                title: Text(
                  'Total Payable',
                  style:
                      GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                trailing: Text(
                  'Rs. 7,300',
                  style:
                      GoogleFonts.poppins(
                    color: Colors.amber,
                    fontWeight:
                        FontWeight.bold,
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
                style:
                    GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // TIME TABLE
  // ============================================================

  void _showTimeTableDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              Colors.brown.shade900,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          title: Text(
            'Weekly Time Table',
            style:
                GoogleFonts.poppins(
              color: Colors.white,
              fontWeight:
                  FontWeight.bold,
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
                style:
                    GoogleFonts.poppins(
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
        backgroundColor:
            Colors.white24,
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
        style:
            GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 13,
        ),
      ),
      subtitle: Text(
        teachersText,
        style:
            GoogleFonts.poppins(
          color: Colors.white70,
          fontSize: 11,
        ),
      ),
    );
  }

  // ============================================================
  // EXAM DATE SHEET
  // ============================================================

  void _showDateSheetDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              Colors.brown.shade900,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          title: Text(
            'Mid-Term Exam Date Sheet',
            style:
                GoogleFonts.poppins(
              color: Colors.white,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
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
                style:
                    GoogleFonts.poppins(
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
        style:
            GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 13,
        ),
      ),
      subtitle: Text(
        schedule,
        style:
            GoogleFonts.poppins(
          color: Colors.white70,
          fontSize: 11,
        ),
      ),
    );
  }

  // ============================================================
  // TEACHER REVIEW
  // ============================================================

  void _showTeacherReviewDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              Colors.brown.shade900,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          title: Text(
            'Teacher Performance Review',
            style:
                GoogleFonts.poppins(
              color: Colors.white,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Class Participation: Excellent (85%)',
                style:
                    GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Behavior & Discipline: Good & Respectful',
                style:
                    GoogleFonts.poppins(
                  color:
                      Colors.greenAccent,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Overall Teacher Review:',
                style:
                    GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding:
                    const EdgeInsets.all(10),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
                child: Text(
                  'This is a general behavior summary. For subject-specific remarks, tap a subject above.',
                  style:
                      GoogleFonts.poppins(
                    color:
                        Colors.white70,
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
                style:
                    GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SUBJECT DETAILS
  // ============================================================

  void _showSubjectDetailsModal(
    Map<String, dynamic> item,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent,
      builder: (context) {
        return Container(
          height:
              MediaQuery.of(context)
                      .size
                      .height *
                  0.75,
          decoration:
              const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.only(
              topLeft:
                  Radius.circular(25),
              topRight:
                  Radius.circular(25),
            ),
          ),
          padding:
              const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.grey[300],
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        Colors.brown
                            .withValues(
                      alpha: 0.15,
                    ),
                    child: Icon(
                      item['icon']
                          as IconData,
                      color: Colors.brown
                          .shade800,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          item['name']
                              as String,
                          style:
                              GoogleFonts
                                  .poppins(
                            fontSize: 18,
                            fontWeight:
                                FontWeight
                                    .bold,
                            color: Colors
                                .brown
                                .shade800,
                          ),
                        ),
                        Text(
                          "Teacher: ${item['teacher']}",
                          style:
                              TextStyle(
                            fontSize: 12,
                            color:
                                Colors.grey[
                                    600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 30),
              Expanded(
                child:
                    SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        'Assignments',
                        style:
                            GoogleFonts
                                .poppins(
                          fontWeight:
                              FontWeight
                                  .bold,
                          color: Colors
                              .brown
                              .shade800,
                        ),
                      ),
                      const SizedBox(
                          height: 8),
                      if ((item['assignments']
                              as List)
                          .isEmpty)
                        Text(
                          'No assignments posted yet.',
                          style:
                              GoogleFonts
                                  .poppins(
                            fontSize: 13,
                            color: Colors
                                .grey[600],
                          ),
                        )
                      else
                        ...(item['assignments']
                                as List)
                            .map(
                          (task) {
                            return Padding(
                              padding:
                                  const EdgeInsets
                                      .only(
                                bottom: 6,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons
                                        .check_circle_outline,
                                    color: Colors
                                        .brown,
                                    size: 16,
                                  ),
                                  const SizedBox(
                                      width: 8),
                                  Expanded(
                                    child: Text(
                                      task.toString(),
                                      style:
                                          GoogleFonts
                                              .poppins(
                                        fontSize:
                                            13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      const SizedBox(
                          height: 20),
                      Text(
                        'Teacher Remarks',
                        style:
                            GoogleFonts
                                .poppins(
                          fontWeight:
                              FontWeight
                                  .bold,
                          color: Colors
                              .brown
                              .shade800,
                        ),
                      ),
                      const SizedBox(
                          height: 8),
                      Container(
                        width:
                            double.infinity,
                        padding:
                            const EdgeInsets
                                .all(12),
                        decoration:
                            BoxDecoration(
                          color: Colors
                              .amber
                              .withValues(
                            alpha: 0.1,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                          border:
                              Border.all(
                            color: Colors
                                .amber
                                .shade300,
                          ),
                        ),
                        child: Text(
                          item[
                                  'teacherComplaint']
                              .toString(),
                          style:
                              GoogleFonts
                                  .poppins(
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(
                          height: 20),
                      Text(
                        'Term-Wise Examination Marks',
                        style:
                            GoogleFonts
                                .poppins(
                          fontWeight:
                              FontWeight
                                  .bold,
                          color: Colors
                              .brown
                              .shade800,
                        ),
                      ),
                      const SizedBox(
                          height: 10),
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children:
                            (item['marks']
                                    as Map<
                                        String,
                                        String>)
                                .entries
                                .map(
                          (e) {
                            return Expanded(
                              child:
                                  Container(
                                margin:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal:
                                      4,
                                ),
                                padding:
                                    const EdgeInsets
                                        .all(
                                  10,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      const Color(
                                    0xFFFAF8F5,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    12,
                                  ),
                                  border:
                                      Border.all(
                                    color: Colors
                                        .brown
                                        .withValues(
                                      alpha:
                                          0.2,
                                    ),
                                  ),
                                ),
                                child:
                                    Column(
                                  children: [
                                    Text(
                                      e.key,
                                      textAlign:
                                          TextAlign
                                              .center,
                                      style:
                                          GoogleFonts
                                              .poppins(
                                        fontSize:
                                            11,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                        color: Colors
                                            .brown,
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                            5),
                                    Text(
                                      e.value,
                                      textAlign:
                                          TextAlign
                                              .center,
                                      style:
                                          GoogleFonts
                                              .poppins(
                                        fontSize:
                                            13,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                        color: Colors
                                            .brown
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


  // ============================================================
// ADMIN COMPLAINT
// ============================================================

void _showAdminComplaintDialog() {
  final TextEditingController complaintController =
      TextEditingController();

  bool isSubmitting = false;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
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
                Expanded(
                  child: Text(
                    'Private Complaint',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),

            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Type your message below. This complaint will be sent directly to school management and will remain confidential.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: complaintController,
                    maxLines: 5,
                    enabled: !isSubmitting,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Enter your concern or complaint here...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(
                        alpha: 0.08,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.white38,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.white38,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            actions: [
              TextButton(
                onPressed: isSubmitting
                    ? null
                    : () {
                        complaintController.dispose();
                        Navigator.pop(dialogContext);
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
                  foregroundColor: Colors.brown.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                onPressed: isSubmitting
                    ? null
                    : () async {
                        final String complaint =
                            complaintController.text.trim();

                        // Empty complaint check
                        if (complaint.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please enter your complaint first.',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        // Current logged-in parent
                        final User? currentUser =
                            FirebaseAuth.instance.currentUser;

                        if (currentUser == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please login again before submitting a complaint.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Selected child information
                        Map<String, dynamic> child =
                            familyChildren.isNotEmpty
                                ? familyChildren[_selectedChildIndex]
                                : <String, dynamic>{};

                        // Capture these BEFORE the await below, so we
                        // never use `context` across an async gap
                        // (fixes use_build_context_synchronously).
                        final NavigatorState navigator =
                            Navigator.of(dialogContext);
                        final ScaffoldMessengerState messenger =
                            ScaffoldMessenger.of(context);

                        setDialogState(() {
                          isSubmitting = true;
                        });

                        try {
                          // ==================================================
                          // SAVE COMPLAINT TO FIRESTORE
                          // Collection:
                          //
                          // complaints
                          //    └── auto generated document
                          //
                          // ==================================================

                          await FirebaseFirestore.instance
                              .collection('complaints')
                              .add({
                            // Complaint information
                            'complaint': complaint,

                            // Parent information
                            'parentUid': currentUser.uid,
                            'parentId':
                                (child['parentId'] ??
                                        currentUser.uid)
                                    .toString(),
                            'parentEmail':
                                (currentUser.email ?? '').trim().toLowerCase(),

                            // Student information
                            'studentId':
                                (child['studentId'] ?? '').toString(),
                            'studentName':
                                (child['name'] ?? '').toString(),
                            'className':
                                (child['className'] ?? '').toString(),
                            'section':
                                (child['section'] ?? '').toString(),
                            'rollNo':
                                (child['roll'] ?? '').toString(),
                            'admissionNo':
                                (child['admissionNo'] ?? '').toString(),

                            // Father/parent contact
                            'fatherName':
                                (child['fatherName'] ?? '').toString(),
                            'phone':
                                (child['phone'] ?? '').toString(),

                            // Complaint status
                            'status': 'Pending',

                            // Admin response will be stored here later
                            'adminReply': '',

                            // Creation time
                            'createdAt':
                                FieldValue.serverTimestamp(),

                            // Last update time
                            'updatedAt':
                                FieldValue.serverTimestamp(),
                          });

                          if (!mounted) return;

                          navigator.pop();

                          complaintController.dispose();

                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Your complaint has been submitted successfully to the Admin.',
                              ),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 4),
                            ),
                          );

                          debugPrint(
                            '======================================',
                          );
                          debugPrint(
                            'COMPLAINT SUBMITTED SUCCESSFULLY',
                          );
                          debugPrint(
                            'Parent UID: ${currentUser.uid}',
                          );
                          debugPrint(
                            'Student: ${child['name']}',
                          );
                          debugPrint(
                            'Class: ${child['className']}',
                          );
                          debugPrint(
                            'Complaint: $complaint',
                          );
                          debugPrint(
                            '======================================',
                          );
                        } catch (e) {
                          debugPrint(
                            'COMPLAINT SUBMISSION ERROR: $e',
                          );

                          if (!mounted) return;

                          setDialogState(() {
                            isSubmitting = false;
                          });

                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                'Complaint could not be submitted.\n$e',
                              ),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        }
                      },

                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.brown,
                        ),
                      )
                    : const Text(
                        'Submit',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          );
        },
      );
    },
  );
}
}