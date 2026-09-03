import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeeManagementScreen extends StatefulWidget {
  const FeeManagementScreen({super.key});

  @override
  State<FeeManagementScreen> createState() => _FeeManagementScreenState();
}

class _FeeManagementScreenState extends State<FeeManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? selectedClass;

  final TextEditingController tuitionController = TextEditingController();
  final TextEditingController labController = TextEditingController();
  final TextEditingController lateFeeController = TextEditingController();
  final TextEditingController dueDayController = TextEditingController(text: '10');

  bool isApplying = false;

  final List<String> classes = const [
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

  @override
  void dispose() {
    tuitionController.dispose();
    labController.dispose();
    lateFeeController.dispose();
    dueDayController.dispose();
    super.dispose();
  }

  double _number(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  String _money(dynamic value) {
    return 'Rs. ${_number(value).toStringAsFixed(0)}';
  }

  Future<void> _applyFeeToClass() async {
    if (selectedClass == null) {
      _showMessage('Please select a class first.');
      return;
    }

    final tuition = double.tryParse(tuitionController.text.trim());
    final lab = double.tryParse(labController.text.trim());
    final lateFee = double.tryParse(lateFeeController.text.trim());
    final dueDay = int.tryParse(dueDayController.text.trim());

    if (tuition == null || tuition < 0) {
      _showMessage('Please enter a valid tuition fee.');
      return;
    }

    if (lab == null || lab < 0) {
      _showMessage('Please enter a valid lab fee.');
      return;
    }

    if (lateFee == null || lateFee < 0) {
      _showMessage('Please enter a valid late fee.');
      return;
    }

    if (dueDay == null || dueDay < 1 || dueDay > 31) {
      _showMessage('Due day must be between 1 and 31.');
      return;
    }

    setState(() {
      isApplying = true;
    });

    try {
      final studentsSnapshot = await _firestore
          .collection('classes')
          .doc(selectedClass)
          .collection('students')
          .get();

      if (studentsSnapshot.docs.isEmpty) {
        _showMessage('No students found in $selectedClass.');
        if (mounted) {
          setState(() {
            isApplying = false;
          });
        }
        return;
      }

      final batch = _firestore.batch();

      for (final student in studentsSnapshot.docs) {
        final feeRef = student.reference;
        batch.set(
          feeRef,
          {
            'tuitionFee': tuition,
            'labFee': lab,
            'lateFee': lateFee,
            'feeDueDay': dueDay,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      await batch.commit();
      _showMessage('Fee updated for all students of $selectedClass.');
    } catch (e) {
      _showMessage('Failed to update class fee: $e');
    }

    if (mounted) {
      setState(() {
        isApplying = false;
      });
    }
  }

  Future<void> _deleteFee(DocumentReference studentRef) async {
    try {
      await studentRef.update({
        'tuitionFee': FieldValue.delete(),
        'labFee': FieldValue.delete(),
        'lateFee': FieldValue.delete(),
        'feeDueDay': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _showMessage('Fee record deleted.');
    } catch (e) {
      _showMessage('Failed to delete fee: $e');
    }
  }

  Future<void> _editFee(DocumentSnapshot<Map<String, dynamic>> student) async {
    final data = student.data() ?? {};

    final editTuitionController = TextEditingController(
      text: _number(data['tuitionFee']).toStringAsFixed(0),
    );
    final editLabController = TextEditingController(
      text: _number(data['labFee']).toStringAsFixed(0),
    );
    final editLateFeeController = TextEditingController(
      text: _number(data['lateFee']).toStringAsFixed(0),
    );
    final editDueDayController = TextEditingController(
      text: (data['feeDueDay'] ?? 10).toString(),
    );

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1D2140).withOpacity(0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          title: Text(
            'Edit Fee',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(
                  controller: editTuitionController,
                  label: 'Monthly Tuition Fee',
                  icon: Icons.school_rounded,
                ),
                const SizedBox(height: 12),
                _dialogField(
                  controller: editLabController,
                  label: 'Computer & Lab Charges',
                  icon: Icons.computer_rounded,
                ),
                const SizedBox(height: 12),
                _dialogField(
                  controller: editLateFeeController,
                  label: 'Late Fee',
                  icon: Icons.warning_rounded,
                ),
                const SizedBox(height: 12),
                _dialogField(
                  controller: editDueDayController,
                  label: 'Due Day',
                  icon: Icons.calendar_month_rounded,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final tuition = double.tryParse(editTuitionController.text.trim());
                final lab = double.tryParse(editLabController.text.trim());
                final lateFee = double.tryParse(editLateFeeController.text.trim());
                final dueDay = int.tryParse(editDueDayController.text.trim());

                if (tuition == null || lab == null || lateFee == null || dueDay == null || dueDay < 1 || dueDay > 31) {
                  return;
                }

                try {
                  await student.reference.update({
                    'tuitionFee': tuition,
                    'labFee': lab,
                    'lateFee': lateFee,
                    'feeDueDay': dueDay,
                    'updatedAt': FieldValue.serverTimestamp(),
                  });

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }

                  _showMessage('Fee updated successfully.');
                } catch (e) {
                  _showMessage('Failed to update fee: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1).withOpacity(0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Update',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    editTuitionController.dispose();
    editLabController.dispose();
    editLateFeeController.dispose();
    editDueDayController.dispose();
  }

  Widget _dialogField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFFA5B4FC)),
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
        child: Container(
          // Dark overlay over image
          color: Colors.black.withOpacity(0.65),
          child: SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      ),
                      Expanded(
                        child: Text(
                          'Fee Management',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Transparent Class Dropdown Container
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 5, 20, 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedClass,
                        isExpanded: true,
                        // Transparent Dropdown Menu Background
                        dropdownColor: Colors.black.withOpacity(0.85),
                        hint: Text(
                          'Select Class',
                          style: GoogleFonts.poppins(color: Colors.white70),
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                        items: classes.map((className) {
                          return DropdownMenuItem<String>(
                            value: className,
                            child: Text(
                              className,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedClass = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                // Transparent Apply Fee Box
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedClass == null ? 'Add Class Fee' : 'Add Fee for $selectedClass',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _inputField(tuitionController, 'Tuition', Icons.school)),
                            const SizedBox(width: 8),
                            Expanded(child: _inputField(labController, 'Lab', Icons.computer)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _inputField(lateFeeController, 'Late Fee', Icons.warning)),
                            const SizedBox(width: 8),
                            Expanded(child: _inputField(dueDayController, 'Due Day', Icons.calendar_month)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: isApplying ? null : _applyFeeToClass,
                            icon: isApplying
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.playlist_add_check_rounded),
                            label: Text(
                              'Apply Fee to All Students',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(color: Colors.white.withOpacity(0.3)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Student List (Transparent Boxes)
                Expanded(
                  child: selectedClass == null
                      ? Center(
                          child: Text(
                            'Select a class to view students',
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                          ),
                        )
                      : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: _firestore
                              .collection('classes')
                              .doc(selectedClass)
                              .collection('students')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator(color: Colors.white));
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Unable to load students.', style: GoogleFonts.poppins(color: Colors.white70)),
                              );
                            }

                            final students = snapshot.data?.docs ?? [];

                            if (students.isEmpty) {
                              return Center(
                                child: Text('No students found in $selectedClass.', style: GoogleFonts.poppins(color: Colors.white70)),
                              );
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
                              itemCount: students.length,
                              itemBuilder: (context, index) {
                                final student = students[index];
                                final data = student.data();

                                final name = data['name'] ?? data['studentName'] ?? student.id;
                                final tuition = _number(data['tuitionFee']);
                                final lab = _number(data['labFee']);
                                final total = tuition + lab;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 45,
                                        height: 45,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: const Icon(Icons.person, color: Colors.white),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name.toString(),
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              total > 0 ? 'Total: ${_money(total)}' : 'Fee not added',
                                              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Edit',
                                        onPressed: () => _editFee(student),
                                        icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                                      ),
                                      IconButton(
                                        tooltip: 'Delete',
                                        onPressed: () => _confirmDelete(student.reference, name.toString()),
                                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70, size: 18),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.white54, fontSize: 11),
        filled: true,
        fillColor: Colors.black.withOpacity(0.25),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(DocumentReference studentRef, String studentName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1D2140).withOpacity(0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          title: Text(
            'Delete Fee?',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Delete fee information for $studentName?',
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: Text('Delete', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _deleteFee(studentRef);
    }
  }
}