import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'groq_api_key_controller.dart';

class ApiKeySetupScreen extends ConsumerStatefulWidget {
  const ApiKeySetupScreen({super.key});

  @override
  ConsumerState<ApiKeySetupScreen> createState() => _ApiKeySetupScreenState();
}

class _ApiKeySetupScreenState extends ConsumerState<ApiKeySetupScreen> {
  final _controller = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiKeyState = ref.watch(groqApiKeyControllerProvider);
    final isLoading = apiKeyState.isLoading;
    final errorMessage = apiKeyState.valueOrNull?.errorMessage;

    ref.listen(groqApiKeyControllerProvider, (previous, next) {
      final value = next.valueOrNull;
      if (value != null && value.hasKey && value.errorMessage == null) {
        context.go('/home');
      }
    });

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
                controller: _controller,
                enabled: !isLoading,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Groq API Key',
                  hintText: 'gsk_...',
                  errorText: errorMessage,
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
                onPressed: isLoading
                    ? null
                    : () => ref
                          .read(groqApiKeyControllerProvider.notifier)
                          .validateAndSave(_controller.text),
                child: isLoading
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Validasi & Lanjut'),
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
