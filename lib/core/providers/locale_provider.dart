import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 지원하는 언어 목록
const supportedLocales = [
  Locale('ko'), // 한국어
  Locale('en'), // 영어
];

/// 언어 설정 키
const _localeKey = 'app_locale';

/// 현재 선택된 언어를 관리하는 Provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});

/// 언어 설정 Notifier
class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    _loadLocale();
  }

  /// 저장된 언어 설정 불러오기
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);
    if (localeCode != null) {
      state = Locale(localeCode);
    }
    // null이면 시스템 기본 언어 사용
  }

  /// 언어 변경
  Future<void> setLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      // 시스템 기본 언어 사용
      await prefs.remove(_localeKey);
    } else {
      await prefs.setString(_localeKey, locale.languageCode);
    }
    state = locale;
  }

  /// 현재 언어 코드 반환 (null이면 시스템 기본)
  String? get currentLanguageCode => state?.languageCode;

  /// 시스템 기본 언어 사용 중인지 확인
  bool get isSystemDefault => state == null;
}

/// 언어 표시 이름 가져오기 (네이티브 이름)
/// Note: This returns native language names. For localized display,
/// use AppLocalizations in the UI layer.
String getLanguageDisplayName(Locale? locale) {
  if (locale == null) return 'System Default';
  switch (locale.languageCode) {
    case 'ko':
      return '한국어';
    case 'en':
      return 'English';
    default:
      return locale.languageCode;
  }
}

/// 영어 언어 표시 이름 가져오기
String getLanguageDisplayNameEn(Locale? locale) {
  if (locale == null) return 'System Default';
  switch (locale.languageCode) {
    case 'ko':
      return 'Korean';
    case 'en':
      return 'English';
    default:
      return locale.languageCode;
  }
}
