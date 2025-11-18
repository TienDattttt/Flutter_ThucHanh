import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { COLLECTIONS, NOTIFICATION_TYPES } from '../utils/constants';
import { logError, logInfo } from '../utils/helpers';

/**
 * Cloud Function triggered when a new review is created
 * Sends push notification to restaurant owner and subscribers
 */
export const sendReviewNotification = functions.firestore
  .document(`${COLLECTIONS.REVIEWS}/{reviewId}`)
  .onCreate(async (snapshot, context) => {
    try {
      const reviewData = snapshot.data();
      const reviewId = context.params.reviewId;

      logInfo('Processing new review notification', { reviewId, restaurantId: reviewData.restaurantId });

      // Get restaurant information
      const restaurantDoc = await admin.firestore()
        .collection(COLLECTIONS.RESTAURANTS)
        .doc(reviewData.restaurantId)
        .get();

      if (!restaurantDoc.exists) {
        logError('Restaurant not found', { restaurantId: reviewData.restaurantId });
        return;
      }

      const restaurantData = restaurantDoc.data()!;

      // Prepare notification data
      const notificationData = {
        type: NOTIFICATION_TYPES.NEW_REVIEW,
        title: 'Đánh giá mới',
        body: `${reviewData.userDisplayName} đã đánh giá ${restaurantData.name} ${reviewData.rating} sao`,
        data: {
          restaurantId: reviewData.restaurantId,
          reviewId: reviewId,
          rating: reviewData.rating.toString(),
          restaurantName: restaurantData.name,
          reviewerName: reviewData.userDisplayName,
        },
        imageUrl: restaurantData.imageUrls?.[0] || null,
      };

      // Send notifications in parallel
      const notificationPromises: Promise<any>[] = [];

      // 1. Send to restaurant owner if exists
      if (restaurantData.ownerId) {
        notificationPromises.push(
          sendNotificationToUser(restaurantData.ownerId, notificationData)
        );
      }

      // 2. Send to restaurant subscribers
      notificationPromises.push(
        sendNotificationToTopic(`restaurant_${reviewData.restaurantId}`, notificationData)
      );

      // 3. Save notification to database for restaurant owner
      if (restaurantData.ownerId) {
        notificationPromises.push(
          saveNotificationToDatabase(restaurantData.ownerId, notificationData, reviewId)
        );
      }

      await Promise.allSettled(notificationPromises);

      logInfo('Review notification sent successfully', { reviewId });

    } catch (error) {
      logError('Error sending review notification', error, { reviewId: context.params.reviewId });
    }
  });

/**
 * Send notification to a specific user
 */
async function sendNotificationToUser(userId: string, notificationData: any): Promise<void> {
  try {
    // Get user's FCM tokens
    const userDoc = await admin.firestore()
      .collection(COLLECTIONS.USERS)
      .doc(userId)
      .get();

    if (!userDoc.exists) {
      logError('User not found for notification', { userId });
      return;
    }

    const userData = userDoc.data()!;
    const fcmTokens = userData.fcmTokens || [];

    if (fcmTokens.length === 0) {
      logInfo('No FCM tokens found for user', { userId });
      return;
    }

    // Prepare FCM message
    const message = {
      notification: {
        title: notificationData.title,
        body: notificationData.body,
        imageUrl: notificationData.imageUrl,
      },
      data: notificationData.data,
      tokens: fcmTokens,
    };

    // Send multicast message
    const response = await admin.messaging().sendMulticast(message);

    // Handle failed tokens
    if (response.failureCount > 0) {
      const failedTokens: string[] = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          failedTokens.push(fcmTokens[idx]);
        }
      });

      // Remove invalid tokens
      if (failedTokens.length > 0) {
        const validTokens = fcmTokens.filter(token => !failedTokens.includes(token));
        await admin.firestore()
          .collection(COLLECTIONS.USERS)
          .doc(userId)
          .update({ fcmTokens: validTokens });
      }
    }

    logInfo('Notification sent to user', { 
      userId, 
      successCount: response.successCount, 
      failureCount: response.failureCount 
    });

  } catch (error) {
    logError('Error sending notification to user', error, { userId });
  }
}

/**
 * Send notification to a topic
 */
async function sendNotificationToTopic(topic: string, notificationData: any): Promise<void> {
  try {
    const message = {
      notification: {
        title: notificationData.title,
        body: notificationData.body,
        imageUrl: notificationData.imageUrl,
      },
      data: notificationData.data,
      topic: topic,
    };

    const response = await admin.messaging().send(message);
    logInfo('Notification sent to topic', { topic, messageId: response });

  } catch (error) {
    logError('Error sending notification to topic', error, { topic });
  }
}

/**
 * Save notification to database for persistence
 */
async function saveNotificationToDatabase(
  userId: string, 
  notificationData: any, 
  reviewId: string
): Promise<void> {
  try {
    const notification = {
      userId: userId,
      type: notificationData.type,
      title: notificationData.title,
      body: notificationData.body,
      data: notificationData.data,
      imageUrl: notificationData.imageUrl,
      isRead: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      relatedId: reviewId,
    };

    await admin.firestore()
      .collection(COLLECTIONS.NOTIFICATIONS)
      .add(notification);

    logInfo('Notification saved to database', { userId, reviewId });

  } catch (error) {
    logError('Error saving notification to database', error, { userId, reviewId });
  }
}

/**
 * Cloud Function to handle FCM token registration
 */
export const registerFCMToken = functions.https.onCall(async (data, context) => {
  try {
    // Verify authentication
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { token } = data;
    const userId = context.auth.uid;

    if (!token) {
      throw new functions.https.HttpsError('invalid-argument', 'FCM token is required');
    }

    // Get current user data
    const userDoc = await admin.firestore()
      .collection(COLLECTIONS.USERS)
      .doc(userId)
      .get();

    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'User not found');
    }

    const userData = userDoc.data()!;
    const currentTokens = userData.fcmTokens || [];

    // Add token if not already present
    if (!currentTokens.includes(token)) {
      const updatedTokens = [...currentTokens, token];
      
      await admin.firestore()
        .collection(COLLECTIONS.USERS)
        .doc(userId)
        .update({ fcmTokens: updatedTokens });

      logInfo('FCM token registered', { userId, token: token.substring(0, 20) + '...' });
    }

    return { success: true };

  } catch (error) {
    logError('Error registering FCM token', error);
    throw error;
  }
});

/**
 * Cloud Function to handle FCM token removal
 */
export const unregisterFCMToken = functions.https.onCall(async (data, context) => {
  try {
    // Verify authentication
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { token } = data;
    const userId = context.auth.uid;

    if (!token) {
      throw new functions.https.HttpsError('invalid-argument', 'FCM token is required');
    }

    // Get current user data
    const userDoc = await admin.firestore()
      .collection(COLLECTIONS.USERS)
      .doc(userId)
      .get();

    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'User not found');
    }

    const userData = userDoc.data()!;
    const currentTokens = userData.fcmTokens || [];

    // Remove token if present
    const updatedTokens = currentTokens.filter(t => t !== token);
    
    if (updatedTokens.length !== currentTokens.length) {
      await admin.firestore()
        .collection(COLLECTIONS.USERS)
        .doc(userId)
        .update({ fcmTokens: updatedTokens });

      logInfo('FCM token unregistered', { userId, token: token.substring(0, 20) + '...' });
    }

    return { success: true };

  } catch (error) {
    logError('Error unregistering FCM token', error);
    throw error;
  }
});

/**
 * Cloud Function to subscribe user to restaurant notifications
 */
export const subscribeToRestaurant = functions.https.onCall(async (data, context) => {
  try {
    // Verify authentication
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { restaurantId } = data;
    const userId = context.auth.uid;

    if (!restaurantId) {
      throw new functions.https.HttpsError('invalid-argument', 'Restaurant ID is required');
    }

    // Get user's FCM tokens
    const userDoc = await admin.firestore()
      .collection(COLLECTIONS.USERS)
      .doc(userId)
      .get();

    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'User not found');
    }

    const userData = userDoc.data()!;
    const fcmTokens = userData.fcmTokens || [];

    if (fcmTokens.length === 0) {
      throw new functions.https.HttpsError('failed-precondition', 'No FCM tokens found');
    }

    // Subscribe tokens to restaurant topic
    const topic = `restaurant_${restaurantId}`;
    await admin.messaging().subscribeToTopic(fcmTokens, topic);

    logInfo('User subscribed to restaurant notifications', { userId, restaurantId });

    return { success: true };

  } catch (error) {
    logError('Error subscribing to restaurant notifications', error);
    throw error;
  }
});

/**
 * Cloud Function to unsubscribe user from restaurant notifications
 */
export const unsubscribeFromRestaurant = functions.https.onCall(async (data, context) => {
  try {
    // Verify authentication
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { restaurantId } = data;
    const userId = context.auth.uid;

    if (!restaurantId) {
      throw new functions.https.HttpsError('invalid-argument', 'Restaurant ID is required');
    }

    // Get user's FCM tokens
    const userDoc = await admin.firestore()
      .collection(COLLECTIONS.USERS)
      .doc(userId)
      .get();

    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'User not found');
    }

    const userData = userDoc.data()!;
    const fcmTokens = userData.fcmTokens || [];

    if (fcmTokens.length === 0) {
      logInfo('No FCM tokens found for unsubscription', { userId, restaurantId });
      return { success: true };
    }

    // Unsubscribe tokens from restaurant topic
    const topic = `restaurant_${restaurantId}`;
    await admin.messaging().unsubscribeFromTopic(fcmTokens, topic);

    logInfo('User unsubscribed from restaurant notifications', { userId, restaurantId });

    return { success: true };

  } catch (error) {
    logError('Error unsubscribing from restaurant notifications', error);
    throw error;
  }
});