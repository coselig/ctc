
import 'dart:async';

import 'package:ctc/app.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // 全域錯誤處理
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    _showErrorSnackBar(details.exceptionAsString());
  };

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
      // 初始化日期格式化 (支援中文和英文)
      await initializeDateFormatting('zh_TW', null);
      await initializeDateFormatting('en_US', null);
    
    await Supabase.initialize(
        url: 'https://coselig.com/api',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE',
    );
    runApp(const AppRoot());
  }, (error, stack) {
    _showErrorSnackBar(error.toString());
  });
}

// SnackBar 顯示錯誤
void _showErrorSnackBar(String message) {
  // 需與 app.dart 的 navigatorKey 對應
  final context = navigatorKey.currentContext;
  if (context != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('資料庫錯誤: $message')),
    );
  }
}