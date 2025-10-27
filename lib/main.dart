
import 'dart:async';

import 'package:ctc/app.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    _showErrorSnackBar(details.exceptionAsString());
  };

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
      await initializeDateFormatting('zh_TW', null);
      await initializeDateFormatting('en_US', null);
    
      await Supabase.initialize(  
        url: 'http://coselig.com:8000',
      anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlhdCI6MTc2MTUzNTgwNX0.ZektOIBBAUq3m3wP9M2vjjLnpiBNas1IrLkWV9_9n3A',
    );
    runApp(const AppRoot());
  }, (error, stack) {
    _showErrorSnackBar(error.toString());
  });
}

void _showErrorSnackBar(String message) {
  final context = navigatorKey.currentContext;
  if (context != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}