class ErrorMessageCatalog {
  static const messages = <String, String>{
    'invalid_source': 'File sumber tidak tersedia. Pilih ulang video.',
    'invalid_range': 'Range clip tidak valid. Geser start/end clip.',
    'export_failed': 'Export gagal. Coba ulangi.',
    'export_cancelled': 'Export dibatalkan.',
    'extract_unavailable':
        'FFmpeg audio extraction belum tersedia di build ini.',
    'api_key_invalid': 'Groq API key tidak valid.',
    'rate_limited': 'Groq sedang rate-limit. Coba beberapa saat lagi.',
  };
}
