import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ParentAboutAppScreen extends StatelessWidget {
  const ParentAboutAppScreen({super.key});

  // =========================
  // COLORS
  // =========================

  static const Color primaryColor = Color(0xFF6C63D9);
  static const Color lightPurple = Color(0xFF9B94F5);
  static const Color whiteColor = Colors.white;
  static const Color mutedWhite = Color(0xFFD7D5E8);

  // =========================
  // MAIN BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090A12),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ==========================================
          // SCHOOL BACKGROUND IMAGE
          // ==========================================
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF11121C),
                );
              },
            ),
          ),

          // ==========================================
          // DARK OVERLAY
          // ==========================================
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.72),
                    Colors.black.withOpacity(0.80),
                    Colors.black.withOpacity(0.90),
                  ],
                ),
              ),
            ),
          ),

          // ==========================================
          // CONTENT
          // ==========================================
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
                    child: Column(
                      children: [
                        _buildLogoSection(),

                        const SizedBox(height: 24),

                        _buildWelcomeCard(),

                        const SizedBox(height: 18),

                        _buildSectionTitle(
                          Icons.auto_awesome_rounded,
                          'About the Application',
                        ),

                        const SizedBox(height: 10),

                        _buildGlassCard(
                          child: Text(
                            'This application is a thoughtfully designed school '
                            'management solution developed to make important '
                            'school-related information and services more '
                            'accessible, organized, and convenient for the '
                            'school community.',
                            style: GoogleFonts.poppins(
                              color: mutedWhite,
                              fontSize: 13.5,
                              height: 1.7,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        _buildSectionTitle(
                          Icons.track_changes_rounded,
                          'Project Purpose',
                        ),

                        const SizedBox(height: 10),

                        _buildGlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'A Connected Digital Experience',
                                style: GoogleFonts.poppins(
                                  color: whiteColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'The application brings essential school '
                                'information together in one digital platform. '
                                'It is designed to support better communication, '
                                'efficient management, and a more connected '
                                'experience for parents and the wider school '
                                'community.',
                                style: GoogleFonts.poppins(
                                  color: mutedWhite,
                                  fontSize: 13.5,
                                  height: 1.7,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        _buildSectionTitle(
                          Icons.groups_rounded,
                          'Development Team',
                        ),

                        const SizedBox(height: 10),

                        _buildGlassCard(
                          child: Column(
                            children: [
                              _buildDeveloperTile(
                                name: 'Kashaf Ul Eman',
                                number: '01',
                              ),
                              const SizedBox(height: 12),
                              _buildDeveloperTile(
                                name: 'Husna',
                                number: '02',
                              ),
                              const SizedBox(height: 12),
                              _buildDeveloperTile(
                                name: 'Hajira',
                                number: '03',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        _buildSectionTitle(
                          Icons.school_rounded,
                          'Academic Background',
                        ),

                        const SizedBox(height: 10),

                        _buildGlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(
                                icon: Icons.menu_book_rounded,
                                title: 'Program',
                                value: 'Bachelor of Science in Computer Science',
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                icon: Icons.account_balance_rounded,
                                title: 'University',
                                value: 'Hazara University',
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                icon: Icons.date_range_rounded,
                                title: 'Academic Period',
                                value: '2024 – 2028',
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'The development team is currently pursuing '
                                'their Bachelor’s degree in Computer Science '
                                'at Hazara University. This project represents '
                                'an opportunity to apply their academic '
                                'knowledge to a practical software solution '
                                'during their 2024–2028 degree program.',
                                style: GoogleFonts.poppins(
                                  color: mutedWhite,
                                  fontSize: 13.5,
                                  height: 1.7,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        _buildSectionTitle(
                          Icons.supervisor_account_rounded,
                          'Project Supervision',
                        ),

                        const SizedBox(height: 10),

                        _buildGlassCard(
                          child: Column(
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.18),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: lightPurple.withOpacity(0.35),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: lightPurple,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Sir Asfandyar Nasim Khan',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: whiteColor,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Project Supervisor',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: lightPurple,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'The project was successfully completed under '
                                'the supervision of Sir Asfandyar Nasim Khan. '
                                'His guidance, valuable feedback, and supervision '
                                'provided important direction throughout the '
                                'development process.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: mutedWhite,
                                  fontSize: 13.5,
                                  height: 1.7,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        _buildSectionTitle(
                          Icons.rocket_launch_rounded,
                          'Our Development Journey',
                        ),

                        const SizedBox(height: 10),

                        _buildGlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.timer_rounded,
                                      color: lightPurple,
                                      size: 23,
                                    ),
                                  ),
                                  const SizedBox(width: 13),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Two-Month Development',
                                          style: GoogleFonts.poppins(
                                            color: whiteColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Successfully completed within a '
                                          'focused two-month development period.',
                                          style: GoogleFonts.poppins(
                                            color: mutedWhite,
                                            fontSize: 12.5,
                                            height: 1.6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'The development journey was built on teamwork, '
                                'dedication, continuous learning, problem-solving, '
                                'and the practical application of software '
                                'development concepts. Completing the application '
                                'within two months was a valuable experience that '
                                'helped transform academic knowledge into a '
                                'functional digital solution.',
                                style: GoogleFonts.poppins(
                                  color: mutedWhite,
                                  fontSize: 13.5,
                                  height: 1.7,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        _buildSectionTitle(
                          Icons.favorite_rounded,
                          'Our Commitment',
                        ),

                        const SizedBox(height: 10),

                        _buildGlassCard(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.format_quote_rounded,
                                color: lightPurple,
                                size: 34,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Built with dedication, teamwork, and a '
                                'commitment to creating a meaningful digital '
                                'solution for the school community.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: whiteColor,
                                  fontSize: 14,
                                  height: 1.7,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ==========================================
                        // FOOTER
                        // ==========================================
                        Text(
                          'BS Computer Science  •  Hazara University',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: mutedWhite.withOpacity(0.75),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          'Academic Period 2024 – 2028',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: mutedWhite.withOpacity(0.55),
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 18, 4),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: whiteColor,
                size: 19,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'About App',
              style: GoogleFonts.poppins(
                color: whiteColor,
                fontSize: 21,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: lightPurple.withOpacity(0.20),
              ),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: lightPurple,
              size: 23,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOGO SECTION
  // ============================================================

  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: 112,
          height: 112,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.10),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.25),
                blurRadius: 25,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.white.withOpacity(0.08),
                  child: const Icon(
                    Icons.school_rounded,
                    color: whiteColor,
                    size: 48,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          'School Management App',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: whiteColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'A smarter way to stay connected',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: mutedWhite,
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // WELCOME CARD
  // ============================================================

  Widget _buildWelcomeCard() {
    return _buildGlassCard(
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.waving_hand_rounded,
              color: lightPurple,
              size: 27,
            ),
          ),
          const SizedBox(height: 13),
          Text(
            'Welcome',
            style: GoogleFonts.poppins(
              color: whiteColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Thank you for being part of our digital school community. '
            'This application has been developed to make everyday '
            'school-related interactions simpler, more organized, '
            'and accessible.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: mutedWhite,
              fontSize: 13.2,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
    IconData icon,
    String title,
  ) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.17),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: lightPurple,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: whiteColor,
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // GLASS CARD
  // ============================================================

  Widget _buildGlassCard({
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.085),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.14),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // ============================================================
  // DEVELOPER TILE
  // ============================================================

  Widget _buildDeveloperTile({
    required String name,
    required String number,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.055),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.09),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.17),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.poppins(
                  color: lightPurple,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    color: whiteColor,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'BS Computer Science Student',
                  style: GoogleFonts.poppins(
                    color: mutedWhite,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.code_rounded,
            color: lightPurple,
            size: 20,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFORMATION ROW
  // ============================================================

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.16),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: lightPurple,
            size: 21,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: mutedWhite.withOpacity(0.70),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: whiteColor,
                  fontSize: 13.5,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}