import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // =========================
                    // Top Bar
                    // =========================

                    Row(
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
                            "My Profile",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Keeps title centered
                        const SizedBox(width: 48),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // =========================
                    // Profile Picture
                    // =========================

                    Container(
  width: 120,
  height: 120,
  decoration: const BoxDecoration(
    color: Colors.white,
    shape: BoxShape.circle,
  ),
  child: const Icon(
    Icons.person,
    color: Colors.grey,
    size: 70,
  ),
),



                    const SizedBox(height: 18),

                    Text(
                      "Administrator Name",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "Administrator",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // =========================
                    // Personal Information
                    // =========================

                    _profileCard(
                      title: "Personal Information",
                      children: [
                        _profileItem(
                          Icons.person_outline,
                          "Name",
                          "Administrator",
                        ),
                        _profileItem(
                          Icons.email_outlined,
                          "Email",
                          "admin@example.com",
                        ),
                        _profileItem(
                          Icons.phone_outlined,
                          "Phone",
                          "03XX-XXXXXXX",
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // =========================
                    // Role Information
                    // =========================

                    _profileCard(
                      title: "Role Information",
                      children: [
                        _profileItem(
                          Icons.admin_panel_settings_outlined,
                          "Role",
                          "Administrator",
                        ),
                        _profileItem(
                          Icons.school_outlined,
                          "School",
                          "Khyber Public School & College",
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // =========================
                    // Edit Profile Button
                    // =========================

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Edit Profile - Coming Soon",
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: Text(
                          "Edit Profile",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // Profile Card
  // =========================

  Widget _profileCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          ...children,
        ],
      ),
    );
  }

  // =========================
  // Profile Information Item
  // =========================

  Widget _profileItem(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
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