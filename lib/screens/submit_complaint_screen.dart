import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubmitComplaintScreen extends StatefulWidget {
  const SubmitComplaintScreen({super.key});

  @override
  State<SubmitComplaintScreen> createState() => _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState extends State<SubmitComplaintScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Dummy list of students linked to the logged-in parent
  final List<Map<String, String>> children = [
    {'name': 'Ali Raza', 'id': 'ST-101'},
    {'name': 'Sara Raza', 'id': 'ST-102'},
  ];

  late String _selectedStudentId;

  @override
  void initState() {
    super.initState();
    _selectedStudentId = children.first['id']!;
  }

  InputDecoration _customInputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.white60, fontSize: 13),
      labelStyle: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white70),
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
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.black.withValues(alpha: 0.25),
            child: SafeArea(
              child: Column(
                children: [
                  const _TopBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Select Student Dropdown
                          DropdownButtonFormField<String>(
                            initialValue: _selectedStudentId,
                            dropdownColor: Colors.brown[300],
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                            decoration: _customInputDecoration('Select Child'),
                            items: children
                                .map(
                                  (child) => DropdownMenuItem(
                                    value: child['id'],
                                    child: Text('${child['name']} (${child['id']})'),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) => setState(() => _selectedStudentId = val!),
                          ),
                          const SizedBox(height: 16),

                          // Subject Textfield
                          TextField(
                            controller: _subjectController,
                            style: GoogleFonts.poppins(color: Colors.white),
                            decoration: _customInputDecoration(
                              'Subject',
                              hint: 'E.g., Bus route delay / Fee query...',
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Complaint Details Multiline Field
                          TextField(
                            controller: _descriptionController,
                            maxLines: 6,
                            style: GoogleFonts.poppins(color: Colors.white),
                            decoration: _customInputDecoration(
                              'Complaint Details',
                              hint: 'Describe your issue in detail...',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Submit Complaint Action Button
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // Validation Check
                          if (_subjectController.text.trim().isEmpty ||
                              _descriptionController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill in all fields')),
                            );
                            return;
                          }

                          // Future backend call to insert into complaints collection
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Complaint submitted to Admin (dummy)')),
                          );
                        },
                        child: Text(
                          'Submit Complaint',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

/// Simple top bar with title matching the app design theme
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 20, 0),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          Text(
            'Submit Complaint',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}