import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final User? currentUser = _auth.currentUser;

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
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                // Query teachers collection using logged-in user's email
                stream: (currentUser?.email != null)
                    ? _firestore
                        .collection('teachers')
                        .where('email', isEqualTo: currentUser!.email!.toLowerCase())
                        .snapshots()
                    : const Stream.empty(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  Map<String, dynamic> data = {};

                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    data = snapshot.data!.docs.first.data();
                  }

                  // Field fallbacks to match Admin screen data
                  final String name = data['fullName']?.toString() ??
                      data['name']?.toString() ??
                      currentUser?.displayName ??
                      'Teacher Profile';

                  final String designation = data['role']?.toString() ??
                      data['designation']?.toString() ??
                      'Subject Teacher';

                  final String email = data['email']?.toString() ??
                      currentUser?.email ??
                      'N/A';

                  final String phone = data['phone']?.toString() ?? 'N/A';

                  final String department = data['subject']?.toString() ??
                      data['department']?.toString() ??
                      data['qualification']?.toString() ??
                      'N/A';

                  final String teacherId = data['employeeId']?.toString() ??
                      data['teacherId']?.toString() ??
                      'N/A';

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
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
                          name,
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
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.brown.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: [
                              _buildProfileDetailTile(
                                icon: Icons.email_outlined,
                                title: 'Email Address',
                                value: email,
                              ),
                              const Divider(
                                color: Colors.white24,
                                indent: 20,
                                endIndent: 20,
                              ),
                              _buildProfileDetailTile(
                                icon: Icons.phone_outlined,
                                title: 'Phone Number',
                                value: phone,
                              ),
                              const Divider(
                                color: Colors.white24,
                                indent: 20,
                                endIndent: 20,
                              ),
                              _buildProfileDetailTile(
                                icon: Icons.school_outlined,
                                title: 'Subject / Qualification',
                                value: department,
                              ),
                              const Divider(
                                color: Colors.white24,
                                indent: 20,
                                endIndent: 20,
                              ),
                              _buildProfileDetailTile(
                                icon: Icons.badge_outlined,
                                title: 'Employee ID',
                                value: teacherId,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
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