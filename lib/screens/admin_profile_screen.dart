import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_management_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  Map<String, dynamic> _adminData = {};

  @override
  void initState() {
    super.initState();
    _loadAdminProfile();
  }

  // ============================================================
  // LOAD ADMIN PROFILE
  // ============================================================

  Future<void> _loadAdminProfile() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = _auth.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          _adminData = {};
          _isLoading = false;
        });

        return;
      }

      final DocumentSnapshot<Map<String, dynamic>> document =
          await _firestore.collection('users').doc(user.uid).get();

      if (!mounted) return;

      if (document.exists && document.data() != null) {
        setState(() {
          _adminData = document.data()!;
          _isLoading = false;
        });
      } else {
        // Fallback values from Firebase Authentication.
        setState(() {
          _adminData = {
            'name': user.displayName ?? 'Main Admin',
            'email': user.email ?? '',
            'phone': '',
            'role': 'Administrator',
            'adminType': 'Main Administrator',
          };
          _isLoading = false;
        });
      }
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        e.message ?? 'Unable to load admin profile.',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Unable to load admin profile.',
      );
    }
  }

  // ============================================================
  // SAFE MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
          backgroundColor: Colors.brown.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  // ============================================================
  // GET ADMIN DATA
  // ============================================================

  String _getName() {
    final String? name = _adminData['name']?.toString();

    if (name == null || name.trim().isEmpty) {
      return 'Main Admin';
    }

    return name.trim();
  }

  String _getEmail() {
    final String? firestoreEmail = _adminData['email']?.toString();

    if (firestoreEmail != null && firestoreEmail.trim().isNotEmpty) {
      return firestoreEmail.trim();
    }

    return _auth.currentUser?.email ?? 'Not provided';
  }

  String _getPhone() {
    final String? phone = _adminData['phone']?.toString();

    if (phone == null || phone.trim().isEmpty) {
      return 'Not provided';
    }

    return phone.trim();
  }

  String _getRole() {
    final String? role = _adminData['role']?.toString();

    if (role == null || role.trim().isEmpty) {
      return 'Administrator';
    }

    return role.trim();
  }

  String _getAdminType() {
    final String? type = _adminData['adminType']?.toString();

    if (type != null && type.trim().isNotEmpty) {
      return type.trim();
    }

    final String? type2 = _adminData['type']?.toString();

    if (type2 != null && type2.trim().isNotEmpty) {
      return type2.trim();
    }

    return 'Main Administrator';
  }

  // ============================================================
  // ADD ADMIN
  // ============================================================

  Future<void> _addAdmin() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminManagementScreen(),
      ),
    );

    // Refresh profile when coming back.
    if (!mounted) return;

    await _loadAdminProfile();
  }

  // ============================================================
  // SHOW ADMIN INFORMATION
  // ============================================================

  Future<void> _showAdminInformation() async {
    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 24,
          ),
          child: _glassDialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ----------------------------------------------------------
                // TITLE
                // ----------------------------------------------------------

                Row(
                  children: [
                    _dialogIcon(Icons.admin_panel_settings_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Admin Information',
                        style: GoogleFonts.poppins(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                _dialogInfoField(
                  icon: Icons.person_outline,
                  title: 'Name',
                  value: _getName(),
                ),

                _dialogInfoField(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  value: _getEmail(),
                ),

                _dialogInfoField(
                  icon: Icons.badge_outlined,
                  title: 'Role',
                  value: _getRole(),
                ),

                _dialogInfoField(
                  icon: Icons.phone_outlined,
                  title: 'Phone Number',
                  value: _getPhone(),
                ),

                _dialogInfoField(
                  icon: Icons.shield_outlined,
                  title: 'Type',
                  value: _getAdminType(),
                ),

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: _brownButtonStyle(),
                    child: Text(
                      'Close',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // EDIT PROFILE
  // ============================================================

  Future<void> _editProfile() async {
    final TextEditingController nameController =
        TextEditingController(text: _getName());

    final TextEditingController phoneController =
        TextEditingController(
      text: _adminData['phone']?.toString() ?? '',
    );

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    try {
      await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.65),
        builder: (dialogContext) {
          bool saving = false;

          return StatefulBuilder(
            builder: (dialogBuildContext, setDialogState) {
              return Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 24,
                ),
                child: _glassDialog(
                  child: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --------------------------------------------------
                          // TITLE
                          // --------------------------------------------------

                          Row(
                            children: [
                              _dialogIcon(Icons.edit_outlined),
                              const SizedBox(width: 12),
                              Text(
                                'Edit Profile',
                                style: GoogleFonts.poppins(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // --------------------------------------------------
                          // NAME
                          // --------------------------------------------------

                          _fieldTitle('Name'),

                          const SizedBox(height: 7),

                          _textField(
                            controller: nameController,
                            hint: 'Enter admin name',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Please enter name';
                              }

                              if (value.trim().length < 2) {
                                return 'Name is too short';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 17),

                          // --------------------------------------------------
                          // EMAIL
                          // --------------------------------------------------

                          _fieldTitle('Email'),

                          const SizedBox(height: 7),

                          TextFormField(
                            initialValue: _getEmail(),
                            readOnly: true,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.60),
                            ),
                            decoration: _inputDecoration(
                              hint: 'Email',
                              icon: Icons.email_outlined,
                            ),
                          ),

                          const SizedBox(height: 17),

                          // --------------------------------------------------
                          // ROLE
                          // --------------------------------------------------

                          _fieldTitle('Role'),

                          const SizedBox(height: 7),

                          TextFormField(
                            initialValue: _getRole(),
                            readOnly: true,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.60),
                            ),
                            decoration: _inputDecoration(
                              hint: 'Role',
                              icon: Icons.badge_outlined,
                            ),
                          ),

                          const SizedBox(height: 17),

                          // --------------------------------------------------
                          // PHONE
                          // --------------------------------------------------

                          _fieldTitle('Phone Number'),

                          const SizedBox(height: 7),

                          TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 11,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white,
                            ),
                            cursorColor: Colors.white,
                            decoration: _inputDecoration(
                              hint: '03XXXXXXXXX',
                              icon: Icons.phone_outlined,
                              counterText: '',
                            ),
                            validator: (value) {
                              final phone = value?.trim() ?? '';

                              if (phone.isEmpty) {
                                return 'Please enter phone number';
                              }

                              if (!RegExp(r'^03\d{9}$')
                                  .hasMatch(phone)) {
                                return 'Enter a valid 11-digit phone number';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 17),

                          // --------------------------------------------------
                          // TYPE
                          // --------------------------------------------------

                          _fieldTitle('Type'),

                          const SizedBox(height: 7),

                          TextFormField(
                            initialValue: _getAdminType(),
                            readOnly: true,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.60),
                            ),
                            decoration: _inputDecoration(
                              hint: 'Account type',
                              icon: Icons.shield_outlined,
                            ),
                          ),

                          const SizedBox(height: 25),

                          // --------------------------------------------------
                          // BUTTONS
                          // --------------------------------------------------

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: saving
                                    ? null
                                    : () {
                                        Navigator.pop(dialogContext);
                                      },
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              ElevatedButton(
                                onPressed: saving
                                    ? null
                                    : () async {
                                        if (!formKey.currentState!
                                            .validate()) {
                                          return;
                                        }

                                        if (!dialogBuildContext.mounted) {
                                          return;
                                        }

                                        setDialogState(() {
                                          saving = true;
                                        });

                                        try {
                                          final User? user =
                                              _auth.currentUser;

                                          if (user == null) {
                                            throw Exception(
                                              'No logged-in administrator found.',
                                            );
                                          }

                                          await _firestore
                                              .collection('users')
                                              .doc(user.uid)
                                              .set(
                                            {
                                              'name': nameController
                                                  .text
                                                  .trim(),
                                              'phone': phoneController
                                                  .text
                                                  .trim(),
                                            },
                                            SetOptions(merge: true),
                                          );

                                          // Update Firebase Auth display name
                                          // as well.
                                          await user.updateDisplayName(
                                            nameController.text.trim(),
                                          );

                                          if (!dialogBuildContext.mounted) {
                                            return;
                                          }

                                          Navigator.pop(dialogContext);

                                          // IMPORTANT:
                                          // Reload only after the dialog closes.
                                          if (!mounted) return;

                                          await _loadAdminProfile();

                                          if (!mounted) return;

                                          _showMessage(
                                            'Profile updated successfully.',
                                          );
                                        } on FirebaseException catch (e) {
                                          if (!dialogBuildContext.mounted) {
                                            return;
                                          }

                                          setDialogState(() {
                                            saving = false;
                                          });

                                          String message =
                                              'Failed to update profile.';

                                          if (e.code == 'permission-denied') {
                                            message =
                                                'Permission denied. Check your Firestore rules.';
                                          } else if (e.message != null &&
                                              e.message!.isNotEmpty) {
                                            message = e.message!;
                                          }

                                          _showDialogError(
                                            dialogBuildContext,
                                            message,
                                          );
                                        } catch (e) {
                                          if (!dialogBuildContext.mounted) {
                                            return;
                                          }

                                          setDialogState(() {
                                            saving = false;
                                          });

                                          _showDialogError(
                                            dialogBuildContext,
                                            'Failed to update profile. Please try again.',
                                          );
                                        }
                                      },
                                style: _brownButtonStyle(),
                                child: saving
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'Save',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
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
              );
            },
          );
        },
      );
    } finally {
      nameController.dispose();
      phoneController.dispose();
    }
  }

  // ============================================================
  // CHANGE PASSWORD
  // ============================================================

  Future<void> _changePassword() async {
    final TextEditingController currentPasswordController =
        TextEditingController();

    final TextEditingController newPasswordController =
        TextEditingController();

    final TextEditingController confirmPasswordController =
        TextEditingController();

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    try {
      await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.65),
        builder: (dialogContext) {
          bool saving = false;

          return StatefulBuilder(
            builder: (dialogBuildContext, setDialogState) {
              return Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 24,
                ),
                child: _glassDialog(
                  child: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --------------------------------------------------
                          // TITLE
                          // --------------------------------------------------

                          Row(
                            children: [
                              _dialogIcon(Icons.lock_reset),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Change Password',
                                  style: GoogleFonts.poppins(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // --------------------------------------------------
                          // CURRENT PASSWORD
                          // --------------------------------------------------

                          _fieldTitle('Current Password'),

                          const SizedBox(height: 7),

                          _passwordField(
                            controller: currentPasswordController,
                            hint: 'Enter current password',
                            icon: Icons.lock_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter current password';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 17),

                          // --------------------------------------------------
                          // NEW PASSWORD
                          // --------------------------------------------------

                          _fieldTitle('New Password'),

                          const SizedBox(height: 7),

                          _passwordField(
                            controller: newPasswordController,
                            hint: 'Enter new password',
                            icon: Icons.lock_reset,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter new password';
                              }

                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 17),

                          // --------------------------------------------------
                          // CONFIRM PASSWORD
                          // --------------------------------------------------

                          _fieldTitle('Confirm New Password'),

                          const SizedBox(height: 7),

                          _passwordField(
                            controller: confirmPasswordController,
                            hint: 'Confirm new password',
                            icon: Icons.lock_reset,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Confirm your new password';
                              }

                              if (value != newPasswordController.text) {
                                return 'Passwords do not match';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 25),

                          // --------------------------------------------------
                          // BUTTONS
                          // --------------------------------------------------

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: saving
                                    ? null
                                    : () {
                                        Navigator.pop(dialogContext);
                                      },
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              ElevatedButton(
                                onPressed: saving
                                    ? null
                                    : () async {
                                        if (!formKey.currentState!
                                            .validate()) {
                                          return;
                                        }

                                        if (!dialogBuildContext.mounted) {
                                          return;
                                        }

                                        setDialogState(() {
                                          saving = true;
                                        });

                                        try {
                                          final User? user =
                                              _auth.currentUser;

                                          if (user == null ||
                                              user.email == null) {
                                            throw FirebaseAuthException(
                                              code: 'no-user',
                                              message:
                                                  'No logged-in administrator found.',
                                            );
                                          }

                                          final AuthCredential credential =
                                              EmailAuthProvider.credential(
                                            email: user.email!,
                                            password:
                                                currentPasswordController
                                                    .text,
                                          );

                                          await user
                                              .reauthenticateWithCredential(
                                            credential,
                                          );

                                          await user.updatePassword(
                                            newPasswordController.text,
                                          );

                                          if (!dialogBuildContext.mounted) {
                                            return;
                                          }

                                          Navigator.pop(dialogContext);

                                          if (!mounted) return;

                                          _showMessage(
                                            'Password changed successfully.',
                                          );
                                        } on FirebaseAuthException catch (e) {
                                          if (!dialogBuildContext.mounted) {
                                            return;
                                          }

                                          setDialogState(() {
                                            saving = false;
                                          });

                                          String message;

                                          switch (e.code) {
                                            case 'wrong-password':
                                            case 'invalid-credential':
                                              message =
                                                  'Current password is incorrect.';
                                              break;

                                            case 'weak-password':
                                              message =
                                                  'The new password is too weak.';
                                              break;

                                            case 'requires-recent-login':
                                              message =
                                                  'Please log in again before changing your password.';
                                              break;

                                            default:
                                              message = e.message ??
                                                  'Password change failed.';
                                          }

                                          _showDialogError(
                                            dialogBuildContext,
                                            message,
                                          );
                                        } catch (e) {
                                          if (!dialogBuildContext.mounted) {
                                            return;
                                          }

                                          setDialogState(() {
                                            saving = false;
                                          });

                                          _showDialogError(
                                            dialogBuildContext,
                                            'Password change failed. Please try again.',
                                          );
                                        }
                                      },
                                style: _brownButtonStyle(),
                                child: saving
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'Change',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
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
              );
            },
          );
        },
      );
    } finally {
      currentPasswordController.dispose();
      newPasswordController.dispose();
      confirmPasswordController.dispose();
    }
  }

  // ============================================================
  // DIALOG ERROR
  // ============================================================

  void _showDialogError(
    BuildContext dialogContext,
    String message,
  ) {
    if (!dialogContext.mounted) return;

    ScaffoldMessenger.of(dialogContext)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          backgroundColor: Colors.brown.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  // ============================================================
  // GLASS DIALOG
  // ============================================================

  Widget _glassDialog({
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.40),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  // ============================================================
  // DIALOG ICON
  // ============================================================

  Widget _dialogIcon(IconData icon) {
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 21,
      ),
    );
  }

  // ============================================================
  // DIALOG INFORMATION FIELD
  // ============================================================

  Widget _dialogInfoField({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.14),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white70,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.65),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
  // FIELD TITLE
  // ============================================================

  Widget _fieldTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white.withOpacity(0.75),
      ),
    );
  }

  // ============================================================
  // NORMAL TEXT FIELD
  // ============================================================

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.poppins(
        fontSize: 13,
        color: Colors.white,
      ),
      cursorColor: Colors.white,
      decoration: _inputDecoration(
        hint: hint,
        icon: icon,
      ),
      validator: validator,
    );
  }

  // ============================================================
  // PASSWORD FIELD
  // ============================================================

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      style: GoogleFonts.poppins(
        fontSize: 13,
        color: Colors.white,
      ),
      cursorColor: Colors.white,
      decoration: _inputDecoration(
        hint: hint,
        icon: icon,
      ),
      validator: validator,
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    String? counterText,
  }) {
    return InputDecoration(
      hintText: hint,
      counterText: counterText,
      hintStyle: GoogleFonts.poppins(
        fontSize: 13,
        color: Colors.white.withOpacity(0.45),
      ),
      prefixIcon: Icon(
        icon,
        color: Colors.white70,
        size: 20,
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.22),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.white,
          width: 1.2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
    );
  }

  // ============================================================
  // BROWN BUTTON STYLE
  // ============================================================

  ButtonStyle _brownButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.brown,
      foregroundColor: Colors.white,
      elevation: 2,
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
      ),
    );
  }

  // ============================================================
  // GLASS TILE
  // ============================================================

  Widget _glassTile({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 8,
          sigmaY: 8,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.22),
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ACTION BUTTON
  // ============================================================

  Widget _actionButton({
    required IconData icon,
    required String title,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.white,
        ),
        label: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
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
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.brown.shade900,

      // ----------------------------------------------------------
      // APP BAR
      // ----------------------------------------------------------

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          'Admin Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // BODY
      // ----------------------------------------------------------

      body: Stack(
        children: [
          // BACKGROUND
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // BACKGROUND BLUR
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 5,
                sigmaY: 5,
              ),
              child: Container(
                color: Colors.black.withOpacity(0.35),
              ),
            ),
          ),

          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : RefreshIndicator(
                    color: Colors.brown,
                    onRefresh: _loadAdminProfile,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        18,
                        15,
                        18,
                        30,
                      ),
                      child: Column(
                        children: [
                          // ==================================================
                          // ADMIN HEADER
                          // ==================================================

                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 8,
                                sigmaY: 8,
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 25,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.22),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // SCHOOL LOGO
                                    Container(
                                      height: 100,
                                      width: 100,
                                      padding: const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.18),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.55),
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: Image.asset(
                                          'assets/images/logo.jpg',
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.school,
                                              color: Colors.white,
                                              size: 52,
                                            );
                                          },
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 15),

                                    Text(
                                      _getName(),
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 21,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      _getEmail(),
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.72),
                                      ),
                                    ),

                                    const SizedBox(height: 13),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.brown,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _getAdminType(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // ==================================================
                          // ADMIN INFORMATION
                          // ==================================================

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'ADMIN INFORMATION',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          _glassTile(
                            onTap: _showAdminInformation,
                            child: Row(
                              children: [
                                Container(
                                  height: 48,
                                  width: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.admin_panel_settings_outlined,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ),

                                const SizedBox(width: 14),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Administrator Details',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Name, email, role, phone & type',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color:
                                              Colors.white.withOpacity(0.65),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white70,
                                  size: 28,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 22),

                          // ==================================================
                          // ACTIONS
                          // ==================================================

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'ACCOUNT ACTIONS',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // ADD ADMIN
                          _actionButton(
                            icon: Icons.person_add_alt_1,
                            title: 'Add Admin',
                            onPressed: _addAdmin,
                          ),

                          const SizedBox(height: 12),

                          // EDIT
                          _actionButton(
                            icon: Icons.edit_outlined,
                            title: 'Edit Profile',
                            onPressed: _editProfile,
                          ),

                          const SizedBox(height: 12),

                          // CHANGE PASSWORD
                          _actionButton(
                            icon: Icons.lock_reset,
                            title: 'Change Password',
                            onPressed: _changePassword,
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}