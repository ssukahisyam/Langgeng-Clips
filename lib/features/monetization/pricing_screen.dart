import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Langgeng Pro')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Export lebih banyak, template premium, dan watermark opsional.',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          const _PlanCard(
            title: 'Free',
            price: 'Rp0',
            features: [
              '3 export per hari',
              'Watermark Made with Langgeng Clip',
              'Template dasar',
            ],
          ),
          const SizedBox(height: 12),
          _PlanCard(
            title: 'Pro',
            price: 'Rp49.000/bulan',
            highlighted: true,
            features: const [
              'Unlimited export',
              'Tanpa watermark',
              'Template premium',
              '7 hari free trial',
            ],
            action: FilledButton(
              onPressed: () => context.go('/paywall'),
              child: const Text('Mulai free trial'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.features,
    this.highlighted = false,
    this.action,
  });

  final String title;
  final String price;
  final List<String> features;
  final bool highlighted;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: highlighted
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            Text(price, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            for (final feature in features) Text('• $feature'),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}
