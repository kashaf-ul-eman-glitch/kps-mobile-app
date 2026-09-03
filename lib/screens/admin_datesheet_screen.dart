import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDatesheetScreen extends StatefulWidget {
  const AdminDatesheetScreen({super.key});

  @override
  State<AdminDatesheetScreen> createState() =>
      _AdminDatesheetScreenState();
}

class _AdminDatesheetScreenState
    extends State<AdminDatesheetScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ==============================================================
  // CLASS LIST
  // ==============================================================

  final List<String> _classList = [
    'Play Group',
    'Reception 1',
    'Reception 2',
    'Class 1',
    'Class 2',
    'Class 3',
    'Class 4',
    'Class 5',
    'Class 6',
    'Class 7',
    'Class 8',
    'Class 9 (Matric Part 1)',
    'Class 10 (Matric Part 2)',
    '1st Year (FSc / FA / ICS)',
    '2nd Year (FSc / FA / ICS)',
  ];

  String? _selectedClass;

  String _examTitle = 'Annual Examination 2026';

  bool _isLoadingClass = false;
  bool _isPublishing = false;

  // ==============================================================
  // PAPER LIST
  // ==============================================================

  final List<Map<String, TextEditingController>>
      _papersList = [];

  // ==============================================================
  // INIT
  // ==============================================================

  @override
  void initState() {
    super.initState();
    _addNewPaperRow();
  }

  // ==============================================================
  // CREATE EMPTY PAPER
  // ==============================================================

  Map<String, TextEditingController>
      _createPaper({
    String subject = '',
    String date = '',
    String startTime = '',
    String endTime = '',
  }) {
    return {
      'subject': TextEditingController(text: subject),
      'date': TextEditingController(text: date),
      'startTime':
          TextEditingController(text: startTime),
      'endTime':
          TextEditingController(text: endTime),
    };
  }

  // ==============================================================
  // ADD PAPER
  // ==============================================================

  void _addNewPaperRow() {
    if (!mounted) return;

    setState(() {
      _papersList.add(_createPaper());
    });
  }

  // ==============================================================
  // CLEAR ALL PAPERS
  // ==============================================================

  void _clearPaperRows({
    bool addEmptyRow = true,
  }) {
    for (final paper in _papersList) {
      paper['subject']?.dispose();
      paper['date']?.dispose();
      paper['startTime']?.dispose();
      paper['endTime']?.dispose();
    }

    _papersList.clear();

    if (addEmptyRow) {
      _papersList.add(_createPaper());
    }
  }

  // ==============================================================
  // REMOVE PAPER
  // ==============================================================

  void _removePaperRow(int index) {
    if (_papersList.length <= 1) {
      _showMessage(
        'At least one paper is required.',
      );
      return;
    }

    final paper = _papersList[index];

    paper['subject']?.dispose();
    paper['date']?.dispose();
    paper['startTime']?.dispose();
    paper['endTime']?.dispose();

    setState(() {
      _papersList.removeAt(index);
    });
  }

  // ==============================================================
  // CLASS CHANGED
  // ==============================================================

  Future<void> _onClassChanged(
    String? value,
  ) async {
    if (value == null || value.trim().isEmpty) {
      return;
    }

    // ------------------------------------------------------------
    // IMPORTANT:
    // Immediately clear previous class from UI.
    // ------------------------------------------------------------

    setState(() {
      _selectedClass = value;
      _isLoadingClass = true;
      _examTitle = 'Annual Examination 2026';

      _clearPaperRows(
        addEmptyRow: false,
      );
    });

    try {
      // ----------------------------------------------------------
      // LOAD SELECTED CLASS ONLY
      // ----------------------------------------------------------

      final snapshot = await _firestore
          .collection('classes')
          .doc(value)
          .collection('datesheet')
          .orderBy('order')
          .get();

      // ----------------------------------------------------------
      // SAFETY:
      // If user changed class while previous request was loading,
      // do not put old request data into the new class.
      // ----------------------------------------------------------

      if (!mounted ||
          _selectedClass != value) {
        return;
      }

      final loadedPapers =
          <Map<String, TextEditingController>>[];

      String loadedExamTitle =
          'Annual Examination 2026';

      // ----------------------------------------------------------
      // LOAD EXISTING PAPERS
      // ----------------------------------------------------------

      for (final doc in snapshot.docs) {
        final data = doc.data();

        final subject =
            (data['subject'] ?? '').toString();

        // --------------------------------------------------------
        // DATE
        // --------------------------------------------------------

        String dateText =
            (data['dateLabel'] ?? '').toString();

        final dateValue = data['date'];

        if (dateValue is Timestamp) {
          final date = dateValue.toDate();

          dateText =
              '${date.day.toString().padLeft(2, '0')}/'
              '${date.month.toString().padLeft(2, '0')}/'
              '${date.year}';
        }

        // --------------------------------------------------------
        // TIME
        // --------------------------------------------------------

        final startTime =
            (data['startTime'] ?? '').toString();

        final endTime =
            (data['endTime'] ?? '').toString();

        // --------------------------------------------------------
        // EXAM TITLE
        // --------------------------------------------------------

        final savedExamTitle =
            (data['examTitle'] ?? '')
                .toString()
                .trim();

        if (savedExamTitle.isNotEmpty) {
          loadedExamTitle = savedExamTitle;
        }

        // --------------------------------------------------------
        // ADD PAPER
        // --------------------------------------------------------

        loadedPapers.add(
          _createPaper(
            subject: subject,
            date: dateText,
            startTime: startTime,
            endTime: endTime,
          ),
        );
      }

      // ----------------------------------------------------------
      // UPDATE UI
      // ----------------------------------------------------------

      if (!mounted ||
          _selectedClass != value) {
        // Dispose loaded controllers if class changed again.
        for (final paper in loadedPapers) {
          paper['subject']?.dispose();
          paper['date']?.dispose();
          paper['startTime']?.dispose();
          paper['endTime']?.dispose();
        }

        return;
      }

      setState(() {
        // Clear anything that may have appeared meanwhile.
        for (final paper in _papersList) {
          paper['subject']?.dispose();
          paper['date']?.dispose();
          paper['startTime']?.dispose();
          paper['endTime']?.dispose();
        }

        _papersList.clear();

        if (loadedPapers.isEmpty) {
          // No datesheet for this class.
          // Show one fresh empty row.
          _papersList.add(
            _createPaper(),
          );
        } else {
          // Existing datesheet.
          _papersList.addAll(
            loadedPapers,
          );
        }

        _examTitle = loadedExamTitle;
      });
    } catch (e) {
      if (!mounted ||
          _selectedClass != value) {
        return;
      }

      setState(() {
        _clearPaperRows(
          addEmptyRow: true,
        );
      });

      _showMessage(
        'Unable to load datesheet: $e',
      );
    } finally {
      if (mounted &&
          _selectedClass == value) {
        setState(() {
          _isLoadingClass = false;
        });
      }
    }
  }

  // ==============================================================
  // DATE PICKER
  // ==============================================================

  Future<void> _pickDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime initialDate =
        DateTime.now();

    if (controller.text.trim().isNotEmpty) {
      final existing =
          _parseDate(controller.text.trim());

      if (existing != null) {
        initialDate = existing;
      }
    }

    final DateTime? picked =
        await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme:
                const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: Color(0xFF1A1A1A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        controller.text =
            '${picked.day.toString().padLeft(2, '0')}/'
            '${picked.month.toString().padLeft(2, '0')}/'
            '${picked.year}';
      });
    }
  }

  // ==============================================================
  // TIME PICKER
  // ==============================================================

  Future<void> _pickTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    TimeOfDay initialTime =
        const TimeOfDay(
      hour: 9,
      minute: 0,
    );

    final TimeOfDay? picked =
        await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme:
                const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: Color(0xFF1A1A1A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        controller.text =
            picked.format(context);
      });
    }
  }

  // ==============================================================
  // PARSE DATE
  // ==============================================================

  DateTime? _parseDate(
    String value,
  ) {
    try {
      final parts =
          value.split('/');

      if (parts.length != 3) {
        return null;
      }

      final day =
          int.parse(parts[0]);
      final month =
          int.parse(parts[1]);
      final year =
          int.parse(parts[2]);

      final date =
          DateTime(year, month, day);

      if (date.year != year ||
          date.month != month ||
          date.day != day) {
        return null;
      }

      return date;
    } catch (_) {
      return null;
    }
  }

  // ==============================================================
  // UPDATE / PUBLISH DATE SHEET
  // ==============================================================

  Future<void> _publishDatesheet() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedClass == null ||
        _selectedClass!.trim().isEmpty) {
      _showMessage(
        'Please select a class first.',
      );
      return;
    }

    setState(() {
      _isPublishing = true;
    });

    try {
      final className =
          _selectedClass!.trim();

      final datesheetRef =
          _firestore
              .collection('classes')
              .doc(className)
              .collection('datesheet');

      // ==========================================================
      // DELETE ONLY SELECTED CLASS'S OLD DATESHEET
      // ==========================================================

      final oldData =
          await datesheetRef.get();

      // Firestore batch limit protection.
      // Delete old documents in chunks of 500.
      final oldDocs = oldData.docs;

      for (int start = 0;
          start < oldDocs.length;
          start += 500) {
        final batch =
            _firestore.batch();

        final end =
            (start + 500 <
                    oldDocs.length)
                ? start + 500
                : oldDocs.length;

        for (int i = start;
            i < end;
            i++) {
          batch.delete(
            oldDocs[i].reference,
          );
        }

        await batch.commit();
      }

      // ==========================================================
      // CREATE NEW DATESHEET FOR SELECTED CLASS
      // ==========================================================

      final newBatch =
          _firestore.batch();

      for (int i = 0;
          i < _papersList.length;
          i++) {
        final paper =
            _papersList[i];

        final subject =
            paper['subject']!
                .text
                .trim();

        final dateText =
            paper['date']!
                .text
                .trim();

        final startTime =
            paper['startTime']!
                .text
                .trim();

        final endTime =
            paper['endTime']!
                .text
                .trim();

        final date =
            _parseDate(dateText);

        if (date == null) {
          throw Exception(
            'Invalid date for $subject',
          );
        }

        final doc =
            datesheetRef.doc();

        newBatch.set(
          doc,
          {
            'subject': subject,

            'date':
                Timestamp.fromDate(
              date,
            ),

            'dateLabel':
                dateText,

            'startTime':
                startTime,

            'endTime':
                endTime,

            'time':
                '$startTime - $endTime',

            'order': i,

            'examTitle':
                _examTitle.trim(),

            'className':
                className,

            'createdAt':
                FieldValue
                    .serverTimestamp(),

            'updatedAt':
                FieldValue
                    .serverTimestamp(),
          },
        );
      }

      await newBatch.commit();

      if (!mounted) return;

      _showMessage(
        'Datesheet updated successfully for $className!',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Unable to update datesheet: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  // ==============================================================
  // MESSAGE
  // ==============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          message,
          style:
              GoogleFonts.poppins(
            fontWeight:
                FontWeight.w600,
            fontSize: 12,
          ),
        ),
        backgroundColor:
            Colors.black87,
        behavior:
            SnackBarBehavior.floating,
        margin:
            const EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ==============================================================
  // DISPOSE
  // ==============================================================

  @override
  void dispose() {
    for (final paper in _papersList) {
      paper['subject']?.dispose();
      paper['date']?.dispose();
      paper['startTime']?.dispose();
      paper['endTime']?.dispose();
    }

    super.dispose();
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: Text(
          'Datesheet Manager',
          style:
              GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 19,
            fontWeight:
                FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: Stack(
        children: [
          // ========================================================
          // BACKGROUND
          // ========================================================

          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) {
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
              color: Colors.black
                  .withOpacity(0.72),
            ),
          ),

          // ========================================================
          // BLUR
          // ========================================================

          Positioned.fill(
            child: BackdropFilter(
              filter:
                  ImageFilter.blur(
                sigmaX: 4,
                sigmaY: 4,
              ),
              child: Container(
                color:
                    Colors.transparent,
              ),
            ),
          ),

          // ========================================================
          // CONTENT
          // ========================================================

          SafeArea(
            child:
                SingleChildScrollView(
              physics:
                  const BouncingScrollPhysics(),
              padding:
                  const EdgeInsets.fromLTRB(
                18,
                12,
                18,
                35,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // CLASS / EXAM INFO
                    // ==================================================

                    _glassBox(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _iconBox(
                                Icons
                                    .edit_calendar_rounded,
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                child:
                                    Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Exam & Class Info',
                                      style:
                                          GoogleFonts.poppins(
                                        color:
                                            Colors.white,
                                        fontSize:
                                            17,
                                        fontWeight:
                                            FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      'Create and manage examination schedule',
                                      style:
                                          GoogleFonts.poppins(
                                        color:
                                            Colors.white.withOpacity(0.60),
                                        fontSize:
                                            10.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 18,
                          ),

                          // ==================================================
                          // CLASS DROPDOWN
                          // ==================================================

                          DropdownButtonFormField<
                              String>(
                            value:
                                _selectedClass,
                            isExpanded:
                                true,

                            dropdownColor:
                                const Color(
                              0xFF171717,
                            ),

                            style:
                                GoogleFonts.poppins(
                              color:
                                  Colors.white,
                              fontSize:
                                  13,
                            ),

                            icon:
                                const Icon(
                              Icons
                                  .keyboard_arrow_down_rounded,
                              color:
                                  Colors.white,
                            ),

                            decoration:
                                _inputStyle(
                              'Select Class',
                              Icons
                                  .school_outlined,
                            ),

                            items:
                                _classList
                                    .map(
                              (
                                String cls,
                              ) {
                                return DropdownMenuItem<
                                    String>(
                                  value:
                                      cls,
                                  child:
                                      Text(
                                    cls,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style:
                                        GoogleFonts.poppins(
                                      color:
                                          Colors.white,
                                      fontSize:
                                          13,
                                    ),
                                  ),
                                );
                              },
                            ).toList(),

                            onChanged:
                                _isLoadingClass
                                    ? null
                                    : _onClassChanged,

                            validator:
                                (value) {
                              if (value ==
                                      null ||
                                  value
                                      .isEmpty) {
                                return 'Please select a class';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          // ==================================================
                          // EXAM TITLE
                          // ==================================================

                          TextFormField(
                            key: ValueKey(
                              'exam_${_selectedClass ?? 'none'}',
                            ),
                            initialValue:
                                _examTitle,
                            style:
                                GoogleFonts.poppins(
                              color:
                                  Colors.white,
                              fontSize:
                                  13,
                            ),
                            decoration:
                                _inputStyle(
                              'Exam Title',
                              Icons
                                  .article_outlined,
                            ),
                            onChanged:
                                (value) {
                              _examTitle =
                                  value;
                            },
                            validator:
                                (value) {
                              if (value ==
                                      null ||
                                  value
                                      .trim()
                                      .isEmpty) {
                                return 'Enter exam title';
                              }

                              return null;
                            },
                          ),

                          if (_isLoadingClass) ...[
                            const SizedBox(
                              height: 16,
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 17,
                                  height: 17,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                    color:
                                        Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  width: 9,
                                ),
                                Text(
                                  'Loading selected class datesheet...',
                                  style:
                                      GoogleFonts.poppins(
                                    color:
                                        Colors.white.withOpacity(0.65),
                                    fontSize:
                                        10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    // ==================================================
                    // PAPERS HEADER
                    // ==================================================

                    Row(
                      children: [
                        Expanded(
                          child:
                              Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Papers Schedule',
                                style:
                                    GoogleFonts.poppins(
                                  color:
                                      Colors.white,
                                  fontSize:
                                      18,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                'Add, edit or remove subjects',
                                style:
                                    GoogleFonts.poppins(
                                  color:
                                      Colors.white.withOpacity(0.58),
                                  fontSize:
                                      10,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        // ==================================================
                        // ADD BUTTON
                        // ==================================================

                        Container(
                          decoration:
                              BoxDecoration(
                            color: Colors
                                .white
                                .withOpacity(
                                    0.14),
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        12),
                            border:
                                Border.all(
                              color: Colors
                                  .white
                                  .withOpacity(
                                      0.20),
                            ),
                          ),
                          child:
                              Material(
                            color: Colors
                                .transparent,
                            child:
                                InkWell(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          12),
                              onTap:
                                  _isLoadingClass
                                      ? null
                                      : _addNewPaperRow,
                              child:
                                  Padding(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal:
                                      12,
                                  vertical:
                                      10,
                                ),
                                child:
                                    Row(
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons
                                          .add_rounded,
                                      color:
                                          Colors.white,
                                      size:
                                          19,
                                    ),
                                    const SizedBox(
                                      width:
                                          5,
                                    ),
                                    Text(
                                      'Add',
                                      style:
                                          GoogleFonts.poppins(
                                        color:
                                            Colors.white,
                                        fontSize:
                                            12,
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    // ==================================================
                    // PAPERS LIST
                    // ==================================================

                    ListView.builder(
                      shrinkWrap:
                          true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount:
                          _papersList.length,
                      itemBuilder:
                          (context, index) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(
                            bottom:
                                15,
                          ),
                          child:
                              _paperCard(
                            index,
                          ),
                        );
                      },
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    // ==================================================
                    // UPDATE BUTTON
                    // ==================================================

                    SizedBox(
                      width:
                          double.infinity,
                      height:
                          54,
                      child:
                          ElevatedButton(
                        onPressed:
                            _isPublishing ||
                                    _isLoadingClass ||
                                    _selectedClass ==
                                        null
                                ? null
                                : _publishDatesheet,

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.white,
                          disabledBackgroundColor:
                              Colors.white
                                  .withOpacity(
                                      0.35),
                          foregroundColor:
                              Colors.black,
                          elevation:
                              5,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              15,
                            ),
                          ),
                        ),

                        child:
                            _isPublishing
                                ? const SizedBox(
                                    width:
                                        23,
                                    height:
                                        23,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2.5,
                                      color:
                                          Colors.black,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons
                                            .publish_rounded,
                                        size:
                                            21,
                                      ),
                                      const SizedBox(
                                        width:
                                            9,
                                      ),
                                      Text(
                                        'UPDATE & PUBLISH DATESHEET',
                                        style:
                                            GoogleFonts.poppins(
                                          fontSize:
                                              13,
                                          fontWeight:
                                              FontWeight.w700,
                                          letterSpacing:
                                              0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
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
  // PAPER CARD
  // ==============================================================

  Widget _paperCard(
    int index,
  ) {
    final paper =
        _papersList[index];

    return _glassBox(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ========================================================
          // HEADER
          // ========================================================

          Row(
            children: [
              Container(
                width:
                    34,
                height:
                    34,
                decoration:
                    BoxDecoration(
                  color: Colors.white
                      .withOpacity(
                          0.10),
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                  border:
                      Border.all(
                    color: Colors.white
                        .withOpacity(
                            0.15),
                  ),
                ),
                child:
                    Center(
                  child:
                      Text(
                    '${index + 1}',
                    style:
                        GoogleFonts.poppins(
                      color:
                          Colors.white,
                      fontSize:
                          13,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width:
                    10,
              ),

              Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paper ${index + 1}',
                      style:
                          GoogleFonts.poppins(
                        color:
                            Colors.white,
                        fontSize:
                            14,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Examination paper details',
                      style:
                          GoogleFonts.poppins(
                        color:
                            Colors.white.withOpacity(0.50),
                        fontSize:
                            9.5,
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // DELETE
              // ==================================================

              if (_papersList.length > 1)
                Container(
                  width:
                      38,
                  height:
                      38,
                  decoration:
                      BoxDecoration(
                    color: Colors.white
                        .withOpacity(
                            0.07),
                    borderRadius:
                        BorderRadius.circular(
                      11,
                    ),
                    border:
                        Border.all(
                      color: Colors.white
                          .withOpacity(
                              0.10),
                    ),
                  ),
                  child:
                      IconButton(
                    onPressed:
                        _isLoadingClass
                            ? null
                            : () {
                                _removePaperRow(
                                  index,
                                );
                              },
                    padding:
                        EdgeInsets.zero,
                    icon:
                        Icon(
                      Icons
                          .delete_outline_rounded,
                      color: Colors.white
                          .withOpacity(
                              0.72),
                      size:
                          21,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(
            height:
                15,
          ),

          // ========================================================
          // SUBJECT
          // ========================================================

          TextFormField(
            controller:
                paper['subject'],
            style:
                GoogleFonts.poppins(
              color:
                  Colors.white,
              fontSize:
                  13,
            ),
            decoration:
                _inputStyle(
              'Subject Name',
              Icons
                  .menu_book_rounded,
            ),
            validator:
                (value) {
              if (value ==
                      null ||
                  value
                      .trim()
                      .isEmpty) {
                return 'Enter subject name';
              }

              return null;
            },
          ),

          const SizedBox(
            height:
                11,
          ),

          // ========================================================
          // DATE
          // ========================================================

          TextFormField(
            controller:
                paper['date'],
            readOnly:
                true,
            style:
                GoogleFonts.poppins(
              color:
                  Colors.white,
              fontSize:
                  13,
            ),
            decoration:
                _inputStyle(
              'Paper Date',
              Icons
                  .calendar_today_rounded,
            ),
            onTap:
                _isLoadingClass
                    ? null
                    : () {
                        _pickDate(
                          context,
                          paper[
                              'date']!,
                        );
                      },
            validator:
                (value) {
              if (value ==
                      null ||
                  value.isEmpty) {
                return 'Select paper date';
              }

              return null;
            },
          ),

          const SizedBox(
            height:
                11,
          ),

          // ========================================================
          // TIME
          // ========================================================

          Row(
            children: [
              Expanded(
                child:
                    TextFormField(
                  controller:
                      paper[
                          'startTime'],
                  readOnly:
                      true,
                  style:
                      GoogleFonts.poppins(
                    color:
                        Colors.white,
                    fontSize:
                        12,
                  ),
                  decoration:
                      _inputStyle(
                    'Start Time',
                    Icons
                        .access_time_rounded,
                  ),
                  onTap:
                      _isLoadingClass
                          ? null
                          : () {
                              _pickTime(
                                context,
                                paper[
                                    'startTime']!,
                              );
                            },
                  validator:
                      (value) {
                    if (value ==
                            null ||
                        value
                            .isEmpty) {
                      return 'Start time';
                    }

                    return null;
                  },
                ),
              ),

              const SizedBox(
                width:
                    10,
              ),

              Expanded(
                child:
                    TextFormField(
                  controller:
                      paper[
                          'endTime'],
                  readOnly:
                      true,
                  style:
                      GoogleFonts.poppins(
                    color:
                        Colors.white,
                    fontSize:
                        12,
                  ),
                  decoration:
                      _inputStyle(
                    'End Time',
                    Icons
                        .more_time_rounded,
                  ),
                  onTap:
                      _isLoadingClass
                          ? null
                          : () {
                              _pickTime(
                                context,
                                paper[
                                    'endTime']!,
                              );
                            },
                  validator:
                      (value) {
                    if (value ==
                            null ||
                        value
                            .isEmpty) {
                      return 'End time';
                    }

                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // GLASS BOX
  // ==============================================================

  Widget _glassBox({
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(
        20,
      ),
      child:
          BackdropFilter(
        filter:
            ImageFilter.blur(
          sigmaX:
              12,
          sigmaY:
              12,
        ),
        child:
            Container(
          width:
              double.infinity,
          padding:
              const EdgeInsets.all(
            16,
          ),
          decoration:
              BoxDecoration(
            color: Colors.white
                .withOpacity(
                    0.075),
            borderRadius:
                BorderRadius.circular(
              20,
            ),
            border:
                Border.all(
              color: Colors.white
                  .withOpacity(
                      0.17),
              width:
                  1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(
                        0.28),
                blurRadius:
                    18,
                offset:
                    const Offset(
                  0,
                  8,
                ),
              ),
            ],
          ),
          child:
              child,
        ),
      ),
    );
  }

  // ==============================================================
  // ICON BOX
  // ==============================================================

  Widget _iconBox(
    IconData icon,
  ) {
    return Container(
      width:
          43,
      height:
          43,
      decoration:
          BoxDecoration(
        color: Colors.white
            .withOpacity(
                0.10),
        borderRadius:
            BorderRadius.circular(
          13,
        ),
        border:
            Border.all(
          color: Colors.white
              .withOpacity(
                  0.16),
        ),
      ),
      child:
          Icon(
        icon,
        color:
            Colors.white,
        size:
            22,
      ),
    );
  }

  // ==============================================================
  // INPUT STYLE
  // ==============================================================

  InputDecoration _inputStyle(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      prefixIcon:
          Icon(
        icon,
        color: Colors.white
            .withOpacity(
                0.72),
        size:
            20,
      ),

      labelText:
          label,

      labelStyle:
          GoogleFonts.poppins(
        color: Colors.white
            .withOpacity(
                0.58),
        fontSize:
            11.5,
      ),

      filled:
          true,

      fillColor:
          Colors.black
              .withOpacity(
                  0.28),

      contentPadding:
          const EdgeInsets
              .symmetric(
        vertical:
            14,
        horizontal:
            12,
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        borderSide:
            BorderSide(
          color: Colors.white
              .withOpacity(
                  0.16),
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        borderSide:
            BorderSide(
          color: Colors.white
              .withOpacity(
                  0.65),
          width:
              1.2,
        ),
      ),

      errorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        borderSide:
            BorderSide(
          color: Colors.white
              .withOpacity(
                  0.55),
        ),
      ),

      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        borderSide:
            const BorderSide(
          color:
              Colors.white,
          width:
              1.2,
        ),
      ),

      errorStyle:
          GoogleFonts.poppins(
        color: Colors.white
            .withOpacity(
                0.80),
        fontSize:
            9.5,
      ),
    );
  }
}