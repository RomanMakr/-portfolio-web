import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../core/widgets/responsive_content.dart';

class PublicPortfolioPage extends ConsumerStatefulWidget {
  const PublicPortfolioPage({super.key, required this.slug});
  final String slug;
  @override
  ConsumerState<PublicPortfolioPage> createState() => _PublicPortfolioPageState();
}

class _PublicPortfolioPageState extends ConsumerState<PublicPortfolioPage> {
  late Future<Map<String, dynamic>> _future;
  @override
  void initState() { super.initState(); _future = ref.read(apiClientProvider).publicPortfolio(widget.slug); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Portfolio'), actions: [TextButton(onPressed: () => Navigator.of(context).maybePop(), child: const Text('Back'))]),
    body: FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) {
          final error = snapshot.error;
          final message = error is DioException && error.response?.statusCode == 404 ? 'This portfolio does not exist or is not published.' : 'Could not load portfolio. Check that the Go API is running.';
          return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(message, textAlign: TextAlign.center)));
        }
        final data = snapshot.data!;
        final projects = (data['projects'] as List<dynamic>? ?? []);
        return SingleChildScrollView(child: ResponsiveContent(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 30),
          CircleAvatar(radius: 38, backgroundColor: const Color(0xFFEDE8FA), child: Text((data['title']?.toString().isNotEmpty ?? false) ? data['title'].toString()[0].toUpperCase() : 'P', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
          const SizedBox(height: 22),
          Text(data['title']?.toString() ?? 'Portfolio', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(data['headline']?.toString() ?? '', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.deepPurple)),
          const SizedBox(height: 18),
          Text(data['bio']?.toString() ?? '', style: Theme.of(context).textTheme.bodyLarge),
          if ((data['location'] ?? '').toString().isNotEmpty) Padding(padding: const EdgeInsets.only(top: 10), child: Text('📍 ${data['location']}')),
          const SizedBox(height: 24),
          Wrap(spacing: 10, children: [
            if ((data['github_url'] ?? '').toString().isNotEmpty) OutlinedButton.icon(onPressed: null, icon: const Icon(Icons.code), label: const Text('GitHub')),
            if ((data['linkedin_url'] ?? '').toString().isNotEmpty) OutlinedButton.icon(onPressed: null, icon: const Icon(Icons.work_outline), label: const Text('LinkedIn')),
          ]),
          const SizedBox(height: 38),
          Text('Projects', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          if (projects.isEmpty) const Text('Projects will appear here when added.'),
          LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth >= 760 ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth;
            return Wrap(spacing: 16, runSpacing: 16, children: projects.map((p) => SizedBox(width: width, child: Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p['title']?.toString() ?? 'Project', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8), Text(p['description']?.toString() ?? ''),
              const SizedBox(height: 10), Wrap(spacing: 6, children: ((p['technologies'] as List<dynamic>?) ?? []).map((t) => Chip(label: Text(t.toString()))).toList()),
            ])))).toList());
          }),
        ])));
      },
    ),
  );
}
