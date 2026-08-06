import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:small_app_flutter/screens/select_user_screen.dart';

class AboutSchoolScreen extends StatelessWidget {
  const AboutSchoolScreen({super.key});

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
            sigmaX: 3,
            sigmaY: 3,
          ),
          child: Container(
            color: Colors.black.withValues(alpha: 0.25),
            child: SafeArea(
  child: SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top -
            40,
      ),
      child: Column(
                    children: [
                      Container(
  width: 110,
  height: 110,
  decoration: const BoxDecoration(
    shape: BoxShape.circle,
  ),
  child: Padding(
    padding: const EdgeInsets.all(10),
    child: ClipOval(
      child: Image.asset(
        'assets/images/logo.jpg',
        fit: BoxFit.contain,
      ),
    ),
  ),
),

const SizedBox(height: 20),

                      // Title
                      Text(
                        'About Our School',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // About School Card
                      Container(
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
                              '📖 About School',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              'Khyber Public School & College Mansehra provides quality education in a safe and supportive environment, helping students achieve academic excellence and develop strong moral values.',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Vision Card
                      Container(
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
                              '🎯 Vision',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              'To inspire every student to become a lifelong learner, responsible citizen, and confident leader through quality education.',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Mission Card
                      Container(
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
                              '🌟 Mission',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              'Our mission is to provide a safe, inclusive, and inspiring learning environment where every student is encouraged to achieve academic excellence and develop strong character.',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute( 
                             builder: (context) => SelectUserScreen(),
                             ),
                            );
                          },
                          child: Text(
                            'Continue',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              
            ),
          ),
        ),
      ),
    ),
    );
  }
}