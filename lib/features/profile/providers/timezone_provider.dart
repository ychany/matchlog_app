import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 지원하는 타임존 목록
class TimezoneOption {
  final String id;
  final String nameKey;  // l10n key for the timezone name
  final String offset;

  const TimezoneOption({
    required this.id,
    required this.nameKey,
    required this.offset,
  });
}

/// 자주 사용되는 타임존 목록
const List<TimezoneOption> availableTimezones = [
  TimezoneOption(id: 'Asia/Seoul', nameKey: 'timezoneKoreaSeoul', offset: 'UTC+9'),
  TimezoneOption(id: 'Asia/Tokyo', nameKey: 'timezoneJapanTokyo', offset: 'UTC+9'),
  TimezoneOption(id: 'Asia/Shanghai', nameKey: 'timezoneChinaShanghai', offset: 'UTC+8'),
  TimezoneOption(id: 'Asia/Singapore', nameKey: 'timezoneSingapore', offset: 'UTC+8'),
  TimezoneOption(id: 'Asia/Hong_Kong', nameKey: 'timezoneHongKong', offset: 'UTC+8'),
  TimezoneOption(id: 'Asia/Bangkok', nameKey: 'timezoneThailandBangkok', offset: 'UTC+7'),
  TimezoneOption(id: 'Asia/Jakarta', nameKey: 'timezoneIndonesiaJakarta', offset: 'UTC+7'),
  TimezoneOption(id: 'Asia/Kolkata', nameKey: 'timezoneIndiaKolkata', offset: 'UTC+5:30'),
  TimezoneOption(id: 'Asia/Dubai', nameKey: 'timezoneUAEDubai', offset: 'UTC+4'),
  TimezoneOption(id: 'Europe/London', nameKey: 'timezoneUKLondon', offset: 'UTC+0'),
  TimezoneOption(id: 'Europe/Paris', nameKey: 'timezoneFranceParis', offset: 'UTC+1'),
  TimezoneOption(id: 'Europe/Berlin', nameKey: 'timezoneGermanyBerlin', offset: 'UTC+1'),
  TimezoneOption(id: 'Europe/Rome', nameKey: 'timezoneItalyRome', offset: 'UTC+1'),
  TimezoneOption(id: 'Europe/Madrid', nameKey: 'timezoneSpainMadrid', offset: 'UTC+1'),
  TimezoneOption(id: 'Europe/Amsterdam', nameKey: 'timezoneNetherlandsAmsterdam', offset: 'UTC+1'),
  TimezoneOption(id: 'Europe/Moscow', nameKey: 'timezoneRussiaMoscow', offset: 'UTC+3'),
  TimezoneOption(id: 'America/New_York', nameKey: 'timezoneUSEastNewYork', offset: 'UTC-5'),
  TimezoneOption(id: 'America/Los_Angeles', nameKey: 'timezoneUSWestLA', offset: 'UTC-8'),
  TimezoneOption(id: 'America/Chicago', nameKey: 'timezoneUSCentralChicago', offset: 'UTC-6'),
  TimezoneOption(id: 'America/Sao_Paulo', nameKey: 'timezoneBrazilSaoPaulo', offset: 'UTC-3'),
  TimezoneOption(id: 'Australia/Sydney', nameKey: 'timezoneAustraliaSydney', offset: 'UTC+11'),
  TimezoneOption(id: 'Pacific/Auckland', nameKey: 'timezoneNewZealandAuckland', offset: 'UTC+13'),
];

const String _timezoneKey = 'selected_timezone';
const String _defaultTimezone = 'Asia/Seoul';

/// 타임존 설정 Notifier
class TimezoneNotifier extends StateNotifier<String> {
  TimezoneNotifier() : super(_defaultTimezone) {
    _loadTimezone();
  }

  Future<void> _loadTimezone() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_timezoneKey);
    if (saved != null) {
      state = saved;
    }
  }

  Future<void> setTimezone(String timezone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_timezoneKey, timezone);
    state = timezone;
  }

  /// 현재 선택된 타임존 옵션 반환
  TimezoneOption get currentOption {
    return availableTimezones.firstWhere(
      (tz) => tz.id == state,
      orElse: () => availableTimezones.first,
    );
  }
}

/// 타임존 Provider
final timezoneProvider = StateNotifierProvider<TimezoneNotifier, String>((ref) {
  return TimezoneNotifier();
});

/// 현재 타임존 옵션 Provider
final currentTimezoneOptionProvider = Provider<TimezoneOption>((ref) {
  final timezone = ref.watch(timezoneProvider);
  return availableTimezones.firstWhere(
    (tz) => tz.id == timezone,
    orElse: () => availableTimezones.first,
  );
});
