import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubjectManagementScreen extends StatefulWidget {
  const SubjectManagementScreen({super.key});

  @override
  State<SubjectManagementScreen> createState() =>
      _SubjectManagementScreenState();
}

class _SubjectManagementScreenState
    extends State<SubjectManagementScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // CLASSES
  // ============================================================

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

  // ============================================================
  // GROUPS
  // ============================================================

  final List<String> groupList = [
    'All',
    'Pre-Medical',
    'Pre-Engineering',
    'ICS',
  ];

  String? selectedClass;
  String selectedGroup = 'All';

  final TextEditingController subjectNameController =
      TextEditingController();

  final TextEditingController subjectCodeController =
      TextEditingController();

  // ============================================================
  // FIRESTORE COLLECTION
  // ============================================================

  CollectionReference<Map<String, dynamic>>
      get subjectsCollection {
    return _firestore
        .collection('classes')
        .doc(selectedClass)
        .collection('subjects');
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    subjectNameController.dispose();
    subjectCodeController.dispose();
    super.dispose();
  }

  // ============================================================
  // ADD SUBJECT
  // ============================================================

  Future<void> _addSubject() async {
    final subjectName =
        subjectNameController.text.trim();

    final subjectCode =
        subjectCodeController.text.trim();

    if (selectedClass == null) {
      _showMessage(
        'Please select a class first.',
        isError: true,
      );
      return;
    }

    if (subjectName.isEmpty) {
      _showMessage(
        'Please enter subject name.',
        isError: true,
      );
      return;
    }

    try {
      await subjectsCollection.add({
        'name': subjectName,
        'code': subjectCode,
        'group': selectedGroup,
        'class': selectedClass,
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      subjectNameController.clear();
      subjectCodeController.clear();

      if (mounted) {
        Navigator.pop(context);
      }

      _showMessage(
        'Subject added successfully.',
      );
    } catch (e) {
      _showMessage(
        'Error adding subject: $e',
        isError: true,
      );
    }
  }

  // ============================================================
  // ADD SUBJECT FORM
  // ============================================================

  void _showAddSubjectForm() {
    subjectNameController.clear();
    subjectCodeController.clear();

    selectedGroup = 'All';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Add New Subject',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // SUBJECT NAME
                TextField(
                  controller: subjectNameController,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Subject Name',
                    hintText: 'e.g. English',
                    labelStyle: const TextStyle(
                      color: Colors.white70,
                    ),
                    hintStyle: const TextStyle(
                      color: Colors.white38,
                    ),
                    prefixIcon: const Icon(
                      Icons.menu_book,
                      color: Colors.white70,
                    ),
                    enabledBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(
                        color: Colors.white30,
                      ),
                    ),
                    focusedBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // SUBJECT CODE
                TextField(
                  controller: subjectCodeController,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Subject Code',
                    hintText: 'e.g. ENG',
                    labelStyle: const TextStyle(
                      color: Colors.white70,
                    ),
                    hintStyle: const TextStyle(
                      color: Colors.white38,
                    ),
                    prefixIcon: const Icon(
                      Icons.code,
                      color: Colors.white70,
                    ),
                    enabledBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(
                        color: Colors.white30,
                      ),
                    ),
                    focusedBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // GROUP
                StatefulBuilder(
                  builder: (
                    context,
                    setDialogState,
                  ) {
                    return DropdownButtonFormField<
                        String>(
                      initialValue: selectedGroup,
                      dropdownColor:
                          Colors.grey.shade900,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration:
                          InputDecoration(
                        labelText: 'Group',
                        labelStyle:
                            const TextStyle(
                          color: Colors.white70,
                        ),
                        prefixIcon:
                            const Icon(
                          Icons.groups,
                          color: Colors.white70,
                        ),
                        enabledBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                          borderSide:
                              const BorderSide(
                            color: Colors.white30,
                          ),
                        ),
                      ),
                      items: groupList.map(
                        (group) {
                          return DropdownMenuItem(
                            value: group,
                            child: Text(group),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedGroup = value;
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: _addSubject,
              icon: const Icon(Icons.add),
              label: const Text('Add Subject'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // EDIT SUBJECT
  // ============================================================

  Future<void> _editSubject(
    DocumentSnapshot<Map<String, dynamic>>
        document,
  ) async {
    final data = document.data();

    if (data == null) return;

    final nameController =
        TextEditingController(
      text: data['name']?.toString() ?? '',
    );

    final codeController =
        TextEditingController(
      text: data['code']?.toString() ?? '',
    );

    String editGroup =
        data['group']?.toString() ?? 'All';

    if (!groupList.contains(editGroup)) {
      editGroup = 'All';
    }

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              backgroundColor:
                  Colors.grey.shade900,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(18),
              ),
              title: Text(
                'Edit Subject',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [

                    TextField(
                      controller:
                          nameController,
                      style:
                          const TextStyle(
                        color: Colors.white,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Subject Name',
                        labelStyle:
                            TextStyle(
                          color:
                              Colors.white70,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    TextField(
                      controller:
                          codeController,
                      style:
                          const TextStyle(
                        color: Colors.white,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Subject Code',
                        labelStyle:
                            TextStyle(
                          color:
                              Colors.white70,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    DropdownButtonFormField<
                        String>(
                      initialValue:
                          editGroup,
                      dropdownColor:
                          Colors.grey.shade900,
                      style:
                          const TextStyle(
                        color: Colors.white,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText: 'Group',
                        labelStyle:
                            TextStyle(
                          color:
                              Colors.white70,
                        ),
                      ),
                      items: groupList.map(
                        (group) {
                          return DropdownMenuItem(
                            value: group,
                            child:
                                Text(group),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setDialogState(() {
                          editGroup =
                              value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(
                    dialogContext,
                  ),
                  child:
                      const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newName =
                        nameController
                            .text
                            .trim();

                    final newCode =
                        codeController
                            .text
                            .trim();

                    if (newName.isEmpty) {
                      return;
                    }

                    try {
                      await document
                          .reference
                          .update({
                        'name': newName,
                        'code': newCode,
                        'group': editGroup,
                        'updatedAt':
                            FieldValue
                                .serverTimestamp(),
                      });

                      if (dialogContext
                          .mounted) {
                        Navigator.pop(
                          dialogContext,
                        );
                      }

                      _showMessage(
                        'Subject updated successfully.',
                      );
                    } catch (e) {
                      _showMessage(
                        'Update error: $e',
                        isError: true,
                      );
                    }
                  },
                  child:
                      const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    codeController.dispose();
  }

  // ============================================================
  // DELETE SUBJECT
  // ============================================================

  Future<void> _deleteSubject(
    DocumentSnapshot<Map<String, dynamic>>
        document,
  ) async {
    final data = document.data();

    final subjectName =
        data?['name']?.toString() ??
            'this subject';

    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Subject',
          ),
          content: Text(
            'Are you sure you want to delete $subjectName?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                false,
              ),
              child:
                  const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                true,
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await document.reference.delete();

      _showMessage(
        'Subject deleted successfully.',
      );
    } catch (e) {
      _showMessage(
        'Delete error: $e',
        isError: true,
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red : Colors.green,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Subject Management',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),

      floatingActionButton:
          selectedClass == null
              ? null
              : FloatingActionButton.extended(
                  onPressed:
                      _showAddSubjectForm,
                  backgroundColor:
                      Colors.white,
                  foregroundColor:
                      Colors.black,
                  icon: const Icon(
                    Icons.add,
                  ),
                  label: const Text(
                    'New Subject',
                  ),
                ),

      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.all(20),
          child: Column(
            children: [

              // ==================================================
              // CLASS
              // ==================================================

              DropdownButtonFormField<
                  String>(
                initialValue:
                    selectedClass,
                dropdownColor:
                    Colors.grey.shade900,
                style:
                    const TextStyle(
                  color: Colors.white,
                ),
                decoration:
                    InputDecoration(
                  labelText:
                      'Select Class',
                  labelStyle:
                      const TextStyle(
                    color:
                        Colors.white70,
                  ),
                  prefixIcon:
                      const Icon(
                    Icons.school,
                    color:
                        Colors.white70,
                  ),
                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      12,
                    ),
                    borderSide:
                        const BorderSide(
                      color:
                          Colors.white30,
                    ),
                  ),
                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      12,
                    ),
                    borderSide:
                        const BorderSide(
                      color:
                          Colors.white,
                    ),
                  ),
                ),
                items:
                    classList.map(
                  (className) {
                    return DropdownMenuItem<
                        String>(
                      value:
                          className,
                      child: Text(
                        className,
                      ),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedClass =
                        value;
                  });
                },
              ),

              const SizedBox(
                height: 20,
              ),

              // ==================================================
              // GROUP FILTER
              // ==================================================

              if (selectedClass != null)
                DropdownButtonFormField<
                    String>(
                  initialValue:
                      selectedGroup,
                  dropdownColor:
                      Colors.grey.shade900,
                  style:
                      const TextStyle(
                    color: Colors.white,
                  ),
                  decoration:
                      InputDecoration(
                    labelText:
                        'Filter by Group',
                    labelStyle:
                        const TextStyle(
                      color:
                          Colors.white70,
                    ),
                    prefixIcon:
                        const Icon(
                      Icons.groups,
                      color:
                          Colors.white70,
                    ),
                    enabledBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                      borderSide:
                          const BorderSide(
                        color:
                            Colors.white30,
                      ),
                    ),
                  ),
                  items:
                      groupList.map(
                    (group) {
                      return DropdownMenuItem<
                          String>(
                        value: group,
                        child:
                            Text(group),
                      );
                    },
                  ).toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      selectedGroup =
                          value;
                    });
                  },
                ),

              const SizedBox(
                height: 20,
              ),

              // ==================================================
              // SUBJECT LIST
              // ==================================================

              Expanded(
                child:
                    selectedClass == null
                        ? const Center(
                            child: Text(
                              'Select a class to manage subjects.',
                              style:
                                  TextStyle(
                                color:
                                    Colors.white70,
                                fontSize:
                                    16,
                              ),
                            ),
                          )
                        : StreamBuilder<
                            QuerySnapshot<
                                Map<String,
                                    dynamic>>>(
                            stream:
                                subjectsCollection
                                    .orderBy(
                                      'name',
                                    )
                                    .snapshots(),
                            builder: (
                              context,
                              snapshot,
                            ) {
                              if (snapshot
                                  .hasError) {
                                return Center(
                                  child:
                                      Text(
                                    'Error: ${snapshot.error}',
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.red,
                                    ),
                                  ),
                                );
                              }

                              if (snapshot
                                      .connectionState ==
                                  ConnectionState
                                      .waiting) {
                                return const Center(
                                  child:
                                      CircularProgressIndicator(),
                                );
                              }

                              final allSubjects =
                                  snapshot
                                          .data
                                          ?.docs ??
                                      [];

                              final subjects =
                                  allSubjects
                                      .where(
                                (document) {
                                  if (selectedGroup ==
                                      'All') {
                                    return true;
                                  }

                                  final group =
                                      document.data()[
                                              'group']
                                          ?.toString() ??
                                      'All';

                                  return group ==
                                      selectedGroup;
                                },
                              ).toList();

                              if (subjects
                                  .isEmpty) {
                                return Center(
                                  child:
                                      Text(
                                    'No subjects found for $selectedClass.',
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.white70,
                                      fontSize:
                                          16,
                                    ),
                                    textAlign:
                                        TextAlign
                                            .center,
                                  ),
                                );
                              }

                              return ListView
                                  .builder(
                                itemCount:
                                    subjects
                                        .length,
                                itemBuilder:
                                    (
                                  context,
                                  index,
                                ) {
                                  final document =
                                      subjects[
                                          index];

                                  final data =
                                      document
                                          .data();

                                  final name =
                                      data['name']
                                              ?.toString() ??
                                          'Unnamed Subject';

                                  final code =
                                      data['code']
                                              ?.toString() ??
                                          '';

                                  final group =
                                      data['group']
                                              ?.toString() ??
                                          'All';

                                  return Card(
                                    color: Colors
                                        .white
                                        .withValues(
                                      alpha:
                                          0.10,
                                    ),
                                    margin:
                                        const EdgeInsets
                                            .only(
                                      bottom:
                                          12,
                                    ),
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        14,
                                      ),
                                    ),
                                    child:
                                        ListTile(
                                      contentPadding:
                                          const EdgeInsets
                                              .symmetric(
                                        horizontal:
                                            16,
                                        vertical:
                                            6,
                                      ),
                                      leading:
                                          CircleAvatar(
                                        backgroundColor:
                                            Colors
                                                .white12,
                                        child:
                                            const Icon(
                                          Icons
                                              .menu_book,
                                          color: Colors
                                              .white,
                                        ),
                                      ),
                                      title:
                                          Text(
                                        name,
                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.white,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          fontSize:
                                              16,
                                        ),
                                      ),
                                      subtitle:
                                          Text(
                                        code.isEmpty
                                            ? 'Group: $group'
                                            : 'Code: $code  •  Group: $group',
                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.white70,
                                        ),
                                      ),
                                      trailing:
                                          Row(
                                        mainAxisSize:
                                            MainAxisSize
                                                .min,
                                        children: [

                                          // EDIT
                                          IconButton(
                                            tooltip:
                                                'Edit',
                                            icon:
                                                const Icon(
                                              Icons
                                                  .edit,
                                              color:
                                                  Colors.white,
                                            ),
                                            onPressed:
                                                () =>
                                                    _editSubject(
                                              document,
                                            ),
                                          ),

                                          // DELETE
                                          IconButton(
                                            tooltip:
                                                'Delete',
                                            icon:
                                                const Icon(
                                              Icons
                                                  .delete,
                                              color:
                                                  Colors.redAccent,
                                            ),
                                            onPressed:
                                                () =>
                                                    _deleteSubject(
                                              document,
                                            ),
                                          ),
                                        ],
                                      ),
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
    );
  }
}