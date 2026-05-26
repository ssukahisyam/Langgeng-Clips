import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
              onPressed: _submitFeedback,
              child: const Text('Submit feedback'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitFeedback() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback tidak boleh kosong.')),
      );
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    final items = preferences.getStringList('feedback_drafts_v1') ?? const [];
    await preferences.setStringList('feedback_drafts_v1', [
      ...items,
      '${DateTime.now().toIso8601String()}|$text',
    ]);
    _controller.clear();
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Feedback tersimpan lokal.')));
  }
}
