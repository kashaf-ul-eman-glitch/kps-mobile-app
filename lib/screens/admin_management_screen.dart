import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ------------------------------------------------------------
  // DEFAULT PASSWORD FOR SUB-ADMINS CREATED BY MAIN ADMIN
  // (Main Admin sets their own password during the Setup form.)
  // ------------------------------------------------------------

  static const String _defaultAdminPassword = 'Admin@123';

  // Whoever is currently viewing this screen — used to show/hide
  // "Add Administrator", "My Profile" edit, etc. Re-checked with
  // _checkMainAdminAccess() before every actual write, too.
  bool? _viewerIsMainAdmin;

  @override
  void initState() {
    super.initState();
    _loadViewerRole();
  }

  Future<void> _loadViewerRole() async {
    final result = await _isMainAdmin();
    if (mounted) {
      setState(() => _viewerIsMainAdmin = result);
    }
  }

  // ------------------------------------------------------------
  // MAIN ADMIN CHECK
  // ------------------------------------------------------------

  Future<bool> _isMainAdmin() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return false;
      }

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        return false;
      }

      final data = doc.data();

      if (data == null) {
        return false;
      }

      return data['isMainAdmin'] == true &&
          data['role'] == 'Administrator' &&
          data['isActive'] == true;
    } catch (e) {
      return false;
    }
  }

  // ------------------------------------------------------------
  // COLORS
  // ------------------------------------------------------------

  final Color _brown = const Color(0xFF795548);
  final Color _lightBrown = const Color(0xFF8D6E63);

  // ------------------------------------------------------------
  // PERMISSIONS
  // ------------------------------------------------------------

  final Map<String, String> _permissionLabels = {
    'teacherManagement': 'Teacher Management',
    'subjectManagement': 'Subject Management',
    'dateSheet': 'Date Sheet',
    'admissionForm': 'Admission Form',
    'feeManagement': 'Fee Management',
    'attendance': 'Attendance',
    'academicCalendar': 'Academic Calendar',
    'notifications': 'Notifications',
    'complaints': 'Complaints',
    'aboutApp': 'About App',
  };

  Map<String, bool> _defaultPermissions() {
    return {
      'teacherManagement': false,
      'subjectManagement': false,
      'dateSheet': false,
      'admissionForm': false,
      'feeManagement': false,
      'attendance': false,
      'academicCalendar': false,
      'notifications': false,
      'complaints': false,
      'aboutApp': true,
    };
  }

  Map<String, bool> _allPermissionsGranted() {
    return {
      for (final key in _permissionLabels.keys) key: true,
    };
  }

  // ------------------------------------------------------------
  // CLASS RANGE OPTIONS (same list used across the app, e.g. in
  // Manage Timetable) — Main Admin assigns a subset of these to
  // each sub-admin, e.g. "Play Group – Reception 1" or
  // "Grade 6 – Grade 8".
  // ------------------------------------------------------------

  static const List<String> _classOptions = [
    'Play Group',
    'Reception 1',
    'Reception 2',
    'Grade 1',
    'Grade 2',
    'Grade 3',
    'Grade 4',
    'Grade 5',
    'Grade 6',
    'Grade 7',
    'Grade 8',
    'Grade 9',
    'Grade 10',
    'Grade 11',
    'Grade 12',
  ];

  // ------------------------------------------------------------
  // CHECK MAIN ADMIN ACCESS (gate for every write action)
  // ------------------------------------------------------------

  Future<bool> _checkMainAdminAccess() async {
    final allowed = await _isMainAdmin();

    if (!allowed && mounted) {
      _showMessage(
        'Only Main Admin can perform this action.',
        isError: true,
      );
    }

    return allowed;
  }

  // ------------------------------------------------------------
  // MESSAGE
  // ------------------------------------------------------------

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
        backgroundColor:
            isError ? Colors.red.shade700 : _brown,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // NEXT ADMIN NUMBER
  // ------------------------------------------------------------

  Future<int> _getNextAdminNumber() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'Administrator')
        .get();

    int highestNumber = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final adminType =
          (data['adminType'] ?? '').toString().trim();

      if (adminType.toLowerCase() == 'main admin' ||
          adminType.toLowerCase() == 'main administrator') {
        continue;
      }

      final match = RegExp(
        r'^Admin\s+(\d+)$',
        caseSensitive: false,
      ).firstMatch(adminType);

      if (match != null) {
        final number = int.tryParse(match.group(1)!);

        if (number != null && number > highestNumber) {
          highestNumber = number;
        }
      }
    }

    return highestNumber + 1;
  }

  // ============================================================
  // FIREBASE AUTH ACCOUNT CREATION (SECONDARY APP)
  //
  // Used for BOTH the Main Admin setup form and for sub-admins
  // added later. A secondary FirebaseApp instance is used so
  // that creating this new login never signs out whoever is
  // currently using the app.
  // ============================================================

  Future<String?> _createAuthAccount({
    required String email,
    required String password,
  }) async {
    FirebaseApp secondaryApp;

    try {
      secondaryApp = Firebase.app('AdminCreationApp');
    } catch (_) {
      secondaryApp = await Firebase.initializeApp(
        name: 'AdminCreationApp',
        options: Firebase.app().options,
      );
    }

    final FirebaseAuth secondaryAuth =
        FirebaseAuth.instanceFor(app: secondaryApp);

    try {
      final credential =
          await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return credential.user?.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showMessage(
          'A login account with this email already exists.',
          isError: true,
        );
      } else if (e.code == 'invalid-email') {
        _showMessage(
          'Please enter a valid email address.',
          isError: true,
        );
      } else if (e.code == 'weak-password') {
        _showMessage(
          'Password is too weak. Use at least 6 characters.',
          isError: true,
        );
      } else {
        _showMessage(
          'Could not create login: ${e.message}',
          isError: true,
        );
      }
      return null;
    } catch (e) {
      _showMessage(
        'Could not create login: $e',
        isError: true,
      );
      return null;
    } finally {
      await secondaryAuth.signOut();
      await secondaryApp.delete();
    }
  }

  // ============================================================
  // MAIN ADMIN SETUP (BOOTSTRAP — only shown when no Main Admin
  // exists yet in the whole 'users' collection)
  // ============================================================

  void _showAddMainAdminDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isSaving = false;
        bool obscurePassword = true;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return _glassDialog(
              title: 'Create Main Admin',
              icon: Icons.shield_outlined,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'This creates the ONE Main Admin account for the '
                          'whole app. It can only be done once.',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _glassTextField(
                  controller: nameController,
                  label: 'Name',
                  hint: 'Enter your full name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 14),
                _glassTextField(
                  controller: emailController,
                  label: 'Email',
                  hint: 'Enter your email address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                _glassTextField(
                  controller: phoneController,
                  label: 'Phone',
                  hint: '03XXXXXXXXX',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                _glassTextField(
                  controller: passwordController,
                  label: 'Password',
                  hint: 'At least 6 characters',
                  icon: Icons.lock_outline,
                  obscureText: obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white70,
                      size: 19,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 14),
                _glassTextField(
                  controller: confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Re-enter password',
                  icon: Icons.lock_outline,
                  obscureText: obscurePassword,
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _brownButton(
                        text: 'Cancel',
                        onPressed: isSaving
                            ? null
                            : () => Navigator.pop(dialogContext),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _brownButton(
                        text: isSaving ? 'Creating...' : 'Create Main Admin',
                        icon: Icons.check_circle_outline,
                        onPressed: isSaving
                            ? null
                            : () async {
                                final name = nameController.text.trim();
                                final email =
                                    emailController.text.trim().toLowerCase();
                                final phone = phoneController.text.trim();
                                final password = passwordController.text;
                                final confirmPassword =
                                    confirmPasswordController.text;

                                if (name.isEmpty ||
                                    email.isEmpty ||
                                    phone.isEmpty ||
                                    password.isEmpty) {
                                  _showMessage(
                                    'Please fill all fields.',
                                    isError: true,
                                  );
                                  return;
                                }

                                if (password.length < 6) {
                                  _showMessage(
                                    'Password must be at least 6 characters.',
                                    isError: true,
                                  );
                                  return;
                                }

                                if (password != confirmPassword) {
                                  _showMessage(
                                    'Passwords do not match.',
                                    isError: true,
                                  );
                                  return;
                                }

                                setDialogState(() => isSaving = true);

                                try {
                                  // Safety re-check: make sure a Main
                                  // Admin was not created moments ago.
                                  final existing = await _firestore
                                      .collection('users')
                                      .where(
                                        'isMainAdmin',
                                        isEqualTo: true,
                                      )
                                      .limit(1)
                                      .get();

                                  if (existing.docs.isNotEmpty) {
                                    _showMessage(
                                      'A Main Admin already exists.',
                                      isError: true,
                                    );
                                    if (dialogContext.mounted) {
                                      Navigator.pop(dialogContext);
                                    }
                                    return;
                                  }

                                  final uid = await _createAuthAccount(
                                    email: email,
                                    password: password,
                                  );

                                  if (uid == null) {
                                    if (dialogContext.mounted) {
                                      setDialogState(() => isSaving = false);
                                    }
                                    return;
                                  }

                                  await _firestore
                                      .collection('users')
                                      .doc(uid)
                                      .set({
                                    'name': name,
                                    'email': email,
                                    'phone': phone,
                                    'role': 'Administrator',
                                    'adminType': 'Main Admin',
                                    'isMainAdmin': true,
                                    'isActive': true,
                                    'permissions': _allPermissionsGranted(),
                                    'assignedClasses': _classOptions,
                                    'createdAt': FieldValue.serverTimestamp(),
                                    'updatedAt': FieldValue.serverTimestamp(),
                                  });

                                  if (!mounted) return;

                                  if (dialogContext.mounted) {
                                    Navigator.pop(dialogContext);
                                  }

                                  _showMessage(
                                    'Main Admin created! Please log in with '
                                    '$email to continue.',
                                  );
                                } catch (e) {
                                  if (dialogContext.mounted) {
                                    setDialogState(() => isSaving = false);
                                  }
                                  _showMessage(
                                    'Failed to create Main Admin: $e',
                                    isError: true,
                                  );
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ------------------------------------------------------------
  // ADD SUB-ADMIN (Main Admin only)
  // ------------------------------------------------------------

  Future<void> _addAdmin({
    required String name,
    required String email,
    required String phone,
    required List<String> assignedClasses,
  }) async {
    try {
      final allowed = await _checkMainAdminAccess();

      if (!allowed) return;

      if (name.trim().isEmpty ||
          email.trim().isEmpty ||
          phone.trim().isEmpty) {
        _showMessage(
          'Please fill all fields.',
          isError: true,
        );
        return;
      }

      final normalizedEmail = email.trim().toLowerCase();

      // Check duplicate email.
      final duplicateEmail = await _firestore
          .collection('users')
          .where(
            'email',
            isEqualTo: normalizedEmail,
          )
          .limit(1)
          .get();

      if (duplicateEmail.docs.isNotEmpty) {
        _showMessage(
          'An admin with this email already exists.',
          isError: true,
        );
        return;
      }

      final nextNumber = await _getNextAdminNumber();
      final adminType = 'Admin $nextNumber';

      // Create the login account first.
      final uid = await _createAuthAccount(
        email: normalizedEmail,
        password: _defaultAdminPassword,
      );

      if (uid == null) {
        return; // message already shown
      }

      await _firestore.collection('users').doc(uid).set({
        'name': name.trim(),
        'email': normalizedEmail,
        'phone': phone.trim(),
        'role': 'Administrator',
        'adminType': adminType,
        'isMainAdmin': false,
        'isActive': true,
        'permissions': _defaultPermissions(),
        'assignedClasses': assignedClasses,
        'mustChangePassword': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pop(context);

      _showMessage(
        '$adminType added! Login email: $normalizedEmail | '
        'Default password: $_defaultAdminPassword',
      );
    } on FirebaseException catch (e) {
      _showMessage(
        'Failed to add admin: ${e.message ?? e.code}',
        isError: true,
      );
    } catch (e) {
      _showMessage(
        'Failed to add admin.',
        isError: true,
      );
    }
  }

  // ------------------------------------------------------------
  // ADD ADMIN DIALOG
  // ------------------------------------------------------------

  void _showAddAdminDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final Set<String> selectedClasses = {};

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return _glassDialog(
              title: 'Add Administrator',
              icon: Icons.person_add_alt_1,
              children: [
                _glassTextField(
                  controller: nameController,
                  label: 'Name',
                  hint: 'Enter administrator name',
                  icon: Icons.person_outline,
                ),

                const SizedBox(height: 14),

                _glassTextField(
                  controller: emailController,
                  label: 'Email',
                  hint: 'Enter email address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 14),

                _glassTextField(
                  controller: phoneController,
                  label: 'Phone',
                  hint: '03XXXXXXXXX',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 18),

                Text(
                  'Assign Classes',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Which classes/grades will this admin manage?',
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 10),

                _classChipSelector(
                  selectedClasses: selectedClasses,
                  onToggle: (className, selected) {
                    setDialogState(() {
                      if (selected) {
                        selectedClasses.add(className);
                      } else {
                        selectedClasses.remove(className);
                      }
                    });
                  },
                ),

                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.admin_panel_settings_outlined,
                        color: Colors.white,
                        size: 21,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Admin number & login account will be created '
                          'automatically with a default password.',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: _brownButton(
                        text: 'Cancel',
                        onPressed: isSaving
                            ? null
                            : () => Navigator.pop(dialogContext),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _brownButton(
                        text: isSaving ? 'Saving...' : 'Add Admin',
                        icon: Icons.add,
                        onPressed: isSaving
                            ? null
                            : () async {
                                setDialogState(() {
                                  isSaving = true;
                                });

                                await _addAdmin(
                                  name: nameController.text,
                                  email: emailController.text,
                                  phone: phoneController.text,
                                  assignedClasses: selectedClasses.toList(),
                                );

                                if (dialogContext.mounted) {
                                  setDialogState(() {
                                    isSaving = false;
                                  });
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ------------------------------------------------------------
  // CHANGE STATUS
  // ------------------------------------------------------------

  Future<void> _changeAdminStatus({
    required String documentId,
    required String adminType,
    required bool makeActive,
  }) async {
    try {
      final allowed = await _checkMainAdminAccess();

      if (!allowed) return;

      final currentUser = _auth.currentUser;

      if (currentUser == null) {
        _showMessage(
          'You are not logged in.',
          isError: true,
        );
        return;
      }

      // Never allow Main Admin to deactivate itself.
      if (documentId == currentUser.uid) {
        _showMessage(
          'Main Admin cannot be deactivated.',
          isError: true,
        );
        return;
      }

      await _firestore
          .collection('users')
          .doc(documentId)
          .set(
        {
          'isActive': makeActive,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      _showMessage(
        '$adminType has been '
        '${makeActive ? 'activated' : 'deactivated'}.',
      );
    } on FirebaseException catch (e) {
      _showMessage(
        'Unable to change status: ${e.message ?? e.code}',
        isError: true,
      );
    } catch (e) {
      _showMessage(
        'Unable to change administrator status.',
        isError: true,
      );
    }
  }

  // ------------------------------------------------------------
  // DELETE ADMIN
  // ------------------------------------------------------------

  Future<void> _deleteAdmin({
    required String documentId,
    required String adminType,
    required bool isMainAdminDoc,
  }) async {
    if (isMainAdminDoc) {
      _showMessage(
        'Main Admin account cannot be deleted.',
        isError: true,
      );
      return;
    }

    final allowed = await _checkMainAdminAccess();
    if (!allowed) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete $adminType?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'This removes their profile and permissions. Their login '
            'account may need to be removed separately by a developer.',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: _brown),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _firestore.collection('users').doc(documentId).delete();

      _showMessage('$adminType deleted successfully.');
    } on FirebaseException catch (e) {
      _showMessage(
        'Failed to delete: ${e.message ?? e.code}',
        isError: true,
      );
    } catch (e) {
      _showMessage(
        'Failed to delete administrator.',
        isError: true,
      );
    }
  }

  // ------------------------------------------------------------
  // EDIT ADMIN (also used for Main Admin editing their own profile)
  // ------------------------------------------------------------

  void _showEditAdminDialog({
    required String documentId,
    required Map<String, dynamic> data,
    bool isSelfEdit = false,
  }) {
    final nameController = TextEditingController(
      text: (data['name'] ?? '').toString(),
    );

    final phoneController = TextEditingController(
      text: (data['phone'] ?? '').toString(),
    );

    final email =
        (data['email'] ?? '').toString();

    final adminType =
        (data['adminType'] ?? 'Administrator').toString();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return _glassDialog(
              title: isSelfEdit ? 'Edit My Profile' : 'Edit $adminType',
              icon: Icons.edit_outlined,
              children: [
                _glassTextField(
                  controller: nameController,
                  label: 'Name',
                  icon: Icons.person_outline,
                ),

                const SizedBox(height: 14),

                _glassTextField(
                  controller: TextEditingController(text: email),
                  label: 'Email',
                  icon: Icons.email_outlined,
                  enabled: false,
                ),

                const SizedBox(height: 14),

                _glassTextField(
                  controller: phoneController,
                  label: 'Phone',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: _brownButton(
                        text: 'Cancel',
                        onPressed: isSaving
                            ? null
                            : () => Navigator.pop(dialogContext),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _brownButton(
                        text: isSaving ? 'Saving...' : 'Save',
                        icon: Icons.save_outlined,
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (nameController.text
                                    .trim()
                                    .isEmpty) {
                                  _showMessage(
                                    'Name cannot be empty.',
                                    isError: true,
                                  );
                                  return;
                                }

                                setDialogState(() {
                                  isSaving = true;
                                });

                                try {
                                  final allowed =
                                      await _checkMainAdminAccess();

                                  if (!allowed) {
                                    if (dialogContext.mounted) {
                                      setDialogState(() {
                                        isSaving = false;
                                      });
                                    }
                                    return;
                                  }

                                  await _firestore
                                      .collection('users')
                                      .doc(documentId)
                                      .set(
                                    {
                                      'name': nameController.text.trim(),
                                      'phone': phoneController.text.trim(),
                                      'updatedAt':
                                          FieldValue.serverTimestamp(),
                                    },
                                    SetOptions(merge: true),
                                  );

                                  if (!dialogContext.mounted) return;

                                  Navigator.pop(dialogContext);

                                  _showMessage(
                                    isSelfEdit
                                        ? 'Profile updated successfully.'
                                        : '$adminType updated successfully.',
                                  );
                                } on FirebaseException catch (e) {
                                  if (dialogContext.mounted) {
                                    setDialogState(() {
                                      isSaving = false;
                                    });
                                  }

                                  _showMessage(
                                    'Failed to update: '
                                    '${e.message ?? e.code}',
                                    isError: true,
                                  );
                                } catch (e) {
                                  if (dialogContext.mounted) {
                                    setDialogState(() {
                                      isSaving = false;
                                    });
                                  }

                                  _showMessage(
                                    'Failed to update administrator.',
                                    isError: true,
                                  );
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ------------------------------------------------------------
  // MANAGE PERMISSIONS
  // ------------------------------------------------------------

  void _showManagePermissionsDialog({
    required String documentId,
    required String adminType,
    required Map<String, dynamic> data,
  }) async {
    final allowed = await _checkMainAdminAccess();

    if (!allowed || !mounted) return;

    final Map<String, bool> permissions = _defaultPermissions();

    final savedPermissions =
        data['permissions'];

    if (savedPermissions is Map) {
      for (final key in permissions.keys) {
        if (savedPermissions.containsKey(key)) {
          permissions[key] =
              savedPermissions[key] == true;
        }
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return _glassDialog(
              title: 'Manage Permissions',
              icon: Icons.security_outlined,
              children: [
                Text(
                  adminType,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Choose which sections this administrator can access.',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 15),

                Container(
                  constraints: const BoxConstraints(
                    maxHeight: 360,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: _permissionLabels.entries.map(
                        (entry) {
                          return Container(
                            margin: const EdgeInsets.only(
                              bottom: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.07),
                              borderRadius:
                                  BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    Colors.white.withValues(alpha: 0.18),
                              ),
                            ),
                            child: SwitchListTile(
                              value: permissions[entry.key] ?? false,
                              activeThumbColor: _brown,
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              title: Text(
                                entry.value,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                              onChanged: isSaving
                                  ? null
                                  : (value) {
                                      setDialogState(() {
                                        permissions[entry.key] =
                                            value;
                                      });
                                    },
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: _brownButton(
                        text: 'Cancel',
                        onPressed: isSaving
                            ? null
                            : () => Navigator.pop(dialogContext),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _brownButton(
                        text: isSaving ? 'Saving...' : 'Save',
                        icon: Icons.save_outlined,
                        onPressed: isSaving
                            ? null
                            : () async {
                                setDialogState(() {
                                  isSaving = true;
                                });

                                try {
                                  final mainAdmin =
                                      await _isMainAdmin();

                                  if (!mainAdmin) {
                                    if (dialogContext.mounted) {
                                      setDialogState(() {
                                        isSaving = false;
                                      });
                                    }

                                    _showMessage(
                                      'Only Main Admin can manage permissions.',
                                      isError: true,
                                    );
                                    return;
                                  }

                                  await _firestore
                                      .collection('users')
                                      .doc(documentId)
                                      .set(
                                    {
                                      'permissions': permissions,
                                      'updatedAt':
                                          FieldValue.serverTimestamp(),
                                    },
                                    SetOptions(merge: true),
                                  );

                                  if (!dialogContext.mounted) return;

                                  Navigator.pop(dialogContext);

                                  _showMessage(
                                    'Permissions updated successfully.',
                                  );
                                } on FirebaseException catch (e) {
                                  if (dialogContext.mounted) {
                                    setDialogState(() {
                                      isSaving = false;
                                    });
                                  }

                                  _showMessage(
                                    'Failed to save permissions: '
                                    '${e.message ?? e.code}',
                                    isError: true,
                                  );
                                } catch (e) {
                                  if (dialogContext.mounted) {
                                    setDialogState(() {
                                      isSaving = false;
                                    });
                                  }

                                  _showMessage(
                                    'Failed to save permissions.',
                                    isError: true,
                                  );
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ------------------------------------------------------------
  // MANAGE CLASSES (which grades/classes this admin looks after)
  // ------------------------------------------------------------

  void _showManageClassesDialog({
    required String documentId,
    required String adminType,
    required Map<String, dynamic> data,
  }) async {
    final allowed = await _checkMainAdminAccess();

    if (!allowed || !mounted) return;

    final Set<String> selectedClasses = {
      if (data['assignedClasses'] is List)
        ...List<String>.from(data['assignedClasses']),
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return _glassDialog(
              title: 'Manage Classes',
              icon: Icons.class_outlined,
              children: [
                Text(
                  adminType,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Choose which classes/grades this administrator manages.',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  constraints: const BoxConstraints(maxHeight: 320),
                  child: SingleChildScrollView(
                    child: _classChipSelector(
                      selectedClasses: selectedClasses,
                      onToggle: (className, selected) {
                        setDialogState(() {
                          if (selected) {
                            selectedClasses.add(className);
                          } else {
                            selectedClasses.remove(className);
                          }
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _brownButton(
                        text: 'Cancel',
                        onPressed: isSaving
                            ? null
                            : () => Navigator.pop(dialogContext),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _brownButton(
                        text: isSaving ? 'Saving...' : 'Save',
                        icon: Icons.save_outlined,
                        onPressed: isSaving
                            ? null
                            : () async {
                                setDialogState(() => isSaving = true);

                                try {
                                  await _firestore
                                      .collection('users')
                                      .doc(documentId)
                                      .set(
                                    {
                                      'assignedClasses':
                                          selectedClasses.toList(),
                                      'updatedAt':
                                          FieldValue.serverTimestamp(),
                                    },
                                    SetOptions(merge: true),
                                  );

                                  if (!dialogContext.mounted) return;
                                  Navigator.pop(dialogContext);

                                  _showMessage(
                                    'Classes updated successfully.',
                                  );
                                } catch (e) {
                                  if (dialogContext.mounted) {
                                    setDialogState(() => isSaving = false);
                                  }
                                  _showMessage(
                                    'Failed to update classes.',
                                    isError: true,
                                  );
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ------------------------------------------------------------
  // CLASS CHIP SELECTOR (shared by Add Admin + Manage Classes)
  // ------------------------------------------------------------

  Widget _classChipSelector({
    required Set<String> selectedClasses,
    required void Function(String className, bool selected) onToggle,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _classOptions.map((className) {
        final bool isSelected = selectedClasses.contains(className);

        return GestureDetector(
          onTap: () => onToggle(className, !isSelected),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? _brown
                  : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? _brown
                    : Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              className,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ------------------------------------------------------------
  // GLASS DIALOG
  // ------------------------------------------------------------

  Widget _glassDialog({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 24,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12,
            sigmaY: 12,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.48),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.30),
                width: 1.2,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: _brown.withValues(alpha: 0.85),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // GLASS TEXT FIELD
  // ------------------------------------------------------------

  Widget _glassTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool enabled = true,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.poppins(
          color: Colors.white70,
          fontSize: 13,
        ),
        hintStyle: GoogleFonts.poppins(
          color: Colors.white38,
          fontSize: 12,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.white70,
          size: 20,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.25),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.65),
            width: 1.2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BROWN BUTTON
  // ------------------------------------------------------------

  Widget _brownButton({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
  }) {
    return SizedBox(
      height: 45,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _brown,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade700,
          disabledForegroundColor: Colors.white60,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
              ),
              const SizedBox(width: 7),
            ],
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // ADMIN CARD (works for both "My Profile" and other admins)
  // ------------------------------------------------------------

  Widget _adminCard({
    required String documentId,
    required Map<String, dynamic> data,
    bool isSelfCard = false,
  }) {
    final name =
        (data['name'] ?? 'Administrator').toString();

    final email =
        (data['email'] ?? 'No email').toString();

    final phone =
        (data['phone'] ?? 'No phone').toString();

    final adminType =
        (data['adminType'] ?? 'Administrator').toString();

    final isActive =
        data['isActive'] != false;

    final bool isMainAdminDoc = data['isMainAdmin'] == true;

    final permissions =
        data['permissions'] is Map
            ? Map<String, dynamic>.from(
                data['permissions'],
              )
            : <String, dynamic>{};

    final permissionCount =
        permissions.values.where(
          (value) => value == true,
        ).length;

    final assignedClasses = data['assignedClasses'] is List
        ? List<String>.from(data['assignedClasses'])
        : <String>[];

    final classesLabel = isMainAdminDoc
        ? 'All classes'
        : assignedClasses.isEmpty
            ? 'No classes assigned'
            : '${assignedClasses.length} classes';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 8,
            sigmaY: 8,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelfCard
                    ? _brown.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.25),
                width: isSelfCard ? 1.4 : 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _brown.withValues(alpha: 0.85),
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                      child: Icon(
                        isMainAdminDoc
                            ? Icons.shield
                            : Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 27,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSelfCard ? '$adminType • You' : adminType,
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            name,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                      ),
                      color: Colors.white,
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditAdminDialog(
                            documentId: documentId,
                            data: data,
                            isSelfEdit: isSelfCard,
                          );
                        }

                        if (value == 'permissions') {
                          _showManagePermissionsDialog(
                            documentId: documentId,
                            adminType: adminType,
                            data: data,
                          );
                        }

                        if (value == 'classes') {
                          _showManageClassesDialog(
                            documentId: documentId,
                            adminType: adminType,
                            data: data,
                          );
                        }

                        if (value == 'status') {
                          _changeAdminStatus(
                            documentId: documentId,
                            adminType: adminType,
                            makeActive: !isActive,
                          );
                        }

                        if (value == 'delete') {
                          _deleteAdmin(
                            documentId: documentId,
                            adminType: adminType,
                            isMainAdminDoc: isMainAdminDoc,
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.edit_outlined,
                                size: 19,
                              ),
                              const SizedBox(width: 9),
                              Text(
                                'Edit',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (!isSelfCard) ...[
                          PopupMenuItem<String>(
                            value: 'permissions',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.security_outlined,
                                  size: 19,
                                ),
                                const SizedBox(width: 9),
                                Text(
                                  'Manage Permissions',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'classes',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.class_outlined,
                                  size: 19,
                                ),
                                const SizedBox(width: 9),
                                Text(
                                  'Manage Classes',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'status',
                            child: Row(
                              children: [
                                Icon(
                                  isActive
                                      ? Icons
                                          .person_off_outlined
                                      : Icons
                                          .person_add_alt_1,
                                  size: 19,
                                ),
                                const SizedBox(width: 9),
                                Text(
                                  isActive
                                      ? 'Deactivate'
                                      : 'Activate',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 19,
                                  color: Colors.red.shade700,
                                ),
                                const SizedBox(width: 9),
                                Text(
                                  'Delete',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Divider(
                  color: Colors.white.withValues(alpha: 0.16),
                  height: 1,
                ),

                const SizedBox(height: 13),

                _infoRow(
                  Icons.email_outlined,
                  email,
                ),

                const SizedBox(height: 8),

                _infoRow(
                  Icons.phone_outlined,
                  phone,
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green.withValues(alpha: 0.18)
                            : Colors.red.withValues(alpha: 0.18),
                        borderRadius:
                            BorderRadius.circular(10),
                        border: Border.all(
                          color: isActive
                              ? Colors.green.withValues(alpha: 0.4)
                              : Colors.red.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isActive
                                ? Icons.check_circle_outline
                                : Icons.cancel_outlined,
                            color: isActive
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            size: 17,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isActive
                                ? 'Active'
                                : 'Inactive',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isMainAdminDoc)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius:
                              BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.lock_outline,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$permissionCount permissions',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius:
                            BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.class_outlined,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            classesLabel,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ],
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
  }

  // ------------------------------------------------------------
  // INFO ROW
  // ------------------------------------------------------------

  Widget _infoRow(
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white60,
          size: 17,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Admin Management',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 5,
                sigmaY: 5,
              ),
              child: Container(
                color: Colors.black.withValues(alpha: 0.25),
              ),
            ),
          ),

          SafeArea(
            child: StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore
                  .collection('users')
                  .where(
                    'role',
                    isEqualTo: 'Administrator',
                  )
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Unable to load administrators.\n\n'
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                }

                final documents =
                    snapshot.data?.docs ?? [];

                QueryDocumentSnapshot<Map<String, dynamic>>? mainAdminDoc;

                for (final document in documents) {
                  if (document.data()['isMainAdmin'] == true) {
                    mainAdminDoc = document;
                    break;
                  }
                }

                // Remove Main Admin from the "other admins" list.
                final otherAdmins =
                    documents.where((document) {
                  final data = document.data();

                  final adminType =
                      (data['adminType'] ?? '')
                          .toString()
                          .trim()
                          .toLowerCase();

                  final isMainAdminEntry =
                      data['isMainAdmin'] == true ||
                      adminType == 'main admin' ||
                      adminType == 'main administrator';

                  return !isMainAdminEntry;
                }).toList();

                final currentUid = _auth.currentUser?.uid;
                final bool viewerIsTheMainAdmin =
                    mainAdminDoc != null && mainAdminDoc.id == currentUid;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    12,
                    16,
                    30,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // HEADER CARD
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 8,
                            sigmaY: 8,
                          ),
                          child: Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withValues(alpha: 0.09),
                              borderRadius:
                                  BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white
                                    .withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: _brown
                                        .withValues(alpha: 0.85),
                                    borderRadius:
                                        BorderRadius.circular(
                                      16,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons
                                        .admin_panel_settings,
                                    color: Colors.white,
                                    size: 29,
                                  ),
                                ),

                                const SizedBox(width: 13),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        'Administrators',
                                        style: GoogleFonts
                                            .poppins(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        'Manage administrator accounts, classes '
                                        'and permissions',
                                        style: GoogleFonts
                                            .poppins(
                                          color:
                                              Colors.white70,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ==================================================
                      // BOOTSTRAP: NO MAIN ADMIN EXISTS YET
                      // ==================================================
                      if (mainAdminDoc == null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: _brown.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _brown.withValues(alpha: 0.6),
                                  width: 1.3,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.shield_outlined,
                                        color: Colors.white,
                                        size: 26,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'No Main Admin set up yet',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Create the Main Admin account first. Only '
                                    'this account will be able to add, edit, '
                                    'delete and manage other administrators.',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: _brownButton(
                                      text: 'Create Main Admin',
                                      icon: Icons.shield_outlined,
                                      onPressed: _showAddMainAdminDialog,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ==================================================
                      // MY PROFILE (only shown to the logged-in Main Admin)
                      // ==================================================
                      if (mainAdminDoc != null && viewerIsTheMainAdmin) ...[
                        Text(
                          'My Profile',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _adminCard(
                          documentId: mainAdminDoc.id,
                          data: mainAdminDoc.data(),
                          isSelfCard: true,
                        ),
                        const SizedBox(height: 10),
                      ],

                      // ==================================================
                      // ADD ADMIN BUTTON (Main Admin only)
                      // ==================================================
                      if (mainAdminDoc != null &&
                          _viewerIsMainAdmin == true) ...[
                        SizedBox(
                          width: double.infinity,
                          child: _brownButton(
                            text: 'Add Administrator',
                            icon: Icons.person_add_alt_1,
                            onPressed: _showAddAdminDialog,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      if (mainAdminDoc != null) ...[
                        Text(
                          'Other Administrators',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 10),

                        if (otherAdmins.isEmpty)
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(18),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 8,
                                sigmaY: 8,
                              ),
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.all(25),
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withValues(alpha: 0.08),
                                  borderRadius:
                                      BorderRadius.circular(
                                    18,
                                  ),
                                  border: Border.all(
                                    color: Colors.white
                                        .withValues(alpha: 0.20),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons
                                          .admin_panel_settings_outlined,
                                      color: Colors.white60,
                                      size: 42,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'No other administrators added yet.',
                                      textAlign:
                                          TextAlign.center,
                                      style:
                                          GoogleFonts.poppins(
                                        color:
                                            Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          ...otherAdmins.map(
                            (document) => _adminCard(
                              documentId: document.id,
                              data: document.data(),
                            ),
                          ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}