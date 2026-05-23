class TranscriptionLanguage {
  const TranscriptionLanguage({required this.code, required this.label});

  static const auto = TranscriptionLanguage(code: 'auto', label: 'Auto detect');
  static const indonesian = TranscriptionLanguage(
    code: 'id',
    label: 'Bahasa Indonesia',
  );
  static const english = TranscriptionLanguage(code: 'en', label: 'English');
  static const japanese = TranscriptionLanguage(code: 'ja', label: 'Japanese');
  static const korean = TranscriptionLanguage(code: 'ko', label: 'Korean');

  static const supported = <TranscriptionLanguage>{
    auto,
    indonesian,
    english,
    japanese,
    korean,
  };

  final String code;
  final String label;

  bool get isAuto => code == auto.code;

  String? get groqParameter => isAuto ? null : code;
}

class TranscriptionSettings {
  const TranscriptionSettings({this.language = TranscriptionLanguage.auto});

  final TranscriptionLanguage language;
}
