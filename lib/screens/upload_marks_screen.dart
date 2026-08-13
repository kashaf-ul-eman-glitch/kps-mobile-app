import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UploadMarksScreen extends StatefulWidget {
  const UploadMarksScreen({super.key});

  @override
  State<UploadMarksScreen> createState() =>
      _UploadMarksScreenState();
}

class _UploadMarksScreenState
    extends State<UploadMarksScreen> {
  String selectedClass = 'Grade 5A';
  String selectedSubject = 'Mathematics';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown.shade800,
        elevation: 4,

        title: Text(
          'Upload Marks',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics:
                    const BouncingScrollPhysics(),

                child: Column(
                  children: [

                    // =========================================
                    // Class & Subject Selection
                    // =========================================

                    Container(
                      padding:
                          const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color:
                            Colors.brown.withValues(
                          alpha: 0.35,
                        ),

                        borderRadius:
                            BorderRadius.circular(20),

                        border: Border.all(
                          color:
                              Colors.white.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),

                      child: Row(
                        children: [

                          // =================================
                          // Class Dropdown
                          // =================================

                          Expanded(
                            child:
                                DropdownButtonFormField<
                                    String>(
                              value: selectedClass,

                              isExpanded: true,

                              dropdownColor:
                                  Colors.brown.shade900,

                              style:
                                  GoogleFonts.poppins(
                                color: Colors.white,
                              ),

                              decoration:
                                  InputDecoration(
                                labelText: 'Class',

                                labelStyle:
                                    const TextStyle(
                                  color:
                                      Colors.white70,
                                ),

                                enabledBorder:
                                    OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(
                                    color:
                                        Colors.white30,
                                  ),

                                  borderRadius:
                                      BorderRadius
                                          .circular(10),
                                ),

                                border:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(10),
                                ),

                                contentPadding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                              ),

                              items: [
                                'Grade 5A',
                                'Grade 6B',
                                'Grade 8C',
                              ].map(
                                (c) {
                                  return DropdownMenuItem<
                                      String>(
                                    value: c,

                                    child: Text(
                                      c,

                                      style:
                                          GoogleFonts
                                              .poppins(
                                        fontSize: 13,
                                        color:
                                            Colors.white,
                                      ),

                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                    ),
                                  );
                                },
                              ).toList(),

                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedClass =
                                        value;
                                  });
                                }
                              },
                            ),
                          ),

                          const SizedBox(width: 10),

                          // =================================
                          // Subject Dropdown
                          // =================================

                          Expanded(
                            child:
                                DropdownButtonFormField<
                                    String>(
                              value: selectedSubject,

                              isExpanded: true,

                              dropdownColor:
                                  Colors.brown.shade900,

                              style:
                                  GoogleFonts.poppins(
                                color: Colors.white,
                              ),

                              decoration:
                                  InputDecoration(
                                labelText: 'Subject',

                                labelStyle:
                                    const TextStyle(
                                  color:
                                      Colors.white70,
                                ),

                                enabledBorder:
                                    OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(
                                    color:
                                        Colors.white30,
                                  ),

                                  borderRadius:
                                      BorderRadius
                                          .circular(10),
                                ),

                                border:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(10),
                                ),

                                contentPadding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                              ),

                              items: [
                                'Mathematics',
                                'Computer Science',
                                'Physics',
                              ].map(
                                (subject) {
                                  return DropdownMenuItem<
                                      String>(
                                    value: subject,

                                    child: Text(
                                      subject,

                                      style:
                                          GoogleFonts
                                              .poppins(
                                        fontSize: 13,
                                        color:
                                            Colors.white,
                                      ),

                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                    ),
                                  );
                                },
                              ).toList(),

                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedSubject =
                                        value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =========================================
                    // Student 1
                    // =========================================

                    _buildStudentMarkTile(
                      name: 'Ali Ahmad',
                      rollNo: '101',
                    ),

                    // =========================================
                    // Student 2
                    // =========================================

                    _buildStudentMarkTile(
                      name: 'Usman Raza',
                      rollNo: '102',
                    ),

                    // =========================================
                    // Student 3
                    // =========================================

                    _buildStudentMarkTile(
                      name: 'Sara Khan',
                      rollNo: '103',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // Student Marks Tile
  // =========================================================

  Widget _buildStudentMarkTile({
    required String name,
    required String rollNo,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 6,
      ),

      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),

      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.15,
        ),

        borderRadius:
            BorderRadius.circular(15),

        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.2,
          ),
        ),
      ),

      child: Row(
        children: [

          // ===============================================
          // Student Information
          // ===============================================

          Expanded(
            flex: 3,

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  name,

                  style: GoogleFonts.poppins(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),

                  overflow:
                      TextOverflow.ellipsis,
                ),

                const SizedBox(height: 3),

                Text(
                  'Roll No: $rollNo',

                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),

                  overflow:
                      TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ===============================================
          // Marks Input
          // ===============================================

          Expanded(
            flex: 2,

            child: TextField(
              keyboardType:
                  TextInputType.number,

              style: GoogleFonts.poppins(
                color: Colors.white,
              ),

              decoration:
                  InputDecoration(
                hintText: 'Marks',

                hintStyle:
                    const TextStyle(
                  color: Colors.white54,
                ),

                contentPadding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),

                enabledBorder:
                    OutlineInputBorder(
                  borderSide:
                      const BorderSide(
                    color: Colors.white30,
                  ),

                  borderRadius:
                      BorderRadius.circular(8),
                ),

                focusedBorder:
                    OutlineInputBorder(
                  borderSide:
                      const BorderSide(
                    color: Colors.white,
                  ),

                  borderRadius:
                      BorderRadius.circular(8),
                ),

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}