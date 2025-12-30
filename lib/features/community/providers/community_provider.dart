import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post_model.dart';
import '../services/community_service.dart';

final communityServiceProvider = Provider((ref) => CommunityService());

// 게시글 목록 Provider
final postsProvider = FutureProvider<List<Post>>((ref) async {
  final service = ref.read(communityServiceProvider);
  return service.getPosts();
});

// 게시글 목록 Notifier (페이지네이션, 새로고침 지원)
class PostsNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  final CommunityService _service;
  bool _hasMore = true;
  bool _isLoading = false;
  List<String> _blockedUserIds = [];

  PostsNotifier(this._service) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    await _loadBlockedUsers();
    await loadPosts();
  }

  Future<void> _loadBlockedUsers() async {
    try {
      _blockedUserIds = await _service.getBlockedUserIds();
    } catch (_) {
      _blockedUserIds = [];
    }
  }

  List<Post> _filterBlockedPosts(List<Post> posts) {
    if (_blockedUserIds.isEmpty) return posts;
    return posts.where((post) => !_blockedUserIds.contains(post.authorId)).toList();
  }

  Future<void> loadPosts() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final posts = await _service.getPosts();
      final filteredPosts = _filterBlockedPosts(posts);
      _hasMore = posts.length >= 20;
      state = AsyncValue.data(filteredPosts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    _hasMore = true;
    await _loadBlockedUsers();
    await loadPosts();
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    final currentPosts = state.valueOrNull ?? [];
    if (currentPosts.isEmpty) return;

    _isLoading = true;

    try {
      // 실제 구현시 lastDocument를 전달해야 함
      // 여기서는 간단히 처리
      final morePosts = await _service.getPosts(limit: 20);
      final filteredPosts = _filterBlockedPosts(morePosts);
      _hasMore = morePosts.length >= 20;
      state = AsyncValue.data([...currentPosts, ...filteredPosts]);
    } catch (e) {
      // 에러 발생해도 기존 데이터 유지
    } finally {
      _isLoading = false;
    }
  }

  // 좋아요 수 업데이트
  void updateLikeCount(String postId, int delta) {
    final currentPosts = state.valueOrNull;
    if (currentPosts == null) return;

    state = AsyncValue.data(
      currentPosts.map((post) {
        if (post.id == postId) {
          return post.copyWith(likeCount: post.likeCount + delta);
        }
        return post;
      }).toList(),
    );
  }

  bool get hasMore => _hasMore;
}

final postsNotifierProvider = StateNotifierProvider<PostsNotifier, AsyncValue<List<Post>>>((ref) {
  final service = ref.read(communityServiceProvider);
  return PostsNotifier(service);
});

// 특정 게시글 Provider
final postProvider = FutureProvider.family<Post?, String>((ref, postId) async {
  final service = ref.read(communityServiceProvider);
  return service.getPost(postId);
});

// 댓글 목록 Provider
final commentsProvider = FutureProvider.family<List<Comment>, String>((ref, postId) async {
  final service = ref.read(communityServiceProvider);
  return service.getComments(postId);
});

// 좋아요 여부 Provider (단일 게시글)
final isLikedProvider = FutureProvider.family<bool, String>((ref, postId) async {
  final service = ref.read(communityServiceProvider);
  return service.isLiked(postId);
});

// 좋아요 상태 관리 Notifier (목록용)
class LikedPostsNotifier extends StateNotifier<Map<String, bool>> {
  final CommunityService _service;

  LikedPostsNotifier(this._service) : super({});

  // 여러 게시글의 좋아요 상태 로드
  Future<void> loadLikedStatus(List<String> postIds) async {
    final status = await _service.getLikedStatusForPosts(postIds);
    state = {...state, ...status};
  }

  // 좋아요 토글 (상태 업데이트)
  void setLiked(String postId, bool isLiked) {
    state = {...state, postId: isLiked};
  }

  // 단일 게시글 좋아요 여부 확인
  bool isLiked(String postId) => state[postId] ?? false;
}

final likedPostsProvider = StateNotifierProvider<LikedPostsNotifier, Map<String, bool>>((ref) {
  final service = ref.read(communityServiceProvider);
  return LikedPostsNotifier(service);
});

// 내 게시글 목록 Provider
final myPostsProvider = FutureProvider<List<Post>>((ref) async {
  final service = ref.read(communityServiceProvider);
  return service.getMyPosts();
});

// 차단된 사용자 ID 목록 Provider
final blockedUserIdsProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.read(communityServiceProvider);
  return service.getBlockedUserIds();
});

// 차단된 사용자 정보
class BlockedUser {
  final String userId;
  final String userName;

  BlockedUser({required this.userId, required this.userName});
}

// 차단된 사용자 목록 Notifier (실시간 업데이트용)
class BlockedUsersNotifier extends StateNotifier<AsyncValue<List<BlockedUser>>> {
  final CommunityService _service;

  BlockedUsersNotifier(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final blockedUsers = await _service.getBlockedUsers();
      state = AsyncValue.data(
        blockedUsers.map((u) => BlockedUser(
          userId: u['userId']!,
          userName: u['userName']!,
        )).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> unblock(String userId) async {
    await _service.unblockUser(userId);
    final currentList = state.valueOrNull ?? [];
    state = AsyncValue.data(currentList.where((u) => u.userId != userId).toList());
  }

  Future<void> block(String userId, String userName) async {
    await _service.blockUser(userId, targetUserName: userName);
    final currentList = state.valueOrNull ?? [];
    if (!currentList.any((u) => u.userId == userId)) {
      state = AsyncValue.data([...currentList, BlockedUser(userId: userId, userName: userName)]);
    }
  }

  bool isBlocked(String userId) {
    return state.valueOrNull?.any((u) => u.userId == userId) ?? false;
  }
}

final blockedUsersNotifierProvider =
    StateNotifierProvider<BlockedUsersNotifier, AsyncValue<List<BlockedUser>>>((ref) {
  final service = ref.read(communityServiceProvider);
  return BlockedUsersNotifier(service);
});
