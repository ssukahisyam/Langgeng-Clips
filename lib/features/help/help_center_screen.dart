import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const articles = <({String title, String body})>[
    (
      title: 'Cara import video',
      body: 'Tap Pilih Video di Home, lalu pilih file lokal.',
    ),
    (
      title: 'Cara membuat clip manual',
      body: 'Geser timeline range, lalu export active clip.',
    ),
    (
      title: 'Cara memilih template',
      body: 'Buka tab Style di Editor dan pilih preset.',
    ),
    (
      title: 'Cara edit caption',
      body: 'Buka tab Caption lalu Open caption editor.',
    ),
    (
      title: 'Cara tambah watermark',
      body: 'Buka tab Watermark dan atur teks, posisi, opacity, scale.',
    ),
    (
      title: 'Kenapa transcribe belum jalan?',
      body: 'Audio extraction native masih menunggu backend final.',
    ),
    (
      title: 'Kenapa AI highlight belum penuh?',
      body: 'LLM foundation siap, deteksi audio/scene native menyusul.',
    ),
    (title: 'Batas free tier', body: 'Free tier dirancang 3 export per hari.'),
    (
      title: 'Cara upgrade Pro',
      body: 'Buka Langgeng Pro dari Settings setelah Play Billing aktif.',
    ),
    (title: 'Cara lapor bug', body: 'Gunakan Send feedback di Settings.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help Center')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: articles.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final article = articles[index];
          return Card(
            child: ExpansionTile(
              title: Text(article.title),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(article.body),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
