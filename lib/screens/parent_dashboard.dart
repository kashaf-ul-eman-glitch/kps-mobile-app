import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/parent_notifications_screen.dart';
import '../widgets/parent_drawer.dart';

// ================================================================
// PARENT DASHBOARD
// ================================================================

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==============================================================
  // CHILDREN
  // ==============================================================

  List<Map<String, dynamic>> _familyChildren = [];

  int _selectedChildIndex = 0;

  bool _isLoading = true;
  String? _errorMessage;

  // ==============================================================
  // SUBJECTS
  // ==============================================================

  List<Map<String, dynamic>> _subjects = [];
  bool _subjectsLoading = false;

  // ==============================================================
  // CURRENT CHILD
  // ==============================================================

  Map<String, dynamic> get _currentChild {
    if (_familyChildren.isEmpty) {
      return <String, dynamic>{};
    }

    if (_selectedChildIndex < 0 ||
        _selectedChildIndex >= _familyChildren.length) {
      return _familyChildren.first;
    }

    return _familyChildren[_selectedChildIndex];
  }

  String get _studentName {
    final String name =
        (_currentChild['name'] ?? '').toString().trim();

    return name.isEmpty ? 'Student' : name;
  }

  String get _className {
    return (_currentChild['className'] ?? '').toString().trim();
  }

  String get _section {
    return (_currentChild['section'] ?? '').toString().trim();
  }

  String get _roll {
    return (_currentChild['roll'] ?? '').toString().trim();
  }

  String get _studentId {
    return (_currentChild['studentId'] ?? '').toString().trim();
  }

  String get _photoUrl {
    return (_currentChild['photoUrl'] ?? '').toString().trim();
  }

  // ==============================================================
  // INIT
  // ==============================================================

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  // ==============================================================
  // LOAD CHILDREN
  // ==============================================================

  Future<void> _loadChildren() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final User? user = _auth.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _errorMessage = 'User is not logged in.';
        });

        return;
      }

      const List<String> schoolClasses = [
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

      final List<Map<String, dynamic>> children = [];

      for (final String className in schoolClasses) {
        try {
          final QuerySnapshot<Map<String, dynamic>> snapshot =
              await _firestore
                  .collection('classes')
                  .doc(className)
                  .collection('students')
                  .where(
                    'parentUid',
                    isEqualTo: user.uid,
                  )
                  .get();

          for (final doc in snapshot.docs) {
            final Map<String, dynamic> data =
                Map<String, dynamic>.from(doc.data());

            if ((data['studentId'] ?? '').toString().trim().isEmpty) {
              data['studentId'] = doc.id;
            }

            if ((data['className'] ?? '').toString().trim().isEmpty) {
              data['className'] = className;
            }

            if ((data['name'] ?? '').toString().trim().isEmpty) {
              if ((data['studentName'] ?? '').toString().trim().isNotEmpty) {
                data['name'] = data['studentName'];
              } else if ((data['fullName'] ?? '').toString().trim().isNotEmpty) {
                data['name'] = data['fullName'];
              } else {
                data['name'] = 'Student';
              }
            }

            data['section'] ??= '';
            data['roll'] ??= '';
            data['photoUrl'] ??= '';

            children.add(data);
          }
        } catch (e) {
          debugPrint('ERROR CHECKING $className: $e');
        }
      }

      children.sort((a, b) {
        final String nameA =
            (a['name'] ?? '').toString().toLowerCase().trim();

        final String nameB =
            (b['name'] ?? '').toString().toLowerCase().trim();

        return nameA.compareTo(nameB);
      });

      if (!mounted) return;

      setState(() {
        _familyChildren = children;
        _selectedChildIndex = 0;
        _isLoading = false;
      });

      if (children.isNotEmpty) {
        await _loadSubjects();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Something went wrong while loading child information.';
      });
    }
  }

  // ==============================================================
  // LOAD SUBJECTS
  // ==============================================================

  Future<void> _loadSubjects() async {
    if (_className.isEmpty || _studentId.isEmpty) {
      if (!mounted) return;

      setState(() {
        _subjects = [];
        _subjectsLoading = false;
      });

      return;
    }

    if (!mounted) return;

    setState(() {
      _subjectsLoading = true;
    });

    try {
      final DocumentSnapshot<Map<String, dynamic>> studentSnapshot =
          await _firestore
              .collection('classes')
              .doc(_className)
              .collection('students')
              .doc(_studentId)
              .get();

      Map<String, dynamic> studentData = {};

      if (studentSnapshot.exists &&
          studentSnapshot.data() != null) {
        studentData =
            Map<String, dynamic>.from(studentSnapshot.data()!);
      }

      final QuerySnapshot<Map<String, dynamic>> subjectSnapshot =
          await _firestore
              .collection('classes')
              .doc(_className)
              .collection('subjects')
              .get();

      final List<Map<String, dynamic>> loadedSubjects = [];

      final dynamic studentSubjects = studentData['subjects'];

      for (final QueryDocumentSnapshot<Map<String, dynamic>> subjectDoc
          in subjectSnapshot.docs) {
        final Map<String, dynamic> subjectData =
            Map<String, dynamic>.from(subjectDoc.data());

        final String subjectName =
            (subjectData['name'] ??
                    subjectData['subjectName'] ??
                    subjectData['title'] ??
                    subjectDoc.id)
                .toString();

        Map<String, dynamic> marks = {};

        if (studentSubjects is Map) {
          dynamic foundSubject;

          if (studentSubjects.containsKey(subjectName)) {
            foundSubject = studentSubjects[subjectName];
          } else if (studentSubjects.containsKey(subjectDoc.id)) {
            foundSubject = studentSubjects[subjectDoc.id];
          } else {
            for (final entry in studentSubjects.entries) {
              if (entry.key
                      .toString()
                      .toLowerCase()
                      .trim() ==
                  subjectName.toLowerCase().trim()) {
                foundSubject = entry.value;
                break;
              }
            }
          }

          if (foundSubject is Map) {
            marks = Map<String, dynamic>.from(foundSubject);
          }
        }

        if (subjectData['marks'] is Map) {
          final Map<String, dynamic> subjectMarks =
              Map<String, dynamic>.from(subjectData['marks']);

          marks = {
            ...marks,
            ...subjectMarks,
          };
        }

        // ==========================================================
        // LIVE MARKS FROM TEACHER UPLOAD
        //
        // This is the same document the Upload Marks screen writes
        // to (classes/{class}/students/{studentId}/subjectRecords/
        // {subjectId}) and the same one the Result screen reads for
        // class position. Whatever the teacher just uploaded is the
        // source of truth, so it overrides anything found above.
        // ==========================================================
        try {
          final DocumentSnapshot<Map<String, dynamic>> recordSnap =
              await _firestore
                  .collection('classes')
                  .doc(_className)
                  .collection('students')
                  .doc(_studentId)
                  .collection('subjectRecords')
                  .doc(subjectDoc.id)
                  .get();

          if (recordSnap.exists) {
            final Map? recordMarks = recordSnap.data()?['marks'] as Map?;

            if (recordMarks != null) {
              final dynamic liveFinal = recordMarks['Final Term'];
              final dynamic liveMid = recordMarks['Mid Term'];
              final dynamic liveFirst = recordMarks['First Term'];

              if (liveFinal != null) {
                marks['final'] = liveFinal;
              }
              if (liveMid != null) {
                marks['midTerm'] = liveMid;
              }
              if (liveFirst != null) {
                marks['firstTerm'] = liveFirst;
              }
            }
          }
        } catch (e) {
          debugPrint('SUBJECT RECORD FETCH ERROR ($subjectDoc.id): $e');
        }

        loadedSubjects.add({
          'id': subjectDoc.id,
          'name': subjectName,

          'firstTerm': _findMark(
            marks,
            [
              'firstTerm',
              'first_term',
              'first term',
              'term1',
              'term_1',
              'term 1',
              'first',
            ],
          ),

          'midTerm': _findMark(
            marks,
            [
              'midTerm',
              'mid_term',
              'mid term',
              'mid',
              'midterm',
            ],
          ),

          'final': _findMark(
            marks,
            [
              'final',
              'finalExam',
              'final_exam',
              'final exam',
              'finalTerm',
              'final_term',
            ],
          ),
        });
      }

      if (loadedSubjects.isEmpty && studentSubjects is Map) {
        for (final entry in studentSubjects.entries) {
          final String subjectName = entry.key.toString();

          Map<String, dynamic> marks = {};

          if (entry.value is Map) {
            marks =
                Map<String, dynamic>.from(entry.value);
          }

          loadedSubjects.add({
            'id': subjectName,
            'name': subjectName,

            'firstTerm': _findMark(
              marks,
              [
                'firstTerm',
                'first_term',
                'first term',
                'term1',
                'term_1',
                'term 1',
                'first',
              ],
            ),

            'midTerm': _findMark(
              marks,
              [
                'midTerm',
                'mid_term',
                'mid term',
                'mid',
                'midterm',
              ],
            ),

            'final': _findMark(
              marks,
              [
                'final',
                'finalExam',
                'final_exam',
                'final exam',
                'finalTerm',
                'final_term',
              ],
            ),
          });
        }
      }

      loadedSubjects.sort((a, b) {
        return a['name']
            .toString()
            .toLowerCase()
            .compareTo(
              b['name']
                  .toString()
                  .toLowerCase(),
            );
      });

      if (!mounted) return;

      setState(() {
        _subjects = loadedSubjects;
        _subjectsLoading = false;
      });
    } catch (e) {
      debugPrint('SUBJECT ERROR: $e');

      if (!mounted) return;

      setState(() {
        _subjects = [];
        _subjectsLoading = false;
      });
    }
  }

  // ==============================================================
  // FIND MARK
  // ==============================================================

  dynamic _findMark(
    Map<String, dynamic> marks,
    List<String> keys,
  ) {
    for (final key in keys) {
      if (marks.containsKey(key)) {
        return marks[key];
      }
    }

    for (final entry in marks.entries) {
      final String entryKey =
          entry.key.toString().toLowerCase();

      for (final key in keys) {
        if (entryKey == key.toLowerCase()) {
          return entry.value;
        }
      }
    }

    return null;
  }

  // ==============================================================
  // CHILD SELECT
  // ==============================================================

  Future<void> _onChildSelected(int index) async {
    if (index < 0 ||
        index >= _familyChildren.length) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _selectedChildIndex = index;
      _subjects = [];
      _subjectsLoading = true;
    });

    await _loadSubjects();

    if (!mounted) return;

    Navigator.of(context).pop();
  }

  Future<void> _onChildSelectedFromDashboard(
    int index,
  ) async {
    if (index < 0 ||
        index >= _familyChildren.length) {
      return;
    }

    if (index == _selectedChildIndex) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _selectedChildIndex = index;
      _subjects = [];
      _subjectsLoading = true;
    });

    await _loadSubjects();
  }

  // ==============================================================
  // REFRESH
  // ==============================================================

  Future<void> _refresh() async {
    await _loadChildren();
  }

  // ==============================================================
  // NOTIFICATIONS
  // ==============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      _notificationsStream() {
    return _firestore.collection('notifications').snapshots();
  }

  // ==============================================================
  // CHECK NOTIFICATION FOR CURRENT PARENT
  // ==============================================================

  bool _isNotificationForParent(
    Map<String, dynamic> data,
    Map<String, dynamic> parentProfile,
  ) {
    final String targetRole =
        data['targetRole']?.toString().toLowerCase().trim() ?? '';

    final User? user = _auth.currentUser;
    final String uid = (user?.uid ?? '').toLowerCase().trim();
    final String email =
        (parentProfile['email'] ?? user?.email ?? '')
            .toString()
            .toLowerCase()
            .trim();
    final String fatherName =
        (parentProfile['fatherName'] ?? parentProfile['father_name'] ?? '')
            .toString()
            .toLowerCase()
            .trim();
    final String rollNo = (parentProfile['rollNo'] ??
            parentProfile['rollNumber'] ??
            parentProfile['roll_no'] ??
            _roll)
        .toString()
        .toLowerCase()
        .trim();
    final String studentName = (parentProfile['studentName'] ??
            parentProfile['name'] ??
            _studentName)
        .toString()
        .toLowerCase()
        .trim();

    // 1. ALL / PUBLIC NOTIFICATIONS
    if (targetRole == 'all' ||
        targetRole == 'all_parents' ||
        targetRole == 'parents' ||
        targetRole == 'parent') {
      return true;
    }

    // Check helper for single field
    bool matchesValue(dynamic value) {
      if (value == null) return false;
      final valStr = value.toString().toLowerCase().trim();
      if (valStr.isEmpty) return false;

      if (uid.isNotEmpty && valStr == uid) return true;
      if (email.isNotEmpty && valStr == email) return true;
      if (rollNo.isNotEmpty && valStr == rollNo) return true;
      if (fatherName.isNotEmpty && valStr == fatherName) return true;
      if (studentName.isNotEmpty && valStr == studentName) return true;

      return false;
    }

    bool matchesMap(Map map) {
      final mapUid = (map['uid'] ?? map['parentUid'] ?? map['userUid'] ?? '')
          .toString()
          .toLowerCase()
          .trim();
      final mapEmail = (map['email'] ?? '').toString().toLowerCase().trim();
      final mapFather = (map['fatherName'] ?? map['father_name'] ?? '')
          .toString()
          .toLowerCase()
          .trim();
      final mapRoll = (map['rollNo'] ?? map['rollNumber'] ?? map['roll_no'] ?? '')
          .toString()
          .toLowerCase()
          .trim();
      final mapStudent = (map['studentName'] ?? map['name'] ?? map['childName'] ?? '')
          .toString()
          .toLowerCase()
          .trim();

      if (uid.isNotEmpty && mapUid.isNotEmpty && mapUid == uid) return true;
      if (email.isNotEmpty && mapEmail.isNotEmpty && mapEmail == email) return true;
      if (rollNo.isNotEmpty && mapRoll.isNotEmpty && mapRoll == rollNo) return true;
      if (fatherName.isNotEmpty && mapFather.isNotEmpty && mapFather == fatherName) {
        return true;
      }
      if (studentName.isNotEmpty &&
          mapStudent.isNotEmpty &&
          mapStudent == studentName) {
        return true;
      }

      for (var entry in map.entries) {
        if (matchesValue(entry.value)) return true;
      }

      return false;
    }

    // 2. CHECK DIRECT SINGLE FIELDS
    final List<String> directFields = [
      'parentUid',
      'parentUID',
      'recipientUid',
      'recipientEmail',
      'email',
      'fatherName',
      'father_name',
      'rollNo',
      'rollNumber',
      'roll_no',
      'studentName',
      'student_name',
      'targetUid',
      'userUid',
    ];

    for (final field in directFields) {
      if (matchesValue(data[field])) {
        return true;
      }
    }

    // 3. CHECK LISTS / COLLECTIONS
    final List<String> collectionFields = [
      'parentUids',
      'parentUIDs',
      'selectedParents',
      'parents',
      'recipients',
      'selectedRecipients',
      'targetUsers',
      'targetUids',
      'selectedUsers',
      'recipientUids',
    ];

    for (final field in collectionFields) {
      final dynamic value = data[field];

      if (value is List) {
        for (final item in value) {
          if (item is Map) {
            if (matchesMap(item)) return true;
          } else {
            if (matchesValue(item)) return true;
          }
        }
      } else if (value is Map) {
        if (matchesMap(value)) return true;
        if (uid.isNotEmpty && value.containsKey(uid)) return true;
        if (email.isNotEmpty && value.containsKey(email)) return true;
        if (rollNo.isNotEmpty && value.containsKey(rollNo)) return true;
      }
    }

    return false;
  }

  // ==============================================================
  // CHECK READ
  // ==============================================================

  bool _isNotificationRead(
    Map<String, dynamic> data,
  ) {
    final User? user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    final dynamic readBy = data['readBy'];

    if (readBy is Map) {
      return readBy[user.uid] == true;
    }

    return false;
  }

  // ==============================================================
  // OPEN NOTIFICATIONS
  // ==============================================================

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const ParentNotificationsScreen(),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    final User? currentUser = _auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,

      // ============================================================
      // SEPARATE DRAWER
      // ============================================================

      drawer: ParentDrawer(
        familyChildren: _familyChildren,
        selectedChildIndex: _selectedChildIndex,
      ),

      body: Stack(
        fit: StackFit.expand,
        children: [
          // ========================================================
          // BACKGROUND
          // ========================================================

          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return Container(
                  color: Colors.black,
                );
              },
            ),
          ),

          // ========================================================
          // DARK OVERLAY
          // ========================================================

          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(
                alpha: 0.58,
              ),
            ),
          ),

          SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,
              color: Colors.white,
              backgroundColor: Colors.black87,

              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  35,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    // ==================================================
                    // TOP BAR
                    // ==================================================

                    Row(
                      children: [
                        // ------------------------------------------------
                        // MENU
                        // ------------------------------------------------

                        Builder(
                          builder: (drawerContext) {
                            return Container(
                              decoration:
                                  BoxDecoration(
                                color: Colors.black
                                    .withValues(
                                  alpha: 0.42,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                  14,
                                ),
                                border:
                                    Border.all(
                                  color: Colors.white
                                      .withValues(
                                    alpha: 0.18,
                                  ),
                                ),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  Scaffold.of(
                                    drawerContext,
                                  ).openDrawer();
                                },
                                icon:
                                    const Icon(
                                  Icons.menu_rounded,
                                  color:
                                      Colors.white,
                                  size: 29,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(
                          width: 14,
                        ),

                        // ------------------------------------------------
                        // TITLE
                        // ------------------------------------------------

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Parent Dashboard',
                                style:
                                    GoogleFonts
                                        .poppins(
                                  color:
                                      Colors.white,
                                  fontSize: 21,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Khyber Public School',
                                style:
                                    GoogleFonts
                                        .poppins(
                                  color:
                                      Colors.white70,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ------------------------------------------------
                        // NOTIFICATION ICON + BADGE
                        // ------------------------------------------------

                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: currentUser != null
                              ? _firestore
                                  .collection('users')
                                  .doc(currentUser.uid)
                                  .snapshots()
                              : const Stream.empty(),
                          builder: (context, userSnapshot) {
                            final parentProfile =
                                userSnapshot.data?.data() ?? <String, dynamic>{};

                            return StreamBuilder<
                                QuerySnapshot<
                                    Map<String,
                                        dynamic>>>(
                              stream: _notificationsStream(),
                              builder: (context, snapshot) {
                                int unreadCount = 0;

                                if (snapshot.hasData) {
                                  for (final doc in snapshot.data!.docs) {
                                    final data = doc.data();

                                    if (_isNotificationForParent(
                                            data, parentProfile) &&
                                        !_isNotificationRead(data)) {
                                      unreadCount++;
                                    }
                                  }
                                }

                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.42,
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.18,
                                          ),
                                        ),
                                      ),
                                      child: IconButton(
                                        onPressed: _openNotifications,
                                        icon: const Icon(
                                          Icons.notifications_none_rounded,
                                          color: Colors.white,
                                          size: 25,
                                        ),
                                      ),
                                    ),
                                    if (unreadCount > 0)
                                      Positioned(
                                        right: -2,
                                        top: -3,
                                        child: Container(
                                          constraints: const BoxConstraints(
                                            minWidth: 19,
                                            minHeight: 19,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              unreadCount > 99
                                                  ? '99+'
                                                  : unreadCount.toString(),
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 8.5,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            );
                          },
                        ),

                        const SizedBox(
                          width: 8,
                        ),

                        // ------------------------------------------------
                        // LOGO
                        // ------------------------------------------------

                        Container(
                          width: 54,
                          height: 54,
                          padding:
                              const EdgeInsets.all(5),
                          decoration:
                              BoxDecoration(
                            color: Colors.black
                                .withValues(
                              alpha: 0.30,
                            ),
                            shape:
                                BoxShape.circle,
                            border:
                                Border.all(
                              color: Colors.white
                                  .withValues(
                                alpha: 0.25,
                              ),
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.jpg',
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return const Icon(
                                  Icons
                                      .school_rounded,
                                  color:
                                      Colors.white,
                                  size: 29,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    // ==================================================
                    // CONTENT
                    // ==================================================

                    if (_isLoading)
                      _buildLoadingCard()
                    else if (_errorMessage != null)
                      _buildErrorCard()
                    else if (_familyChildren.isEmpty)
                      _buildEmptyCard()
                    else ...[
                      _buildWelcomeCard(),

                      const SizedBox(
                        height: 18,
                      ),

                      _buildChildCard(),

                      const SizedBox(
                        height: 25,
                      ),

                      _buildSubjectsSection(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // LOADING CARD
  // ==============================================================

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: 0.46,
        ),
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.14,
          ),
        ),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(
            color: Colors.white,
          ),
          SizedBox(height: 18),
          Text(
            'Loading your child information...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // ERROR CARD
  // ==============================================================

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: 0.48,
        ),
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.15,
          ),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.white,
            size: 52,
          ),
          const SizedBox(height: 15),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: _refresh,
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            label: const Text(
              'Try Again',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // EMPTY CHILD
  // ==============================================================

  Widget _buildEmptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: 0.46,
        ),
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.15,
          ),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.person_search_rounded,
            color: Colors.white,
            size: 55,
          ),
          const SizedBox(height: 16),
          Text(
            'No Child Record Found',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your child information has not been added yet. Please contact the school administration.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: _refresh,
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            label: const Text(
              'Refresh',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // WELCOME
  // ==============================================================

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: 0.42,
        ),
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.14,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildStudentAvatar(
            size: 58,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, Parent',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _studentName,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                if (_className.isNotEmpty)
                  Text(
                    _className,
                    style:
                        GoogleFonts.poppins(
                      color: Colors.white60,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // STUDENT AVATAR
  // ==============================================================

  Widget _buildStudentAvatar({
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(
          alpha: 0.30,
        ),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: ClipOval(
        child: _photoUrl.isNotEmpty
            ? Image.network(
                _photoUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) {
                  return Icon(
                    Icons.person,
                    color: Colors.white,
                    size: size * 0.50,
                  );
                },
              )
            : Icon(
                Icons.person,
                color: Colors.white,
                size: size * 0.50,
              ),
      ),
    );
  }

  // ==============================================================
  // CHILD CARD
  // ==============================================================

  Widget _buildChildCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: 0.42,
        ),
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.14,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'CURRENT CHILD',
            style: GoogleFonts.poppins(
              color: Colors.white60,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),

          PopupMenuButton<int>(
            color: const Color(0xFF171717),
            elevation: 12,
            offset:
                const Offset(0, 8),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),
            onSelected: (index) async {
              await _onChildSelectedFromDashboard(
                index,
              );
            },
            itemBuilder: (context) {
              return List.generate(
                _familyChildren.length,
                (index) {
                  final child =
                      _familyChildren[index];

                  final String name =
                      (child['name'] ??
                              child['studentName'] ??
                              'Student')
                          .toString();

                  final String className =
                      (child['className'] ??
                              '')
                          .toString();

                  final bool selected =
                      index ==
                          _selectedChildIndex;

                  return PopupMenuItem<int>(
                    value: index,
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration:
                              BoxDecoration(
                            shape:
                                BoxShape.circle,
                            color: Colors.white
                                .withValues(
                              alpha: 0.10,
                            ),
                          ),
                          child: const Icon(
                            Icons
                                .person_rounded,
                            color:
                                Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style: GoogleFonts
                                    .poppins(
                                  color:
                                      Colors
                                          .white,
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                ),
                              ),
                              if (className
                                  .isNotEmpty)
                                Text(
                                  className,
                                  style:
                                      GoogleFonts
                                          .poppins(
                                    color: Colors
                                        .white60,
                                    fontSize: 9,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (selected)
                          const Icon(
                            Icons
                                .check_circle_rounded,
                            color:
                                Colors.white,
                            size: 20,
                          ),
                      ],
                    ),
                  );
                },
              );
            },
            child: Row(
              children: [
                _buildStudentAvatar(
                  size: 68,
                ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        _studentName,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            GoogleFonts
                                .poppins(
                          color:
                              Colors.white,
                          fontSize: 18,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        [
                          if (_className
                              .isNotEmpty)
                            _className,
                          if (_section
                              .isNotEmpty)
                            _section,
                        ].join(' • '),
                        style:
                            GoogleFonts
                                .poppins(
                          color:
                              Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      if (_roll.isNotEmpty) ...[
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          'Roll No: $_roll',
                          style:
                              GoogleFonts
                                  .poppins(
                            color:
                                Colors.white60,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  width: 38,
                  height: 38,
                  decoration:
                      BoxDecoration(
                    color: Colors.white
                        .withValues(
                      alpha: 0.09,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: const Icon(
                    Icons
                        .keyboard_arrow_down_rounded,
                    color:
                        Colors.white,
                    size: 25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // SUBJECT SECTION
  // ==============================================================

  Widget _buildSubjectsSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Subjects',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
            if (_className.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.black
                      .withValues(
                    alpha: 0.35,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                  border: Border.all(
                    color: Colors.white
                        .withValues(
                      alpha: 0.15,
                    ),
                  ),
                ),
                child: Text(
                  _className,
                  style:
                      GoogleFonts.poppins(
                    color:
                        Colors.white70,
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 5),

        Text(
          'Subjects for $_studentName • Tap a subject to view marks',
          style: GoogleFonts.poppins(
            color: Colors.white60,
            fontSize: 10,
          ),
        ),

        const SizedBox(height: 14),

        if (_subjectsLoading)
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(25),
            decoration:
                BoxDecoration(
              color: Colors.black
                  .withValues(
                alpha: 0.38,
              ),
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
              border: Border.all(
                color: Colors.white
                    .withValues(
                  alpha: 0.12,
                ),
              ),
            ),
            child: const Center(
              child:
                  CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          )
        else if (_subjects.isEmpty)
          _buildNoSubjectsCard()
        else
          GridView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),

            itemCount:
                _subjects.length,

            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.02,
            ),

            itemBuilder:
                (context, index) {
              return _buildSubjectBox(
                _subjects[index],
                index,
              );
            },
          ),
      ],
    );
  }

  // ==============================================================
  // NO SUBJECTS
  // ==============================================================

  Widget _buildNoSubjectsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: 0.38,
        ),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.12,
          ),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.menu_book_outlined,
            color: Colors.white70,
            size: 42,
          ),
          const SizedBox(height: 10),
          Text(
            'No Subjects Found',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Subjects for $_className have not been added yet.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white60,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // SUBJECT BOX WITH MARKS
  // ==============================================================

  Widget _buildSubjectBox(
    Map<String, dynamic> subject,
    int index,
  ) {
    final String name =
        subject['name'].toString();

    final dynamic firstTerm =
        subject['firstTerm'];

    final dynamic midTerm =
        subject['midTerm'];

    final dynamic finalMark =
        subject['final'];

    final double? total =
        _calculateTotal(
      firstTerm,
      midTerm,
      finalMark,
    );

    return InkWell(
      onTap: () {
        _showSubjectMarks(subject);
      },
      borderRadius:
          BorderRadius.circular(20),
      child: Container(
        padding:
            const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.black
              .withValues(
            alpha: 0.40,
          ),
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white
                .withValues(
              alpha: 0.14,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration:
                      BoxDecoration(
                    color: Colors.white
                        .withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      11,
                    ),
                  ),
                  child: const Icon(
                    Icons
                        .menu_book_rounded,
                    color:
                        Colors.white,
                    size: 19,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons
                      .arrow_forward_ios_rounded,
                  color:
                      Colors.white54,
                  size: 11,
                ),
              ],
            ),

            const SizedBox(height: 9),

            Text(
              name,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  GoogleFonts.poppins(
                color:
                    Colors.white,
                fontSize: 12.5,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(height: 7),

            // ------------------------------------------------------
            // MARKS
            // ------------------------------------------------------

            Row(
              children: [
                Expanded(
                  child: _buildSmallMark(
                    '1st',
                    firstTerm,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: _buildSmallMark(
                    'Mid',
                    midTerm,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: _buildSmallMark(
                    'Final',
                    finalMark,
                  ),
                ),
              ],
            ),

            const Spacer(),

            if (total != null)
              Row(
                children: [
                  Text(
                    'Total',
                    style:
                        GoogleFonts.poppins(
                      color:
                          Colors.white54,
                      fontSize: 9,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatMark(total),
                    style:
                        GoogleFonts.poppins(
                      color:
                          Colors.white,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ],
              )
            else
              Text(
                'Marks not available',
                style:
                    GoogleFonts.poppins(
                  color:
                      Colors.white54,
                  fontSize: 8.5,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // SMALL MARK
  // ==============================================================

  Widget _buildSmallMark(
    String title,
    dynamic mark,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white
            .withValues(
          alpha: 0.07,
        ),
        borderRadius:
            BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white
              .withValues(
            alpha: 0.08,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style:
                GoogleFonts.poppins(
              color:
                  Colors.white54,
              fontSize: 7,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _formatMark(mark),
            style:
                GoogleFonts.poppins(
              color:
                  Colors.white,
              fontSize: 10,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // CALCULATE TOTAL
  // ==============================================================

  double? _calculateTotal(
    dynamic firstTerm,
    dynamic midTerm,
    dynamic finalMark,
  ) {
    final double? a =
        _toDouble(firstTerm);

    final double? b =
        _toDouble(midTerm);

    final double? c =
        _toDouble(finalMark);

    if (a == null &&
        b == null &&
        c == null) {
      return null;
    }

    return (a ?? 0) +
        (b ?? 0) +
        (c ?? 0);
  }

  // ==============================================================
  // DOUBLE
  // ==============================================================

  double? _toDouble(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }

  // ==============================================================
  // FORMAT MARK
  // ==============================================================

  String _formatMark(
    dynamic value,
  ) {
    if (value == null) {
      return '—';
    }

    if (value is num) {
      if (value % 1 == 0) {
        return value.toInt().toString();
      }

      return value.toString();
    }

    return value.toString();
  }

  // ==============================================================
  // SUBJECT MARK DETAILS
  // ==============================================================

  void _showSubjectMarks(
    Map<String, dynamic> subject,
  ) {
    final String name =
        subject['name'].toString();

    final dynamic firstTerm =
        subject['firstTerm'];

    final dynamic midTerm =
        subject['midTerm'];

    final dynamic finalMark =
        subject['final'];

    final double? total =
        _calculateTotal(
      firstTerm,
      midTerm,
      finalMark,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor:
          Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            30,
          ),
          decoration:
              BoxDecoration(
            color:
                const Color(0xFF111111),
            borderRadius:
                const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
            border: Border.all(
              color: Colors.white
                  .withValues(
                alpha: 0.12,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 4,
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white30,
                    borderRadius:
                        BorderRadius.circular(
                      5,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                Container(
                  width: 62,
                  height: 62,
                  decoration:
                      BoxDecoration(
                    color: Colors.white
                        .withValues(
                      alpha: 0.10,
                    ),
                    shape:
                        BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons
                        .menu_book_rounded,
                    color:
                        Colors.white,
                    size: 30,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                Text(
                  name,
                  textAlign:
                      TextAlign.center,
                  style:
                      GoogleFonts.poppins(
                    color:
                        Colors.white,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                Text(
                  'Marks of $_studentName',
                  style:
                      GoogleFonts.poppins(
                    color:
                        Colors.white60,
                    fontSize: 10,
                  ),
                ),

                const SizedBox(
                  height: 22,
                ),

                _buildMarkRow(
                  icon: Icons
                      .looks_one_outlined,
                  title: '1st Term',
                  mark: firstTerm,
                ),

                const SizedBox(
                  height: 10,
                ),

                _buildMarkRow(
                  icon: Icons
                      .looks_two_outlined,
                  title: 'Mid Term',
                  mark: midTerm,
                ),

                const SizedBox(
                  height: 10,
                ),

                _buildMarkRow(
                  icon: Icons
                      .school_outlined,
                  title: 'Final',
                  mark: finalMark,
                ),

                const SizedBox(
                  height: 14,
                ),

                if (total != null)
                  Container(
                    width:
                        double.infinity,
                    padding:
                    const EdgeInsets
                            .symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    decoration:
                        BoxDecoration(
                      color: Colors.white
                          .withValues(
                        alpha: 0.08,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        16,
                      ),
                      border: Border.all(
                        color: Colors.white
                            .withValues(
                          alpha: 0.15,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons
                              .calculate_outlined,
                          color:
                              Colors.white70,
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: Text(
                            'Total Marks',
                            style: GoogleFonts
                                .poppins(
                              color:
                                  Colors.white,
                              fontSize: 13,
                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                          ),
                        ),
                        Text(
                          _formatMark(total),
                          style: GoogleFonts
                              .poppins(
                            color:
                                Colors.white,
                            fontSize: 17,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(
                  height: 20,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  child:
                      OutlinedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },
                    style: OutlinedButton
                        .styleFrom(
                      side: BorderSide(
                        color: Colors.white
                            .withValues(
                          alpha: 0.25,
                        ),
                      ),
                      padding:
                          const EdgeInsets
                              .symmetric(
                        vertical: 13,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          14,
                        ),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: GoogleFonts
                          .poppins(
                        color:
                            Colors.white,
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==============================================================
  // MARK ROW
  // ==============================================================

  Widget _buildMarkRow({
    required IconData icon,
    required String title,
    required dynamic mark,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white
            .withValues(
          alpha: 0.06,
        ),
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color: Colors.white
              .withValues(
            alpha: 0.10,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration:
                BoxDecoration(
              color: Colors.white
                  .withValues(
                alpha: 0.08,
              ),
              borderRadius:
                  BorderRadius.circular(
                11,
              ),
            ),
            child: Icon(
              icon,
              color:
                  Colors.white70,
              size: 20,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Text(
              title,
              style:
                  GoogleFonts.poppins(
                color:
                    Colors.white,
                fontSize: 12,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),

          Text(
            _formatMark(mark),
            style:
                GoogleFonts.poppins(
              color:
                  Colors.white,
              fontSize: 16,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}