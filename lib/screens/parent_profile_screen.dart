import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ================================================================
// PARENT PROFILE SCREEN
// ================================================================
//
// Live student profile:
// classes/{className}/students/{studentId}
//
// Background:
// assets/images/background.jpg
// ================================================================

class ParentProfileScreen extends StatelessWidget {
  final String studentId;
  final String className;
  final Map<String, dynamic> fallbackChild;

  const ParentProfileScreen({
    super.key,
    required this.studentId,
    required this.className,
    required this.fallbackChild,
  });

  // ==============================================================
  // STUDENT STREAM
  // ==============================================================

  Stream<DocumentSnapshot<Map<String, dynamic>>> _studentStream() {
    return FirebaseFirestore.instance
        .collection('classes')
        .doc(className)
        .collection('students')
        .doc(studentId)
        .snapshots();
  }

  // ==============================================================
  // NORMALIZE DATA
  // ==============================================================

  Map<String, dynamic> _normalize(
    Map<String, dynamic> data,
  ) {
    return {
      'name': (
        data['studentName'] ??
        data['name'] ??
        fallbackChild['name'] ??
        'Student'
      ).toString(),

      'className': (
        data['class'] ??
        data['className'] ??
        fallbackChild['className'] ??
        className
      ).toString(),

      'section': (
        data['section'] ??
        fallbackChild['section'] ??
        ''
      ).toString(),

      'roll': (
        data['rollNo'] ??
        data['roll'] ??
        fallbackChild['roll'] ??
        ''
      ).toString(),

      'admissionNo': (
        data['admissionNo'] ??
        fallbackChild['admissionNo'] ??
        ''
      ).toString(),

      'fatherName': (
        data['fatherName'] ??
        fallbackChild['fatherName'] ??
        ''
      ).toString(),

      'phone': (
        data['fatherPhone'] ??
        data['phone'] ??
        fallbackChild['phone'] ??
        ''
      ).toString(),

      'email': (
        data['email'] ??
        fallbackChild['email'] ??
        ''
      ).toString(),

      'photoUrl': (
        data['photoUrl'] ??
        fallbackChild['photoUrl'] ??
        ''
      ).toString(),
    };
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [
          // ========================================================
          // FULL SCREEN BACKGROUND IMAGE
          // ========================================================

          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
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
                alpha: 0.60,
              ),
            ),
          ),

          // ========================================================
          // CONTENT
          // ========================================================

          SafeArea(
            child: StreamBuilder<
                DocumentSnapshot<Map<String, dynamic>>>(
              stream: _studentStream(),

              builder: (
                context,
                snapshot,
              ) {
                // --------------------------------------------------
                // LIVE DATA
                // --------------------------------------------------

                final Map<String, dynamic> data =
                    snapshot.hasData &&
                            snapshot.data!.exists
                        ? _normalize(
                            snapshot.data!.data() ?? {},
                          )
                        : _normalize(
                            fallbackChild,
                          );

                // --------------------------------------------------
                // CLASS LINE
                // --------------------------------------------------

                final String classLine = [
                  if (data['className']
                      .toString()
                      .trim()
                      .isNotEmpty)
                    data['className'],

                  if (data['section']
                      .toString()
                      .trim()
                      .isNotEmpty)
                    data['section'],
                ].join(' • ');

                // --------------------------------------------------
                // PHOTO
                // --------------------------------------------------

                final String photoUrl =
                    data['photoUrl']
                        .toString()
                        .trim();

                return Column(
                  children: [
                    // ==================================================
                    // TOP BAR
                    // ==================================================

                    _topBar(
                      context,
                      'Student Profile',
                    ),

                    // ==================================================
                    // MAIN CONTENT
                    // ==================================================

                    Expanded(
                      child: SingleChildScrollView(
                        physics:
                            const BouncingScrollPhysics(),

                        padding:
                            const EdgeInsets.fromLTRB(
                          20,
                          12,
                          20,
                          35,
                        ),

                        child: Column(
                          children: [
                            // ==================================================
                            // PROFILE HEADER CARD
                            // ==================================================

                            Container(
                              width:
                                  double.infinity,

                              padding:
                                  const EdgeInsets
                                      .fromLTRB(
                                20,
                                24,
                                20,
                                22,
                              ),

                              decoration:
                                  BoxDecoration(
                                color: Colors.black
                                    .withValues(
                                  alpha: 0.38,
                                ),

                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  25,
                                ),

                                border:
                                    Border.all(
                                  color: Colors.white
                                      .withValues(
                                    alpha: 0.15,
                                  ),
                                ),

                                boxShadow: [
                                  BoxShadow(
                                    color: Colors
                                        .black
                                        .withValues(
                                      alpha: 0.25,
                                    ),
                                    blurRadius: 20,
                                    offset:
                                        const Offset(
                                      0,
                                      8,
                                    ),
                                  ),
                                ],
                              ),

                              child: Column(
                                children: [
                                  // --------------------------------
                                  // PROFILE PHOTO
                                  // --------------------------------

                                  Container(
                                    width: 104,
                                    height: 104,
                                    padding:
                                        const EdgeInsets
                                            .all(
                                      4,
                                    ),

                                    decoration:
                                        BoxDecoration(
                                      shape:
                                          BoxShape
                                              .circle,

                                      color: Colors
                                          .white
                                          .withValues(
                                        alpha: 0.08,
                                      ),

                                      border:
                                          Border.all(
                                        color: Colors
                                            .white
                                            .withValues(
                                          alpha: 0.35,
                                        ),
                                        width: 2,
                                      ),

                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors
                                              .black
                                              .withValues(
                                            alpha: 0.30,
                                          ),
                                          blurRadius:
                                              16,
                                        ),
                                      ],
                                    ),

                                    child: ClipOval(
                                      child: photoUrl
                                              .isNotEmpty
                                          ? Image.network(
                                              photoUrl,
                                              fit: BoxFit
                                                  .cover,
                                              errorBuilder:
                                                  (
                                                _,
                                                __,
                                                ___,
                                              ) {
                                                return const Icon(
                                                  Icons
                                                      .person_rounded,
                                                  color: Colors
                                                      .white,
                                                  size:
                                                      55,
                                                );
                                              },
                                            )
                                          : const Icon(
                                              Icons
                                                  .person_rounded,
                                              color: Colors
                                                  .white,
                                              size: 55,
                                            ),
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 16),

                                  // --------------------------------
                                  // STUDENT NAME
                                  // --------------------------------

                                  Text(
                                    data['name']
                                        .toString()
                                        .isEmpty
                                        ? 'Student'
                                        : data['name']
                                            .toString(),

                                    textAlign:
                                        TextAlign
                                            .center,

                                    style:
                                        GoogleFonts
                                            .poppins(
                                      color: Colors
                                          .white,
                                      fontSize: 22,
                                      fontWeight:
                                          FontWeight
                                              .w700,
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 5),

                                  // --------------------------------
                                  // CLASS + SECTION
                                  // --------------------------------

                                  Text(
                                    classLine.isEmpty
                                        ? 'Student Profile'
                                        : classLine,

                                    textAlign:
                                        TextAlign
                                            .center,

                                    style:
                                        GoogleFonts
                                            .poppins(
                                      color: Colors
                                          .white70,
                                      fontSize: 11,
                                    ),
                                  ),

                                  // --------------------------------
                                  // ROLL NUMBER
                                  // --------------------------------

                                  if (data['roll']
                                      .toString()
                                      .isNotEmpty) ...[
                                    const SizedBox(
                                        height: 4),

                                    Container(
                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                        horizontal: 11,
                                        vertical: 5,
                                      ),

                                      decoration:
                                          BoxDecoration(
                                        color: Colors
                                            .white
                                            .withValues(
                                          alpha: 0.08,
                                        ),
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          10,
                                        ),
                                        border:
                                            Border.all(
                                          color: Colors
                                              .white
                                              .withValues(
                                            alpha: 0.12,
                                          ),
                                        ),
                                      ),

                                      child: Text(
                                        'Roll No: ${data['roll']}',
                                        style:
                                            GoogleFonts
                                                .poppins(
                                          color: Colors
                                              .white70,
                                          fontSize: 9,
                                          fontWeight:
                                              FontWeight
                                                  .w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(
                                height: 20),

                            // ==================================================
                            // INFORMATION TITLE
                            // ==================================================

                            Align(
                              alignment:
                                  Alignment.centerLeft,

                              child: Text(
                                'Student Information',
                                style:
                                    GoogleFonts
                                        .poppins(
                                  color:
                                      Colors.white,
                                  fontSize: 17,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ),

                            const SizedBox(
                                height: 5),

                            Align(
                              alignment:
                                  Alignment.centerLeft,

                              child: Text(
                                'Personal and parent details',
                                style:
                                    GoogleFonts
                                        .poppins(
                                  color:
                                      Colors.white60,
                                  fontSize: 10,
                                ),
                              ),
                            ),

                            const SizedBox(
                                height: 13),

                            // ==================================================
                            // INFORMATION CARD
                            // ==================================================

                            Container(
                              width:
                                  double.infinity,

                              decoration:
                                  BoxDecoration(
                                color: Colors.black
                                    .withValues(
                                  alpha: 0.38,
                                ),

                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  22,
                                ),

                                border:
                                    Border.all(
                                  color: Colors.white
                                      .withValues(
                                    alpha: 0.14,
                                  ),
                                ),
                              ),

                              child: Column(
                                children: [
                                  _tile(
                                    Icons.badge_outlined,
                                    'Admission No.',
                                    data[
                                        'admissionNo'],
                                  ),

                                  _divider(),

                                  _tile(
                                    Icons.class_outlined,
                                    'Class',
                                    data[
                                        'className'],
                                  ),

                                  _divider(),

                                  _tile(
                                    Icons.groups_outlined,
                                    'Section',
                                    data[
                                        'section'],
                                  ),

                                  _divider(),

                                  _tile(
                                    Icons
                                        .format_list_numbered_rounded,
                                    'Roll No.',
                                    data['roll'],
                                  ),

                                  _divider(),

                                  _tile(
                                    Icons
                                        .family_restroom_outlined,
                                    'Father Name',
                                    data[
                                        'fatherName'],
                                  ),

                                  _divider(),

                                  _tile(
                                    Icons.phone_outlined,
                                    'Contact',
                                    data['phone'],
                                  ),

                                  _divider(),

                                  _tile(
                                    Icons.email_outlined,
                                    'Parent Email',
                                    data['email'],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                                height: 20),

                            // ==================================================
                            // LIVE DATA INDICATOR
                            // ==================================================

                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 13,
                                vertical: 9,
                              ),

                              decoration:
                                  BoxDecoration(
                                color: Colors.black
                                    .withValues(
                                  alpha: 0.30,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  12,
                                ),
                                border:
                                    Border.all(
                                  color: Colors.white
                                      .withValues(
                                    alpha: 0.10,
                                  ),
                                ),
                              ),

                              child: Row(
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons
                                        .sync_rounded,
                                    color:
                                        Colors.white70,
                                    size: 15,
                                  ),

                                  const SizedBox(
                                      width: 7),

                                  Text(
                                    'Information updates automatically',
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
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // DIVIDER
  // ==============================================================

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 0.7,
      color: Colors.white.withValues(
        alpha: 0.09,
      ),
      indent: 15,
      endIndent: 15,
    );
  }

  // ==============================================================
  // INFORMATION TILE
  // ==============================================================

  Widget _tile(
    IconData icon,
    String title,
    dynamic value,
  ) {
    final String text =
        (value ?? '').toString().trim();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 5,
      ),

      child: ListTile(
        dense: true,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 2,
        ),

        leading: Container(
          width: 40,
          height: 40,

          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: 0.08,
            ),

            borderRadius:
                BorderRadius.circular(12),

            border: Border.all(
              color: Colors.white.withValues(
                alpha: 0.10,
              ),
            ),
          ),

          child: Icon(
            icon,
            color: Colors.white70,
            size: 20,
          ),
        ),

        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white60,
            fontSize: 10,
            fontWeight: FontWeight.w400,
          ),
        ),

        subtitle: Padding(
          padding:
              const EdgeInsets.only(
            top: 2,
          ),
          child: Text(
            text.isEmpty
                ? 'Not available'
                : text,

            maxLines: 2,

            overflow:
                TextOverflow.ellipsis,

            style:
                GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // TOP BAR
  // ==============================================================

  Widget _topBar(
    BuildContext context,
    String title,
  ) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        8,
        8,
        12,
        8,
      ),

      child: Row(
        children: [
          // BACK BUTTON
          Container(
            decoration: BoxDecoration(
              color: Colors.black
                  .withValues(
                alpha: 0.38,
              ),

              borderRadius:
                  BorderRadius.circular(
                14,
              ),

              border: Border.all(
                color: Colors.white
                    .withValues(
                  alpha: 0.14,
                ),
              ),
            ),

            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },

              icon: const Icon(
                Icons
                    .arrow_back_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // TITLE
          Expanded(
            child: Text(
              title,
              textAlign:
                  TextAlign.center,

              style:
                  GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 19,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),

          // RIGHT SIDE BALANCE
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}