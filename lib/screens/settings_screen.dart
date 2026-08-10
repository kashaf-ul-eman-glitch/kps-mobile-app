import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool announcementsEnabled = true;

  final List<Map<String, dynamic>> settingsSections = [
    {
      'title': 'Account Settings',
      'icon': Icons.person_outline,
      'expanded': false,
      'items': [
        'Profile Information',
        'Change Password',
      ],
    },
    {
      'title': 'Notification Settings',
      'icon': Icons.notifications_none,
      'expanded': false,
      'items': [
        'Notifications',
        'Announcements',
      ],
    },
    {
      'title': 'School Settings',
      'icon': Icons.school_outlined,
      'expanded': false,
      'items': [
        'School Information',
        'Academic Year',
      ],
    },
    {
      'title': 'Appearance',
      'icon': Icons.palette_outlined,
      'expanded': false,
      'items': [
        'Theme',
      ],
    },
    {
      'title': 'About App',
      'icon': Icons.info_outline,
      'expanded': false,
      'items': [
        'App Information',
      ],
    },
  ];

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
                  // =========================
                  // Top Bar
                  // =========================

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Settings',
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

                  // =========================
                  // Description
                  // =========================

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      5,
                      20,
                      18,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Manage your application preferences',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  // =========================
                  // Settings Sections
                  // =========================

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        0,
                        20,
                        25,
                      ),
                      itemCount: settingsSections.length,
                      itemBuilder: (context, index) {
                        final section =
                            settingsSections[index];

                        return _settingsSection(
                          section,
                        );
                      },
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

  // =========================
  // Settings Section
  // =========================

  Widget _settingsSection(
    Map<String, dynamic> section,
  ) {
    final bool isExpanded =
        section['expanded'] ?? false;

    final List<dynamic> items =
        section['items'] ?? [];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white24,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              setState(() {
                section['expanded'] =
                    !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      section['icon'],
                      color: Colors.white,
                      size: 25,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Text(
                      section['title'],
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),

          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                12,
              ),
              child: Column(
                children: items.map<Widget>(
                  (item) {
                    return _settingItem(
                      item.toString(),
                    );
                  },
                ).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // =========================
  // Individual Setting
  // =========================

  Widget _settingItem(
    String item,
  ) {
    if (item == 'Notifications') {
      return _switchItem(
        title: 'Notifications',
        value: notificationsEnabled,
        onChanged: (value) {
          setState(() {
            notificationsEnabled = value;
          });
        },
      );
    }

    if (item == 'Announcements') {
      return _switchItem(
        title: 'Announcements',
        value: announcementsEnabled,
        onChanged: (value) {
          setState(() {
            announcementsEnabled = value;
          });
        },
      );
    }

 return Material(
  color: Colors.black.withValues(alpha: 0.12),
  borderRadius: BorderRadius.circular(12),
  child: ListTile(
      
        dense: true,
        leading: const Icon(
          Icons.settings_outlined,
          color: Colors.white70,
          size: 20,
        ),
        title: Text(
          item,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.white54,
          size: 20,
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$item - Coming Soon',
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================
  // Switch Setting
  // =========================

  Widget _switchItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Material(
  color: Colors.black.withValues(alpha: 0.12),
  borderRadius: BorderRadius.circular(12),
      child: SwitchListTile(
        dense: true,
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
        value: value,
        onChanged: onChanged,
      thumbColor: WidgetStatePropertyAll(Colors.white),
      trackColor: WidgetStatePropertyAll(Colors.brown),
      ),
    );
  }
}