import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/providers.dart';
import '../../../core/widgets/responsive_content.dart';

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
  bool _register = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() { _name.dispose(); _email.dispose(); _password.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _busy = true; _error = null; });
    try {
      final api = ref.read(apiClientProvider);
      final result = _register
          ? await api.register(email: _email.text.trim(), password: _password.text, displayName: _name.text.trim())
          : await api.login(email: _email.text.trim(), password: _password.text);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', result['token'] as String);
      if (mounted) context.go('/dashboard');
    } on DioException catch (e) {
      final data = e.response?.data;
      setState(() => _error = data is Map ? (data['error']?.toString() ?? 'Request failed') : 'Could not connect to the API. Is the Go server running?');
    } catch (_) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally { if (mounted) setState(() => _busy = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(leading: IconButton(onPressed: () => context.go('/'), icon: const Icon(Icons.arrow_back)), title: const Text('Portfolia')),
    body: ResponsiveContent(maxWidth: 480, child: Center(child: SingleChildScrollView(child: Card(
      child: Padding(padding: const EdgeInsets.all(24), child: Form(key: _formKey, child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_register ? 'Create your account' : 'Welcome back', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8), Text(_register ? 'Start building your professional portfolio.' : 'Log in to manage your portfolio.'),
          const SizedBox(height: 24),
          if (_register) ...[
            TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Display name'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null),
            const SizedBox(height: 14),
          ],
          TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email'), validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null),
          const SizedBox(height: 14),
          TextFormField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Password'), validator: (v) => (v == null || v.length < 8) ? 'Use at least 8 characters' : null),
          if (_error != null) ...[const SizedBox(height: 14), Text(_error!, style: const TextStyle(color: Colors.red))],
          const SizedBox(height: 20),
          FilledButton(onPressed: _busy ? null : _submit, child: Padding(padding: const EdgeInsets.all(12), child: _busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(_register ? 'Create account' : 'Log in'))),
          TextButton(onPressed: _busy ? null : () => setState(() { _register = !_register; _error = null; }), child: Text(_register ? 'Already have an account? Log in' : 'New here? Create an account')),
        ],
      ))),))),
  );
}
