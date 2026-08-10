import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FamilyManagementScreen extends StatefulWidget {
  const FamilyManagementScreen({super.key});

  @override
  State<FamilyManagementScreen> createState() =>
      _FamilyManagementScreenState();
}

class _FamilyManagementScreenState
    extends State<FamilyManagementScreen> {
  final TextEditingController searchController =
      TextEditingController();

  String searchText = '';

  final List<Map<String, dynamic>> families = [
    {
      'familyName': 'Ali Family',
      'guardianName': 'Muhammad Ali',
      'phone': 'Not set',
      'email': 'Not set',
      'children': [
        {
          'name': 'Ahmed Ali',
          'class': 'Grade 5',
          'section': 'Section A',
        },
        {
          'name': 'Ayesha Ali',
          'class': 'Grade 2',
          'section': 'Section B',
        },
      ],
      'expanded': false,
    },
    {
      'familyName': 'Khan Family',
      'guardianName': 'Usman Khan',
      'phone': 'Not set',
      'email': 'Not set',
      'children': [
        {
          'name': 'Hamza Khan',
          'class': 'Grade 7',
          'section': 'Section A',
        },
      ],
      'expanded': false,
    },
    {
      'familyName': 'Shah Family',
      'guardianName': 'Imran Shah',
      'phone': 'Not set',
      'email': 'Not set',
      'children': [
        {
          'name': 'Fatima Shah',
          'class': 'Grade 4',
          'section': 'Section B',
        },
        {
          'name': 'Hassan Shah',
          'class': 'Grade 1',
          'section': 'Section A',
        },
      ],
      'expanded': false,
    },
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredFamilies = families.where((family) {
      final familyName =
          family['familyName'].toString().toLowerCase();

      final guardianName =
          family['guardianName'].toString().toLowerCase();

      return familyName.contains(searchText.toLowerCase()) ||
          guardianName.contains(searchText.toLowerCase());
    }).toList();

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
                            'Family Management',
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
                  // Search Bar
                  // =========================

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      5,
                      20,
                      15,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white24,
                        ),
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            searchText = value;
                          });
                        },
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search families...',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.white60,
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.white70,
                          ),
                          suffixIcon: searchText.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    searchController.clear();

                                    setState(() {
                                      searchText = '';
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.white70,
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // =========================
                  // Family List
                  // =========================

                  Expanded(
                    child: filteredFamilies.isEmpty
                        ? Center(
                            child: Text(
                              'No families found',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              20,
                              0,
                              20,
                              25,
                            ),
                            itemCount: filteredFamilies.length,
                            itemBuilder: (context, index) {
                              final family =
                                  filteredFamilies[index];

                              return _familyCard(
                                family: family,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // =========================
      // Add Family Button
      // =========================

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Add Family - Coming Soon',
              ),
            ),
          );
        },
        backgroundColor: Colors.brown,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  // =========================
  // Family Card
  // =========================

  Widget _familyCard({
    required Map<String, dynamic> family,
  }) {
    final bool isExpanded = family['expanded'] ?? false;

    final List<Map<String, dynamic>> children =
        List<Map<String, dynamic>>.from(
      family['children'],
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          family['expanded'] = !isExpanded;
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white24,
          ),
        ),
        child: Column(
          children: [
            // =========================
            // Main Family Row
            // =========================

            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.family_restroom,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        family['familyName'],
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        '${family['guardianName']} • '
                        '${children.length} '
                        '${children.length == 1 ? 'Child' : 'Children'}',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white70,
                ),
              ],
            ),

            // =========================
            // Expanded Details
            // =========================

            if (isExpanded) ...[
              const SizedBox(height: 15),

              const Divider(
                color: Colors.white24,
              ),

              const SizedBox(height: 10),

              _familyDetail(
                Icons.person,
                'Guardian',
                family['guardianName'],
              ),

              _familyDetail(
                Icons.phone,
                'Phone',
                family['phone'],
              ),

              _familyDetail(
                Icons.email,
                'Email',
                family['email'],
              ),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Children',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              ...children.map(
                (child) => _childTile(child),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =========================
  // Family Detail
  // =========================

  Widget _familyDetail(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 9,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white70,
            size: 19,
          ),

          const SizedBox(width: 10),

          Text(
            '$title: ',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // Child Tile
  // =========================

  Widget _childTile(
    Map<String, dynamic> child,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 8,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.person,
            color: Colors.white70,
            size: 21,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  child['name'],
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  '${child['class']} • ${child['section']}',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}