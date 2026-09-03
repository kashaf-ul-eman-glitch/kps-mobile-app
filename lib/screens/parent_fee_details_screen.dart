import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ================================================================
// PARENT FEE DETAILS SCREEN
// ================================================================
//
// Firestore structure:
//
// classes
//   └── {className}
//         └── students
//               └── {studentId}
//                     ├── name / studentName
//                     ├── tuitionFee / tuition_fee
//                     ├── labFee / lab_fee
//                     ├── lateFee / late_fee
//                     ├── feeDueDay / dueDay / fee_due_day
//                     └── updatedAt
//
// ================================================================

class ParentFeeDetailsScreen extends StatelessWidget {
  final String studentId;
  final String className;

  const ParentFeeDetailsScreen({
    super.key,
    required this.studentId,
    required this.className,
  });

  // ================================================================
  // FIRESTORE STREAM
  // ================================================================

  Stream<DocumentSnapshot<Map<String, dynamic>>> _stream() {
    return FirebaseFirestore.instance
        .collection('classes')
        .doc(className)
        .collection('students')
        .doc(studentId)
        .snapshots();
  }

  // ================================================================
  // HELPER TO PARSE NUMBERS SAFELY
  // ================================================================

  double _getDynamicNum(Map<String, dynamic> data, List<String> possibleKeys) {
    for (String key in possibleKeys) {
      if (data.containsKey(key) && data[key] != null) {
        var value = data[key];
        if (value is num) return value.toDouble();
        return double.tryParse(value.toString()) ?? 0.0;
      }
    }
    return 0.0;
  }

  int _getDynamicInt(Map<String, dynamic> data, List<String> possibleKeys, int defaultValue) {
    for (String key in possibleKeys) {
      if (data.containsKey(key) && data[key] != null) {
        var value = data[key];
        if (value is num) return value.toInt();
        return int.tryParse(value.toString()) ?? defaultValue;
      }
    }
    return defaultValue;
  }

  // ================================================================
  // ORDINAL SUFFIX
  // ================================================================

  String _ordinalSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }

    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  // ================================================================
  // FORMAT MONEY
  // ================================================================

  String _money(double amount) {
    return 'Rs. ${amount.toStringAsFixed(0)}';
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF10142B),
      body: Stack(
        children: [
          // ==========================================================
          // BACKGROUND
          // ==========================================================

          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF111827),
                        Color(0xFF1E1B4B),
                        Color(0xFF312E81),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ==========================================================
          // DARK OVERLAY
          // ==========================================================

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.66),
                    Colors.black.withOpacity(0.50),
                    const Color(0xFF11152F).withOpacity(0.78),
                    const Color(0xFF090C1F).withOpacity(0.90),
                  ],
                ),
              ),
            ),
          ),

          // ==========================================================
          // LIGHT EFFECTS
          // ==========================================================

          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withOpacity(0.20),
              ),
            ),
          ),

          Positioned(
            bottom: -120,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withOpacity(0.14),
              ),
            ),
          ),

          // ==========================================================
          // MAIN CONTENT
          // ==========================================================

          SafeArea(
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _stream(),
              builder: (context, snapshot) {
                // LOADING
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: [
                      _topBar(context, 'Fee Details'),
                      const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                }

                // ERROR
                if (snapshot.hasError) {
                  return Column(
                    children: [
                      _topBar(context, 'Fee Details'),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(25),
                            child: Text(
                              'Unable to load fee details.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                // STUDENT DOES NOT EXIST
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Column(
                    children: [
                      _topBar(context, 'Fee Details'),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Student information not found.',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                // FIRESTORE DATA PARSING
                final Map<String, dynamic> data = snapshot.data!.data() ?? {};

                // Flexible field lookup to handle camelCase and snake_case
                final double tuition = _getDynamicNum(data, ['tuitionFee', 'tuition_fee', 'tuition']);
                final double lab = _getDynamicNum(data, ['labFee', 'lab_fee', 'lab', 'computerFee']);
                final double lateFee = _getDynamicNum(data, ['lateFee', 'late_fee']);
                final int dueDay = _getDynamicInt(data, ['feeDueDay', 'dueDay', 'fee_due_day', 'due_day'], 10);

                final double total = tuition + lab;

                // CHECK WHETHER FEE HAS BEEN ADDED
                final bool hasFee = (tuition > 0 || lab > 0 || lateFee > 0) ||
                    data.containsKey('tuitionFee') ||
                    data.containsKey('tuition_fee') ||
                    data.containsKey('labFee') ||
                    data.containsKey('lab_fee');

                return Column(
                  children: [
                    _topBar(context, 'Fee Details'),
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 35),
                        children: [
                          _headerSection(
                            studentName: data['name'] ?? data['studentName'] ?? data['student_name'] ?? studentId,
                            hasFee: hasFee,
                          ),
                          const SizedBox(height: 22),
                          if (!hasFee)
                            _noFeeCard()
                          else ...[
                            _dueDateCard(
                              dueDay: dueDay,
                              lateFee: lateFee,
                            ),
                            const SizedBox(height: 18),
                            _feeCard(
                              tuition: tuition,
                              lab: lab,
                              total: total,
                            ),
                            const SizedBox(height: 18),
                            _infoCard(),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  size: 15,
                                  color: Colors.white.withOpacity(0.70),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Fee information is updated live',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5,
                                    color: Colors.white.withOpacity(0.70),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
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

  // ================================================================
  // HEADER
  // ================================================================

  Widget _headerSection({
    required dynamic studentName,
    required bool hasFee,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.18),
            Colors.white.withOpacity(0.07),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF818CF8),
                  Color(0xFF6366F1),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Fee',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.72),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Fee Summary',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasFee
                      ? '${studentName.toString()} • Current fee details'
                      : '${studentName.toString()} • Fee not added yet',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    color: Colors.white.withOpacity(0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // NO FEE CARD
  // ================================================================

  Widget _noFeeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withOpacity(0.10),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFFFA62B).withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Color(0xFFFFC46B),
              size: 29,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Fee Not Added Yet',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'The school has not added fee information for your child yet.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.60),
              fontSize: 10.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // DUE DATE CARD
  // ================================================================

  Widget _dueDateCard({
    required int dueDay,
    required double lateFee,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xFFFFA62B).withOpacity(0.14),
        border: Border.all(
          color: const Color(0xFFFFB84D).withOpacity(0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFFA62B).withOpacity(0.20),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: Color(0xFFFFC46B),
              size: 24,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fee Due Date',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$dueDay${_ordinalSuffix(dueDay)} of every month',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFC46B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_money(lateFee)} late fee applies after the deadline.',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    height: 1.5,
                    color: Colors.white.withOpacity(0.68),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // FEE CARD
  // ================================================================

  Widget _feeCard({
    required double tuition,
    required double lab,
    required double total,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(7, 8, 7, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white.withOpacity(0.11),
        border: Border.all(
          color: Colors.white.withOpacity(0.17),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _feeRow(
            icon: Icons.school_rounded,
            title: 'Monthly Tuition Fee',
            subtitle: 'Regular school fee',
            amount: tuition,
          ),
          _glassDivider(),
          _feeRow(
            icon: Icons.computer_rounded,
            title: 'Computer & Lab Charges',
            subtitle: 'Computer / laboratory charges',
            amount: lab,
          ),
          const SizedBox(height: 5),
          Container(
            margin: const EdgeInsets.fromLTRB(8, 7, 8, 8),
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFF6366F1).withOpacity(0.70),
                  const Color(0xFF8B5CF6).withOpacity(0.60),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.payments_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Total Payable',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  _money(total),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // FEE ROW
  // ================================================================

  Widget _feeRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required double amount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 12,
      ),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFA5B4FC),
              size: 23,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.52),
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _money(amount),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // DIVIDER
  // ================================================================

  Widget _glassDivider() {
    return Divider(
      height: 1,
      thickness: 0.7,
      indent: 17,
      endIndent: 17,
      color: Colors.white.withOpacity(0.10),
    );
  }

  // ================================================================
  // INFORMATION CARD
  // ================================================================

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.black.withOpacity(0.18),
        border: Border.all(
          color: Colors.white.withOpacity(0.11),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF60A5FA).withOpacity(0.13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF93C5FD),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Important Information',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Please make sure the monthly fee is paid before the due date to avoid late charges.',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.62),
                    fontSize: 10.5,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // TOP BAR
  // ================================================================

  Widget _topBar(
    BuildContext context,
    String title,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 7, 14, 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 19,
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}