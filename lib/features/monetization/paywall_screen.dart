import 'package:flutter/material.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade to Pro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Langgeng Pro',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            const Text(
              '7 hari free trial, lalu Rp49.000/bulan. Batalkan kapan saja.',
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: null,
              child: const Text('Start 7-day free trial'),
            ),
            TextButton(onPressed: null, child: const Text('Restore purchase')),
            TextButton(
              onPressed: null,
              child: const Text('Cancel subscription info'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Billing belum aktif. Tombol subscription akan diaktifkan setelah integrasi Play Billing selesai.',
            ),
          ],
        ),
      ),
    );
  }
}
