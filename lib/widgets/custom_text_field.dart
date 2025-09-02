import 'package:flutter/material.dart';

/// 自定義輸入欄位
/// 統一的輸入欄位樣式
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}

/// 電子郵件輸入欄位
class EmailTextField extends StatelessWidget {
  const EmailTextField({
    super.key,
    required this.controller,
    this.onSubmitted,
    this.validator,
  });

  final TextEditingController controller;
  final void Function(String)? onSubmitted;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: '電子郵件',
      hintText: '請輸入您的電子郵件',
      keyboardType: TextInputType.emailAddress,
      prefixIcon: const Icon(Icons.email),
      onSubmitted: onSubmitted,
      validator: validator ?? _defaultEmailValidator,
    );
  }

  String? _defaultEmailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入電子郵件';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return '請輸入有效的電子郵件格式';
    }
    return null;
  }
}

/// 密碼輸入欄位
class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    super.key,
    required this.controller,
    this.labelText = '密碼',
    this.onSubmitted,
    this.validator,
  });

  final TextEditingController controller;
  final String labelText;
  final void Function(String)? onSubmitted;
  final String? Function(String?)? validator;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      labelText: widget.labelText,
      obscureText: _obscureText,
      prefixIcon: const Icon(Icons.lock),
      suffixIcon: IconButton(
        icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
        onPressed: () => setState(() => _obscureText = !_obscureText),
      ),
      onSubmitted: widget.onSubmitted,
      validator: widget.validator ?? _defaultPasswordValidator,
    );
  }

  String? _defaultPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入密碼';
    }
    if (value.length < 6) {
      return '密碼至少需要6個字符';
    }
    return null;
  }
}
