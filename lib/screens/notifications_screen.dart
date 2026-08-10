import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool showUnreadOnly = false;

  final List<Map<String, dynamic>> notifications = [
    {
      'icon': Icons.chat_bubble_outline,
      'title': 'New Complaint',
      'message': 'A parent has submitted a new complaint.',
      'time': '10 min ago',
      'unread': true,
      'details': [
        'Submitted by: Parent',
        'Subject: Fee Issue',
        'Status: Pending',
        'Submitted: Today',
      ],
    },
    {
      'icon': Icons.how_to_reg,
      'title': 'Attendance Update',
      'message': "Today's attendance has been submitted by teachers.",
      'time': '30 min ago',
      'unread': true,
      'details': [
        'Students Present: 1130',
        'Students Absent: 70',
        'Total Students: 1200',
        'Submitted by: Teachers',
        'Updated: Today, 9:30 AM',
      ],
    },
    {
      'icon': Icons.co_present,
      'title': 'Teacher Update',
      'message': 'A teacher profile was updated.',
      'time': '1 hour ago',
      'unread': false,
      'details': [
        'Teacher: Teacher Name',
        'Action: Profile Updated',
        'Updated: Today',
      ],
    },
    {
      'icon': Icons.family_restroom,
      'title': 'Family Added',
      'message': 'A new family has been added.',
      'time': '2 hours ago',
      'unread': false,
      'details': [
        'Family: Family Name',
        'Children: 2',
        'Added by: Administrator',
        'Added: Today',
      ],
    },
    {
      'icon': Icons.campaign_outlined,
      'title': 'School Announcement',
      'message': 'A new school announcement has been published.',
      'time': '3 hours ago',
      'unread': false,
      'details': [
        'Announcement: School Event',
        'Published by: Administrator',
        'Published: Today',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = showUnreadOnly
        ? notifications.where((notification) {
            return notification['unread'] == true;
          }).toList()
        : notifications;

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
                            'Notifications',
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
                  // All / Unread
                  // =========================

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        _filterButton(
                          title: 'All',
                          selected: !showUnreadOnly,
                          onTap: () {
                            setState(() {
                              showUnreadOnly = false;
                            });
                          },
                        ),

                        const SizedBox(width: 10),

                        _filterButton(
                          title: 'Unread',
                          selected: showUnreadOnly,
                          onTap: () {
                            setState(() {
                              showUnreadOnly = true;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 5),

                  // =========================
                  // Notification List
                  // =========================

                  Expanded(
                    child: filteredNotifications.isEmpty
                        ? Center(
                            child: Text(
                              'No unread notifications',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              20,
                              10,
                              20,
                              20,
                            ),
                            itemCount: filteredNotifications.length,
                            itemBuilder: (context, index) {
                              final notification =
                                  filteredNotifications[index];

                              return _notificationCard(
                                notification: notification,
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
  // Filter Button
  // =========================

  Widget _filterButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white24,
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // =========================
  // Notification Card
  // =========================

  Widget _notificationCard({
    required Map<String, dynamic> notification,
  }) {
    bool isExpanded = notification['expanded'] ?? false;

    return GestureDetector(
      onTap: () {
        setState(() {
          notification['expanded'] = !isExpanded;
          notification['unread'] = false;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification['unread'] == true
              ? Colors.white.withValues(alpha: 0.20)
              : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
          border: notification['unread'] == true
              ? Border.all(
                  color: Colors.white24,
                )
              : null,
        ),
        child: Column(
          children: [
            // =========================
            // Main Notification Row
            // =========================

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    notification['icon'],
                    color: Colors.white,
                    size: 23,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title'],
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight:
                              notification['unread'] == true
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        notification['message'],
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Text(
                        notification['time'],
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // Unread dot / expand icon
                Column(
                  children: [
                    if (notification['unread'] == true)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),

                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white70,
                      size: 22,
                    ),
                  ],
                ),
              ],
            ),

            // =========================
            // Expanded Details
            // =========================

            if (isExpanded) ...[
              const SizedBox(height: 15),

              const Divider(
                color: Colors.white24,
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Details',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              ...List.generate(
                notification['details'].length,
                (index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 6,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        notification['details'][index],
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}