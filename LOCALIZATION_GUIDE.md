# 다국어 지원 가이드 (Localization)

## 개요

MatchLog 앱의 다국어(i18n) 지원을 위한 작업 가이드입니다.

## 목표

- 한국어(ko) - 기본 언어
- 영어(en) - 추가 언어

## Flutter 공식 다국어 방식

### 1. 패키지 설정 (pubspec.yaml)

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: any

flutter:
  generate: true
```

### 2. l10n.yaml 파일 생성 (프로젝트 루트)

```yaml
arb-dir: lib/l10n
template-arb-file: app_ko.arb
output-localization-file: app_localizations.dart
```

### 3. ARB 파일 구조

```
lib/
└── l10n/
    ├── app_ko.arb    # 한국어 (기본)
    └── app_en.arb    # 영어
```

### 4. ARB 파일 예시

**app_ko.arb:**
```json
{
  "@@locale": "ko",
  "home": "홈",
  "schedule": "일정",
  "nextMatch": "다음 경기",
  "noTeamSelected": "응원할 팀을 선택해주세요",
  "settings": "설정",
  "language": "언어"
}
```

**app_en.arb:**
```json
{
  "@@locale": "en",
  "home": "Home",
  "schedule": "Schedule",
  "nextMatch": "Next Match",
  "noTeamSelected": "Please select a team to support",
  "settings": "Settings",
  "language": "Language"
}
```

### 5. MaterialApp 설정

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  // ...
)
```

### 6. 코드에서 사용

```dart
// 변경 전 (하드코딩)
Text('홈')
Text('다음 경기')

// 변경 후 (다국어)
Text(AppLocalizations.of(context)!.home)
Text(AppLocalizations.of(context)!.nextMatch)
```

## 작업 순서

### Phase 1: 텍스트 추출
```bash
# lib 폴더에서 한글 텍스트 검색
grep -rn "Text('.*[가-힣]" lib/
grep -rn "'.*[가-힣].*'" lib/ --include="*.dart"
```

### Phase 2: ARB 파일 생성
- 추출된 텍스트로 키-값 쌍 생성
- 한국어 ARB 파일 작성
- 영어 번역 (클로드 코드로 진행)

### Phase 3: 코드 수정
- 각 파일에서 하드코딩된 텍스트를 `AppLocalizations` 호출로 변경
- `const` 위젯은 `const` 제거 필요

### Phase 4: 테스트
- 한국어/영어 전환 테스트
- 누락된 텍스트 확인

## 예상 작업량

- 텍스트 키: 약 300~400개
- 수정 파일: 약 50개 이상
- 주요 화면: home, schedule, national_team, league, team, profile

## iOS 언어 설정 연동

iOS 설정 앱의 언어 설정으로 이동하려면:

```dart
import 'package:url_launcher/url_launcher.dart';

Future<void> openAppSettings() async {
  final uri = Uri.parse('app-settings:');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}
```

**주의:** 앱 설정에서 언어 옵션이 보이려면 Info.plist에 지원 언어 선언 필요:

```xml
<key>CFBundleLocalizations</key>
<array>
    <string>en</string>
    <string>ko</string>
</array>
```

## 축구 용어 번역 참고

| 한국어 | 영어 |
|--------|------|
| 경기 | Match |
| 일정 | Schedule / Fixtures |
| 순위 | Standings |
| 득점 | Goals |
| 도움 | Assists |
| 골키퍼 | Goalkeeper (GK) |
| 수비수 | Defender (DF) |
| 미드필더 | Midfielder (MF) |
| 공격수 | Forward (FW) |
| 교체 | Substitution |
| 경고 | Yellow Card |
| 퇴장 | Red Card |
| 전반 | 1st Half |
| 후반 | 2nd Half |
| 연장 | Extra Time |
| 승부차기 | Penalty Shootout |
| 직관 | Stadium Visit |
| 홈 | Home |
| 원정 | Away |

## 참고 자료

- [Flutter 공식 다국어 문서](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)
- [intl 패키지](https://pub.dev/packages/intl)
