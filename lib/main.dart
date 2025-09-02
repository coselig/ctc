import 'package:ctc/app.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qikzlcnsyiihftudbmkp.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFpa3psY25zeWlpaGZ0dWRibWtwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM3MzI3NDcsImV4cCI6MjA2OTMwODc0N30.Sjy7wm7gqgXfOy48aW52w9lYD8UdeBoKe3AGY1NaUPk',
  );

/*
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE
http://192.168.1.10:54321
*/
  runApp(const MyApp());
}
