import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// ============================================
// SCHEDULED FUNCTIONS
// ============================================

/**
 * Daily function to update match schedules from external API
 * Runs every day at 6:00 AM
 */
export const updateDailySchedules = functions.pubsub
  .schedule("0 6 * * *")
  .timeZone("Asia/Seoul")
  .onRun(async () => {
    console.log("Starting daily schedule update...");

    // TODO: Implement API call to fetch schedules
    // This is a placeholder - replace with actual API integration
    // Example: API-Football, SportsDataIO, etc.

    /*
    const response = await fetch('YOUR_API_ENDPOINT', {
      headers: {
        'X-API-Key': 'YOUR_API_KEY',
      },
    });
    const data = await response.json();

    // Process and save matches to Firestore
    const batch = db.batch();
    for (const match of data.matches) {
      const matchRef = db.collection('schedules').doc(match.id);
      batch.set(matchRef, {
        league: match.league,
        homeTeamId: match.homeTeam.id,
        homeTeamName: match.homeTeam.name,
        homeTeamLogo: match.homeTeam.logo,
        awayTeamId: match.awayTeam.id,
        awayTeamName: match.awayTeam.name,
        awayTeamLogo: match.awayTeam.logo,
        kickoff: admin.firestore.Timestamp.fromDate(new Date(match.kickoff)),
        stadium: match.venue,
        broadcast: match.broadcast,
        status: 'scheduled',
      });
    }
    await batch.commit();
    */

    console.log("Daily schedule update completed");
    return null;
  });

/**
 * Function to send kickoff notifications
 * Runs every 5 minutes to check for upcoming matches
 */
export const sendKickoffNotifications = functions.pubsub
  .schedule("*/5 * * * *")
  .timeZone("Asia/Seoul")
  .onRun(async () => {
    const now = new Date();
    const thirtyMinutesLater = new Date(now.getTime() + 30 * 60 * 1000);
    const thirtyFiveMinutesLater = new Date(now.getTime() + 35 * 60 * 1000);

    // Find matches starting in ~30 minutes
    const matchesSnapshot = await db
      .collection("schedules")
      .where("kickoff", ">=", admin.firestore.Timestamp.fromDate(thirtyMinutesLater))
      .where("kickoff", "<", admin.firestore.Timestamp.fromDate(thirtyFiveMinutesLater))
      .where("status", "==", "scheduled")
      .get();

    if (matchesSnapshot.empty) {
      console.log("No upcoming matches in the next 30 minutes");
      return null;
    }

    for (const matchDoc of matchesSnapshot.docs) {
      const match = matchDoc.data();

      // Find users who want notifications for this match
      const notificationSettingsSnapshot = await db
        .collection("notification_settings")
        .where("matchId", "==", matchDoc.id)
        .where("notifyKickoff", "==", true)
        .get();

      if (notificationSettingsSnapshot.empty) continue;

      const userIds = notificationSettingsSnapshot.docs.map((doc) => doc.data().userId);

      // Get FCM tokens for these users
      for (const userId of userIds) {
        const userDoc = await db.collection("users").doc(userId).get();
        const fcmToken = userDoc.data()?.fcmToken;

        if (fcmToken) {
          try {
            await messaging.send({
              token: fcmToken,
              notification: {
                title: "Match Starting Soon!",
                body: `${match.homeTeamName} vs ${match.awayTeamName} kicks off in 30 minutes`,
              },
              data: {
                type: "kickoff",
                matchId: matchDoc.id,
              },
              android: {
                priority: "high",
                notification: {
                  channelId: "match_notifications",
                },
              },
              apns: {
                payload: {
                  aps: {
                    sound: "default",
                    badge: 1,
                  },
                },
              },
            });
            console.log(`Sent kickoff notification to user ${userId}`);
          } catch (error) {
            console.error(`Failed to send notification to user ${userId}:`, error);
          }
        }
      }
    }

    return null;
  });

/**
 * Function to send match result notifications
 * Triggered when a match status changes to 'finished'
 */
export const onMatchFinished = functions.firestore
  .document("schedules/{matchId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Check if match just finished
    if (before.status !== "finished" && after.status === "finished") {
      const matchId = context.params.matchId;

      // Find users who want result notifications
      const notificationSettingsSnapshot = await db
        .collection("notification_settings")
        .where("matchId", "==", matchId)
        .where("notifyResult", "==", true)
        .get();

      if (notificationSettingsSnapshot.empty) return null;

      const userIds = notificationSettingsSnapshot.docs.map((doc) => doc.data().userId);

      for (const userId of userIds) {
        const userDoc = await db.collection("users").doc(userId).get();
        const fcmToken = userDoc.data()?.fcmToken;

        if (fcmToken) {
          try {
            await messaging.send({
              token: fcmToken,
              notification: {
                title: "Match Finished!",
                body: `${after.homeTeamName} ${after.homeScore} - ${after.awayScore} ${after.awayTeamName}`,
              },
              data: {
                type: "result",
                matchId: matchId,
              },
            });
            console.log(`Sent result notification to user ${userId}`);
          } catch (error) {
            console.error(`Failed to send notification to user ${userId}:`, error);
          }
        }
      }
    }

    return null;
  });

// ============================================
// USER TRIGGERS
// ============================================

/**
 * Update followedBoost when user follows/unfollows a team
 */
export const onUserFavoritesUpdate = functions.firestore
  .document("users/{userId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    const beforeTeams: string[] = before.favoriteTeamIds || [];
    const afterTeams: string[] = after.favoriteTeamIds || [];

    // Find newly followed teams
    const newlyFollowed = afterTeams.filter((id) => !beforeTeams.includes(id));

    // Find newly unfollowed teams
    const newlyUnfollowed = beforeTeams.filter((id) => !afterTeams.includes(id));

    const batch = db.batch();

    // Update schedules for newly followed teams
    for (const teamId of newlyFollowed) {
      const homeMatches = await db
        .collection("schedules")
        .where("homeTeamId", "==", teamId)
        .get();

      const awayMatches = await db
        .collection("schedules")
        .where("awayTeamId", "==", teamId)
        .get();

      for (const doc of [...homeMatches.docs, ...awayMatches.docs]) {
        batch.update(doc.ref, { followedBoost: true });
      }
    }

    // Check if unfollowed teams still have followers
    for (const teamId of newlyUnfollowed) {
      const usersFollowing = await db
        .collection("users")
        .where("favoriteTeamIds", "array-contains", teamId)
        .limit(1)
        .get();

      if (usersFollowing.empty) {
        const homeMatches = await db
          .collection("schedules")
          .where("homeTeamId", "==", teamId)
          .get();

        const awayMatches = await db
          .collection("schedules")
          .where("awayTeamId", "==", teamId)
          .get();

        for (const doc of [...homeMatches.docs, ...awayMatches.docs]) {
          batch.update(doc.ref, { followedBoost: false });
        }
      }
    }

    await batch.commit();
    return null;
  });

// ============================================
// DATA CLEANUP
// ============================================

/**
 * Clean up old notification settings for past matches
 * Runs weekly on Sunday at midnight
 */
export const cleanupOldNotifications = functions.pubsub
  .schedule("0 0 * * 0")
  .timeZone("Asia/Seoul")
  .onRun(async () => {
    const oneWeekAgo = new Date();
    oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);

    // Get all matches from more than a week ago
    const oldMatchesSnapshot = await db
      .collection("schedules")
      .where("kickoff", "<", admin.firestore.Timestamp.fromDate(oneWeekAgo))
      .get();

    const oldMatchIds = oldMatchesSnapshot.docs.map((doc) => doc.id);

    if (oldMatchIds.length === 0) {
      console.log("No old matches to clean up");
      return null;
    }

    // Delete notification settings for old matches
    const batch = db.batch();
    let deleteCount = 0;

    for (const matchId of oldMatchIds) {
      const notificationSettings = await db
        .collection("notification_settings")
        .where("matchId", "==", matchId)
        .get();

      for (const doc of notificationSettings.docs) {
        batch.delete(doc.ref);
        deleteCount++;
      }
    }

    await batch.commit();
    console.log(`Cleaned up ${deleteCount} old notification settings`);
    return null;
  });

// ============================================
// HTTP CALLABLE FUNCTIONS
// ============================================

/**
 * Register FCM token for push notifications
 */
export const registerFCMToken = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
  }

  const { token } = data;
  if (!token) {
    throw new functions.https.HttpsError("invalid-argument", "FCM token is required");
  }

  await db.collection("users").doc(context.auth.uid).update({
    fcmToken: token,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { success: true };
});

/**
 * Get attendance statistics for a user
 */
export const getAttendanceStats = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
  }

  const userId = context.auth.uid;
  const attendanceSnapshot = await db
    .collection("attendance_records")
    .where("userId", "==", userId)
    .get();

  const records = attendanceSnapshot.docs.map((doc) => doc.data());

  const stats = {
    totalMatches: records.length,
    wins: 0,
    draws: 0,
    losses: 0,
    stadiumVisits: {} as Record<string, number>,
    leagueCount: {} as Record<string, number>,
  };

  for (const record of records) {
    // Count stadium visits
    const stadium = record.stadium as string;
    stats.stadiumVisits[stadium] = (stats.stadiumVisits[stadium] || 0) + 1;

    // Count league
    const league = record.league as string;
    stats.leagueCount[league] = (stats.leagueCount[league] || 0) + 1;

    // Calculate win/draw/loss (simplified - would need favorite team context)
    if (record.homeScore !== null && record.awayScore !== null) {
      if (record.homeScore > record.awayScore) {
        stats.wins++;
      } else if (record.homeScore < record.awayScore) {
        stats.losses++;
      } else {
        stats.draws++;
      }
    }
  }

  return stats;
});
