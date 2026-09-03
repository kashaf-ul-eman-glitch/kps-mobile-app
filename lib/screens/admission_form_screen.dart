import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

/// =====================================================================
/// ADMISSION FORM SCREEN
/// =====================================================================

class AdmissionFormScreen extends StatefulWidget {
  const AdmissionFormScreen({super.key});

  @override
  State<AdmissionFormScreen> createState() => _AdmissionFormScreenState();
}

class _AdmissionFormScreenState extends State<AdmissionFormScreen> {
  // =====================================================================
  // FIREBASE INSTANCES
  // =====================================================================

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // =====================================================================
  // DEFAULT PARENT PASSWORD
  // =====================================================================

  static const String _defaultParentPassword = 'Parent@123';

  final ImagePicker _picker = ImagePicker();

  final formKey = GlobalKey<FormState>();

  // =====================================================================
  // STUDENT FIELDS
  // =====================================================================

  final TextEditingController admissionNoController =
      TextEditingController();

  final TextEditingController registrationNoController =
      TextEditingController();

  final TextEditingController studentNameController =
      TextEditingController();

  final TextEditingController rollNoController =
      TextEditingController();

  final TextEditingController religionController =
      TextEditingController();

  final TextEditingController casteController =
      TextEditingController();

  final TextEditingController nationalityController =
      TextEditingController();

  final TextEditingController dobWordsController =
      TextEditingController();

  final TextEditingController previousInstitutionController =
      TextEditingController();

  DateTime? dobDate;

  String? selectedClass;
  String? selectedSection;

  final List<String> classList = [
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

  // Default Sections List (Fallback and Initial Values)
  final List<String> _defaultSections = ['Pink', 'Blue'];

  // =====================================================================
  // FAMILY / PARENT FIELDS
  // =====================================================================

  final TextEditingController fatherNameController =
      TextEditingController();

  final TextEditingController occupationController =
      TextEditingController();

  final TextEditingController cnicController =
      TextEditingController();

  final TextEditingController fatherAddressController =
      TextEditingController();

  final TextEditingController fatherPhoneController =
      TextEditingController();

  final TextEditingController motherNameController =
      TextEditingController();

  final TextEditingController guardianNameController =
      TextEditingController();

  final TextEditingController guardianAddressController =
      TextEditingController();

  final TextEditingController guardianPhoneController =
      TextEditingController();

  final TextEditingController permanentAddressController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  // =====================================================================
  // STATE
  // =====================================================================

  File? _pickedImage;

  bool _saving = false;

  DocumentReference<Map<String, dynamic>>? _editingDocument;

  String? _editingClass;

  String? _editingPhotoUrl;

  // =====================================================================
  // DISPOSE
  // =====================================================================

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
  // ADD NEW SECTION (ADMIN FEATURE)
  // =====================================================================

  Future<void> _showAddSectionDialog() async {
    final TextEditingController newSectionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Section'),
          content: TextField(
            controller: newSectionController,
            decoration: const InputDecoration(
              labelText: 'Section Name (e.g. Pink, Blue)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final String sectionName = newSectionController.text.trim();
                if (sectionName.isNotEmpty) {
                  try {
                    await _firestore.collection('sections').doc(sectionName).set({
                      'name': sectionName,
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    if (mounted) {
                      setState(() {
                        selectedSection = sectionName;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Section "$sectionName" added successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error adding section: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // =====================================================================
  // PICK STUDENT IMAGE
  // =====================================================================

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 800,
      );

      if (image != null && mounted) {
        setState(() {
          _pickedImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image selection error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =====================================================================
  // DATE OF BIRTH PICKER
  // =====================================================================

  Future<void> _pickDob() async {
    final DateTime now = DateTime.now();

    final DateTime initial =
        dobDate ?? DateTime(now.year - 5);

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
              onPrimary: Color.fromARGB(255, 242, 234, 234),
              surface: Color.fromARGB(221, 189, 182, 182),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        dobDate = picked;
        dobWordsController.text = _dobToWords(picked);
      });
    }
  }

  // =====================================================================
  // NUMBER TO WORDS
  // =====================================================================

  String _numberToWords(int number) {
    const List<String> ones = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen',
    ];

    const List<String> tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety',
    ];

    if (number == 0) {
      return 'Zero';
    }

    if (number < 20) {
      return ones[number];
    }

    if (number < 100) {
      return '${tens[number ~/ 10]}'
          '${number % 10 != 0 ? ' ${ones[number % 10]}' : ''}';
    }

    if (number < 1000) {
      final int hundreds = number ~/ 100;
      final int rest = number % 100;

      return '${ones[hundreds]} Hundred'
          '${rest != 0 ? ' ${_numberToWords(rest)}' : ''}';
    }

    final int thousands = number ~/ 1000;
    final int rest = number % 1000;

    return '${_numberToWords(thousands)} Thousand'
        '${rest != 0 ? ' ${_numberToWords(rest)}' : ''}';
  }

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String _dobToWords(DateTime date) {
    final String day = _numberToWords(date.day);

    final String month =
        _monthNames[date.month - 1];

    final String year =
        _numberToWords(date.year);

    return '$day $month $year';
  }

  // =====================================================================
  // FORMAT DATE
  // =====================================================================

  String _formatDate(DateTime date) {
    final String dd =
        date.day.toString().padLeft(2, '0');

    final String mm =
        date.month.toString().padLeft(2, '0');

    final String yyyy =
        date.year.toString();

    return '$dd-$mm-$yyyy';
  }

  // =====================================================================
  // UPLOAD PHOTO
  // =====================================================================

  Future<String?> _uploadPhoto(String studentName) async {
    if (_pickedImage == null) {
      return null;
    }

    try {
      final String safeName = studentName
          .trim()
          .replaceAll(RegExp(r'[^\w\s]+'), '')
          .replaceAll(' ', '_');

      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$safeName.jpg';

      final Reference ref = _storage
          .ref()
          .child('student_photos')
          .child(fileName);

      final TaskSnapshot snapshot =
          await ref.putFile(_pickedImage!);

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint(
        'Storage Upload Error: $e',
      );

      return null;
    }
  }

  // =====================================================================
  // DELETE PHOTO
  // =====================================================================

  Future<void> _deletePhotoByUrl(String? photoUrl) async {
    if (photoUrl == null ||
        photoUrl.trim().isEmpty) {
      return;
    }

    try {
      await _storage
          .refFromURL(photoUrl)
          .delete();
    } catch (e) {
      debugPrint(
        'Storage Delete Error: $e',
      );
    }
  }

  // =====================================================================
  // FIND EXISTING PARENT BY EMAIL
  // =====================================================================

  Future<String?> _findExistingParentUid(
    String email,
  ) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> query =
          await _firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .where('role', isEqualTo: 'Parent')
              .limit(1)
              .get();

      if (query.docs.isEmpty) {
        return null;
      }

      return query.docs.first.id;
    } catch (e) {
      debugPrint(
        'Find Existing Parent Error: $e',
      );

      return null;
    }
  }

  // =====================================================================
  // CREATE PARENT FIREBASE AUTH ACCOUNT
  // =====================================================================

  Future<String> _createParentAccount(
    String email,
  ) async {
    FirebaseApp? parentApp;

    try {
      final String appName =
          'ParentAuthApp_${DateTime.now().millisecondsSinceEpoch}';

      parentApp = await Firebase.initializeApp(
        name: appName,
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final FirebaseAuth parentAuth =
          FirebaseAuth.instanceFor(
        app: parentApp,
      );

      final UserCredential credential =
          await parentAuth.createUserWithEmailAndPassword(
        email: email,
        password: _defaultParentPassword,
      );

      final User? parentUser =
          credential.user;

      if (parentUser == null) {
        throw FirebaseAuthException(
          code: 'parent-uid-missing',
          message:
              'Parent account was created but UID was not returned.',
        );
      }

      final String parentUid =
          parentUser.uid;

      await _firestore
          .collection('users')
          .doc(parentUid)
          .set(
        {
          'uid': parentUid,
          'role': 'Parent',
          'email': email,
          'isFirstLogin': true,
          'createdAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      return parentUid;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'Parent Auth Error: ${e.code} - ${e.message}',
      );

      if (e.code == 'email-already-in-use') {
        final String? existingUid =
            await _findExistingParentUid(email);

        if (existingUid != null) {
          return existingUid;
        }

        throw Exception(
          'This parent email already has a Firebase account. '
          'Please use another email address.',
        );
      }

      if (e.code == 'invalid-email') {
        throw Exception(
          'The parent email address is invalid.',
        );
      }

      if (e.code == 'weak-password') {
        throw Exception(
          'The default parent password is too weak.',
        );
      }

      throw Exception(
        e.message ?? 'Could not create parent account.',
      );
    } catch (e) {
      debugPrint(
        'Parent Account Creation Error: $e',
      );

      rethrow;
    } finally {
      if (parentApp != null) {
        try {
          await parentApp.delete();
        } catch (e) {
          debugPrint(
            'Secondary Firebase App Delete Error: $e',
          );
        }
      }
    }
  }

  // =====================================================================
  // SUBMIT ADMISSION
  // =====================================================================

  Future<void> _submitForm() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedClass == null ||
        selectedSection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please select class and section.'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    if (dobDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please select date of birth.'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    final String? currentUid =
        _auth.currentUser?.uid;

    if (currentUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You must be logged in to save an admission form.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() {
      _saving = true;
    });

    bool linkedToExistingParent = false;

    try {
      final String parentEmail =
          emailController.text
              .trim()
              .toLowerCase();

      String parentUid = currentUid;

      if (_editingDocument != null) {
        final DocumentSnapshot<Map<String, dynamic>>
            existingSnapshot =
            await _editingDocument!.get();

        if (existingSnapshot.exists) {
          final data =
              existingSnapshot.data();

          parentUid =
              (data?['parentUid'] as String?) ??
                  currentUid;
        }

        final String? matchedUid =
            await _findExistingParentUid(parentEmail);

        if (matchedUid != null) {
          parentUid = matchedUid;
        }
      } else {
        final String? existingParentUid =
            await _findExistingParentUid(parentEmail);

        if (existingParentUid != null) {
          parentUid = existingParentUid;
          linkedToExistingParent = true;
        } else {
          parentUid = await _createParentAccount(
            parentEmail,
          );
        }
      }

      String photoUrl =
          _editingPhotoUrl ?? '';

      final String? newPhotoUrl =
          await _uploadPhoto(
        studentNameController.text.trim(),
      );

      if (newPhotoUrl != null) {
        photoUrl = newPhotoUrl;

        if (_editingPhotoUrl != null &&
            _editingPhotoUrl!.isNotEmpty &&
            _editingPhotoUrl !=
                newPhotoUrl) {
          await _deletePhotoByUrl(
            _editingPhotoUrl,
          );
        }
      }

      final Map<String, dynamic> studentData =
          {
        'admissionNo':
            admissionNoController.text.trim(),

        'registrationNo':
            registrationNoController.text.trim(),

        'studentName':
            studentNameController.text.trim(),

        'rollNo':
            rollNoController.text.trim(),

        'religion':
            religionController.text.trim(),

        'caste':
            casteController.text.trim(),

        'nationality':
            nationalityController.text.trim(),

        'dobFigure':
            Timestamp.fromDate(dobDate!),

        'dobWords':
            dobWordsController.text.trim(),

        'previousInstitution':
            previousInstitutionController.text.trim(),

        'class':
            selectedClass,

        'section':
            selectedSection,

        'photoUrl':
            photoUrl,

        'fatherName':
            fatherNameController.text.trim(),

        'occupation':
            occupationController.text.trim(),

        'cnic':
            cnicController.text.trim(),

        'fatherAddress':
            fatherAddressController.text.trim(),

        'fatherPhone':
            fatherPhoneController.text.trim(),

        'motherName':
            motherNameController.text.trim(),

        'guardianName':
            guardianNameController.text.trim(),

        'guardianAddress':
            guardianAddressController.text.trim(),

        'guardianPhone':
            guardianPhoneController.text.trim(),

        'permanentAddress':
            permanentAddressController.text.trim(),

        'email':
            parentEmail,

        'parentUid':
            parentUid,

        'admissionStatus':
            'Pending',

        'updatedAt':
            FieldValue.serverTimestamp(),
      };

      if (_editingDocument == null) {
        studentData['createdAt'] =
            FieldValue.serverTimestamp();

        await _firestore
            .collection('classes')
            .doc(selectedClass)
            .collection('students')
            .add(studentData);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              linkedToExistingParent
                  ? 'Admission saved successfully. This child has been linked to the existing parent account.'
                  : 'Admission saved successfully. Parent account created successfully.',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        final String oldClass =
            _editingClass ?? selectedClass!;

        if (oldClass == selectedClass) {
          await _editingDocument!
              .update(studentData);
        } else {
          final DocumentReference<Map<String, dynamic>>
              newDocument =
              _firestore
                  .collection('classes')
                  .doc(selectedClass)
                  .collection('students')
                  .doc(_editingDocument!.id);

          await newDocument.set(
            studentData,
          );

          await _editingDocument!
              .delete();
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Admission updated successfully.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      _resetForm();
    } catch (e) {
      debugPrint(
        'Admission Save Error: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
          ),
          backgroundColor: Colors.red,
          duration:
              const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  // =====================================================================
  // RESET FORM
  // =====================================================================

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

    if (!mounted) return;

    setState(() {
      selectedClass = null;
      selectedSection = null;

      _pickedImage = null;

      dobDate = null;

      _editingDocument = null;
      _editingClass = null;
      _editingPhotoUrl = null;
    });
  }

  // =====================================================================
  // EDIT ADMISSION
  // =====================================================================

  Future<void> _editAdmission(
    DocumentSnapshot<Map<String, dynamic>>
        document,
  ) async {
    final Map<String, dynamic>? data =
        document.data();

    if (data == null) {
      return;
    }

    final String className =
        (data['class'] ?? '').toString();

    if (className.isEmpty) {
      return;
    }

    setState(() {
      _editingDocument =
          document.reference;

      _editingClass =
          className;

      _editingPhotoUrl =
          (data['photoUrl'] ?? '').toString();

      admissionNoController.text =
          (data['admissionNo'] ?? '').toString();

      registrationNoController.text =
          (data['registrationNo'] ?? '').toString();

      studentNameController.text =
          (data['studentName'] ?? '').toString();

      rollNoController.text =
          (data['rollNo'] ?? '').toString();

      religionController.text =
          (data['religion'] ?? '').toString();
      casteController.text =
          (data['caste'] ?? '').toString();

      nationalityController.text =
          (data['nationality'] ?? '').toString();

      dobWordsController.text =
          (data['dobWords'] ?? '').toString();

      previousInstitutionController.text =
          (data['previousInstitution'] ?? '')
              .toString();

      selectedClass =
          className;

      selectedSection =
          (data['section'] ?? '').toString();

      fatherNameController.text =
          (data['fatherName'] ?? '').toString();

      occupationController.text =
          (data['occupation'] ?? '').toString();

      cnicController.text =
          (data['cnic'] ?? '').toString();

      fatherAddressController.text =
          (data['fatherAddress'] ?? '').toString();

      fatherPhoneController.text =
          (data['fatherPhone'] ?? '').toString();

      motherNameController.text =
          (data['motherName'] ?? '').toString();

      guardianNameController.text =
          (data['guardianName'] ?? '').toString();

      guardianAddressController.text =
          (data['guardianAddress'] ?? '').toString();

      guardianPhoneController.text =
          (data['guardianPhone'] ?? '').toString();

      permanentAddressController.text =
          (data['permanentAddress'] ?? '').toString();

      emailController.text =
          (data['email'] ?? '').toString();

      _pickedImage = null;

      final dynamic dobValue =
          data['dobFigure'];

      dobDate =
          dobValue is Timestamp
              ? dobValue.toDate()
              : null;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Admission loaded. Edit the information and press Update Admission.',
        ),
      ),
    );
  }

  // =====================================================================
  // DELETE ADMISSION
  // =====================================================================

  Future<void> _deleteAdmission(
    DocumentSnapshot<Map<String, dynamic>>
        document,
  ) async {
    final Map<String, dynamic>? data =
        document.data();

    if (data == null) {
      return;
    }

    final String name =
        (data['studentName'] ??
                'this admission')
            .toString();

    final bool? confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text('Delete Admission'),

          content: Text(
            'Are you sure you want to delete $name?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child:
                  const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
                foregroundColor:
                    Colors.white,
              ),
              child:
                  const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      final String? photoUrl =
          data['photoUrl']?.toString();

      await document.reference.delete();

      await _deletePhotoByUrl(
        photoUrl,
      );

      if (!mounted) return;

      if (_editingDocument?.path ==
          document.reference.path) {
        _resetForm();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Admission deleted successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Delete error: $e'),
          backgroundColor:
              Colors.red,
        ),
      );
    }
  }

  // =====================================================================
  // VIEW ADMISSION
  // =====================================================================

  Future<void> _viewAdmission(
    DocumentSnapshot<Map<String, dynamic>>
        document,
  ) async {
    final Map<String, dynamic>? data =
        document.data();

    if (data == null) {
      return;
    }

    String dob = '';

    final dynamic dobValue =
        data['dobFigure'];

    if (dobValue is Timestamp) {
      dob = _formatDate(
        dobValue.toDate(),
      );
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            (data['studentName'] ??
                    'Admission Details')
                .toString(),
          ),

          content:
              SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _detailRow(
                  'Admission No',
                  data['admissionNo'],
                ),

                _detailRow(
                  'Registration No',
                  data['registrationNo'],
                ),

                _detailRow(
                  'Student Name',
                  data['studentName'],
                ),

                _detailRow(
                  'Roll No',
                  data['rollNo'],
                ),

                _detailRow(
                  'Class',
                  data['class'],
                ),

                _detailRow(
                  'Section',
                  data['section'],
                ),

                _detailRow(
                  'Admission Status',
                  data['admissionStatus'],
                ),

                _detailRow(
                  'Religion',
                  data['religion'],
                ),

                _detailRow(
                  'Caste',
                  data['caste'],
                ),

                _detailRow(
                  'Nationality',
                  data['nationality'],
                ),

                _detailRow(
                  'Date of Birth',
                  dob,
                ),

                _detailRow(
                  'DOB in Words',
                  data['dobWords'],
                ),

                _detailRow(
                  'Previous Institution',
                  data['previousInstitution'],
                ),

                const Divider(),

                _detailRow(
                  'Father Name',
                  data['fatherName'],
                ),

                _detailRow(
                  'Occupation',
                  data['occupation'],
                ),

                _detailRow(
                  'CNIC',
                  data['cnic'],
                ),

                _detailRow(
                  'Father Address',
                  data['fatherAddress'],
                ),

                _detailRow(
                  'Father Phone',
                  data['fatherPhone'],
                ),

                _detailRow(
                  'Mother Name',
                  data['motherName'],
                ),

                _detailRow(
                  'Guardian Name',
                  data['guardianName'],
                ),

                _detailRow(
                  'Guardian Address',
                  data['guardianAddress'],
                ),

                _detailRow(
                  'Guardian Phone',
                  data['guardianPhone'],
                ),

                _detailRow(
                  'Permanent Address',
                  data['permanentAddress'],
                ),

                _detailRow(
                  'Parent Email',
                  data['email'],
                ),

                _detailRow(
                  'Parent UID',
                  data['parentUid'],
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child:
                  const Text('Close'),
            ),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(
                  context,
                );

                _editAdmission(
                  document,
                );
              },
              icon:
                  const Icon(Icons.edit),
              label:
                  const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  // =====================================================================
  // DETAIL ROW
  // =====================================================================

  Widget _detailRow(
    String label,
    dynamic value,
  ) {
    final String text =
        value == null
            ? '-'
            : value.toString();

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: RichText(
        text: TextSpan(
          style:
              const TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            TextSpan(
              text:
                  text.isEmpty
                      ? '-'
                      : text,
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================================
  // SAVED ADMISSIONS
  // =====================================================================

  Widget _savedAdmissionsSection() {
    return _sectionCard(
      title: 'Saved Admissions',
      icon: Icons.people_alt,
      children: [
        StreamBuilder<
            QuerySnapshot<
                Map<String, dynamic>>>(
          stream: _firestore
              .collectionGroup('students')
              .snapshots(),

          builder:
              (context, snapshot) {
            if (snapshot.hasError) {
              return Text(
                'Could not load admissions: ${snapshot.error}',
                style:
                    const TextStyle(
                  color:
                      Colors.redAccent,
                ),
              );
            }

            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding:
                      EdgeInsets.all(20),
                  child:
                      CircularProgressIndicator(
                    color:
                        Colors.white,
                  ),
                ),
              );
            }

            final documents = [
              ...(snapshot.data?.docs ?? [])
            ];

            documents.sort(
              (a, b) {
                final dynamic aTime =
                    a.data()['createdAt'];

                final dynamic bTime =
                    b.data()['createdAt'];

                if (aTime is Timestamp &&
                    bTime is Timestamp) {
                  return bTime.compareTo(
                    aTime,
                  );
                }

                return 0;
              },
            );

            if (documents.isEmpty) {
              return const Padding(
                padding:
                    EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No saved admissions yet.',
                    style:
                        TextStyle(
                      color:
                          Colors.white70,
                    ),
                  ),
                ),
              );
            }

            return Column(
              children:
                  documents.map(
                (document) {
                  final data =
                      document.data();

                  final String name =
                      (data['studentName'] ??
                              'Unnamed Student')
                          .toString();

                  final String admissionNo =
                      (data['admissionNo'] ??
                              '-')
                          .toString();

                  final String className =
                      (data['class'] ?? '-')
                          .toString();

                  final String section =
                      (data['section'] ??
                              '-')
                          .toString();

                  final String status =
                      (data[
                                  'admissionStatus'] ??
                              'Pending')
                          .toString();

                  return Card(
                    color: Colors.white
                        .withValues(
                      alpha: 0.10,
                    ),
                    margin:
                        const EdgeInsets.only(
                      bottom: 12,
                    ),

                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        12,
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [
                          Text(
                            name,
                            style:
                                GoogleFonts
                                    .poppins(
                              color:
                                  Colors.white,
                              fontSize: 17,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          Text(
                            'Admission No: $admissionNo',
                            style:
                                const TextStyle(
                              color:
                                  Colors.white70,
                            ),
                          ),

                          Text(
                            'Class: $className  •  $section',
                            style:
                                const TextStyle(
                              color:
                                  Colors.white70,
                            ),
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          Text(
                            'Status: $status',
                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton
                                  .icon(
                                onPressed:
                                    () =>
                                        _viewAdmission(
                                  document,
                                ),
                                icon:
                                    const Icon(
                                  Icons
                                      .visibility,
                                ),
                                label:
                                    const Text(
                                  'View',
                                ),
                                style:
                                    OutlinedButton
                                        .styleFrom(
                                  foregroundColor:
                                      Colors
                                          .white,
                                ),
                              ),

                              OutlinedButton
                                  .icon(
                                onPressed:
                                    () =>
                                        _editAdmission(
                                  document,
                                ),
                                icon:
                                    const Icon(
                                  Icons.edit,
                                ),
                                label:
                                    const Text(
                                  'Edit',
                                ),
                                style:
                                    OutlinedButton
                                        .styleFrom(
                                  foregroundColor:
                                      Colors
                                          .white,
                                ),
                              ),

                              OutlinedButton
                                  .icon(
                                onPressed:
                                    () =>
                                        _deleteAdmission(
                                  document,
                                ),
                                icon:
                                    const Icon(
                                  Icons
                                      .delete,
                                ),
                                label:
                                    const Text(
                                  'Delete',
                                ),
                                style:
                                    OutlinedButton
                                        .styleFrom(
                                  foregroundColor:
                                      Colors
                                          .redAccent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ).toList(),
            );
          },
        ),
      ],
    );
  }

  // =====================================================================
  // BUILD
  // =====================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          Colors.black,

      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color:
                  Colors.black.withValues(
                alpha: 0.55,
              ),
            ),
          ),

          SafeArea(
            child:
                SingleChildScrollView(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                40,
              ),

              child: Form(
                key: formKey,

                child: Column(
                  children: [
                    if (_editingDocument !=
                        null)
                      Container(
                        width:
                            double.infinity,
                        margin:
                            const EdgeInsets
                                .only(
                          bottom: 16,
                        ),
                        padding:
                            const EdgeInsets
                                .all(14),

                        decoration:
                            BoxDecoration(
                          color: Colors
                              .orange
                              .withValues(
                            alpha: 0.18,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                          border:
                              Border.all(
                            color: Colors
                                .orange
                                .withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),

                        child: Row(
                          children: [
                            const Icon(
                              Icons
                                  .edit_note,
                              color: Colors
                                  .orange,
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            const Expanded(
                              child: Text(
                                'Edit Mode: change the information and press Update Admission.',
                                style:
                                    TextStyle(
                                  color:
                                      Colors
                                          .white,
                                ),
                              ),
                            ),

                            TextButton(
                              onPressed:
                                  _saving
                                      ? null
                                      : _resetForm,
                              child:
                                  const Text(
                                'Cancel',
                                style:
                                    TextStyle(
                                  color:
                                      Colors
                                          .orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    Container(
                      width: 90,
                      height: 90,

                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,
                        color: Colors
                            .white
                            .withValues(
                          alpha: 0.1,
                        ),
                        border:
                            Border.all(
                          color: Colors
                              .white
                              .withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),

                      child: ClipOval(
                        child:
                            Image.asset(
                          'assets/images/school_logo.png',
                          fit:
                              BoxFit.cover,

                          errorBuilder:
                              (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const Icon(
                              Icons.school,
                              color:
                                  Colors.white,
                              size: 45,
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Text(
                      'Admission Form',
                      style:
                          GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Colors.white,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    GestureDetector(
                      onTap:
                          _pickImage,

                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundColor:
                                Colors
                                    .white
                                    .withValues(
                              alpha: 0.15,
                            ),
                            backgroundImage:
                                _pickedImage !=
                                        null
                                    ? FileImage(
                                        _pickedImage!,
                                      )
                                    : null,
                            child:
                                _pickedImage ==
                                        null
                                    ? const Icon(
                                        Icons
                                            .person,
                                        size:
                                            55,
                                        color:
                                            Colors
                                                .white70,
                                      )
                                    : null,
                          ),

                          Positioned(
                            bottom: 0,
                            right: 0,

                            child:
                                Container(
                              padding:
                                  const EdgeInsets
                                      .all(
                                6,
                              ),

                              decoration:
                                  BoxDecoration(
                                color: Colors
                                    .black
                                    .withValues(
                                  alpha: 0.8,
                                ),
                                shape:
                                    BoxShape
                                        .circle,
                                border:
                                    Border.all(
                                  color:
                                      Colors
                                          .white,
                                ),
                              ),

                              child:
                                  const Icon(
                                Icons
                                    .camera_alt,
                                color:
                                    Colors
                                        .white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    _sectionCard(
                      title:
                          'Student Information',
                      icon:
                          Icons.badge,

                      children: [
                        _buildTextField(
                          controller:
                              admissionNoController,
                          label:
                              'Admission Number',
                          icon:
                              Icons
                                  .confirmation_number_outlined,
                          requiredField:
                              false,
                        ),

                        _buildTextField(
                          controller:
                              registrationNoController,
                          label:
                              'Registration Number',
                          icon:
                              Icons.numbers,
                          requiredField:
                              false,
                        ),

                        _buildTextField(
                          controller:
                              studentNameController,
                          label:
                              "Candidate's Name in Full",
                          icon:
                              Icons.person,
                        ),

                        _buildTextField(
                          controller:
                              religionController,
                          label:
                              'Religion',
                          icon:
                              Icons.menu_book,
                        ),

                        _buildTextField(
                          controller:
                              casteController,
                          label:
                              'Caste',
                          icon:
                              Icons.groups_2,
                        ),

                        _buildTextField(
                          controller:
                              nationalityController,
                          label:
                              'Nationality',
                          icon:
                              Icons.flag,
                        ),

                        _buildDobField(),

                        _buildTextField(
                          controller:
                              dobWordsController,
                          label:
                              'Date of Birth in Words',
                          icon:
                              Icons.short_text,
                        ),

                        _buildTextField(
                          controller:
                              previousInstitutionController,
                          label:
                              'Name of Institution & Class Attended (if any, with medium of instruction)',
                          icon:
                              Icons
                                  .account_balance,
                          requiredField:
                              false,
                          maxLines: 2,
                        ),

                        _buildDropdown(
                          label:
                              'Class in Which Admission is Sought',
                          icon:
                              Icons.school,
                          value:
                              selectedClass,
                          items:
                              classList,
                          onChanged:
                              (value) {
                            setState(() {
                              selectedClass =
                                  value;
                            });
                          },
                        ),

                        _buildSectionDropdown(),

                        _buildTextField(
                          controller:
                              rollNoController,
                          label:
                              'Roll No (optional)',
                          icon:
                              Icons.tag,
                          requiredField:
                              false,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    _sectionCard(
                      title:
                          'Family & Guardian Information',
                      icon:
                          Icons.family_restroom,

                      children: [
                        _buildTextField(
                          controller:
                              fatherNameController,
                          label:
                              "Father's Name",
                          icon:
                              Icons.person,
                        ),

                        _buildTextField(
                          controller:
                              occupationController,
                          label:
                              'Occupation',
                          icon:
                              Icons.work,
                        ),

                        _buildTextField(
                          controller:
                              cnicController,
                          label:
                              'CNIC No.',
                          icon:
                              Icons.badge_outlined,
                          keyboardType:
                              TextInputType
                                  .number,
                        ),

                        _buildTextField(
                          controller:
                              fatherAddressController,
                          label:
                              "Father's Present Address",
                          icon:
                              Icons.home,
                          maxLines: 2,
                        ),

                        _buildTextField(
                          controller:
                              fatherPhoneController,
                          label:
                              'Phone #',
                          icon:
                              Icons.phone,
                          keyboardType:
                              TextInputType
                                  .phone,
                        ),

                        _buildTextField(
                          controller:
                              motherNameController,
                          label:
                              "Mother's Name",
                          icon:
                              Icons
                                  .person_outline,
                          requiredField:
                              false,
                        ),

                        const Divider(
                          height: 22,
                          color:
                              Colors.white24,
                        ),

                        Text(
                          "Guardian's Details (only if father is not alive or serving abroad)",
                          style:
                              GoogleFonts.poppins(
                            fontSize: 12,
                            color:
                                Colors.white60,
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        _buildTextField(
                          controller:
                              guardianNameController,
                          label:
                              "Guardian's Name",
                          icon:
                              Icons.shield,
                          requiredField:
                              false,
                        ),

                        _buildTextField(
                          controller:
                              guardianAddressController,
                          label:
                              "Guardian's Present Address",
                          icon:
                              Icons
                                  .location_city,
                          requiredField:
                              false,
                          maxLines: 2,
                        ),

                        _buildTextField(
                          controller:
                              guardianPhoneController,
                          label:
                              'Phone #',
                          icon:
                              Icons
                                  .phone_android,
                          keyboardType:
                              TextInputType
                                  .phone,
                          requiredField:
                              false,
                        ),

                        const Divider(
                          height: 22,
                          color:
                              Colors.white24,
                        ),

                        _buildTextField(
                          controller:
                              permanentAddressController,
                          label:
                              'Permanent Home Address',
                          icon:
                              Icons
                                  .location_on,
                          maxLines: 2,
                        ),

                        _buildTextField(
                          controller:
                              emailController,
                          label:
                              'Parent Email',
                          icon:
                              Icons.email,
                          keyboardType:
                              TextInputType
                                  .emailAddress,
                          requiredField:
                              true,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    SizedBox(
                      width:
                          double.infinity,

                      child:
                          ElevatedButton.icon(
                        onPressed:
                            _saving
                                ? null
                                : _submitForm,

                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                  color:
                                      Colors
                                          .white,
                                ),
                              )
                            : const Icon(
                                Icons.check,
                              ),

                        label:
                            Text(
                          _saving
                              ? (_editingDocument !=
                                      null
                                  ? 'Updating...'
                                  : 'Submitting...')
                              : (_editingDocument !=
                                      null
                                  ? 'Update Admission'
                                  : 'Submit Admission'),
                        ),

                        style:
                            ElevatedButton
                                .styleFrom(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 16,
                          ),

                          backgroundColor:
                              Colors.black
                                  .withValues(
                            alpha: 0.75,
                          ),

                          foregroundColor:
                              Colors.white,

                          side:
                              BorderSide(
                            color: Colors
                                .white
                                .withValues(
                              alpha: 0.25,
                            ),
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              12,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    _savedAdmissionsSection(),

                    const SizedBox(
                      height: 20,
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
  // DYNAMIC SECTION DROPDOWN WITH ADD BUTTON (ADMIN)
  // =====================================================================

  Widget _buildSectionDropdown() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore.collection('sections').snapshots(),
      builder: (context, snapshot) {
        List<String> sections = List.from(_defaultSections);

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final fetchedSections = snapshot.data!.docs
              .map((doc) => doc.data()['name']?.toString() ?? '')
              .where((name) => name.isNotEmpty)
              .toList();

          for (var sec in fetchedSections) {
            if (!sections.contains(sec)) {
              sections.add(sec);
            }
          }
        }

        if (selectedSection != null && !sections.contains(selectedSection)) {
          sections.add(selectedSection!);
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedSection,
                  dropdownColor: Colors.grey.shade900,
                  style: const TextStyle(color: Colors.white),
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white70,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Section',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(
                      Icons.groups,
                      color: Colors.white70,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.30),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                  items: sections
                      .map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSection = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Section is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.30),
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  tooltip: 'Add New Section',
                  onPressed: _showAddSectionDialog,
                ),
              ),
            ],
          ),
        );
      },
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
      borderRadius:
          BorderRadius.circular(18),

      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5,
          sigmaY: 5,
        ),

        child: Container(
          width:
              double.infinity,

          padding:
              const EdgeInsets.all(16),

          decoration:
              BoxDecoration(
            color:
                Colors.black.withValues(
              alpha: 0.45,
            ),

            borderRadius:
                BorderRadius.circular(
              18,
            ),

            border:
                Border.all(
              color: Colors.white
                  .withValues(
                alpha: 0.18,
              ),
            ),
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color:
                        Colors.white70,
                    size: 20,
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Text(
                    title,
                    style:
                        GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          Colors.white,
                    ),
                  ),
                ],
              ),

              const Divider(
                height: 22,
                color:
                    Colors.white24,
              ),

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
    required TextEditingController
        controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType =
        TextInputType.text,
    bool requiredField = true,
    int maxLines = 1,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 14,
      ),

      child: TextFormField(
        controller:
            controller,

        keyboardType:
            keyboardType,

        maxLines:
            maxLines,

        style:
            const TextStyle(
          color:
              Colors.white,
        ),

        decoration:
            InputDecoration(
          labelText:
              label,

          labelStyle:
              const TextStyle(
            color:
                Colors.white70,
          ),

          prefixIcon:
              Icon(
            icon,
            color:
                Colors.white70,
          ),

          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),

            borderSide:
                BorderSide(
              color: Colors.white
                  .withValues(
                alpha: 0.30,
              ),
            ),
          ),

          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),

            borderSide:
                const BorderSide(
              color:
                  Colors.white,
              width: 2,
            ),
          ),
        ),

        validator:
            (value) {
          if (requiredField &&
              (value == null ||
                  value.trim()
                      .isEmpty)) {
            return '$label is required';
          }

          if (label ==
                  'Parent Email' &&
              value != null &&
              value.trim()
                  .isNotEmpty) {
            final RegExp emailRegex =
                RegExp(
              r'^[\w\.-]+@[\w\.-]+\.\w+$',
            );

            if (!emailRegex
                .hasMatch(
              value.trim(),
            )) {
              return 'Please enter a valid email address';
            }
          }

          return null;
        },
      ),
    );
  }

  // =====================================================================
  // DATE OF BIRTH FIELD
  // =====================================================================

  Widget _buildDobField() {
    final String displayText =
        dobDate == null
            ? ''
            : _formatDate(
                dobDate!,
              );

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 14,
      ),

      child: TextFormField(
        readOnly:
            true,

        onTap:
            _pickDob,

        controller:
            TextEditingController(
          text:
              displayText,
        ),

        style:
            const TextStyle(
          color:
              Colors.white,
        ),

        decoration:
            InputDecoration(
          labelText:
              'Date of Birth in Figure',

          labelStyle:
              const TextStyle(
            color:
                Colors.white70,
          ),

          prefixIcon:
              const Icon(
            Icons.calendar_today,
            color:
                Colors.white70,
          ),

          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),

            borderSide:
                BorderSide(
              color: Colors.white
                  .withValues(
                alpha: 0.30,
              ),
            ),
          ),

          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),

            borderSide:
                const BorderSide(
              color:
                  Colors.white,
              width: 2,
            ),
          ),
        ),

        validator:
            (value) {
          if (dobDate == null) {
            return 'Date of birth is required';
          }

          return null;
        },
      ),
    );
  }

  // =====================================================================
  // GENERAL DROPDOWN
  // =====================================================================

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?>
        onChanged,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 14,
      ),

      child:
          DropdownButtonFormField<String>(
        initialValue:
            value,

        dropdownColor:
            Colors.grey.shade900,

        style:
            const TextStyle(
          color:
              Colors.white,
        ),

        icon:
            const Icon(
          Icons.arrow_drop_down,
          color:
              Colors.white70,
        ),

        decoration:
            InputDecoration(
          labelText:
              label,

          labelStyle:
              const TextStyle(
            color:
                Colors.white70,
          ),

          prefixIcon:
              Icon(
            icon,
            color:
                Colors.white70,
          ),

          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),

            borderSide:
                BorderSide(
              color: Colors.white
                  .withValues(
                alpha: 0.30,
              ),
            ),
          ),

          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),

            borderSide:
                const BorderSide(
              color:
                  Colors.white,
              width: 2,
            ),
          ),
        ),

        items: items
            .map(
              (item) =>
                  DropdownMenuItem<String>(
                value:
                    item,
                child:
                    Text(item),
              ),
            )
            .toList(),

        onChanged:
            onChanged,

        validator:
            (value) {
          if (value == null) {
            return '$label is required';
          }

          return null;
        },
      ),
    );
  }
}