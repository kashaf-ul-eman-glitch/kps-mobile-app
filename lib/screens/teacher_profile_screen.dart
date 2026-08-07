import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyProfileScreen extends StatelessWidget {
  final String teacherName;
  final String designation;

  const MyProfileScreen({
    super.key,
    this.teacherName = 'Mr. Ahmed Khan',
    this.designation = 'Senior Science Teacher',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown.shade800,
        elevation: 4,
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.black.withValues(alpha: 0.25),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // Male Teacher Avatar (Icons.person)
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const ClipOval(
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    Text(
                      teacherName,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      designation,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Profile Details inside Glassmorphic Transparent Container
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.brown.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          _buildProfileDetailTile(
                            icon: Icons.email_outlined,
                            title: 'Email Address',
                            value: 'ahmed.khan@school.edu.pk',
                          ),
                          const Divider(color: Colors.white24, indent: 20, endIndent: 20),
                          _buildProfileDetailTile(
                            icon: Icons.phone_outlined,
                            title: 'Phone Number',
                            value: '+92 300 1234567',
                          ),
                          const Divider(color: Colors.white24, indent: 20, endIndent: 20),
                          _buildProfileDetailTile(
                            icon: Icons.school_outlined,
                            title: 'Department',
                            value: 'Science & Mathematics',
                          ),
                          const Divider(color: Colors.white24, indent: 20, endIndent: 20),
                          _buildProfileDetailTile(
                            icon: Icons.badge_outlined,
                            title: 'Teacher ID',
                            value: 'T-2026-88',
                          ),
                        ],
                      ),
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

  Widget _buildProfileDetailTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.white70,
        ),
      ),
      subtitle: Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}