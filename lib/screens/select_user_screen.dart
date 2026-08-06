import 'login_screen.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectUserScreen extends StatelessWidget {
  const SelectUserScreen({super.key});

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
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
<<<<<<< HEAD
                    
=======
>>>>>>> 1dbb3b435680672e81fe9b66ec29db08d7e8d013

                    // Welcome Text
                    Text(
                      'Welcome',
                
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                      const SizedBox(height: 25),
                    

                    // ================= Administrator Card =================

                    InkWell(
                      onTap: () {
                         Navigator.push(
                        context,
                         MaterialPageRoute(
                         builder: (context) => const LoginScreen(
                         userType: 'Administrator',
      ),
    ),
  );
                        // Navigate to Login Screen
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: double.infinity,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 20),

                            const Icon(
                              Icons.admin_panel_settings,
                              color: Colors.white,
                              size: 34,
                            ),
<<<<<<< HEAD
                          

                            const SizedBox(width: 20),
                            
=======

                            const SizedBox(width: 20),
>>>>>>> 1dbb3b435680672e81fe9b66ec29db08d7e8d013

                            Text(
                              'Administrator',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const Spacer(),

                            const Padding(
                              padding: EdgeInsets.only(right: 20),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white70,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ================= Teacher Card =================

                    InkWell(
                      onTap: () {
                       Navigator.push(
                        context,
                         MaterialPageRoute(
                        builder: (context) => const LoginScreen(
                      userType: 'Teacher',
      ),
    ),
  );
                        
                        // Navigate to Login Screen
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: double.infinity,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 20),

                            const Icon(
                              Icons.school,
                              color: Colors.white,
                              size: 34,
                            ),

                            const SizedBox(width: 20),

                            Text(
                              'Teacher',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const Spacer(),

                            const Padding(
                              padding: EdgeInsets.only(right: 20),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white70,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ================= Parent Card =================

                    InkWell(
                      onTap: () {
                        Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const LoginScreen(
        userType: 'Parent',
      ),
    ),
  );
                        // Navigate to Login Screen
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: double.infinity,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 20),

                            const Icon(
                              Icons.people,
                              color: Colors.white,
                              size: 34,
                            ),

                            const SizedBox(width: 20),

                            Text(
                              'Parent',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const Spacer(),

                            const Padding(
                              padding: EdgeInsets.only(right: 20),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white70,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
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
}