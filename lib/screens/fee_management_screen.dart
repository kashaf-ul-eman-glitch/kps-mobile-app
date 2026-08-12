import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeeManagementScreen extends StatefulWidget {
  const FeeManagementScreen({super.key});

  @override
  State<FeeManagementScreen> createState() =>
      _FeeManagementScreenState();
}

class _FeeManagementScreenState
    extends State<FeeManagementScreen> {
  final List<Map<String, dynamic>> feeSections = [
    {
      'title': 'Fee Overview',
      'subtitle': 'View overall fee collection summary',
      'icon': Icons.account_balance_wallet_outlined,
      'details': [
        'Total Fee: Rs. 1,250,000',
        'Collected: Rs. 950,000',
        'Pending: Rs. 300,000',
      ],
      'expanded': false,
    },
    {
      'title': 'Student Fee Records',
      'subtitle': 'View student-wise fee information',
      'icon': Icons.receipt_long_outlined,
      'details': [
        'Total Students: 1200',
        'Paid Students: 920',
        'Pending Students: 280',
      ],
      'expanded': false,
    },
    {
      'title': 'Pending Fees',
      'subtitle': 'View outstanding student fees',
      'icon': Icons.pending_actions_outlined,
      'details': [
        'Pending Records: 280',
        'Total Pending Amount: Rs. 300,000',
      ],
      'expanded': false,
    },
    {
      'title': 'Paid Fees',
      'subtitle': 'View completed fee payments',
      'icon': Icons.check_circle_outline,
      'details': [
        'Paid Records: 920',
        'Total Collected: Rs. 950,000',
      ],
      'expanded': false,
    },
    {
      'title': 'Fee Structure',
      'subtitle': 'View class-wise fee structure',
      'icon': Icons.account_balance_outlined,
      'details': [
        'Primary Classes: Rs. 5,000 / month',
        'Middle Classes: Rs. 6,000 / month',
        'Secondary Classes: Rs. 7,000 / month',
      ],
      'expanded': false,
    },
    {
      'title': 'Payment History',
      'subtitle': 'View recent fee transactions',
      'icon': Icons.history_outlined,
      'details': [
        'Recent Payments: 45',
        'Last Payment: Today',
      ],
      'expanded': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                            'Fee Management',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // =========================
                  // Summary Card
                  // =========================

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      5,
                      20,
                      18,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.15,
                        ),
                        borderRadius:
                            BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white24,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.payments_outlined,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Fee Collection',
                                  style:
                                      GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Rs. 950,000 Collected',
                                  style:
                                      GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // =========================
                  // Section Title
                  // =========================

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      12,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Fee Information',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // =========================
                  // Fee Sections
                  // =========================

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        0,
                        20,
                        25,
                      ),
                      itemCount: feeSections.length,
                      itemBuilder: (context, index) {
                        return _feeCard(
                          feeSections[index],
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
    );
  }

  Widget _feeCard(
    Map<String, dynamic> section,
  ) {
    final bool isExpanded =
        section['expanded'] ?? false;

    return GestureDetector(
      onTap: () {
        setState(() {
          section['expanded'] = !isExpanded;
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(
          bottom: 14,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: 0.15,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white24,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Icon(
                    section['icon'],
                    color: Colors.white,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        section['title'],
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        section['subtitle'],
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 11,
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

            if (isExpanded) ...[
              const SizedBox(height: 14),

              const Divider(
                color: Colors.white24,
              ),

              const SizedBox(height: 8),

              Column(
                children: [
                  for (final detail
                      in section['details'])
                    Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 8,
                      ),
                      child: Align(
                        alignment:
                            Alignment.centerLeft,
                        child: Text(
                          detail,
                          style:
                              GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}