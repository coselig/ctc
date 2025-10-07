import 'package:flutter/material.dart';

class MyFirstWidgetState extends StatefulWidget {
  const MyFirstWidgetState({super.key});

  @override
  State<MyFirstWidgetState> createState() => _MyFirstWidgetStateState();
}

class _MyFirstWidgetStateState extends State<MyFirstWidgetState> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}