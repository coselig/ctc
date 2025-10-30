import 'package:flutter/material.dart';

class SystemCardData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget page;

  SystemCardData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.page,
  });
}