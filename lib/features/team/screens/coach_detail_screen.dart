import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_football_service.dart';
import '../../../shared/widgets/loading_indicator.dart';

// Coach detail provider
final coachDetailProvider = FutureProvider.family<ApiFootballCoach?, int>((ref, coachId) async {
  final service = ApiFootballService();
  return service.getCoachById(coachId);
});

// Coach trophies provider
final coachTrophiesProvider = FutureProvider.family<List<CoachTrophy>, int>((ref, coachId) async {
  final service = ApiFootballService();
  return service.getCoachTrophies(coachId);
});

class CoachDetailScreen extends ConsumerWidget {
  final String coachId;

  static const _textPrimary = Color(0xFF111827);
  static const _textSecondary = Color(0xFF6B7280);
  static const _background = Color(0xFFF9FAFB);

  const CoachDetailScreen({super.key, required this.coachId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = int.tryParse(coachId);
    if (id == null) {
      return Scaffold(
        backgroundColor: _background,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              const Expanded(
                child: Center(
                  child: Text('잘못된 감독 ID입니다'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final coachAsync = ref.watch(coachDetailProvider(id));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _background,
        body: coachAsync.when(
          data: (coach) {
            if (coach == null) {
              return SafeArea(
                child: Column(
                  children: [
                    _buildAppBar(context),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_outline,
                                size: 64, color: _textSecondary),
                            const SizedBox(height: 16),
                            Text(
                              '감독 정보를 찾을 수 없습니다',
                              style: TextStyle(color: _textSecondary, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return _CoachDetailContent(coach: coach);
          },
          loading: () => const LoadingIndicator(),
          error: (e, _) => SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: Center(
                    child: Text('오류: $e', style: TextStyle(color: _textSecondary)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            color: _textPrimary,
            onPressed: () => context.pop(),
          ),
          const Expanded(
            child: Text(
              '감독 정보',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _CoachDetailContent extends ConsumerWidget {
  final ApiFootballCoach coach;

  static const _primary = Color(0xFF2563EB);
  static const _textPrimary = Color(0xFF111827);
  static const _textSecondary = Color(0xFF6B7280);
  static const _border = Color(0xFFE5E7EB);
  static const _gold = Color(0xFFFFD700);

  const _CoachDetailContent({required this.coach});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trophiesAsync = ref.watch(coachTrophiesProvider(coach.id));

    return SafeArea(
      child: Column(
        children: [
          // 헤더
          _buildHeader(context),

          // 내용
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 기본 정보 카드
                _buildBasicInfoCard(),

                const SizedBox(height: 16),

                // 트로피 카드
                trophiesAsync.when(
                  data: (trophies) {
                    if (trophies.isEmpty) return const SizedBox.shrink();
                    return Column(
                      children: [
                        _buildTrophiesCard(trophies),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                  loading: () => Column(
                    children: [
                      _buildTrophiesLoadingCard(),
                      const SizedBox(height: 16),
                    ],
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // 경력 카드
                if (coach.career.isNotEmpty) _buildCareerCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // 앱바
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  color: _textPrimary,
                  onPressed: () => context.pop(),
                ),
                const Expanded(
                  child: Text(
                    '감독 정보',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // 프로필 이미지
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _border, width: 3),
              color: Colors.grey.shade100,
            ),
            child: ClipOval(
              child: coach.photo != null
                  ? CachedNetworkImage(
                      imageUrl: coach.photo!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Icon(
                        Icons.person,
                        size: 50,
                        color: _textSecondary,
                      ),
                      errorWidget: (_, __, ___) => Icon(
                        Icons.person,
                        size: 50,
                        color: _textSecondary,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 50,
                      color: _textSecondary,
                    ),
            ),
          ),
          const SizedBox(height: 12),

          // 이름
          Text(
            coach.name,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),

          // 국적
          if (coach.nationality != null) ...[
            const SizedBox(height: 4),
            Text(
              coach.nationality!,
              style: const TextStyle(
                color: _textSecondary,
                fontSize: 14,
              ),
            ),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.info_outline, color: _primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                '기본 정보',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (coach.age != null)
            _InfoRow(
              icon: Icons.cake_outlined,
              label: '나이',
              value: '${coach.age}세',
            ),
          if (coach.birthDate != null)
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: '생년월일',
              value: coach.birthDate!,
            ),
          if (coach.birthPlace != null)
            _InfoRow(
              icon: Icons.location_city_outlined,
              label: '출생지',
              value: coach.birthPlace!,
            ),
          if (coach.birthCountry != null)
            _InfoRow(
              icon: Icons.flag_outlined,
              label: '출생 국가',
              value: coach.birthCountry!,
            ),
          if (coach.totalCareerYears > 0)
            _InfoRow(
              icon: Icons.work_outline,
              label: '감독 경력',
              value: '${coach.totalCareerYears}년',
            ),
        ],
      ),
    );
  }

  Widget _buildTrophiesLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.emoji_events, color: _gold, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                '수상 기록',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _gold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrophiesCard(List<CoachTrophy> trophies) {
    // 우승만 필터링하고 시즌 기준 정렬
    final winners = trophies.where((t) => t.isWinner).toList()
      ..sort((a, b) => b.season.compareTo(a.season));

    // 준우승 필터링
    final runnerUps = trophies.where((t) => t.isRunnerUp).toList()
      ..sort((a, b) => b.season.compareTo(a.season));

    final winnerCount = winners.length;
    final runnerUpCount = runnerUps.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.emoji_events, color: _gold, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  '수상 기록',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const Spacer(),
                // 우승/준우승 카운트
                if (winnerCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.emoji_events, size: 14, color: _gold),
                        const SizedBox(width: 4),
                        Text(
                          '$winnerCount',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (runnerUpCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.emoji_events, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          '$runnerUpCount',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: _border),

          // 우승 목록
          if (winners.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                '우승',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber.shade800,
                ),
              ),
            ),
            ...winners.take(10).map((trophy) => _TrophyTile(
              trophy: trophy,
              isWinner: true,
            )),
            if (winners.length > 10)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  '외 ${winners.length - 10}개',
                  style: TextStyle(
                    fontSize: 12,
                    color: _textSecondary,
                  ),
                ),
              ),
          ],

          // 준우승 목록
          if (runnerUps.isNotEmpty) ...[
            if (winners.isNotEmpty) const Divider(height: 1, color: _border),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                '준우승',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ...runnerUps.take(5).map((trophy) => _TrophyTile(
              trophy: trophy,
              isWinner: false,
            )),
            if (runnerUps.length > 5)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  '외 ${runnerUps.length - 5}개',
                  style: TextStyle(
                    fontSize: 12,
                    color: _textSecondary,
                  ),
                ),
              ),
          ],

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildCareerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.history, color: _primary, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  '경력',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${coach.career.length}개 팀',
                  style: const TextStyle(
                    fontSize: 13,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _border),

          // 경력 목록
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: coach.career.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: _border),
            itemBuilder: (context, index) {
              final career = coach.career[index];
              final isCurrentTeam = career.end == null;

              return InkWell(
                onTap: career.teamId != null
                    ? () => context.push('/team/${career.teamId}')
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // 팀 로고
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCurrentTeam ? _primary : _border,
                            width: isCurrentTeam ? 2 : 1,
                          ),
                          color: Colors.grey.shade100,
                        ),
                        child: ClipOval(
                          child: career.teamLogo != null
                              ? CachedNetworkImage(
                                  imageUrl: career.teamLogo!,
                                  fit: BoxFit.contain,
                                  placeholder: (_, __) => Icon(
                                    Icons.shield,
                                    size: 22,
                                    color: _textSecondary,
                                  ),
                                  errorWidget: (_, __, ___) => Icon(
                                    Icons.shield,
                                    size: 22,
                                    color: _textSecondary,
                                  ),
                                )
                              : Icon(
                                  Icons.shield,
                                  size: 22,
                                  color: _textSecondary,
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // 팀 정보
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    career.teamName ?? '알 수 없음',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isCurrentTeam
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isCurrentTeam ? _primary : _textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isCurrentTeam) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      '현재',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              career.periodText,
                              style: const TextStyle(
                                fontSize: 13,
                                color: _textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (career.teamId != null)
                        Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: _textSecondary,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  static const _textPrimary = Color(0xFF111827);
  static const _textSecondary = Color(0xFF6B7280);

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _textSecondary),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: _textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrophyTile extends StatelessWidget {
  final CoachTrophy trophy;
  final bool isWinner;

  static const _textPrimary = Color(0xFF111827);
  static const _textSecondary = Color(0xFF6B7280);
  static const _gold = Color(0xFFFFD700);

  const _TrophyTile({
    required this.trophy,
    required this.isWinner,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // 트로피 아이콘
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isWinner
                  ? _gold.withValues(alpha: 0.15)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events,
              size: 16,
              color: isWinner ? _gold : Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 12),

          // 대회 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trophy.league,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (trophy.country != null)
                  Text(
                    trophy.country!,
                    style: TextStyle(
                      fontSize: 12,
                      color: _textSecondary,
                    ),
                  ),
              ],
            ),
          ),

          // 시즌
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isWinner
                  ? _gold.withValues(alpha: 0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              trophy.season,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isWinner ? Colors.amber.shade800 : _textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
