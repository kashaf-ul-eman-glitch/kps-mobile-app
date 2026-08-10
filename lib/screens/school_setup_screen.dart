import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SchoolSetupScreen extends StatefulWidget {
  const SchoolSetupScreen({super.key});

  @override
  State<SchoolSetupScreen> createState() => _SchoolSetupScreenState();
}

class _SchoolSetupScreenState extends State<SchoolSetupScreen> {
  bool schoolInformationExpanded = false;
  bool academicSetupExpanded = false;
  bool configurationExpanded = false;

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
          filter: ImageFilter.blur(
            sigmaX: 5,
            sigmaY: 5,
          ),
          child: Container(
            color: Colors.black.withValues(alpha: 0.25),
            child: SafeArea(
              child: Column(
                children: [
                  // =========================
                  // Top Bar
                  // =========================

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),

                        Expanded(
                          child: Text(
                            'School Setup',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // =========================
                  // Expandable Content
                  // =========================

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        10,
                        20,
                        30,
                      ),
                      child: Column(
                        children: [
                          // School Information
                          _expandableSection(
                            icon: Icons.school,
                            title: 'School Information',
                            expanded: schoolInformationExpanded,
                            onTap: () {
                              setState(() {
                                schoolInformationExpanded =
                                    !schoolInformationExpanded;
                              });
                            },
                            children: [
                              _infoTile(
                                Icons.business,
                                'School Name',
                                'Khyber Public School & College',
                              ),
                              _infoTile(
                                Icons.location_on,
                                'School Address',
                                'Mansehra',
                              ),
                              _infoTile(
                                Icons.phone,
                                'Contact Number',
                                'Not set',
                              ),
                              _infoTile(
                                Icons.email,
                                'Email',
                                'Not set',
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          // Academic Setup
                          _expandableSection(
                            icon: Icons.menu_book,
                            title: 'Academic Setup',
                            expanded: academicSetupExpanded,
                            onTap: () {
                              setState(() {
                                academicSetupExpanded =
                                    !academicSetupExpanded;
                              });
                            },
                            children: [
                              _infoTile(
                                Icons.calendar_month,
                                'Academic Year',
                                '2026 - 2027',
                              ),
                              _infoTile(
                                Icons.class_,
                                'Classes',
                                'Manage Classes',
                              ),
                              _infoTile(
                                Icons.book,
                                'Subjects',
                                'Manage Subjects',
                              ),
                              _infoTile(
                                Icons.event_note,
                                'Academic Calendar',
                                'View Academic Calendar',
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          // Configuration
                          _expandableSection(
                            icon: Icons.settings,
                            title: 'Configuration',
                            expanded: configurationExpanded,
                            onTap: () {
                              setState(() {
                                configurationExpanded =
                                    !configurationExpanded;
                              });
                            },
                            children: [
                              _infoTile(
                                Icons.access_time,
                                'School Timing',
                                'Not set',
                              ),
                              _infoTile(
                                Icons.how_to_reg,
                                'Attendance Settings',
                                'Manage Attendance',
                              ),
                            ],
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
      ),
    );
  }

  // =========================
  // Expandable Section
  // =========================

  Widget _expandableSection({
    required IconData icon,
    required String title,
    required bool expanded,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white24,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 25,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white70,
                  size: 25,
                ),
              ],
            ),

            if (expanded) ...[
              const SizedBox(height: 15),

              const Divider(
                color: Colors.white24,
              ),

              const SizedBox(height: 8),

              ...children,
            ],
          ],
        ),
      ),
    );
  }

  // =========================
  // Information Tile
  // =========================

  Widget _infoTile(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white70,
            size: 21,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
    );
  }
}