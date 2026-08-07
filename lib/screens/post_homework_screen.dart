import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PostHomeworkScreen extends StatefulWidget {
  const PostHomeworkScreen({super.key});

  @override
  State<PostHomeworkScreen> createState() => _PostHomeworkScreenState();
}

class _PostHomeworkScreenState extends State<PostHomeworkScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _selectedSubject = 'Mathematics';
  final List<String> subjects = ['Mathematics', 'Science'];

  // Dummy posted homework — will come from `homework` table later.
  final List<Map<String, String>> postedHomework = [
    {'subject': 'Mathematics', 'title': 'Exercise 4.2', 'due': '10 Aug 2026'},
    {'subject': 'Science', 'title': 'Chapter 3 Questions', 'due': '08 Aug 2026'},
  ];

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
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
                  _TopBar(),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            children: [
                              DropdownButtonFormField<String>(
                                initialValue: _selectedSubject,
                                dropdownColor: Colors.brown[300],
                                style: GoogleFonts.poppins(color: Colors.white),
                                decoration: _fieldDecoration('Subject'),
                                items: subjects
                                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                    .toList(),
                                onChanged: (val) => setState(() => _selectedSubject = val!),
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: _titleController,
                                style: GoogleFonts.poppins(color: Colors.white),
                                decoration: _fieldDecoration('Title'),
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: _descController,
                                maxLines: 3,
                                style: GoogleFonts.poppins(color: Colors.white),
                                decoration: _fieldDecoration('Description'),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.brown,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () {
                                    if (_titleController.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please enter a title')),
                                      );
                                      return;
                                    }
                                    setState(() {
                                      postedHomework.insert(0, {
                                        'subject': _selectedSubject,
                                        'title': _titleController.text.trim(),
                                        'due': 'TBD',
                                      });
                                      _titleController.clear();
                                      _descController.clear();
                                    });
                                    // Will insert into `homework` table via Supabase later.
                                  },
                                  child: Text(
                                    'Post Homework',
                                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Recently Posted',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        ...postedHomework.map(
                          (h) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.menu_book, color: Colors.white),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        h['title']!,
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
                                      ),
                                      Text(
                                        '${h['subject']} • Due: ${h['due']}',
                                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }
}

/// Simple top bar with the screen title, styled the same way as
/// the rest of the app (Poppins, white text over the blurred image).
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
            'Post Homework',
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