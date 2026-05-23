import 'package:shared_preferences/shared_preferences.dart';

class FreeTierLimits {
  const FreeTierLimits({this.dailyExportLimit = 3});

  final int dailyExportLimit;

  bool canExport(int exportsToday) => exportsToday < dailyExportLimit;

  int remainingExports(int exportsToday) {
    return (dailyExportLimit - exportsToday).clamp(0, dailyExportLimit);
  }
}

class RewardedExportCredit {
  const RewardedExportCredit({this.extraExports = 1});

  final int extraExports;

  int apply(int remainingExports) => remainingExports + extraExports;
}

class DailyExportCounter {
  DailyExportCounter({
    required SharedPreferences preferences,
    DateTime Function()? now,
  }) : _preferences = preferences,
       _now = now ?? DateTime.now;

  static const _countKey = 'free_tier_daily_export_count';
  static const _dateKey = 'free_tier_daily_export_date_wib';

  final SharedPreferences _preferences;
  final DateTime Function() _now;

  int readCount() {
    _resetIfNeeded();
    return _preferences.getInt(_countKey) ?? 0;
  }

  Future<int> increment() async {
    _resetIfNeeded();
    final next = readCount() + 1;
    await _preferences.setInt(_countKey, next);
    await _preferences.setString(_dateKey, _todayWib());
    return next;
  }

  void _resetIfNeeded() {
    final today = _todayWib();
    if (_preferences.getString(_dateKey) == today) {
      return;
    }

    _preferences.setString(_dateKey, today);
    _preferences.setInt(_countKey, 0);
  }

  String _todayWib() {
    final wib = _now().toUtc().add(const Duration(hours: 7));
    return '${wib.year.toString().padLeft(4, '0')}-'
        '${wib.month.toString().padLeft(2, '0')}-'
        '${wib.day.toString().padLeft(2, '0')}';
  }
}
