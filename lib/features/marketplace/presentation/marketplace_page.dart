import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/providers.dart';
import '../../../core/widgets/responsive_content.dart';

class MarketplacePage extends ConsumerWidget {
  const MarketplacePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(templatesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolia', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          TextButton(onPressed: () => context.go('/login'), child: const Text('Log in')),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 8),
            child: FilledButton(onPressed: () => context.go('/login'), child: const Text('Create portfolio')),
          ),
        ],
      ),
      body: ResponsiveContent(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 26),
          Text('Your work deserves\na beautiful portfolio.',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, height: 1.1)),
          const SizedBox(height: 16),
          Text('Choose a template, add your story, and publish your own professional website.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black54)),
          const SizedBox(height: 28),
          Wrap(spacing: 10, runSpacing: 10, children: const [
            _FeatureChip(icon: Icons.web, label: 'Responsive websites'),
            _FeatureChip(icon: Icons.palette_outlined, label: 'Beautiful templates'),
            _FeatureChip(icon: Icons.link, label: 'Shareable URL'),
          ]),
          const SizedBox(height: 44),
          Text('Explore templates', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          templates.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
            error: (error, stack) => Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [const Text('Could not load templates.'), const SizedBox(height: 8), Text('$error', style: const TextStyle(color: Colors.red)),
                TextButton(onPressed: () => ref.invalidate(templatesProvider), child: const Text('Try again'))],
            ))),
            data: (items) => LayoutBuilder(builder: (context, constraints) {
              final width = constraints.maxWidth >= 900 ? (constraints.maxWidth - 32) / 3 : constraints.maxWidth >= 580 ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth;
              return Wrap(spacing: 16, runSpacing: 16, children: items.map((item) => SizedBox(width: width, child: _TemplateCard(
                name: item['name']?.toString() ?? 'Portfolio template',
                description: item['description']?.toString() ?? '',
                premium: item['is_premium'] == true,
                onChoose: () => context.go('/login'),
              ))).toList());
            }),
          ),
          const SizedBox(height: 44),
          Center(child: Text('Build your professional identity — one page at a time.', style: Theme.of(context).textTheme.bodyMedium)),
        ],
      )),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.name, required this.description, required this.premium, required this.onChoose});
  final String name, description;
  final bool premium;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) => Card(clipBehavior: Clip.antiAlias, child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(height: 150, width: double.infinity, color: const Color(0xFFEDE8FA),
        child: Stack(children: [
          Positioned(left: 22, right: 22, top: 22, bottom: 22, child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 70, height: 8, decoration: BoxDecoration(color: const Color(0xFF6750A4), borderRadius: BorderRadius.circular(8))),
              const SizedBox(height: 12), Container(width: 125, height: 14, color: const Color(0xFFE5E1EC)),
              const SizedBox(height: 7), Container(width: 170, height: 7, color: const Color(0xFFF0EEF4)),
              const Spacer(), Row(children: List.generate(3, (i) => Expanded(child: Container(height: 28, margin: EdgeInsets.only(right: i == 2 ? 0 : 6), decoration: BoxDecoration(color: const Color(0xFFF0EEF4), borderRadius: BorderRadius.circular(5))))))
            ]),
          )),
          if (premium) const Positioned(right: 12, top: 12, child: Chip(label: Text('PRO'))),
        ])),
      Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6), Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 16), SizedBox(width: double.infinity, child: OutlinedButton(onPressed: onChoose, child: const Text('Use this template'))),
      ])),
    ],
  ));
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Chip(avatar: Icon(icon, size: 18), label: Text(label), side: BorderSide.none, backgroundColor: const Color(0xFFEDE8FA));
}
