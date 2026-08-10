import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:small_app_flutter/screens/notifications_screen.dart';
import 'package:small_app_flutter/widgets/admin_drawer.dart';
import '../screens/admin_profile_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(),

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // Dashboard App Bar

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,

                      children: [
                        // Menu Button

                        Builder(
                          builder: (context) => IconButton(
                            onPressed: () {
                              Scaffold.of(context)
                                  .openDrawer();
                            },

                            icon: const Icon(
                              Icons.menu,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),

                        // Dashboard Title

                        Text(
                          "Dashboard",

                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Row(
                          children: [
                            // Notification Button

                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const NotificationsScreen(),
                                  ),
                                );
                              },

                              icon: const Icon(
                                Icons.notifications_none,
                                color: Colors.white,
                              ),
                            ),

                            // Profile Button

                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AdminProfileScreen(),
                                  ),
                                );
                              },

                              icon: const Icon(
                                Icons.account_circle,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // Welcome Card

                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.symmetric(
                        vertical: 25,
                        horizontal: 20,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.15,
                        ),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),

                      child: Column(
                        children: [
                          // School Logo

                          Container(
                            width: 90,
                            height: 90,

                            decoration:
                                const BoxDecoration(
                              shape: BoxShape.circle,
                            ),

                            child: Padding(
                              padding:
                                  const EdgeInsets.all(8),

                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/logo.jpg',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Welcome Text

                          Text(
                            "Welcome, Administrator",
                            textAlign: TextAlign.center,

                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // School Name

                          Text(
                            "Khyber Public School & College",
                            textAlign: TextAlign.center,

                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Today's Overview

                    Text(
                      "Today's Overview",

                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: _dashboardCard(
                            Icons.school,
                            "Students",
                            "1250",
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: _dashboardCard(
                            Icons.person,
                            "Teachers",
                            "68",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: _dashboardCard(
                            Icons.how_to_reg,
                            "Attendance",
                            "1130/1200",
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: _dashboardCard(
                            Icons.class_,
                            "Classes",
                            "42",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dashboardCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 35,
          ),

          const SizedBox(height: 12),

          Text(
            value,

            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            title,

            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}