import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _busy = false;
  bool _showPassword = false;
  String? _error;
  String? _notice;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });

    try {
      final api = ref.read(apiClientProvider);
      final registering = _register;
      final result = registering
          ? await api.register(
              email: _email.text.trim(),
              password: _password.text,
              displayName: _name.text.trim(),
            )
          : await api.login(
              email: _email.text.trim(),
              password: _password.text,
            );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', result['token'] as String);
      if (mounted) {
        setState(() {
          _notice = registering
              ? 'Account created successfully.'
              : 'Signed in successfully.';
        });
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      setState(() => _error = data is Map
          ? (data['error']?.toString() ?? 'Request failed')
          : 'Could not connect to the API. Is the Go server running?');
    } catch (_) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F3),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    child: _AuthCard(
                      formKey: _formKey,
                      nameController: _name,
                      emailController: _email,
                      passwordController: _password,
                      register: _register,
                      busy: _busy,
                      errorText: _error,
                      noticeText: _notice,
                      showPassword: _showPassword,
                      onToggleMode: () => setState(() {
                        _register = !_register;
                        _error = null;
                        _notice = null;
                      }),
                      onTogglePassword: () => setState(() {
                        _showPassword = !_showPassword;
                      }),
                      onSubmit: _submit,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.register,
    required this.busy,
    required this.errorText,
    required this.noticeText,
    required this.showPassword,
    required this.onToggleMode,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool register;
  final bool busy;
  final String? errorText;
  final String? noticeText;
  final bool showPassword;
  final VoidCallback onToggleMode;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 26),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          border: Border.all(
              color: Colors.black.withValues(alpha: 0.18), width: 1.4),
          borderRadius: BorderRadius.circular(0),
        ),
        padding: const EdgeInsets.fromLTRB(10, 16, 10, 14),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  register ? 'Sign up' : 'Sign in',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 54,
                        height: 0.95,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -2,
                        color: Colors.black,
                      ),
                ),
              ),
              const SizedBox(height: 22),
              if (register) ...[
                _FieldLabel(text: 'Name'),
                const SizedBox(height: 10),
                _StyledField(
                  controller: nameController,
                  hintText: 'Your full name',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter your name'
                      : null,
                ),
                const SizedBox(height: 18),
              ],
              _FieldLabel(text: 'Email'),
              const SizedBox(height: 10),
              _StyledField(
                controller: emailController,
                hintText: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || !v.contains('@'))
                    ? 'Enter a valid email'
                    : null,
              ),
              const SizedBox(height: 18),
              _FieldLabel(text: 'Password'),
              const SizedBox(height: 10),
              Stack(
                children: [
                  _StyledField(
                    controller: passwordController,
                    hintText:
                        register ? 'Create a password' : 'Enter your password',
                    obscureText: !showPassword,
                    validator: (v) => (v == null || v.length < 8)
                        ? 'Use at least 8 characters'
                        : null,
                  ),
                  Positioned(
                    right: 14,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: onTogglePassword,
                        child: Text(
                          showPassword ? 'Hide' : 'Show',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (!register)
                Align(
                  alignment: Alignment.centerRight,
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              if (errorText != null) ...[
                const SizedBox(height: 12),
                Text(
                  errorText!,
                  style: const TextStyle(
                      color: Colors.red, fontSize: 14, height: 1.4),
                ),
              ],
              if (noticeText != null) ...[
                const SizedBox(height: 12),
                Text(
                  noticeText!,
                  style: const TextStyle(
                    color: Color(0xFF276749),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: busy ? null : onSubmit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1F1F1F),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  child: busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              register ? 'Sign up' : 'Sign in',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 12),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: onToggleMode,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  child: Text(
                    register
                        ? 'Already have an account? Sign in ↗'
                        : 'New around here? Sign up ↗',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.black54,
          ),
    );
  }
}

class _StyledField extends StatelessWidget {
  const _StyledField({
    required this.controller,
    required this.hintText,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(fontSize: 18, color: Colors.black),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle:
            const TextStyle(color: Colors.black38, fontWeight: FontWeight.w400),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black38, width: 1.2),
          borderRadius: BorderRadius.zero,
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black87, width: 1.4),
          borderRadius: BorderRadius.zero,
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.2),
          borderRadius: BorderRadius.zero,
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.4),
          borderRadius: BorderRadius.zero,
        ),
      ),
    );
  }
}
