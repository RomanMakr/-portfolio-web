import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/providers.dart';
import '../../../core/widgets/responsive_content.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});
  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  final _formKey = GlobalKey<FormState>();
  final _slug = TextEditingController();
  final _title = TextEditingController(text: 'My Portfolio');
  final _headline = TextEditingController(text: 'Flutter Developer');
  final _bio = TextEditingController();
  String _templateId = 'minimal';
  bool _busy = false;
  String? _message;
  bool _isError = false;

  @override
  void dispose() { _slug.dispose(); _title.dispose(); _headline.dispose(); _bio.dispose(); super.dispose(); }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _busy = true; _message = null; });
    try {
      await ref.read(apiClientProvider).createPortfolio({
        'template_id': _templateId,
        'slug': _slug.text.trim().toLowerCase().replaceAll(' ', '-'),
        'title': _title.text.trim(),
        'headline': _headline.text.trim(),
        'bio': _bio.text.trim(),
        'avatar_url': '', 'location': '', 'github_url': '', 'linkedin_url': '',
        'published': true,
      });
      ref.invalidate(myPortfoliosProvider);
      setState(() { _message = 'Portfolio created and published!'; _isError = false; });
      _slug.clear();
    } on DioException catch (e) {
      final data = e.response?.data;
      setState(() { _message = data is Map ? (data['error']?.toString() ?? 'Could not create portfolio') : 'Could not connect to the Go API.'; _isError = true; });
    } finally { if (mounted) setState(() => _busy = false); }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final portfolios = ref.watch(myPortfoliosProvider);
    final templates = ref.watch(templatesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Your dashboard'), actions: [TextButton(onPressed: _logout, child: const Text('Log out')), const SizedBox(width: 12)]),
      body: ResponsiveContent(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Create a portfolio', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8), const Text('Fill in the essentials. You can expand your portfolio content as the product grows.'),
        const SizedBox(height: 22),
        Card(child: Padding(padding: const EdgeInsets.all(22), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          templates.when(data: (items) => DropdownButtonFormField<String>(value: items.any((e) => e['id'] == _templateId) ? _templateId : (items.isNotEmpty ? items.first['id'].toString() : 'minimal'), decoration: const InputDecoration(labelText: 'Template'), items: items.map((item) => DropdownMenuItem<String>(value: item['id'].toString(), child: Text(item['name'].toString()))).toList(), onChanged: (value) { if (value != null) setState(() => _templateId = value); }), loading: () => const LinearProgressIndicator(), error: (e, s) => const Text('Templates unavailable; check API connection.')),
          const SizedBox(height: 14),
          TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Portfolio title'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a title' : null),
          const SizedBox(height: 14),
          TextFormField(controller: _slug, decoration: const InputDecoration(labelText: 'Public URL slug', prefixText: '/p/'), validator: (v) => (v == null || v.trim().length < 3) ? 'Use at least 3 characters' : null),
          const SizedBox(height: 14),
          TextFormField(controller: _headline, decoration: const InputDecoration(labelText: 'Headline')),
          const SizedBox(height: 14),
          TextFormField(controller: _bio, minLines: 3, maxLines: 5, decoration: const InputDecoration(labelText: 'Short bio')),
          if (_message != null) ...[const SizedBox(height: 12), Text(_message!, style: TextStyle(color: _isError ? Colors.red : Colors.green))],
          const SizedBox(height: 18), Align(alignment: Alignment.centerLeft, child: FilledButton.icon(onPressed: _busy ? null : _create, icon: const Icon(Icons.publish), label: Text(_busy ? 'Creating…' : 'Create and publish'))),
        ]))),
        const SizedBox(height: 32),
        Text('Your portfolios', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        portfolios.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Could not load your portfolios. If you just registered, refresh this page.'), TextButton(onPressed: () => ref.invalidate(myPortfoliosProvider), child: const Text('Retry'))]))),
          data: (items) => items.isEmpty ? const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('No portfolios yet. Create your first one above.'))) : Column(children: items.map((item) => Card(child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.web)), title: Text(item['title']?.toString() ?? 'Untitled'), subtitle: Text('/p/${item['slug']}'),
            trailing: IconButton(tooltip: 'Open portfolio', icon: const Icon(Icons.open_in_new), onPressed: () => context.go('/p/${item['slug']}')),
          ))).toList()),
        ),
      ])),
    );
  }
}
