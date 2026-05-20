import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ApiKeySetupScreen extends StatefulWidget {
  const ApiKeySetupScreen({super.key});

  @override
  State<ApiKeySetupScreen> createState() => _ApiKeySetupScreenState();
}

class _ApiKeySetupScreenState extends State<ApiKeySetupScreen> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hubungkan Groq',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Untuk transkrip dan auto highlight. Key disimpan aman di device kamu.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              TextField(
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Groq API Key',
                  hintText: 'gsk_...',
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(Icons.shield_outlined, size: 18),
                  SizedBox(width: 8),
                  Expanded(child: Text('Disimpan dengan Android Keystore.')),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {},
                child: const Text('Cara dapat API key'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.go('/home'),
                child: const Text('Validasi & Lanjut'),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Lewati untuk sekarang'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
