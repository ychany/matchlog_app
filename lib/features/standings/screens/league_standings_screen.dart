import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_football_service.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/standings_provider.dart';

// League info provider
final leagueInfoProvider = FutureProvider.family<ApiFootballLeague?, int>((ref, leagueId) async {
  final service = ApiFootballService();
  final leagues = await service.getLeagueById(leagueId);
  return leagues;
});

// League standings provider for specific league
final externalLeagueStandingsProvider = FutureProvider.family<List<ApiFootballStanding>, StandingsKey>((ref, key) async {
  final service = ApiFootballService();
  return service.getStandings(key.leagueId, key.season);
});

class LeagueStandingsScreen extends ConsumerStatefulWidget {
  final String leagueId;

  const LeagueStandingsScreen({super.key, required this.leagueId});

  @override
  ConsumerState<LeagueStandingsScreen> createState() => _LeagueStandingsScreenState();
}

class _LeagueStandingsScreenState extends ConsumerState<LeagueStandingsScreen> {
  static const _primary = Color(0xFF2563EB);
  static const _primaryLight = Color(0xFFDBEAFE);
  static const _textPrimary = Color(0xFF111827);
  static const _textSecondary = Color(0xFF6B7280);
  static const _border = Color(0xFFE5E7EB);
  static const _background = Color(0xFFF9FAFB);

  int? _selectedSeason;
  int _selectedTab = 0; // 0: 순위, 1: 득점, 2: 어시스트

  int get _leagueIdInt => int.tryParse(widget.leagueId) ?? 0;

  int get _currentSeason {
    if (_selectedSeason != null) return _selectedSeason!;
    return getCurrentSeasonForLeague(_leagueIdInt);
  }

  List<int> get _availableSeasons => getAvailableSeasons(_leagueIdInt);

  @override
  Widget build(BuildContext context) {
    final leagueId = _leagueIdInt;
    if (leagueId == 0) {
      return Scaffold(
        backgroundColor: _background,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, null),
              const Expanded(
                child: Center(
                  child: Text('잘못된 리그 ID입니다'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final leagueAsync = ref.watch(leagueInfoProvider(leagueId));
    final standingsKey = StandingsKey(leagueId, _currentSeason);
    final standingsAsync = ref.watch(externalLeagueStandingsProvider(standingsKey));
    final topScorersAsync = ref.watch(topScorersProvider(standingsKey));
    final topAssistsAsync = ref.watch(topAssistsProvider(standingsKey));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _background,
        body: SafeArea(
          child: Column(
            children: [
              // Header with league info
              leagueAsync.when(
                data: (league) => _buildHeader(context, league),
                loading: () => _buildAppBar(context, null),
                error: (_, __) => _buildAppBar(context, null),
              ),

              // Season selector
              _buildSeasonSelector(),

              const SizedBox(height: 12),

              // Tab selector
              _buildTabSelector(),

              const SizedBox(height: 12),

              // Content
              Expanded(
                child: _selectedTab == 0
                    ? _buildStandingsContent(standingsAsync, standingsKey)
                    : _selectedTab == 1
                        ? _buildTopScorersContent(topScorersAsync, standingsKey)
                        : _buildTopAssistsContent(topAssistsAsync, standingsKey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ApiFootballLeague? league) {
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
          Expanded(
            child: Text(
              league?.name ?? '리그 순위',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ApiFootballLeague? league) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // App bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  color: _textPrimary,
                  onPressed: () => context.pop(),
                ),
                if (league?.logo != null) ...[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _border),
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: league!.logo!,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => const Icon(Icons.emoji_events, size: 18),
                        errorWidget: (_, __, ___) => const Icon(Icons.emoji_events, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    league?.name ?? '리그 순위',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (league?.countryName != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      league!.countryName!,
                      style: TextStyle(
                        fontSize: 12,
                        color: _primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonSelector() {
    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _availableSeasons.map((season) {
          final isSelected = season == _currentSeason;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSeason = season;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected ? _primaryLight : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? _primary : _border,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  getSeasonDisplayName(season, _leagueIdInt),
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? _primary : _textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          _buildTabButton('순위', 0),
          _buildTabButton('득점', 1),
          _buildTabButton('어시스트', 2),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? _primary : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : _textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStandingsContent(
    AsyncValue<List<ApiFootballStanding>> standingsAsync,
    StandingsKey standingsKey,
  ) {
    return standingsAsync.when(
      data: (standings) {
        if (standings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.leaderboard_outlined, size: 64, color: _textSecondary),
                const SizedBox(height: 16),
                const Text('순위 정보가 없습니다', style: TextStyle(color: _textSecondary)),
                const SizedBox(height: 8),
                const Text(
                  '해당 시즌의 순위 정보를 불러올 수 없습니다',
                  style: TextStyle(color: _textSecondary, fontSize: 12),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(externalLeagueStandingsProvider(standingsKey));
          },
          child: _StandingsTable(standings: standings),
        );
      },
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorState(
        message: e.toString(),
        onRetry: () => ref.invalidate(externalLeagueStandingsProvider(standingsKey)),
      ),
    );
  }

  Widget _buildTopScorersContent(
    AsyncValue<List<ApiFootballTopScorer>> topScorersAsync,
    StandingsKey standingsKey,
  ) {
    return topScorersAsync.when(
      data: (scorers) {
        if (scorers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_soccer, size: 64, color: _textSecondary),
                const SizedBox(height: 16),
                const Text('득점 순위 정보가 없습니다', style: TextStyle(color: _textSecondary)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(topScorersProvider(standingsKey));
          },
          child: _TopScorersTable(scorers: scorers, isGoals: true),
        );
      },
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorState(
        message: e.toString(),
        onRetry: () => ref.invalidate(topScorersProvider(standingsKey)),
      ),
    );
  }

  Widget _buildTopAssistsContent(
    AsyncValue<List<ApiFootballTopScorer>> topAssistsAsync,
    StandingsKey standingsKey,
  ) {
    return topAssistsAsync.when(
      data: (assists) {
        if (assists.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.handshake_outlined, size: 64, color: _textSecondary),
                const SizedBox(height: 16),
                const Text('어시스트 순위 정보가 없습니다', style: TextStyle(color: _textSecondary)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(topAssistsProvider(standingsKey));
          },
          child: _TopScorersTable(scorers: assists, isGoals: false),
        );
      },
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorState(
        message: e.toString(),
        onRetry: () => ref.invalidate(topAssistsProvider(standingsKey)),
      ),
    );
  }
}

class _StandingsTable extends StatelessWidget {
  final List<ApiFootballStanding> standings;

  const _StandingsTable({required this.standings});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const SizedBox(width: 28, child: Text('순위', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                const SizedBox(width: 8),
                const Expanded(child: Text('팀', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                _HeaderCell('경기'),
                _HeaderCell('승'),
                _HeaderCell('무'),
                _HeaderCell('패'),
                _HeaderCell('득점'),
                _HeaderCell('실점'),
                _HeaderCell('득실'),
                const SizedBox(
                  width: 36,
                  child: Text(
                    '승점',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Rows
          ...standings.map((standing) => _StandingRow(standing: standing)),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;

  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  final ApiFootballStanding standing;

  static const _primary = Color(0xFF2563EB);

  const _StandingRow({required this.standing});

  @override
  Widget build(BuildContext context) {
    final desc = standing.description?.toLowerCase() ?? '';

    Color rankColor = Colors.grey;
    Color? rowColor;

    // Determine colors based on description
    if (desc.contains('champions') && !desc.contains('championship')) {
      rowColor = Colors.blue.withValues(alpha: 0.08);
      rankColor = Colors.blue;
    } else if (desc.contains('europa') && !desc.contains('relegation')) {
      rowColor = Colors.orange.withValues(alpha: 0.08);
      rankColor = Colors.orange;
    } else if (desc.contains('conference') && !desc.contains('relegation')) {
      rowColor = Colors.green.withValues(alpha: 0.08);
      rankColor = Colors.green;
    } else if (desc.contains('promotion')) {
      rowColor = Colors.green.withValues(alpha: 0.08);
      rankColor = Colors.green;
    } else if (desc.contains('relegation') && !desc.contains('europa') && !desc.contains('conference')) {
      rowColor = Colors.red.withValues(alpha: 0.08);
      rankColor = Colors.red;
    }

    return InkWell(
      onTap: () => context.push('/team/${standing.teamId}'),
      child: Container(
        color: rowColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 28,
              alignment: Alignment.center,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: rankColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${standing.rank}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: rankColor,
                  ),
                ),
              ),
            ),

            Expanded(
              child: Row(
                children: [
                  if (standing.teamLogo != null)
                    CachedNetworkImage(
                      imageUrl: standing.teamLogo!,
                      width: 24,
                      height: 24,
                      placeholder: (_, __) => const SizedBox(width: 24, height: 24),
                      errorWidget: (_, __, ___) => const Icon(Icons.shield, size: 24, color: Colors.grey),
                    )
                  else
                    const Icon(Icons.shield, size: 24, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      standing.teamName,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            _StatCell('${standing.played}'),
            _StatCell('${standing.win}', color: Colors.green),
            _StatCell('${standing.draw}'),
            _StatCell('${standing.lose}', color: Colors.red),
            _StatCell('${standing.goalsFor}'),
            _StatCell('${standing.goalsAgainst}'),
            _StatCell(
              standing.goalsDiff >= 0 ? '+${standing.goalsDiff}' : '${standing.goalsDiff}',
              color: standing.goalsDiff > 0 ? Colors.green : (standing.goalsDiff < 0 ? Colors.red : null),
            ),

            Container(
              width: 36,
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${standing.points}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: _primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String text;
  final Color? color;

  const _StatCell(this.text, {this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: color),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TopScorersTable extends StatelessWidget {
  final List<ApiFootballTopScorer> scorers;
  final bool isGoals;

  const _TopScorersTable({required this.scorers, required this.isGoals});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const SizedBox(width: 28, child: Text('순위', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                const SizedBox(width: 8),
                const Expanded(child: Text('선수', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                const SizedBox(
                  width: 50,
                  child: Text(
                    '출전',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    isGoals ? '득점' : '어시',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Rows
          ...scorers.asMap().entries.map((entry) => _TopScorerRow(
            rank: entry.key + 1,
            scorer: entry.value,
            isGoals: isGoals,
          )),
        ],
      ),
    );
  }
}

class _TopScorerRow extends StatelessWidget {
  final int rank;
  final ApiFootballTopScorer scorer;
  final bool isGoals;

  static const _primary = Color(0xFF2563EB);

  const _TopScorerRow({
    required this.rank,
    required this.scorer,
    required this.isGoals,
  });

  @override
  Widget build(BuildContext context) {
    Color rankColor = Colors.grey;
    Color? rowColor;

    if (rank == 1) {
      rankColor = Colors.amber.shade700;
      rowColor = Colors.amber.withValues(alpha: 0.08);
    } else if (rank == 2) {
      rankColor = Colors.grey.shade500;
      rowColor = Colors.grey.withValues(alpha: 0.05);
    } else if (rank == 3) {
      rankColor = Colors.brown.shade400;
      rowColor = Colors.brown.withValues(alpha: 0.05);
    }

    return InkWell(
      onTap: () => context.push('/player/${scorer.playerId}'),
      child: Container(
        color: rowColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Rank
            Container(
              width: 28,
              alignment: Alignment.center,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: rankColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: rankColor,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Player Photo + Name + Team
            Expanded(
              child: Row(
                children: [
                  if (scorer.playerPhoto != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: scorer.playerPhoto!,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, size: 20, color: Colors.grey),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, size: 20, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, size: 20, color: Colors.grey),
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scorer.playerName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            if (scorer.teamLogo != null) ...[
                              CachedNetworkImage(
                                imageUrl: scorer.teamLogo!,
                                width: 14,
                                height: 14,
                                placeholder: (_, __) => const SizedBox(width: 14, height: 14),
                                errorWidget: (_, __, ___) => const Icon(Icons.shield, size: 14, color: Colors.grey),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(
                                scorer.teamName,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Appearances
            SizedBox(
              width: 50,
              child: Text(
                '${scorer.appearances ?? 0}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),

            // Goals or Assists
            Container(
              width: 50,
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${isGoals ? (scorer.goals ?? 0) : (scorer.assists ?? 0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: _primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
