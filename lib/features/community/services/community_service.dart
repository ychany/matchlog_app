import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/errors/app_exception.dart';
import '../models/post_model.dart';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _postsCollection => _firestore.collection('posts');
  CollectionReference get _commentsCollection => _firestore.collection('comments');
  CollectionReference get _likesCollection => _firestore.collection('likes');
  CollectionReference get _reportsCollection => _firestore.collection('reports');
  CollectionReference get _blockedUsersCollection => _firestore.collection('blocked_users');

  // 게시글 목록 조회 (페이지네이션)
  Future<List<Post>> getPosts({
    DocumentSnapshot? lastDocument,
    int limit = 20,
    String? tag,
  }) async {
    Query query = _postsCollection.orderBy('createdAt', descending: true).limit(limit);

    if (tag != null && tag.isNotEmpty) {
      query = query.where('tags', arrayContains: tag);
    }

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
  }

  // 게시글 상세 조회
  Future<Post?> getPost(String postId) async {
    final doc = await _postsCollection.doc(postId).get();
    if (doc.exists) {
      return Post.fromFirestore(doc);
    }
    return null;
  }

  // 게시글 작성
  Future<String> createPost({
    required String title,
    required String content,
    List<String> imageUrls = const [],
    List<String> tags = const [],
    String? attendanceId,
    String? homeTeamName,
    String? awayTeamName,
    String? homeTeamLogo,
    String? awayTeamLogo,
    int? homeScore,
    int? awayScore,
    DateTime? matchDate,
    String? stadium,
    String? league,
    // 통계 필드
    int? statsTotalMatches,
    int? statsWins,
    int? statsDraws,
    int? statsLosses,
    double? statsWinRate,
    String? statsTopStadium,
    int? statsTopStadiumCount,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw AppException(AppErrorCode.loginRequired);

    final post = Post(
      id: '',
      authorId: user.uid,
      authorName: user.displayName ?? '익명',
      authorProfileUrl: user.photoURL,
      title: title,
      content: content,
      imageUrls: imageUrls,
      tags: tags,
      createdAt: DateTime.now(),
      attendanceId: attendanceId,
      homeTeamName: homeTeamName,
      awayTeamName: awayTeamName,
      homeTeamLogo: homeTeamLogo,
      awayTeamLogo: awayTeamLogo,
      homeScore: homeScore,
      awayScore: awayScore,
      matchDate: matchDate,
      stadium: stadium,
      league: league,
      statsTotalMatches: statsTotalMatches,
      statsWins: statsWins,
      statsDraws: statsDraws,
      statsLosses: statsLosses,
      statsWinRate: statsWinRate,
      statsTopStadium: statsTopStadium,
      statsTopStadiumCount: statsTopStadiumCount,
    );

    final firestoreData = post.toFirestore();
    final docRef = await _postsCollection.add(firestoreData);
    return docRef.id;
  }

  // 게시글 수정
  Future<void> updatePost({
    required String postId,
    required String title,
    required String content,
    List<String>? imageUrls,
    List<String>? tags,
    String? attendanceId,
    String? homeTeamName,
    String? awayTeamName,
    String? homeTeamLogo,
    String? awayTeamLogo,
    int? homeScore,
    int? awayScore,
    DateTime? matchDate,
    String? stadium,
    String? league,
    bool clearAttendance = false,
    // 통계 필드
    int? statsTotalMatches,
    int? statsWins,
    int? statsDraws,
    int? statsLosses,
    double? statsWinRate,
    String? statsTopStadium,
    int? statsTopStadiumCount,
    bool clearStats = false,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw AppException(AppErrorCode.loginRequired);

    final post = await getPost(postId);
    if (post == null) throw AppException(AppErrorCode.postNotFound);
    if (post.authorId != user.uid) throw AppException(AppErrorCode.postEditPermissionDenied);

    final updateData = <String, dynamic>{
      'title': title,
      'content': content,
      'updatedAt': Timestamp.now(),
    };

    if (imageUrls != null) updateData['imageUrls'] = imageUrls;
    if (tags != null) updateData['tags'] = tags;

    if (clearAttendance) {
      updateData['attendanceId'] = FieldValue.delete();
      updateData['homeTeamName'] = FieldValue.delete();
      updateData['awayTeamName'] = FieldValue.delete();
      updateData['homeTeamLogo'] = FieldValue.delete();
      updateData['awayTeamLogo'] = FieldValue.delete();
      updateData['homeScore'] = FieldValue.delete();
      updateData['awayScore'] = FieldValue.delete();
      updateData['matchDate'] = FieldValue.delete();
      updateData['stadium'] = FieldValue.delete();
      updateData['league'] = FieldValue.delete();
    } else if (attendanceId != null) {
      updateData['attendanceId'] = attendanceId;
      if (homeTeamName != null) updateData['homeTeamName'] = homeTeamName;
      if (awayTeamName != null) updateData['awayTeamName'] = awayTeamName;
      if (homeTeamLogo != null) updateData['homeTeamLogo'] = homeTeamLogo;
      if (awayTeamLogo != null) updateData['awayTeamLogo'] = awayTeamLogo;
      if (homeScore != null) updateData['homeScore'] = homeScore;
      if (awayScore != null) updateData['awayScore'] = awayScore;
      if (matchDate != null) updateData['matchDate'] = Timestamp.fromDate(matchDate);
      if (stadium != null) updateData['stadium'] = stadium;
      if (league != null) updateData['league'] = league;
    }

    // 통계 데이터 처리
    if (clearStats) {
      updateData['statsTotalMatches'] = FieldValue.delete();
      updateData['statsWins'] = FieldValue.delete();
      updateData['statsDraws'] = FieldValue.delete();
      updateData['statsLosses'] = FieldValue.delete();
      updateData['statsWinRate'] = FieldValue.delete();
      updateData['statsTopStadium'] = FieldValue.delete();
      updateData['statsTopStadiumCount'] = FieldValue.delete();
    } else if (statsTotalMatches != null) {
      updateData['statsTotalMatches'] = statsTotalMatches;
      if (statsWins != null) updateData['statsWins'] = statsWins;
      if (statsDraws != null) updateData['statsDraws'] = statsDraws;
      if (statsLosses != null) updateData['statsLosses'] = statsLosses;
      if (statsWinRate != null) updateData['statsWinRate'] = statsWinRate;
      if (statsTopStadium != null) updateData['statsTopStadium'] = statsTopStadium;
      if (statsTopStadiumCount != null) updateData['statsTopStadiumCount'] = statsTopStadiumCount;
    }

    await _postsCollection.doc(postId).update(updateData);
  }

  // 게시글 삭제
  Future<void> deletePost(String postId) async {
    final user = _auth.currentUser;
    if (user == null) throw AppException(AppErrorCode.loginRequired);

    final post = await getPost(postId);
    if (post == null) throw AppException(AppErrorCode.postNotFound);
    if (post.authorId != user.uid) throw AppException(AppErrorCode.postDeletePermissionDenied);

    // 댓글 삭제
    final comments = await _commentsCollection.where('postId', isEqualTo: postId).get();
    for (final doc in comments.docs) {
      await doc.reference.delete();
    }

    // 좋아요 삭제
    final likes = await _likesCollection.where('postId', isEqualTo: postId).get();
    for (final doc in likes.docs) {
      await doc.reference.delete();
    }

    // 게시글 삭제
    await _postsCollection.doc(postId).delete();
  }

  // 좋아요 토글
  Future<bool> toggleLike(String postId) async {
    final user = _auth.currentUser;
    if (user == null) throw AppException(AppErrorCode.loginRequired);

    final likeId = '${user.uid}_$postId';
    final likeDoc = _likesCollection.doc(likeId);
    final likeSnapshot = await likeDoc.get();

    if (likeSnapshot.exists) {
      // 좋아요 취소
      await likeDoc.delete();
      await _postsCollection.doc(postId).update({
        'likeCount': FieldValue.increment(-1),
      });
      return false;
    } else {
      // 좋아요 추가
      final likeData = {
        'userId': user.uid,
        'postId': postId,
        'createdAt': Timestamp.now(),
      };
      await likeDoc.set(likeData);
      await _postsCollection.doc(postId).update({
        'likeCount': FieldValue.increment(1),
      });
      return true;
    }
  }

  // 좋아요 여부 확인
  Future<bool> isLiked(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final likeId = '${user.uid}_$postId';
    final likeDoc = await _likesCollection.doc(likeId).get();
    return likeDoc.exists;
  }

  // 여러 게시글의 좋아요 여부 일괄 확인
  Future<Map<String, bool>> getLikedStatusForPosts(List<String> postIds) async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final result = <String, bool>{};
    for (final postId in postIds) {
      final likeId = '${user.uid}_$postId';
      final likeDoc = await _likesCollection.doc(likeId).get();
      result[postId] = likeDoc.exists;
    }
    return result;
  }

  // 댓글 목록 조회
  Future<List<Comment>> getComments(String postId) async {
    final snapshot = await _commentsCollection
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: false)
        .get();
    return snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();
  }

  // 댓글 작성
  Future<String> createComment({
    required String postId,
    required String content,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw AppException(AppErrorCode.loginRequired);

    final comment = Comment(
      id: '',
      postId: postId,
      authorId: user.uid,
      authorName: user.displayName ?? '익명',
      authorProfileUrl: user.photoURL,
      content: content,
      createdAt: DateTime.now(),
    );

    final commentData = comment.toFirestore();
    final docRef = await _commentsCollection.add(commentData);

    // 댓글 수 증가
    await _postsCollection.doc(postId).update({
      'commentCount': FieldValue.increment(1),
    });

    return docRef.id;
  }

  // 댓글 삭제
  Future<void> deleteComment(String commentId, String postId) async {
    final user = _auth.currentUser;
    if (user == null) throw AppException(AppErrorCode.loginRequired);

    final commentDoc = await _commentsCollection.doc(commentId).get();
    if (!commentDoc.exists) throw AppException(AppErrorCode.commentNotFound);

    final comment = Comment.fromFirestore(commentDoc);
    if (comment.authorId != user.uid) throw AppException(AppErrorCode.commentDeletePermissionDenied);

    await _commentsCollection.doc(commentId).delete();

    // 댓글 수 감소
    await _postsCollection.doc(postId).update({
      'commentCount': FieldValue.increment(-1),
    });
  }

  // 내 게시글 목록
  Future<List<Post>> getMyPosts() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _postsCollection
        .where('authorId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
  }

  // 신고하기
  Future<void> reportContent({
    required String contentType, // 'post', 'comment', 'user'
    required String contentId,
    required String reason,
    String? additionalInfo,
    String? reportedUserId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw AppException(AppErrorCode.loginRequired);

    // 중복 신고 확인
    final existingReport = await _reportsCollection
        .where('reporterId', isEqualTo: user.uid)
        .where('contentType', isEqualTo: contentType)
        .where('contentId', isEqualTo: contentId)
        .get();

    if (existingReport.docs.isNotEmpty) {
      throw Exception('ALREADY_REPORTED');
    }

    await _reportsCollection.add({
      'reporterId': user.uid,
      'reporterName': user.displayName ?? 'Unknown',
      'contentType': contentType,
      'contentId': contentId,
      'reportedUserId': reportedUserId,
      'reason': reason,
      'additionalInfo': additionalInfo,
      'status': 'pending', // pending, reviewed, resolved
      'createdAt': Timestamp.now(),
    });
  }

  // 사용자 차단
  Future<void> blockUser(String targetUserId, {String? targetUserName}) async {
    final user = _auth.currentUser;
    if (user == null) throw AppException(AppErrorCode.loginRequired);

    final blockId = '${user.uid}_$targetUserId';
    await _blockedUsersCollection.doc(blockId).set({
      'blockerId': user.uid,
      'blockedUserId': targetUserId,
      'blockedUserName': targetUserName ?? 'Unknown',
      'createdAt': Timestamp.now(),
    });
  }

  // 차단 해제
  Future<void> unblockUser(String targetUserId) async {
    final user = _auth.currentUser;
    if (user == null) throw AppException(AppErrorCode.loginRequired);

    final blockId = '${user.uid}_$targetUserId';
    await _blockedUsersCollection.doc(blockId).delete();
  }

  // 차단 여부 확인
  Future<bool> isUserBlocked(String targetUserId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final blockId = '${user.uid}_$targetUserId';
    final doc = await _blockedUsersCollection.doc(blockId).get();
    return doc.exists;
  }

  // 차단된 사용자 목록 (ID만)
  Future<List<String>> getBlockedUserIds() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _blockedUsersCollection
        .where('blockerId', isEqualTo: user.uid)
        .get();

    return snapshot.docs
        .map((doc) => doc['blockedUserId'] as String)
        .toList();
  }

  // 차단된 사용자 목록 (ID와 이름 포함)
  Future<List<Map<String, String>>> getBlockedUsers() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _blockedUsersCollection
        .where('blockerId', isEqualTo: user.uid)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'userId': data['blockedUserId'] as String,
        'userName': data['blockedUserName'] as String? ?? 'Unknown',
      };
    }).toList();
  }
}
