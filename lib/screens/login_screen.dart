import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_dashboard.dart';
import 'parent_dashboard.dart';
import 'teacher_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.userType,
  });

  final String userType;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ============================================================
  // ADMIN DEFAULT PASSWORD
  // ============================================================
  //
  // IMPORTANT:
  // Apna actual Admin default password yahan likhein.
  //
  // Example:
  // static const String defaultAdminPassword = 'Admin@123';
  //
  // ============================================================

  static const String defaultAdminPassword = 'YOUR_ADMIN_DEFAULT_PASSWORD';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _login() async {
    final String email = _emailController.text.trim().toLowerCase();
    final String password = _passwordController.text.trim();

    // ----------------------------------------------------------
    // VALIDATION
    // ----------------------------------------------------------

    if (email.isEmpty && password.isEmpty) {
      _showMessage('Please enter email and password');
      return;
    }

    if (email.isEmpty) {
      _showMessage('Please enter email');
      return;
    }

    if (password.isEmpty) {
      _showMessage('Please enter password');
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // ========================================================
      // FIREBASE AUTHENTICATION
      // ========================================================

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('User account could not be found.');
      }

      // ========================================================
      // FIRST LOGIN CHECK
      // Works for:
      // Parent
      // Teacher
      // Admin / Administrator
      // ========================================================

      bool isFirstLogin = false;

      try {
        final DocumentSnapshot<Map<String, dynamic>> userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (userDoc.exists) {
          final Map<String, dynamic> data = userDoc.data() ?? {};

          final dynamic firstLoginValue = data['isFirstLogin'];

          // ----------------------------------------------------
          // If Firestore explicitly says true
          // ----------------------------------------------------

          if (firstLoginValue is bool) {
            isFirstLogin = firstLoginValue;
          } else {
            // --------------------------------------------------
            // If isFirstLogin field does not exist
            // treat it as first login
            // --------------------------------------------------

            isFirstLogin = true;
          }
        } else {
          // ----------------------------------------------------
          // Auth account exists but users document does not
          // exist -> first login
          // ----------------------------------------------------

          isFirstLogin = true;
        }

        // ======================================================
        // ADMIN DEFAULT PASSWORD CHECK
        // ======================================================
        //
        // If Admin is still using the default password,
        // force the password change screen.
        //
        // ======================================================

        final bool isAdmin =
            widget.userType == 'Admin' ||
            widget.userType == 'Administrator';

        if (isAdmin && password == defaultAdminPassword) {
          isFirstLogin = true;
        }
      } catch (e) {
        debugPrint('USER DOCUMENT ERROR: $e');

        // If Firestore read fails, safely treat it as first login
        isFirstLogin = true;
      }

      if (!mounted) return;

      // ========================================================
      // FIRST LOGIN HANDLER
      // ========================================================

      if (isFirstLogin) {
        _showChangePasswordDialog(
          user.uid,
          email,
        );
      } else {
        // ======================================================
        // NORMAL DASHBOARD NAVIGATION
        // ======================================================

        _navigateToDashboard();
      }
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'invalid-credential':
          message = 'Invalid email or password';
          break;

        case 'user-not-found':
          message = 'No account found with this email';
          break;

        case 'wrong-password':
          message = 'Incorrect password';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email';
          break;

        case 'user-disabled':
          message = 'This account has been disabled';
          break;

        case 'too-many-requests':
          message = 'Too many attempts. Please try again later';
          break;

        case 'network-request-failed':
          message = 'Network error. Please check your internet connection.';
          break;

        default:
          message = e.message ?? 'Login failed. Please try again.';
      }

      if (mounted) {
        _showMessage(message);
      }
    } catch (e) {
      debugPrint('LOGIN ERROR: $e');

      if (mounted) {
        _showMessage('Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // FIRST LOGIN - CHANGE PASSWORD DIALOG
  // ============================================================

  void _showChangePasswordDialog(
    String uid,
    String email,
  ) {
    final TextEditingController newPasswordController =
        TextEditingController();

    final TextEditingController confirmPasswordController =
        TextEditingController();

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 15,
                    sigmaY: 15,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ==================================================
                          // ICON
                          // ==================================================

                          Icon(
                            Icons.lock_reset_rounded,
                            size: 48,
                            color: Colors.amber.shade400,
                          ),

                          const SizedBox(height: 12),

                          // ==================================================
                          // TITLE
                          // ==================================================

                          Text(
                            'Set Your Password',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // ==================================================
                          // DESCRIPTION
                          // ==================================================

                          Text(
                            'This is your first login. Please set a new secure password to continue.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ==================================================
                          // NEW PASSWORD
                          // ==================================================

                          TextFormField(
                            controller: newPasswordController,
                            obscureText: true,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                            ),
                            decoration: _buildInputDecoration(
                              hintText: 'New Password',
                              icon: Icons.lock_outline,
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().length < 6) {
                                return 'Password must be at least 6 characters';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 14),

                          // ==================================================
                          // CONFIRM PASSWORD
                          // ==================================================

                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: true,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                            ),
                            decoration: _buildInputDecoration(
                              hintText: 'Confirm Password',
                              icon: Icons.lock_reset,
                            ),
                            validator: (value) {
                              if (value != newPasswordController.text) {
                                return 'Passwords do not match';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          // ==================================================
                          // SAVE BUTTON
                          // ==================================================

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber.shade700,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: isSaving
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate()) {
                                        return;
                                      }

                                      setStateDialog(() {
                                        isSaving = true;
                                      });

                                      try {
                                        final User? currentUser =
                                            FirebaseAuth.instance.currentUser;

                                        if (currentUser == null) {
                                          throw Exception(
                                            'Current user not found.',
                                          );
                                        }

                                        // ==================================
                                        // UPDATE FIREBASE AUTH PASSWORD
                                        // ==================================

                                        await currentUser.updatePassword(
                                          newPasswordController.text.trim(),
                                        );

                                        // ==================================
                                        // UPDATE FIRESTORE USER RECORD
                                        // ==================================

                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(uid)
                                            .set(
                                          {
                                            'role': widget.userType,
                                            'email': email,
                                            'isFirstLogin': false,
                                            'updatedAt':
                                                FieldValue.serverTimestamp(),
                                          },
                                          SetOptions(merge: true),
                                        );

                                        if (!context.mounted) return;

                                        Navigator.of(context).pop();

                                        _showMessage(
                                          'Password updated successfully!',
                                        );

                                        _navigateToDashboard();
                                      } on FirebaseAuthException catch (e) {
                                        String message;

                                        switch (e.code) {
                                          case 'requires-recent-login':
                                            message =
                                                'Please log in again and retry setting your password.';
                                            break;

                                          case 'weak-password':
                                            message =
                                                'Please choose a stronger password.';
                                            break;

                                          default:
                                            message = e.message ??
                                                'Failed to update password.';
                                        }

                                        setStateDialog(() {
                                          isSaving = false;
                                        });

                                        _showMessage(message);
                                      } catch (e) {
                                        debugPrint(
                                          'PASSWORD UPDATE ERROR: $e',
                                        );

                                        setStateDialog(() {
                                          isSaving = false;
                                        });

                                        _showMessage(
                                          'Failed to update password.',
                                        );
                                      }
                                    },
                              child: isSaving
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      'Save Password',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // FORGOT PASSWORD DIALOG
  // ============================================================

  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController =
        TextEditingController(
      text: _emailController.text.trim(),
    );

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    bool isSending = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 15,
                    sigmaY: 15,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.mark_email_read_outlined,
                            size: 48,
                            color: Colors.lightBlue.shade300,
                          ),

                          const SizedBox(height: 12),

                          Text(
                            'Reset Password',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Enter your registered email address. We will send you a reset link.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),

                          const SizedBox(height: 20),

                          TextFormField(
                            controller: resetEmailController,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                            ),
                            decoration: _buildInputDecoration(
                              hintText: 'Email Address',
                              icon: Icons.email_outlined,
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Please enter your email';
                              }

                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: isSending
                                      ? null
                                      : () => Navigator.of(context).pop(),
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.brown.shade700,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: isSending
                                      ? null
                                      : () async {
                                          if (!formKey.currentState!
                                              .validate()) {
                                            return;
                                          }

                                          setStateDialog(() {
                                            isSending = true;
                                          });

                                          try {
                                            await FirebaseAuth.instance
                                                .sendPasswordResetEmail(
                                              email: resetEmailController
                                                  .text
                                                  .trim()
                                                  .toLowerCase(),
                                            );

                                            if (!context.mounted) return;

                                            Navigator.of(context).pop();

                                            _showMessage(
                                              'Password reset link sent! Please check your email.',
                                            );
                                          } on FirebaseAuthException catch (e) {
                                            String message;

                                            switch (e.code) {
                                              case 'invalid-email':
                                                message =
                                                    'Please enter a valid email';
                                                break;

                                              case 'user-not-found':
                                                message =
                                                    'No account found with this email';
                                                break;

                                              case 'too-many-requests':
                                                message =
                                                    'Too many attempts. Please try again later';
                                                break;

                                              default:
                                                message = e.message ??
                                                    'Failed to send reset link';
                                            }

                                            setStateDialog(() {
                                              isSending = false;
                                            });

                                            _showMessage(message);
                                          } catch (e) {
                                            setStateDialog(() {
                                              isSending = false;
                                            });

                                            _showMessage(
                                              'Something went wrong. Please try again.',
                                            );
                                          }
                                        },
                                  child: isSending
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          'Send Link',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // NAVIGATE TO DASHBOARD
  // ============================================================

  void _navigateToDashboard() {
    if (!mounted) return;

    // ============================================================
    // ADMIN
    // ============================================================

    if (widget.userType == 'Administrator' ||
        widget.userType == 'Admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminDashboard(),
        ),
      );

      return;
    }

    // ============================================================
    // PARENT
    // ============================================================

    if (widget.userType == 'Parent') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ParentDashboard(),
        ),
      );

      return;
    }

    // ============================================================
    // TEACHER
    // ============================================================

    if (widget.userType == 'Teacher') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const TeacherDashboardScreen(),
        ),
      );

      return;
    }

    _showMessage(
      '${widget.userType} Dashboard Coming Soon',
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(
        color: Colors.white60,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(
        icon,
        color: Colors.white70,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.12),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.8),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.redAccent.withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ======================================================
          // BACKGROUND IMAGE
          // ======================================================

          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // ======================================================
          // DARK OVERLAY + BLUR
          // ======================================================

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 8,
                sigmaY: 8,
              ),
              child: Container(
                color: Colors.black.withValues(alpha: 0.45),
              ),
            ),
          ),

          // ======================================================
          // GLASSMORPHIC LOGIN FORM
          // ======================================================

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 450,
                  ),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ==================================================
                      // LOGO
                      // ==================================================

                      Container(
                        width: 110,
                        height: 110,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return const Icon(
                                Icons.school,
                                color: Colors.white,
                                size: 55,
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // TITLE
                      // ==================================================

                      Text(
                        '${widget.userType} Login',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ==================================================
                      // EMAIL
                      // ==================================================

                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _buildInputDecoration(
                          hintText: 'Email',
                          icon: Icons.email_rounded,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ==================================================
                      // PASSWORD
                      // ==================================================

                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _buildInputDecoration(
                          hintText: 'Password',
                          icon: Icons.lock_rounded,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword =
                                    !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ==================================================
                      // FORGOT PASSWORD
                      // ==================================================

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showForgotPasswordDialog,
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(
                                alpha: 0.9,
                              ),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              decoration:
                                  TextDecoration.underline,
                              decorationColor: Colors.white70,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // LOGIN BUTTON
                      // ==================================================

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.brown.shade800,
                            foregroundColor: Colors.white,
                            elevation: 5,
                            shadowColor: Colors.black45,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(16),
                              side: BorderSide(
                                color: Colors.white.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                          ),
                          onPressed:
                              _isLoading ? null : _login,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 25,
                                  height: 25,
                                  child:
                                      CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : Text(
                                  'Login',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MESSAGE SNACKBAR
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
            Colors.grey.shade900.withValues(alpha: 0.95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
