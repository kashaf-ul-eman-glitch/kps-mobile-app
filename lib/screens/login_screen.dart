import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore Import

import 'parent_dashboard.dart';
import 'teacher_dashboard.dart';
import 'admin_dashboard.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validation
    if (email.isEmpty && password.isEmpty) {
      _showMessage("Please enter email and password");
      return;
    }

    if (email.isEmpty) {
      _showMessage("Please enter email");
      return;
    }

    if (password.isEmpty) {
      _showMessage("Please enter password");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;

      if (user != null) {
        // 2. Firestore سے یوزر کی تفصیلات فیچ کرنا
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!mounted) return;

        // ==================================================================
        // FIRST-LOGIN CHECK — ONLY APPLIES TO PARENTS.
        //
        // Parent accounts are created by the Admission Form with the
        // default password and `isFirstLogin: true` in `users/{parentUid}`.
        // Admin/Teacher accounts should NOT be pushed into this flow even
        // if they happen to have no `users` doc yet — so the default here
        // is `false`, and the dialog only ever shows for widget.userType
        // == 'Parent'.
        //
        // FALLBACK FIX:
        // Some parent accounts may exist in Firebase Authentication
        // WITHOUT a matching `users/{uid}` document yet — for example
        // parents that were created before this feature was added, or
        // if the Firestore write in the Admission Form ever failed
        // silently. For those cases `userDoc.exists` is false, and
        // without this fallback such a parent would be able to keep
        // logging in with the default password forever without ever
        // being asked to set a new one.
        //
        // So: if this is a Parent login and there is NO `users/{uid}`
        // doc at all, we treat it as a first login too. Saving the
        // password inside `_showChangePasswordDialog` uses
        // `SetOptions(merge: true)`, which will create the missing
        // `users/{uid}` document automatically once they set a password,
        // so this fallback self-heals after the first successful run.
        // ==================================================================

        bool isFirstLogin = false;

        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          isFirstLogin = data['isFirstLogin'] ?? false;
        } else if (widget.userType == 'Parent') {
          // No users/{uid} doc found for this parent at all.
          // Treat this as first login so they are still forced to set
          // a real password instead of using the default one forever.
          isFirstLogin = true;
        }

        if (widget.userType == 'Parent' && isFirstLogin) {
          // Parent logging in for the first time with the default
          // password ("Parent@123") -> force them to set a new password
          // before letting them into the dashboard.
          _showChangePasswordDialog(user.uid, email);
        } else {
          // Everyone else (or a parent who already set their password)
          // goes straight to their dashboard.
          _navigateToDashboard();
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'invalid-credential':
          message = "Invalid email or password";
          break;

        case 'user-not-found':
          message = "No account found with this email";
          break;

        case 'wrong-password':
          message = "Incorrect password";
          break;

        case 'invalid-email':
          message = "Please enter a valid email";
          break;

        case 'user-disabled':
          message = "This account has been disabled";
          break;

        case 'too-many-requests':
          message = "Too many attempts. Please try again later";
          break;

        default:
          message = e.message ?? "Login failed";
      }

      if (mounted) {
        _showMessage(message);
      }
    } catch (e) {
      if (mounted) {
        _showMessage("Something went wrong. Please try again");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // پاسورڈ تبدیل کرنے کا ڈائیلاگ باکس (Parent - first login)
  void _showChangePasswordDialog(String uid, String email) {
    final TextEditingController newPasswordController =
        TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false, // صارف لازمی پاسورڈ چینج کرے
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(
                'Set Your Password',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'This is your first login. Please set a new secure password to continue.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val != newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setStateDialog(() {
                            isSaving = true;
                          });

                          try {
                            // Firebase Auth میں پاسورڈ اپ ڈیٹ کریں
                            await FirebaseAuth.instance.currentUser
                                ?.updatePassword(
                              newPasswordController.text.trim(),
                            );

                            // Firestore میں isFirstLogin کو false کریں
                            // (merge: true creates the users/{uid} doc if
                            // it never existed in the first place — this
                            // is what self-heals the fallback case above).
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .set({
                              'role': 'Parent',
                              'email': email,
                              'isFirstLogin': false,
                              'updatedAt': FieldValue.serverTimestamp(),
                            }, SetOptions(merge: true));

                            if (!context.mounted) return;
                            Navigator.pop(context); // Dialog بند کریں
                            _showMessage("Password updated successfully!");
                            _navigateToDashboard();
                          } on FirebaseAuthException catch (e) {
                            String message;
                            switch (e.code) {
                              case 'requires-recent-login':
                                message =
                                    "Please log in again and retry to set your password.";
                                break;
                              case 'weak-password':
                                message = "Please choose a stronger password.";
                                break;
                              default:
                                message = e.message ??
                                    "Failed to update password.";
                            }
                            setStateDialog(() {
                              isSaving = false;
                            });
                            _showMessage(message);
                          } catch (e) {
                            setStateDialog(() {
                              isSaving = false;
                            });
                            _showMessage(
                                "Failed to update password: ${e.toString()}");
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save Password',
                          style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==================================================================
  // FORGOT PASSWORD — ONLY FOR PARENT LOGIN.
  //
  // Sends a real Firebase password-reset email. Admin/Teacher logins
  // still show the old "coming soon" message (handled in build()).
  // ==================================================================
  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController =
        TextEditingController(text: _emailController.text.trim());
    final formKey = GlobalKey<FormState>();
    bool isSending = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(
                'Reset Password',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Enter your registered email address. We will send you a link to reset your password.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: resetEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!val.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSending ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                  onPressed: isSending
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setStateDialog(() {
                            isSending = true;
                          });

                          try {
                            await FirebaseAuth.instance
                                .sendPasswordResetEmail(
                              email: resetEmailController.text.trim(),
                            );

                            if (!context.mounted) return;
                            Navigator.pop(context);
                            _showMessage(
                              "Password reset link sent! Please check your email.",
                            );
                          } on FirebaseAuthException catch (e) {
                            String message;
                            switch (e.code) {
                              case 'invalid-email':
                                message = "Please enter a valid email";
                                break;
                              case 'user-not-found':
                                message =
                                    "No account found with this email";
                                break;
                              case 'too-many-requests':
                                message =
                                    "Too many attempts. Please try again later";
                                break;
                              default:
                                message =
                                    e.message ?? "Failed to send reset link";
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
                                "Something went wrong. Please try again");
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
                      : const Text(
                          'Send Link',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ڈیش بورڈ پر نیویگیٹ کرنے کا طریقہ
  void _navigateToDashboard() {
    if (widget.userType == 'Administrator') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminDashboard(),
        ),
      );
    } else if (widget.userType == 'Parent') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ParentDashboard(),
        ),
      );
    } else if (widget.userType == 'Teacher') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const TeacherDashboardScreen(),
        ),
      );
    } else {
      _showMessage("${widget.userType} Dashboard Coming Soon");
    }
  }

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
                padding: const EdgeInsets.all(25),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        50,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
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

                        // Login title
                        Text(
                          '${widget.userType} Login',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Email
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Colors.white,
                            ),
                            filled: true,
                            fillColor:
                                Colors.white.withValues(alpha: 0.15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Password
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.white,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword =
                                      !_obscurePassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor:
                                Colors.white.withValues(alpha: 0.15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // Forgot Password — real reset flow for Parent only
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              if (widget.userType == 'Parent') {
                                _showForgotPasswordDialog();
                              } else {
                                _showMessage(
                                  "Forgot password feature coming soon",
                                );
                              }
                            },
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 25,
                                    height: 25,
                                    child: CircularProgressIndicator(
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
          ),
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}