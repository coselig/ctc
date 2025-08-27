import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({
    super.key,
    required this.onThemeToggle,
    required this.currentThemeMode,
  });

  final VoidCallback onThemeToggle;
  final ThemeMode currentThemeMode;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final supabase = Supabase.instance.client;

      if (_isSignUp) {
        await supabase.auth.signUp(email: email, password: password);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('請檢查您的電子郵件以完成註冊')));
        }
      } else {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('錯誤: ${e.toString()}')));
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  IconData _getThemeIcon() {
    switch (widget.currentThemeMode) {
      case ThemeMode.light:
        return Icons.wb_sunny;
      case ThemeMode.dark:
        return Icons.nightlight_round;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_isSignUp ? '註冊' : '登入'),
        actions: [
          IconButton(
            icon: Icon(_getThemeIcon()),
            onPressed: widget.onThemeToggle,
            tooltip: '切換主題',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: AutofillGroup(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: '電子郵件',
                              hintText: '請輸入您的電子郵件',
                              prefixIcon: Icon(Icons.email),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '請輸入電子郵件';
                              }
                              if (!value.contains('@')) {
                                return '請輸入有效的電子郵件';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: '密碼',
                              hintText: '請輸入您的密碼',
                              prefixIcon: Icon(Icons.lock),
                            ),
                            obscureText: true,
                            autofillHints: const [AutofillHints.password],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '請輸入密碼';
                              }
                              if (value.length < 6) {
                                return '密碼長度至少為6個字符';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSubmit,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(_isSignUp ? '註冊' : '登入'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _isSignUp = !_isSignUp;
                                    });
                                  },
                            child: Text(_isSignUp ? '已有帳號？登入' : '沒有帳號？註冊'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
