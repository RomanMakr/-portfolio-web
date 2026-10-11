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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 680;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 24 : 36,
                      vertical: isCompact ? 32 : 48,
                    ),
                    child: isCompact
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _BrandPanel(compact: true),
                              const SizedBox(height: 32),
                              _buildAuthCard(),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Expanded(
                                flex: 6,
                                child: _BrandPanel(),
                              ),
                              SizedBox(width: screenWidth < 1000 ? 48 : 80),
                              Expanded(
                                flex: 5,
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 390),
                                    child: _buildAuthCard(),
                                  ),
                                ),
                              ),
                            ],
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

  Widget _buildAuthCard() => _AuthCard(
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
      );
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final headingSize = compact ? 38.0 : 36.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'YOUR STORY. YOUR WORK. YOUR SPACE.',
          style: TextStyle(
            color: Color(0xFFFF0050),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.25,
          ),
        ),
        const SizedBox(height: 14),
        Text.rich(
          TextSpan(
            style: TextStyle(
              color: Colors.white,
              fontSize: headingSize,
              height: 0.99,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.2,
            ),
            children: const [
              TextSpan(text: 'Your next\nchapter starts\nhere'),
              TextSpan(
                text: '.',
                style: TextStyle(color: Color(0xFFFF0050)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'A portfolio built around you. Add your story, showcase your work and open the door to what’s next.',
          style: TextStyle(
            color: Color(0xFF999999),
            fontSize: 12,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 18),
        const _PortfolioPreview(),
        const SizedBox(height: 18),
        const Text(
          'No sample identity. No borrowed work. Just your content.',
          style: TextStyle(
            color: Color(0xFF777777),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _PortfolioPreview extends StatelessWidget {
  const _PortfolioPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF191919),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Expanded(
                child: Text(
                  'One portfolio. Every part of you.',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
              Text(
                '08 steps',
                style: TextStyle(
                  color: Color(0xFFFF0050),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          const Divider(height: 1, color: Color(0xFF292929)),
          const SizedBox(height: 9),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: const [
              'Home',
              'About',
              'Services',
              'Resume',
              'Skills',
              'Projects',
              'Contacts',
            ]
                .map(
                  (section) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF333333)),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    child: Text(
                      section,
                      style: const TextStyle(
                        color: Color(0xFFBDBDBD),
                        fontSize: 8,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF292929),
          width: 1,
        ),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              register ? 'Create account' : 'Welcome back',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              register
                  ? 'Start building your portfolio in minutes.'
                  : 'Sign in to shape your portfolio and keep your story moving.',
              style: const TextStyle(
                color: Color(0xFF999999),
                fontSize: 9,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            if (register) ...[
              _FieldLabel(text: 'Full name'),
              const SizedBox(height: 10),
              _StyledField(
                controller: nameController,
                hintText: 'Your full name',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
              ),
              const SizedBox(height: 10),
            ],
            _FieldLabel(text: 'Email address'),
            const SizedBox(height: 5),
            _StyledField(
              controller: emailController,
              hintText: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || !v.contains('@'))
                  ? 'Enter a valid email'
                  : null,
            ),
            const SizedBox(height: 9),
            _FieldLabel(text: 'Password'),
            const SizedBox(height: 5),
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
                  right: 5,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    onPressed: onTogglePassword,
                    icon: Icon(
                      showPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF999999),
                      size: 16,
                    ),
                    tooltip: showPassword ? 'Hide password' : 'Show password',
                  ),
                ),
              ],
            ),
            if (!register) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF444444)),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Remember me',
                      style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const Flexible(
                    child: Text(
                      'Forgot password?',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Color(0xFFFF0050),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (errorText != null) ...[
              const SizedBox(height: 12),
              Text(
                errorText!,
                style: const TextStyle(
                  color: Color(0xFFB3261E),
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (noticeText != null) ...[
              const SizedBox(height: 12),
              Text(
                noticeText!,
                style: const TextStyle(
                  color: Color(0xFF1B7A55),
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: busy ? null : onSubmit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF0050),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                ),
                child: busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            register ? 'Create account' : 'Sign in',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.arrow_forward_rounded, size: 15),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: TextButton(
                onPressed: onToggleMode,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF999999),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                child: Text(
                  register
                      ? 'Already here? Sign in'
                      : 'New here? Create an account',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
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
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w600,
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
      style: const TextStyle(
        fontSize: 11,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF777777),
          fontWeight: FontWeight.w400,
          fontSize: 10,
        ),
        filled: true,
        fillColor: const Color(0xFF151515),
        isDense: true,
        constraints: const BoxConstraints(minHeight: 30),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF303030), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF303030), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFFF0050), width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFB3261E), width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFB3261E), width: 1.4),
        ),
      ),
    );
  }
}
