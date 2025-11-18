import * as admin from "firebase-admin";
import { COLLECTIONS } from "./constants";

/**
 * Calculate average rating from reviews
 */
export async function calculateRestaurantAverageRating(
  restaurantId: string
): Promise<{ averageRating: number; totalReviews: number }> {
  try {
    const reviewsSnapshot = await admin
      .firestore()
      .collection(COLLECTIONS.REVIEWS)
      .where("restaurantId", "==", restaurantId)
      .get();

    if (reviewsSnapshot.empty) {
      return { averageRating: 0, totalReviews: 0 };
    }

    let totalRating = 0;
    let totalReviews = 0;

    reviewsSnapshot.forEach((doc) => {
      const reviewData = doc.data();
      if (reviewData.rating && typeof reviewData.rating === "number") {
        totalRating += reviewData.rating;
        totalReviews++;
      }
    });

    const averageRating = totalReviews > 0 ? totalRating / totalReviews : 0;

    return {
      averageRating: Math.round(averageRating * 10) / 10, // Round to 1 decimal place
      totalReviews,
    };
  } catch (error) {
    console.error("Error calculating average rating:", error);
    throw new Error("Failed to calculate average rating");
  }
}

/**
 * Update restaurant rating in Firestore
 */
export async function updateRestaurantRating(
  restaurantId: string,
  averageRating: number,
  totalReviews: number
): Promise<void> {
  try {
    await admin
      .firestore()
      .collection(COLLECTIONS.RESTAURANTS)
      .doc(restaurantId)
      .update({
        averageRating,
        totalReviews,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
  } catch (error) {
    console.error("Error updating restaurant rating:", error);
    throw new Error("Failed to update restaurant rating");
  }
}

/**
 * Send push notification to topic
 */
export async function sendNotificationToTopic(
  topic: string,
  title: string,
  body: string,
  data?: Record<string, string>
): Promise<void> {
  try {
    const message = {
      notification: {
        title,
        body,
      },
      data: data || {},
      topic,
    };

    await admin.messaging().send(message);
  } catch (error) {
    console.error("Error sending notification to topic:", error);
    throw new Error("Failed to send notification");
  }
}

/**
 * Send push notification to specific user
 */
export async function sendNotificationToUser(
  userId: string,
  title: string,
  body: string,
  data?: Record<string, string>
): Promise<void> {
  try {
    // Get user's FCM token from user document
    const userDoc = await admin
      .firestore()
      .collection(COLLECTIONS.USERS)
      .doc(userId)
      .get();

    if (!userDoc.exists) {
      throw new Error("User not found");
    }

    const userData = userDoc.data();
    const fcmToken = userData?.fcmToken;

    if (!fcmToken) {
      console.log(`No FCM token found for user ${userId}`);
      return;
    }

    const message = {
      notification: {
        title,
        body,
      },
      data: data || {},
      token: fcmToken,
    };

    await admin.messaging().send(message);
  } catch (error) {
    console.error("Error sending notification to user:", error);
    throw new Error("Failed to send notification to user");
  }
}

/**
 * Create notification document in Firestore
 */
export async function createNotificationDocument(
  userId: string,
  type: string,
  title: string,
  body: string,
  data?: Record<string, any>,
  imageUrl?: string,
  actionUrl?: string
): Promise<void> {
  try {
    await admin
      .firestore()
      .collection(COLLECTIONS.NOTIFICATIONS)
      .add({
        userId,
        type,
        title,
        body,
        data: data || {},
        imageUrl: imageUrl || null,
        actionUrl: actionUrl || null,
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
  } catch (error) {
    console.error("Error creating notification document:", error);
    throw new Error("Failed to create notification document");
  }
}

/**
 * Get restaurant data by ID
 */
export async function getRestaurantById(restaurantId: string): Promise<any> {
  try {
    const restaurantDoc = await admin
      .firestore()
      .collection(COLLECTIONS.RESTAURANTS)
      .doc(restaurantId)
      .get();

    if (!restaurantDoc.exists) {
      throw new Error("Restaurant not found");
    }

    return { id: restaurantDoc.id, ...restaurantDoc.data() };
  } catch (error) {
    console.error("Error getting restaurant:", error);
    throw new Error("Failed to get restaurant");
  }
}

/**
 * Get user data by ID
 */
export async function getUserById(userId: string): Promise<any> {
  try {
    const userDoc = await admin
      .firestore()
      .collection(COLLECTIONS.USERS)
      .doc(userId)
      .get();

    if (!userDoc.exists) {
      throw new Error("User not found");
    }

    return { id: userDoc.id, ...userDoc.data() };
  } catch (error) {
    console.error("Error getting user:", error);
    throw new Error("Failed to get user");
  }
}

/**
 * Validate rating value
 */
export function isValidRating(rating: any): boolean {
  return (
    typeof rating === "number" &&
    rating >= 1 &&
    rating <= 5 &&
    Number.isInteger(rating)
  );
}

/**
 * Sanitize string input
 */
export function sanitizeString(input: any): string {
  if (typeof input !== "string") {
    return "";
  }
  return input.trim();
}

/**
 * Validate required fields
 */
export function validateRequiredFields(
  data: Record<string, any>,
  requiredFields: string[]
): string | null {
  for (const field of requiredFields) {
    if (!data[field] || data[field] === "") {
      return `Missing required field: ${field}`;
    }
  }
  return null;
}