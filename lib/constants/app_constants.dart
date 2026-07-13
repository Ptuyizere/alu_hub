import 'package:flutter/material.dart';

class AppConstants {
  // Academic program constants
  static const List<String> academicPrograms = [
    'Software Engineering (BSc)', 
    'Entrepreneurial Leadership (BSc)', 
    'International Business & Trade (BSc)',
  ];

  // Roles constants
  static const List<String> roleTypes = [
    'Software Development', 
    'Design', 
    'Marketing', 
    'Operations', 
    'Research', 
    'Business Analysis', 
    'Content Creation', 
    'Community Management', 
    'Other'
  ];

  // Location constants
  static const List<String> locationTypes = ['Remote', 'On-Campus'];

  // Compensation constants
  static const List<String> compensationTypes = ['Paid', 'Shares Based', 'Unpaid'];

  // Theme colors
  static const Color primaryColor = Color(0xFF0A5C36);
  static const Color secondaryColor = Color(0xFF0D9488);
  static const Color accentColor = Color(0xFF14B8A6);
  static const Color backgroundColor = Color(0xFF0B0F19);
  static const Color cardColor = Color(0xFF1E293B);
  static const Color textPrimaryColor = Color(0xFFF8FAFC);
  static const Color textSecondaryColor = Color(0xFF94A3B8);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);

  // Font family
  static const String fontFamily = 'Outfit';
}
