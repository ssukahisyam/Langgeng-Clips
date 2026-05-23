import 'package:flutter/material.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send feedback')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ceritakan bug, ide, atau bagian app yang membingungkan.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              minLines: 6,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'Feedback',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Feedback form tersimpan lokal untuk wiring backend nanti.',
                    ),
                  ),
                );
              },
              child: const Text('Submit feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
