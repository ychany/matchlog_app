import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 지원하는 타임존 목록
class TimezoneOption {
  final String id;
  final String name;
  final String offset;

  const TimezoneOption({
    required this.id,
    required this.name,
    required this.offset,
  });
}

/// 자주 사용되는 타임존 목록
const List<TimezoneOption> availableTimezones = [
  TimezoneOption(id: 'Asia/Seoul', name: '한국 (서울)', offset: 'UTC+9'),
  TimezoneOption(id: 'Asia/Tokyo', name: '일본 (도쿄)', offset: 'UTC+9'),
  TimezoneOption(id: 'Asia/Shanghai', name: '중국 (상하이)', offset: 'UTC+8'),
  TimezoneOption(id: 'Asia/Singapore', name: '싱가포르', offset: 'UTC+8'),
  TimezoneOption(id: 'Asia/Hong_Kong', name: '홍콩', offset: 'UTC+8'),
  TimezoneOption(id: 'Asia/Bangkok', name: '태국 (방콕)', offset: 'UTC+7'),
  TimezoneOption(id: 'Asia/Jakarta', name: '인도네시아 (자카르타)', offset: 'UTC+7'),
  TimezoneOption(id: 'Asia/Kolkata', name: '인도 (콜카타)', offset: 'UTC+5:30'),
  TimezoneOption(id: 'Asia/Dubai', name: 'UAE (두바이)', offset: 'UTC+4'),
  TimezoneOption(id: 'Europe/London', name: '영국 (런던)', offset: 'UTC+0'),
  TimezoneOption(id: 'Europe/Paris', name: '프랑스 (파리)', offset: 'UTC+1'),
  TimezoneOption(id: 'Europe/Berlin', name: '독일 (베를린)', offset: 'UTC+1'),
  TimezoneOption(id: 'Europe/Rome', name: '이탈리아 (로마)', offset: 'UTC+1'),
  TimezoneOption(id: 'Europe/Madrid', name: '스페인 (마드리드)', offset: 'UTC+1'),
  TimezoneOption(id: 'Europe/Amsterdam', name: '네덜란드 (암스테르담)', offset: 'UTC+1'),
  TimezoneOption(id: 'Europe/Moscow', name: '러시아 (모스크바)', offset: 'UTC+3'),
  TimezoneOption(id: 'America/New_York', name: '미국 동부 (뉴욕)', offset: 'UTC-5'),
  TimezoneOption(id: 'America/Los_Angeles', name: '미국 서부 (LA)', offset: 'UTC-8'),
  TimezoneOption(id: 'America/Chicago', name: '미국 중부 (시카고)', offset: 'UTC-6'),
  TimezoneOption(id: 'America/Sao_Paulo', name: '브라질 (상파울루)', offset: 'UTC-3'),
  TimezoneOption(id: 'Australia/Sydney', name: '호주 (시드니)', offset: 'UTC+11'),
  TimezoneOption(id: 'Pacific/Auckland', name: '뉴질랜드 (오클랜드)', offset: 'UTC+13'),
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
