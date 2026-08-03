import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'about_school_screen.dart';

 class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
void initState() {
  super.initState();

  Timer(
    const Duration(seconds: 5),
    () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>  AboutSchoolScreen(),
        ),
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown,
      body: Container(
  width: double.infinity,
  height: double.infinity,
  decoration: const BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/images/background.jpg'),
      fit: BoxFit.cover,
    ),
  ),
  child: Container(
  decoration: BoxDecoration(
    color: Colors.black.withValues(alpha:0.35),
  ),
   child: BackdropFilter(
  filter: ImageFilter.blur(
    sigmaX: 5,
    sigmaY: 5,
  ),

  child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            Container(
  decoration: const BoxDecoration(
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 10,
        spreadRadius: 2,
      ),
    ],
  ),
  child: const CircleAvatar(
    radius: 70,
    backgroundColor: Colors.white,
    backgroundImage: AssetImage('assets/images/logo.jpg'),
  ),
),

const SizedBox(height: 20),

            // School Name
           Text(
              'Khyber Public School\n & \nCollege Mansehra',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                 fontSize: 30,
                 fontWeight: FontWeight.w700,
                 color: Colors.white,
                 letterSpacing: 1,
              ),
            ),

           const SizedBox(height: 30),

            // Loading Spinner
            const CircularProgressIndicator(
              color: Colors.white,
            ),

            const SizedBox(height: 15),

            // Loading Text
             Text(
              'Loading...',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                  fontWeight: FontWeight.w500,
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
}