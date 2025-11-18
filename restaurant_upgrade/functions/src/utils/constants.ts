// Firebase Collections
export const COLLECTIONS = {
  USERS: "users",
  RESTAURANTS: "restaurants",
  REVIEWS: "reviews",
  NOTIFICATIONS: "notifications",
  CATEGORIES: "categories",
} as const;

// Notification Topics
export const NOTIFICATION_TOPICS = {
  ALL_USERS: "all_users",
  RESTAURANT_PREFIX: "restaurant_",
  USER_PREFIX: "user_",
} as const;

// Notification Types
export const NOTIFICATION_TYPES = {
  NEW_REVIEW: "new_review",
  REVIEW_LIKED: "review_liked",
  RESTAURANT_UPDATE: "restaurant_update",
  SYSTEM_MESSAGE: "system_message",
} as const;

// Rating Constants
export const RATING_CONSTANTS = {
  MIN_RATING: 1,
  MAX_RATING: 5,
  DEFAULT_RATING: 0,
} as const;

// Error Messages
export const ERROR_MESSAGES = {
  RESTAURANT_NOT_FOUND: "Không tìm thấy nhà hàng",
  REVIEW_NOT_FOUND: "Không tìm thấy đánh giá",
  USER_NOT_FOUND: "Không tìm thấy người dùng",
  INVALID_DATA: "Dữ liệu không hợp lệ",
  PERMISSION_DENIED: "Không có quyền truy cập",
  INTERNAL_ERROR: "Lỗi nội bộ",
} as const;

// Success Messages
export const SUCCESS_MESSAGES = {
  RATING_UPDATED: "Đánh giá đã được cập nhật",
  NOTIFICATION_SENT: "Thông báo đã được gửi",
  USER_CREATED: "Người dùng đã được tạo",
  RESTAURANT_CREATED: "Nhà hàng đã được tạo",
} as const;