import 'package:flutter/material.dart';

/// 簡單的錯誤邊界 Widget，用於捕獲渲染錯誤
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final String? errorMessage;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorMessage,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool hasError = false;
  Object? error;
  StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              widget.errorMessage ?? '渲染錯誤',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  hasError = false;
                  error = null;
                  stackTrace = null;
                });
              },
              child: const Text('重試'),
            ),
          ],
        ),
      );
    }

    try {
      return widget.child;
    } catch (e, s) {
      // 捕獲同步錯誤
      print('ErrorBoundary 捕獲到錯誤: $e');
      print('堆疊追蹤: $s');
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            hasError = true;
            error = e;
            stackTrace = s;
          });
        }
      });
      
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}