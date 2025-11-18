import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// Initialize Firebase Admin SDK
admin.initializeApp();

// Export all functions
export { calculateAverageRating } from "./triggers/calculateAverageRating";
export { 
  sendReviewNotification,
  registerFCMToken,
  unregisterFCMToken,
  subscribeToRestaurant,
  unsubscribeFromRestaurant
} from "./triggers/sendReviewNotification";
export { onUserCreate } from "./triggers/onUserCreate";
export { onRestaurantCreate } from "./triggers/onRestaurantCreate";

// Health check function
export const healthCheck = functions.https.onRequest((request, response) => {
  response.json({
    status: "healthy",
    timestamp: new Date().toISOString(),
    message: "Restaurant Review System Cloud Functions are running",
  });
});