import 'package:shared_preferences/shared_preferences.dart';

class VoiceUsageService {
  VoiceUsageService._();
  static final VoiceUsageService instance = VoiceUsageService._();

  static const dailyWordLimit = 350;
  static const _dateKey = 'voice_usage_date';
  static const _countKey = 'voice_usage_count';

  String _todayString() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  Future<void> _ensureToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    if (prefs.getString(_dateKey) != today) {
      await prefs.setString(_dateKey, today);
      await prefs.setInt(_countKey, 0);
    }
  }

  Future<int> getWordsUsedToday() async {
    await _ensureToday();
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_countKey) ?? 0;
  }

  Future<int> getRemainingWords() async {
    final used = await getWordsUsedToday();
    final remaining = dailyWordLimit - used;
    return remaining < 0 ? 0 : remaining;
  }

  Future<bool> canStartVoiceInput() async {
    return (await getRemainingWords()) > 0;
  }

  Future<void> recordWords(int count) async {
    if (count <= 0) return;
    await _ensureToday();
    final prefs = await SharedPreferences.getInstance();
    final used = prefs.getInt(_countKey) ?? 0;
    await prefs.setInt(_countKey, used + count);
  }

  static int countWords(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  static String truncateToWordCount(String text, int maxWords) {
    if (maxWords <= 0) return '';
    final parts = text.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length <= maxWords) return text.trim();
    return parts.take(maxWords).join(' ');
  }
}
