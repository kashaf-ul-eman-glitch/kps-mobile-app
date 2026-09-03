import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class AddTeacherScreen extends StatefulWidget {
  const AddTeacherScreen({
    super.key,
    this.teacherId,
    this.existingTeacher,
  });

  final String? teacherId;
  final Map<String, dynamic>? existingTeacher;

  bool get isEditing => teacherId != null;

  @override
  State<AddTeacherScreen> createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<AddTeacherScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController employeeIdController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController qualificationController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController classController = TextEditingController();

  String selectedGender = 'Male';
  String selectedRole = 'Subject Teacher';

  bool isSaving = false;

  // ============================================================
  // DEFAULT PASSWORD FOR NEWLY CREATED TEACHER LOGINS
  // Teacher will use this password for their FIRST login only.
  // They can change it later from their own dashboard
  // (via FirebaseAuth.instance.currentUser.updatePassword()).
  // ============================================================
  static const String defaultTeacherPassword = 'Teacher@123';

  @override
  void initState() {
    super.initState();

    if (widget.existingTeacher != null) {
      final teacher = widget.existingTeacher!;

      nameController.text =
          teacher['fullName']?.toString() ?? teacher['name']?.toString() ?? '';

      employeeIdController.text = teacher['employeeId']?.toString() ??
          teacher['teacherId']?.toString() ??
          '';

      emailController.text = teacher['email']?.toString() ?? '';

      phoneController.text = teacher['phone']?.toString() ?? '';

      qualificationController.text =
          teacher['qualification']?.toString() ?? '';

      subjectController.text = teacher['subject']?.toString() ??
          teacher['department']?.toString() ??
          '';

      classController.text = teacher['className']?.toString() ?? '';

      selectedGender = teacher['gender']?.toString() ?? 'Male';

      selectedRole = teacher['role']?.toString() ??
          teacher['designation']?.toString() ??
          'Subject Teacher';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    employeeIdController.dispose();
    emailController.dispose();
    phoneController.dispose();
    qualificationController.dispose();
    subjectController.dispose();
    classController.dispose();

    super.dispose();
  }

  // ============================================================
  // CREATE FIREBASE AUTH ACCOUNT FOR TEACHER (SECONDARY APP)
  //
  // We use a SECONDARY FirebaseApp instance here on purpose.
  // If we used FirebaseAuth.instance directly, creating a new
  // user automatically signs that new user in on this device,
  // which would kick the currently logged-in admin out of
  // their own session. The secondary app avoids that completely.
  //
  // Returns the new user's UID on success, or null on failure
  // (and shows an appropriate message).
  // ============================================================

  Future<String?> _createAuthAccountForTeacher(String email) async {
    FirebaseApp secondaryApp;

    try {
      secondaryApp = Firebase.app('TeacherCreationApp');
    } catch (_) {
      secondaryApp = await Firebase.initializeApp(
        name: 'TeacherCreationApp',
        options: Firebase.app().options,
      );
    }

    final FirebaseAuth secondaryAuth =
        FirebaseAuth.instanceFor(app: secondaryApp);

    try {
      final UserCredential credential =
          await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: defaultTeacherPassword,
      );

      return credential.user?.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showMessage(
          'A login account with this email already exists.',
        );
      } else if (e.code == 'invalid-email') {
        _showMessage(
          'Please enter a valid email address.',
        );
      } else if (e.code == 'weak-password') {
        _showMessage(
          'Default password is not accepted by Firebase. Contact admin.',
        );
      } else {
        _showMessage(
          'Could not create teacher login: ${e.message}',
        );
      }
      return null;
    } catch (e) {
      _showMessage(
        'Could not create teacher login: $e',
      );
      return null;
    } finally {
      // Sign out of the secondary app so it never stays "logged in"
      // and clean it up so the next call starts fresh.
      await secondaryAuth.signOut();
      await secondaryApp.delete();
    }
  }

  // ============================================================
  // SAVE TEACHER
  // ============================================================

  Future<void> saveTeacher() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final String employeeId = employeeIdController.text.trim();
      final String email = emailController.text.trim().toLowerCase();

      // ========================================================
      // CHECK DUPLICATE EMPLOYEE ID
      // ========================================================

      final employeeQuery = await FirebaseFirestore.instance
          .collection('teachers')
          .where(
            'employeeId',
            isEqualTo: employeeId,
          )
          .limit(2)
          .get();

      final duplicateEmployeeId = employeeQuery.docs.any(
        (doc) => !widget.isEditing || doc.id != widget.teacherId,
      );

      if (duplicateEmployeeId) {
        if (!mounted) return;

        setState(() {
          isSaving = false;
        });

        _showMessage(
          'Employee ID already exists. Please use a different Employee ID.',
        );

        return;
      }

      // ========================================================
      // CHECK DUPLICATE EMAIL
      // ========================================================

      final emailQuery = await FirebaseFirestore.instance
          .collection('teachers')
          .where(
            'email',
            isEqualTo: email,
          )
          .limit(2)
          .get();

      final duplicateEmail = emailQuery.docs.any(
        (doc) => !widget.isEditing || doc.id != widget.teacherId,
      );

      if (duplicateEmail) {
        if (!mounted) return;

        setState(() {
          isSaving = false;
        });

        _showMessage(
          'This email is already assigned to another teacher.',
        );

        return;
      }

      // ========================================================
      // TEACHER DATA (Includes field mappings for profile screen)
      // ========================================================

      final Map<String, dynamic> teacherData = {
        'fullName': nameController.text.trim(),
        'name': nameController.text.trim(),
        'employeeId': employeeId,
        'teacherId': employeeId,
        'email': email,
        'phone': phoneController.text.trim(),
        'gender': selectedGender,
        'qualification': qualificationController.text.trim(),
        'subject': subjectController.text.trim(),
        'department': subjectController.text.trim(),
        'className': classController.text.trim(),
        'role': selectedRole,
        'designation': selectedRole,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // ========================================================
      // EDIT EXISTING TEACHER
      // (Auth account already exists from when teacher was
      // first added, so we do NOT touch Firebase Auth here.
      // Note: if the email is changed here, the Auth login
      // email will NOT automatically update — that requires
      // either the teacher themselves updating it while signed
      // in, or an admin backend/Cloud Function.)
      // ========================================================

      if (widget.isEditing) {
        await FirebaseFirestore.instance
            .collection('teachers')
            .doc(widget.teacherId)
            .update(teacherData);

        if (!mounted) return;

        _showMessage(
          'Teacher updated successfully.',
        );

        Navigator.pop(context);
        return;
      }

      // ========================================================
      // ADD NEW TEACHER -> CREATE AUTH LOGIN FIRST
      // ========================================================

      final String? uid = await _createAuthAccountForTeacher(email);

      if (uid == null) {
        if (!mounted) return;

        setState(() {
          isSaving = false;
        });

        return; // message already shown inside _createAuthAccountForTeacher
      }

      teacherData['createdAt'] = FieldValue.serverTimestamp();
      teacherData['uid'] = uid;
      teacherData['mustChangePassword'] = true;

      // Document ID = Auth UID, so the teacher dashboard can fetch
      // this profile directly using FirebaseAuth.instance.currentUser!.uid
      await FirebaseFirestore.instance
          .collection('teachers')
          .doc(uid)
          .set(teacherData);

      if (!mounted) return;

      _showMessage(
        'Teacher added! Login email: $email | Default password: $defaultTeacherPassword',
      );

      Navigator.pop(context);
    } on FirebaseException catch (e) {
      if (!mounted) return;

      _showMessage(
        'Firestore error: ${e.message ?? 'Unable to save teacher.'}',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to save teacher: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: Column(
                children: [
                  // ==================================================
                  // TOP BAR
                  // ==================================================

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: isSaving
                              ? null
                              : () {
                                  Navigator.pop(
                                    context,
                                  );
                                },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.isEditing
                                ? 'Edit Teacher'
                                : 'Add Teacher',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // ==================================================
                  // FORM
                  // ==================================================

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        10,
                        20,
                        30,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(
                                  alpha: 0.15,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white24,
                                ),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 55,
                              ),
                            ),
                            const SizedBox(height: 25),

                            if (!widget.isEditing)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: Colors.white70,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'A login account will be created for this '
                                        'teacher automatically with the password '
                                        '"$defaultTeacherPassword". They should change '
                                        'it after their first login.',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // =================================================
                            // PERSONAL INFORMATION
                            // =================================================

                            _glassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _sectionTitle(
                                    'Personal Information',
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  _buildTextField(
                                    controller: nameController,
                                    label: 'Full Name',
                                    hint: 'Enter teacher name',
                                    icon: Icons.person_outline,
                                    maxLength: 50,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(
                                          r'[a-zA-Z\s]',
                                        ),
                                      ),
                                    ],
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter teacher name';
                                      }
                                      if (value.trim().length < 2) {
                                        return 'Name must be at least 2 characters';
                                      }
                                      if (value.trim().length > 50) {
                                        return 'Name cannot exceed 50 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: 18,
                                  ),
                                  _buildTextField(
                                    controller: employeeIdController,
                                    label: 'Employee ID',
                                    hint: 'e.g. T-001',
                                    icon: Icons.badge_outlined,
                                    maxLength: 20,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(
                                          r'[a-zA-Z0-9\-]',
                                        ),
                                      ),
                                    ],
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter employee ID';
                                      }
                                      if (value.trim().length < 2) {
                                        return 'Employee ID must be at least 2 characters';
                                      }
                                      if (value.trim().length > 20) {
                                        return 'Employee ID cannot exceed 20 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: 18,
                                  ),
                                  _buildTextField(
                                    controller: emailController,
                                    label: 'Email',
                                    hint: 'teacher@example.com',
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    maxLength: 50,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter email';
                                      }
                                      final emailRegex = RegExp(
                                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                      );
                                      if (!emailRegex.hasMatch(
                                        value.trim(),
                                      )) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: 18,
                                  ),
                                  _buildTextField(
                                    controller: phoneController,
                                    label: 'Phone Number',
                                    hint: '03XXXXXXXXX',
                                    icon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone,
                                    maxLength: 11,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(
                                        11,
                                      ),
                                    ],
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter phone number';
                                      }
                                      if (value.trim().length != 11) {
                                        return 'Phone number must contain exactly 11 digits';
                                      }
                                      if (!value.startsWith(
                                        '03',
                                      )) {
                                        return 'Phone number must start with 03';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: 18,
                                  ),
                                  _buildDropdown(
                                    label: 'Gender',
                                    icon: Icons.people_outline,
                                    value: selectedGender,
                                    items: const [
                                      'Male',
                                      'Female',
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedGender = value!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              height: 20,
                            ),

                            // =================================================
                            // PROFESSIONAL INFORMATION
                            // =================================================

                            _glassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _sectionTitle(
                                    'Professional Information',
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  _buildTextField(
                                    controller: qualificationController,
                                    label: 'Qualification',
                                    hint: 'e.g. M.Sc Mathematics',
                                    icon: Icons.school_outlined,
                                    maxLength: 20,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter qualification';
                                      }
                                      if (value.trim().length < 2) {
                                        return 'Qualification must be at least 2 characters';
                                      }
                                      if (value.trim().length > 20) {
                                        return 'Qualification cannot exceed 20 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: 18,
                                  ),
                                  _buildTextField(
                                    controller: subjectController,
                                    label: 'Subject',
                                    hint: 'e.g. Mathematics',
                                    icon: Icons.menu_book_outlined,
                                    maxLength: 15,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter subject';
                                      }
                                      if (value.trim().length < 2) {
                                        return 'Subject must be at least 2 characters';
                                      }
                                      if (value.trim().length > 15) {
                                        return 'Subject cannot exceed 15 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: 18,
                                  ),
                                  _buildTextField(
                                    controller: classController,
                                    label: 'Class',
                                    hint: 'e.g. Grade 8',
                                    icon: Icons.class_outlined,
                                    maxLength: 15,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter class';
                                      }
                                      if (value.trim().length < 2) {
                                        return 'Class must be at least 2 characters';
                                      }
                                      if (value.trim().length > 15) {
                                        return 'Class cannot exceed 15 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: 18,
                                  ),
                                  _buildDropdown(
                                    label: 'Role',
                                    icon: Icons.badge_outlined,
                                    value: selectedRole,
                                    items: const [
                                      'Class Teacher',
                                      'Subject Teacher',
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedRole = value!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              height: 30,
                            ),

                            // =================================================
                            // SAVE BUTTON
                            // =================================================

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: isSaving ? null : saveTeacher,
                                icon: isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Icon(
                                        widget.isEditing
                                            ? Icons.edit
                                            : Icons.save_outlined,
                                      ),
                                label: Text(
                                  isSaving
                                      ? 'Saving...'
                                      : widget.isEditing
                                          ? 'Update Teacher'
                                          : 'Save Teacher',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.brown,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      15,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // =================================================
                            // CANCEL
                            // =================================================

                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: isSaving
                                    ? null
                                    : () {
                                        Navigator.pop(
                                          context,
                                        );
                                      },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  side: const BorderSide(
                                    color: Colors.white70,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      15,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _glassCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.15,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white24,
        ),
      ),
      child: child,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: GoogleFonts.poppins(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.poppins(
          color: Colors.white70,
        ),
        hintStyle: GoogleFonts.poppins(
          color: Colors.white38,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.white70,
        ),
        filled: true,
        fillColor: Colors.white.withValues(
          alpha: 0.10,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.white24,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.white,
            width: 1.5,
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
            width: 1.5,
          ),
        ),
        counterStyle: GoogleFonts.poppins(
          color: Colors.white54,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      dropdownColor: Colors.brown.shade800,
      style: GoogleFonts.poppins(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.white70,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.white70,
        ),
        filled: true,
        fillColor: Colors.white.withValues(
          alpha: 0.10,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.white24,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.white,
            width: 1.5,
          ),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }
}