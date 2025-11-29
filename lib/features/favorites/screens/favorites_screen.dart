import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/team_model.dart';
import '../../../shared/models/player_model.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/team_logo.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedFavoritesTabProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('즐겨찾기'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context, ref, selectedTab),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label: '팀',
                    isSelected: selectedTab == FavoritesTab.teams,
                    onTap: () {
                      ref.read(selectedFavoritesTabProvider.notifier).state =
                          FavoritesTab.teams;
                    },
                  ),
                ),
                Expanded(
                  child: _TabButton(
                    label: '선수',
                    isSelected: selectedTab == FavoritesTab.players,
                    onTap: () {
                      ref.read(selectedFavoritesTabProvider.notifier).state =
                          FavoritesTab.players;
                    },
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: selectedTab == FavoritesTab.teams
                ? const _TeamsTab()
                : const _PlayersTab(),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref, FavoritesTab tab) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => tab == FavoritesTab.teams
            ? _AddTeamSheet(scrollController: scrollController)
            : _AddPlayerSheet(scrollController: scrollController),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _TeamsTab extends ConsumerWidget {
  const _TeamsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsAsync = ref.watch(favoriteTeamsProvider);

    return teamsAsync.when(
      data: (teams) {
        if (teams.isEmpty) {
          return const EmptyFavoritesState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: teams.length,
          itemBuilder: (context, index) {
            return _TeamCard(
              team: teams[index],
              onUnfollow: () {
                ref
                    .read(favoritesNotifierProvider.notifier)
                    .unfollowTeam(teams[index].id);
              },
            );
          },
        );
      },
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorState(
        message: e.toString(),
        onRetry: () => ref.invalidate(favoriteTeamsProvider),
      ),
    );
  }
}

class _PlayersTab extends ConsumerWidget {
  const _PlayersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(favoritePlayersProvider);

    return playersAsync.when(
      data: (players) {
        if (players.isEmpty) {
          return const EmptyFavoritesState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: players.length,
          itemBuilder: (context, index) {
            return _PlayerCard(
              player: players[index],
              onUnfollow: () {
                ref
                    .read(favoritesNotifierProvider.notifier)
                    .unfollowPlayer(players[index].id);
              },
            );
          },
        );
      },
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorState(
        message: e.toString(),
        onRetry: () => ref.invalidate(favoritePlayersProvider),
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final Team team;
  final VoidCallback onUnfollow;

  const _TeamCard({
    required this.team,
    required this.onUnfollow,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: TeamLogo(
          logoUrl: team.logoUrl,
          teamName: team.name,
          size: 48,
        ),
        title: Text(team.nameKr, style: AppTextStyles.subtitle1),
        subtitle: Text(
          '${team.league} | ${team.stadiumName ?? ""}',
          style: AppTextStyles.caption,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: AppColors.error),
          onPressed: () => _confirmUnfollow(context),
        ),
      ),
    );
  }

  void _confirmUnfollow(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('팀 팔로우 해제'),
        content: Text('${team.nameKr}을(를) 즐겨찾기에서 제거하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onUnfollow();
            },
            child: const Text('해제', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final Player player;
  final VoidCallback onUnfollow;

  const _PlayerCard({
    required this.player,
    required this.onUnfollow,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundImage:
              player.photoUrl != null ? NetworkImage(player.photoUrl!) : null,
          child: player.photoUrl == null
              ? Text(player.name.substring(0, 1))
              : null,
        ),
        title: Text(player.nameKr, style: AppTextStyles.subtitle1),
        subtitle: Text(
          '${player.teamName} | ${player.position}',
          style: AppTextStyles.caption,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (player.number != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '#${player.number}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.favorite, color: AppColors.error),
              onPressed: () => _confirmUnfollow(context),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmUnfollow(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('선수 팔로우 해제'),
        content: Text('${player.nameKr}을(를) 즐겨찾기에서 제거하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onUnfollow();
            },
            child: const Text('해제', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _AddTeamSheet extends ConsumerStatefulWidget {
  final ScrollController scrollController;

  const _AddTeamSheet({required this.scrollController});

  @override
  ConsumerState<_AddTeamSheet> createState() => _AddTeamSheetState();
}

class _AddTeamSheetState extends ConsumerState<_AddTeamSheet> {
  String? selectedLeague;
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('팀 추가', style: AppTextStyles.headline3),
          const SizedBox(height: 16),

          // Search
          TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: '팀 검색...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              ref.read(teamSearchQueryProvider.notifier).state = value;
            },
          ),
          const SizedBox(height: 16),

          // League filter
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _LeagueFilterChip(
                  label: '전체',
                  isSelected: selectedLeague == null,
                  onTap: () => setState(() => selectedLeague = null),
                ),
                ...AppConstants.supportedLeagues.map((league) => _LeagueFilterChip(
                  label: league,
                  isSelected: selectedLeague == league,
                  onTap: () => setState(() => selectedLeague = league),
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Results
          Expanded(
            child: _buildTeamResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamResults() {
    final searchQuery = ref.watch(teamSearchQueryProvider);

    if (searchQuery.isNotEmpty) {
      final searchResults = ref.watch(teamSearchResultsProvider);
      return searchResults.when(
        data: (teams) => _buildTeamList(teams),
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
      );
    }

    if (selectedLeague != null) {
      final leagueTeams = ref.watch(teamsByLeagueProvider(selectedLeague!));
      return leagueTeams.when(
        data: (teams) => _buildTeamList(teams),
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
      );
    }

    return const Center(
      child: Text('리그를 선택하거나 팀을 검색하세요'),
    );
  }

  Widget _buildTeamList(List<Team> teams) {
    if (teams.isEmpty) {
      return const Center(child: Text('팀을 찾을 수 없습니다'));
    }

    return ListView.builder(
      controller: widget.scrollController,
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        final isFollowedAsync = ref.watch(isTeamFollowedProvider(team.id));

        return ListTile(
          leading: TeamLogo(
            logoUrl: team.logoUrl,
            teamName: team.name,
            size: 40,
          ),
          title: Text(team.nameKr),
          subtitle: Text(team.league),
          trailing: isFollowedAsync.when(
            data: (isFollowed) => IconButton(
              icon: Icon(
                isFollowed ? Icons.favorite : Icons.favorite_border,
                color: isFollowed ? AppColors.error : null,
              ),
              onPressed: () {
                ref
                    .read(favoritesNotifierProvider.notifier)
                    .toggleTeamFollow(team.id);
              },
            ),
            loading: () => const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, __) => const Icon(Icons.error),
          ),
        );
      },
    );
  }
}

class _AddPlayerSheet extends ConsumerStatefulWidget {
  final ScrollController scrollController;

  const _AddPlayerSheet({required this.scrollController});

  @override
  ConsumerState<_AddPlayerSheet> createState() => _AddPlayerSheetState();
}

class _AddPlayerSheetState extends ConsumerState<_AddPlayerSheet> {
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(playerSearchResultsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('선수 추가', style: AppTextStyles.headline3),
          const SizedBox(height: 16),

          // Search
          TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: '선수 검색...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              ref.read(playerSearchQueryProvider.notifier).state = value;
            },
          ),
          const SizedBox(height: 16),

          // Results
          Expanded(
            child: searchResults.when(
              data: (players) {
                if (players.isEmpty) {
                  return const Center(
                    child: Text('선수 이름으로 검색하세요'),
                  );
                }
                return ListView.builder(
                  controller: widget.scrollController,
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    final isFollowedAsync =
                        ref.watch(isPlayerFollowedProvider(player.id));

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: player.photoUrl != null
                            ? NetworkImage(player.photoUrl!)
                            : null,
                        child: player.photoUrl == null
                            ? Text(player.name.substring(0, 1))
                            : null,
                      ),
                      title: Text(player.nameKr),
                      subtitle: Text('${player.teamName} | ${player.position}'),
                      trailing: isFollowedAsync.when(
                        data: (isFollowed) => IconButton(
                          icon: Icon(
                            isFollowed ? Icons.favorite : Icons.favorite_border,
                            color: isFollowed ? AppColors.error : null,
                          ),
                          onPressed: () {
                            ref
                                .read(favoritesNotifierProvider.notifier)
                                .togglePlayerFollow(player.id);
                          },
                        ),
                        loading: () => const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (_, __) => const Icon(Icons.error),
                      ),
                    );
                  },
                );
              },
              loading: () => const LoadingIndicator(),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeagueFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LeagueFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
      ),
    );
  }
}
