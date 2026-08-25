import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

/// =====================================================================
/// ADMISSION FORM SCREEN
/// =====================================================================
/// Data is stored classwise at:  classes/{className}/students/{autoId}
/// Every document also carries a `parentUid` field so:
///   - Parents can query (collectionGroup) their own children only.
///   - Admin can browse class-by-class OR run a collectionGroup query
///     across every class to see all admissions in one place.
/// See the matching `firestore.rules` file for the security rules that
/// make sure a parent can ONLY read documents where parentUid == their
/// own uid, while admins can read everything.
/// =====================================================================
class AdmissionFormScreen extends StatefulWidget {
  const AdmissionFormScreen({super.key});

  @override
  State<AdmissionFormScreen> createState() => _AdmissionFormScreenState();
}

class _AdmissionFormScreenState extends State<AdmissionFormScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  final formKey = GlobalKey<FormState>();

  // ---------------- Student fields ----------------
  final TextEditingController admissionNoController = TextEditingController();
  final TextEditingController registrationNoController =
      TextEditingController();
  final TextEditingController studentNameController =
      TextEditingController(); // Candidate name in full
  final TextEditingController rollNoController = TextEditingController();
  final TextEditingController religionController = TextEditingController();
  final TextEditingController casteController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController dobWordsController = TextEditingController();
  final TextEditingController previousInstitutionController =
      TextEditingController(); // institution + class attended + medium

  DateTime? dobDate; // Date of birth in figure

  String? selectedClass; // Class in which admission is sought
  String? selectedSection;

  final List<String> classList = [
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

  final List<String> sectionList = ['Section A', 'Section B', 'Section C'];

  // ---------------- Family fields ----------------
  final TextEditingController familyNameController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController fatherAddressController =
      TextEditingController(); // Father's present address
  final TextEditingController fatherPhoneController = TextEditingController();

  final TextEditingController motherNameController = TextEditingController();

  final TextEditingController guardianNameController =
      TextEditingController();
  final TextEditingController guardianAddressController =
      TextEditingController();
  final TextEditingController guardianPhoneController =
      TextEditingController();

  final TextEditingController permanentAddressController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();

  File? _pickedImage;
  bool _saving = false;

  @override
  void dispose() {
    admissionNoController.dispose();
    registrationNoController.dispose();
    studentNameController.dispose();
    rollNoController.dispose();
    religionController.dispose();
    casteController.dispose();
    nationalityController.dispose();
    dobWordsController.dispose();
    previousInstitutionController.dispose();

    familyNameController.dispose();
    fatherNameController.dispose();
    occupationController.dispose();
    cnicController.dispose();
    fatherAddressController.dispose();
    fatherPhoneController.dispose();
    motherNameController.dispose();
    guardianNameController.dispose();
    guardianAddressController.dispose();
    guardianPhoneController.dispose();
    permanentAddressController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // =====================================================================
  // PICK STUDENT PHOTO
  // =====================================================================
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 800,
    );

    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
  }

  // =====================================================================
  // PICK DATE OF BIRTH (figure) + AUTO-FILL DATE OF BIRTH IN WORDS
  // =====================================================================
  Future<void> _pickDob() async {
    final DateTime now = DateTime.now();
    final DateTime initial = dobDate ?? DateTime(now.year - 5);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 25),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: Colors.black87,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dobDate = picked;
        // Auto-fill the "in words" field — the parent can still edit it.
        dobWordsController.text = _dobToWords(picked);
      });
    }
  }

  // Very small number-to-words helper, good enough for day/year values.
  String _numberToWords(int number) {
    const List<String> ones = [
      '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight',
      'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen',
      'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'
    ];
    const List<String> tens = [
      '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy',
      'Eighty', 'Ninety'
    ];

    if (number == 0) return 'Zero';
    if (number < 20) return ones[number];
    if (number < 100) {
      return '${tens[number ~/ 10]}${number % 10 != 0 ? ' ${ones[number % 10]}' : ''}';
    }
    if (number < 1000) {
      final int hundreds = number ~/ 100;
      final int rest = number % 100;
      return '${ones[hundreds]} Hundred${rest != 0 ? ' ${_numberToWords(rest)}' : ''}';
    }
    // Handles years like 2015, 2024 as "Two Thousand Fifteen"
    final int thousands = number ~/ 1000;
    final int rest = number % 1000;
    return '${_numberToWords(thousands)} Thousand${rest != 0 ? ' ${_numberToWords(rest)}' : ''}';
  }

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December'
  ];

  String _dobToWords(DateTime date) {
    final String day = _numberToWords(date.day);
    final String month = _monthNames[date.month - 1];
    final String year = _numberToWords(date.year);
    return '$day $month $year';
  }

  // Small manual dd-MM-yyyy formatter so we don't need the `intl`
  // package just for one date field.
  String _formatDate(DateTime date) {
    final String dd = date.day.toString().padLeft(2, '0');
    final String mm = date.month.toString().padLeft(2, '0');
    final String yyyy = date.year.toString();
    return '$dd-$mm-$yyyy';
  }

  // =====================================================================
  // UPLOAD PHOTO TO FIREBASE STORAGE (SAFE FIX)
  // =====================================================================
  Future<String?> _uploadPhoto(String studentName) async {
    if (_pickedImage == null) return null;

    try {
      // Clean student name to prevent illegal path characters
      final String safeName =
          studentName.trim().replaceAll(RegExp(r'[^\w\s]+'), '');
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$safeName.jpg';

      final Reference ref = _storage.ref().child('student_photos/$fileName');

      // Upload file directly
      final TaskSnapshot snapshot = await ref.putFile(_pickedImage!);

      // Get Download URL safely
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint("Storage Upload Error: $e");
      return null;
    }
  }

  // =====================================================================
  // SUBMIT ADMISSION FORM -> FIRESTORE (classwise, linked to parent)
  // =====================================================================
  Future<void> _submitForm() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedClass == null || selectedSection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select class and section.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (dobDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date of birth.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String? parentUid = _auth.currentUser?.uid;
    if (parentUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to submit an admission form.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      // Upload photo first (if selected)
      final String? photoUrl = await _uploadPhoto(studentNameController.text);

      final Map<String, dynamic> studentData = {
        // ---- Student info ----
        'admissionNo': admissionNoController.text.trim(),
        'registrationNo': registrationNoController.text.trim(),
        'studentName': studentNameController.text.trim(), // full name
        'rollNo': rollNoController.text.trim(),
        'religion': religionController.text.trim(),
        'caste': casteController.text.trim(),
        'nationality': nationalityController.text.trim(),
        'dobFigure': Timestamp.fromDate(dobDate!),
        'dobWords': dobWordsController.text.trim(),
        'previousInstitution': previousInstitutionController.text.trim(),
        'class': selectedClass, // class in which admission is sought
        'section': selectedSection,
        'photoUrl': photoUrl ?? '',

        // ---- Family / guardian info ----
        'familyName': familyNameController.text.trim(),
        'fatherName': fatherNameController.text.trim(),
        'occupation': occupationController.text.trim(),
        'cnic': cnicController.text.trim(),
        'fatherAddress': fatherAddressController.text.trim(),
        'fatherPhone': fatherPhoneController.text.trim(),
        'motherName': motherNameController.text.trim(),
        'guardianName': guardianNameController.text.trim(),
        'guardianAddress': guardianAddressController.text.trim(),
        'guardianPhone': guardianPhoneController.text.trim(),
        'permanentAddress': permanentAddressController.text.trim(),
        'email': emailController.text.trim(),

        // ---- Link to parent account so only this parent can see it ----
        'parentUid': parentUid,

        'createdAt': FieldValue.serverTimestamp(),
      };

      // Stored class-wise: classes/{className}/students/{autoId}
      // Admin can read every class's subcollection directly, or run a
      // collectionGroup('students') query to see everything at once.
      await _firestore
          .collection('classes')
          .doc(selectedClass)
          .collection('students')
          .add(studentData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admission form submitted successfully.'),
          backgroundColor: Colors.green,
        ),
      );

      _resetForm();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _resetForm() {
    admissionNoController.clear();
    registrationNoController.clear();
    studentNameController.clear();
    rollNoController.clear();
    religionController.clear();
    casteController.clear();
    nationalityController.clear();
    dobWordsController.clear();
    previousInstitutionController.clear();

    familyNameController.clear();
    fatherNameController.clear();
    occupationController.clear();
    cnicController.clear();
    fatherAddressController.clear();
    fatherPhoneController.clear();
    motherNameController.clear();
    guardianNameController.clear();
    guardianAddressController.clear();
    guardianPhoneController.clear();
    permanentAddressController.clear();
    emailController.clear();

    setState(() {
      selectedClass = null;
      selectedSection = null;
      _pickedImage = null;
      dobDate = null;
    });
  }

  // =====================================================================
  // BUILD
  // =====================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ---------------- BACKGROUND IMAGE ----------------
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // ---------------- DARK OVERLAY (kept light enough to still
          // see the background picture through it) ----------------
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.55),
            ),
          ),

          // ---------------- FORM CONTENT ----------------
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    // ---------------- SCHOOL LOGO ----------------
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/school_logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.school,
                              color: Colors.white,
                              size: 45,
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Admission Form',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ---------------- STUDENT PHOTO PICKER (profile pic) ----
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.15),
                            backgroundImage: _pickedImage != null
                                ? FileImage(_pickedImage!)
                                : null,
                            child: _pickedImage == null
                                ? const Icon(
                                    Icons.person,
                                    size: 55,
                                    color: Colors.white70,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.8),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ---------------- STUDENT INFO CARD ----------------
                    _sectionCard(
                      title: 'Student Information',
                      icon: Icons.badge,
                      children: [
                        _buildTextField(
                          controller: admissionNoController,
                          label: 'Admission Number',
                          icon: Icons.confirmation_number_outlined,
                          requiredField: false,
                        ),
                        _buildTextField(
                          controller: registrationNoController,
                          label: 'Registration Number',
                          icon: Icons.numbers,
                          requiredField: false,
                        ),
                        _buildTextField(
                          controller: studentNameController,
                          label: "Candidate's Name in Full",
                          icon: Icons.person,
                        ),
                        _buildTextField(
                          controller: religionController,
                          label: 'Religion',
                          icon: Icons.menu_book,
                        ),
                        _buildTextField(
                          controller: casteController,
                          label: 'Caste',
                          icon: Icons.groups_2,
                        ),
                        _buildTextField(
                          controller: nationalityController,
                          label: 'Nationality',
                          icon: Icons.flag,
                        ),
                        _buildDobField(),
                        _buildTextField(
                          controller: dobWordsController,
                          label: 'Date of Birth in Words',
                          icon: Icons.short_text,
                        ),
                        _buildTextField(
                          controller: previousInstitutionController,
                          label:
                              'Name of Institution & Class Attended (if any, with medium of instruction)',
                          icon: Icons.account_balance,
                          requiredField: false,
                          maxLines: 2,
                        ),
                        _buildDropdown(
                          label: 'Class in Which Admission is Sought',
                          icon: Icons.school,
                          value: selectedClass,
                          items: classList,
                          onChanged: (v) => setState(() => selectedClass = v),
                        ),
                        _buildDropdown(
                          label: 'Section',
                          icon: Icons.groups,
                          value: selectedSection,
                          items: sectionList,
                          onChanged: (v) =>
                              setState(() => selectedSection = v),
                        ),
                        _buildTextField(
                          controller: rollNoController,
                          label: 'Roll No (optional)',
                          icon: Icons.tag,
                          requiredField: false,
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ---------------- FAMILY / GUARDIAN INFO CARD -------
                    _sectionCard(
                      title: 'Family & Guardian Information',
                      icon: Icons.family_restroom,
                      children: [
                        _buildTextField(
                          controller: familyNameController,
                          label: 'Family Name (optional)',
                          icon: Icons.family_restroom,
                          requiredField: false,
                        ),
                        _buildTextField(
                          controller: fatherNameController,
                          label: "Father's Name",
                          icon: Icons.person,
                        ),
                        _buildTextField(
                          controller: occupationController,
                          label: 'Occupation',
                          icon: Icons.work,
                        ),
                        _buildTextField(
                          controller: cnicController,
                          label: 'CNIC No.',
                          icon: Icons.badge_outlined,
                          keyboardType: TextInputType.number,
                        ),
                        _buildTextField(
                          controller: fatherAddressController,
                          label: "Father's Present Address",
                          icon: Icons.home,
                          maxLines: 2,
                        ),
                        _buildTextField(
                          controller: fatherPhoneController,
                          label: 'Phone #',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        _buildTextField(
                          controller: motherNameController,
                          label: "Mother's Name",
                          icon: Icons.person_outline,
                          requiredField: false,
                        ),
                        const Divider(height: 22, color: Colors.white24),
                        Text(
                          "Guardian's Details (only if father is not alive "
                          "or serving abroad)",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: guardianNameController,
                          label: "Guardian's Name",
                          icon: Icons.shield,
                          requiredField: false,
                        ),
                        _buildTextField(
                          controller: guardianAddressController,
                          label: "Guardian's Present Address",
                          icon: Icons.location_city,
                          requiredField: false,
                          maxLines: 2,
                        ),
                        _buildTextField(
                          controller: guardianPhoneController,
                          label: 'Phone #',
                          icon: Icons.phone_android,
                          keyboardType: TextInputType.phone,
                          requiredField: false,
                        ),
                        const Divider(height: 22, color: Colors.white24),
                        _buildTextField(
                          controller: permanentAddressController,
                          label: 'Permanent Home Address',
                          icon: Icons.location_on,
                          maxLines: 2,
                        ),
                        _buildTextField(
                          controller: emailController,
                          label: 'Email (optional)',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          requiredField: false,
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // ---------------- SUBMIT BUTTON ----------------
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : _submitForm,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check),
                        label: Text(
                          _saving ? 'Submitting...' : 'Submit Admission',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.black.withValues(alpha: 0.75),
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
    );
  }

  // =====================================================================
  // SECTION CARD
  // =====================================================================
  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const Divider(height: 22, color: Colors.white24),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================================
  // TEXT FIELD
  // =====================================================================
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool requiredField = true,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.30),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white, width: 2),
          ),
        ),
        validator: (value) {
          if (requiredField && (value == null || value.trim().isEmpty)) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  // =====================================================================
  // DATE OF BIRTH FIELD (figure) — opens a date picker
  // =====================================================================
  Widget _buildDobField() {
    final String displayText =
        dobDate == null ? '' : _formatDate(dobDate!);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        readOnly: true,
        onTap: _pickDob,
        controller: TextEditingController(text: displayText),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Date of Birth in Figure',
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.30),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white, width: 2),
          ),
        ),
        validator: (value) {
          if (dobDate == null) return 'Date of birth is required';
          return null;
        },
      ),
    );
  }

  // =====================================================================
  // DROPDOWN (class / section)
  // =====================================================================
  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        dropdownColor: Colors.grey.shade900,
        style: const TextStyle(color: Colors.white),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.30),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white, width: 2),
          ),
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? '$label is required' : null,
      ),
    );
  }
}