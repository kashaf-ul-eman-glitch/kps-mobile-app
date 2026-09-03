import 'package:flutter/material.dart';

/// =====================================================
/// SHARED CALENDAR DATA
/// =====================================================
///
/// App-wide single source of truth for Academic Calendar.
///
/// Admin screen:
/// - Add event
/// - Update event
/// - Delete event
///
/// Parent screen:
/// - Read/display events
/// - Expand/collapse event details
///
/// Both screens use the same CalendarData.instance.
/// ChangeNotifier automatically notifies listeners whenever
/// calendar data changes.
///
/// NOTE:
/// This is currently in-memory storage.
/// Data will reset when the app is completely restarted.
/// Later, Firebase/Firestore can be connected here without
/// changing the Parent Calendar UI.
/// =====================================================

class CalendarData extends ChangeNotifier {
  // =====================================================
  // SINGLETON
  // =====================================================

  CalendarData._internal();

  static final CalendarData instance = CalendarData._internal();

  // =====================================================
  // ACADEMIC YEAR
  // =====================================================

  final String academicYear = '2026 - 2027';

  // =====================================================
  // CALENDAR EVENTS
  // =====================================================

  final List<Map<String, dynamic>> events = [
    {
      'date': '10 Aug 2026',
      'title': 'First Day of School',
      'category': 'Academic',
      'icon': Icons.school_outlined,
      'description':
          'First day of the new academic session.',
      'expanded': false,
    },
    {
      'date': '14 Aug 2026',
      'title': 'Independence Day',
      'category': 'Holiday',
      'icon': Icons.flag_outlined,
      'description':
          'School will remain closed on this national holiday.',
      'expanded': false,
    },
    {
      'date': '25 Aug 2026',
      'title': 'Parent-Teacher Meeting',
      'category': 'Event',
      'icon': Icons.groups_outlined,
      'description':
          'Parents and teachers will meet to discuss student progress.',
      'expanded': false,
    },
    {
      'date': '05 Sep 2026',
      'title': 'Monthly Assessment',
      'category': 'Examination',
      'icon': Icons.assignment_outlined,
      'description':
          'Monthly academic assessment for students.',
      'expanded': false,
    },
    {
      'date': '20 Sep 2026',
      'title': 'Mid-Term Examination',
      'category': 'Examination',
      'icon': Icons.edit_note_outlined,
      'description':
          'Mid-term examinations will begin according to the examination schedule.',
      'expanded': false,
    },
  ];

  // =====================================================
  // CATEGORY ICONS
  // =====================================================

  static const Map<String, IconData> categoryIcons = {
    'Academic': Icons.school_outlined,
    'Holiday': Icons.flag_outlined,
    'Event': Icons.groups_outlined,
    'Examination': Icons.assignment_outlined,
  };

  // =====================================================
  // AVAILABLE CATEGORIES
  // =====================================================

  static const List<String> categories = [
    'Academic',
    'Holiday',
    'Event',
    'Examination',
  ];

  // =====================================================
  // ADD EVENT
  // =====================================================

  void addEvent(Map<String, dynamic> event) {
    events.add({
      ...event,
      'expanded': event['expanded'] ?? false,
    });

    notifyListeners();
  }

  // =====================================================
  // UPDATE EVENT
  // =====================================================

  void updateEvent(
    int index,
    Map<String, dynamic> event,
  ) {
    if (index < 0 || index >= events.length) {
      return;
    }

    events[index] = {
      ...event,
      'expanded': event['expanded'] ?? false,
    };

    notifyListeners();
  }

  // =====================================================
  // DELETE EVENT
  // =====================================================

  void deleteEvent(int index) {
    if (index < 0 || index >= events.length) {
      return;
    }

    events.removeAt(index);

    notifyListeners();
  }

  // =====================================================
  // EXPAND / COLLAPSE EVENT
  // =====================================================

  void toggleExpanded(int index) {
    if (index < 0 || index >= events.length) {
      return;
    }

    final currentValue =
        events[index]['expanded'] == true;

    events[index]['expanded'] = !currentValue;

    notifyListeners();
  }
}
