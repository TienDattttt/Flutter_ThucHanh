# Tài liệu Thiết kế - Hệ thống Đánh giá Nhà hàng

## Tổng quan

Hệ thống Đánh giá Nhà hàng được thiết kế theo Clean Architecture với 3 layer chính: Presentation, Domain và Data. Ứng dụng sử dụng Flutter cho frontend và Firebase ecosystem cho backend, đảm bảo khả năng mở rộng và bảo trì cao.

## Kiến trúc

### Kiến trúc tổng thể

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter App (Client)                     │
├─────────────────────────────────────────────────────────────┤
│  Presentation Layer                                         │
│  ├── Pages (UI Screens)                                     │
│  ├── Widgets (Reusable Components)                          │
│  └── State Management (BLoC/Cubit)                          │
├─────────────────────────────────────────────────────────────┤
│  Domain Layer                                               │
│  ├── Entities (Business Objects)                            │
│  ├── Use Cases (Business Logic)                             │
│  └── Repository Interfaces                                  │
├─────────────────────────────────────────────────────────────┤
│  Data Layer                                                 │
│  ├── Repository Implementations                             │
│  ├── Data Sources (Remote/Local)                            │
│  └── Models (Data Transfer Objects)                         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Firebase Backend                         │
├─────────────────────────────────────────────────────────────┤
│  Firebase Authentication                                    │
│  ├── User Registration/Login                                │
│  └── Session Management                                     │
├─────────────────────────────────────────────────────────────┤
│  Cloud Firestore                                           │
│  ├── Users Collection                                       │
│  ├── Restaurants Collection                                 │
│  └── Reviews Collection                                     │
├─────────────────────────────────────────────────────────────┤
│  Firebase Storage                                           │
│  └── Review Images                                          │
├─────────────────────────────────────────────────────────────┤
│  Cloud Functions                                            │
│  ├── Calculate Average Rating                               │
│  └── Send Push Notifications                                │
├─────────────────────────────────────────────────────────────┤
│  Firebase Cloud Messaging                                   │
│  └── Push Notifications                                     │
└─────────────────────────────────────────────────────────────┘
```

### Clean Architecture Layers

**1. Presentation Layer**
- Chứa UI components, pages và state management
- Sử dụng BLoC pattern để quản lý state
- Không chứa business logic

**2. Domain Layer**
- Chứa business entities và use cases
- Định nghĩa repository interfaces
- Độc lập với framework và external dependencies

**3. Data Layer**
- Implement repository interfaces
- Xử lý data sources (Firebase services)
- Chuyển đổi giữa models và entities

## Thành phần và Giao diện

### 1. Authentication Module

**AuthRepository Interface:**
```dart
abstract class AuthRepository {
  Future<User?> signUp(String email, String password);
  Future<User?> signIn(String email, String password);
  Future<void> signOut();
  Stream<User?> get authStateChanges;
  User? get currentUser;
}
```

**Use Cases:**
- `SignUpUseCase`: Xử lý đăng ký người dùng
- `SignInUseCase`: Xử lý đăng nhập
- `SignOutUseCase`: Xử lý đăng xuất
- `GetCurrentUserUseCase`: Lấy thông tin người dùng hiện tại

### 2. Restaurant Module

**RestaurantRepository Interface:**
```dart
abstract class RestaurantRepository {
  Stream<List<Restaurant>> getRestaurants();
  Future<Restaurant?> getRestaurantById(String id);
  Future<void> addRestaurant(Restaurant restaurant);
  Future<void> updateRestaurant(Restaurant restaurant);
}
```

**Use Cases:**
- `GetRestaurantsUseCase`: Lấy danh sách nhà hàng
- `GetRestaurantDetailsUseCase`: Lấy chi tiết nhà hàng
- `AddRestaurantUseCase`: Thêm nhà hàng mới

### 3. Review Module

**ReviewRepository Interface:**
```dart
abstract class ReviewRepository {
  Stream<List<Review>> getReviewsByRestaurant(String restaurantId);
  Future<void> addReview(Review review);
  Future<String> uploadImage(File image);
  Future<void> deleteReview(String reviewId);
}
```

**Use Cases:**
- `GetReviewsUseCase`: Lấy danh sách đánh giá
- `AddReviewUseCase`: Thêm đánh giá mới
- `UploadImageUseCase`: Upload ảnh đánh giá

### 4. Notification Module

**NotificationRepository Interface:**
```dart
abstract class NotificationRepository {
  Future<void> initializeNotifications();
  Future<String?> getToken();
  Stream<RemoteMessage> get onMessage;
  Stream<RemoteMessage> get onMessageOpenedApp;
}
```

## Mô hình Dữ liệu

### 1. User Entity
```dart
class User {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### 2. Restaurant Entity
```dart
class Restaurant {
  final String id;
  final String name;
  final String address;
  final String description;
  final List<String> imageUrls;
  final double averageRating;
  final int totalReviews;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### 3. Review Entity
```dart
class Review {
  final String id;
  final String restaurantId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final int rating;
  final String comment;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Firestore Collections Structure

**Users Collection:**
```
users/{userId}
├── email: string
├── displayName: string
├── photoUrl: string?
├── createdAt: timestamp
└── updatedAt: timestamp
```

**Restaurants Collection:**
```
restaurants/{restaurantId}
├── name: string
├── address: string
├── description: string
├── imageUrls: array<string>
├── averageRating: number
├── totalReviews: number
├── createdAt: timestamp
└── updatedAt: timestamp
```

**Reviews Collection:**
```
reviews/{reviewId}
├── restaurantId: string
├── userId: string
├── userName: string
├── userPhotoUrl: string?
├── rating: number
├── comment: string
├── imageUrls: array<string>
├── createdAt: timestamp
└── updatedAt: timestamp
```

## Xử lý Lỗi

### 1. Authentication Errors
- `UserNotFoundException`: Người dùng không tồn tại
- `WrongPasswordException`: Mật khẩu sai
- `EmailAlreadyInUseException`: Email đã được sử dụng
- `WeakPasswordException`: Mật khẩu yếu

### 2. Network Errors
- `NetworkException`: Lỗi kết nối mạng
- `TimeoutException`: Timeout khi gọi API
- `ServerException`: Lỗi từ phía server

### 3. Storage Errors
- `ImageUploadException`: Lỗi khi upload ảnh
- `FileSizeException`: File quá lớn
- `UnsupportedFileTypeException`: Định dạng file không được hỗ trợ

### Error Handling Strategy
```dart
class Failure {
  final String message;
  final String code;
  
  const Failure({required this.message, required this.code});
}

// Use Cases return Either<Failure, Success>
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
```

## Chiến lược Kiểm thử

### 1. Unit Tests
- Test tất cả Use Cases với mock dependencies
- Test Repository implementations với mock data sources
- Test Entity validation và business logic
- Coverage target: 90%+

### 2. Widget Tests
- Test UI components với mock data
- Test user interactions và state changes
- Test error states và loading states
- Test responsive design

### 3. Integration Tests
- Test end-to-end user flows
- Test Firebase integration
- Test image upload functionality
- Test real-time data synchronization

### Test Structure
```
test/
├── unit/
│   ├── domain/
│   │   ├── entities/
│   │   └── usecases/
│   └── data/
│       ├── repositories/
│       └── datasources/
├── widget/
│   ├── pages/
│   └── widgets/
└── integration/
    ├── auth_flow_test.dart
    ├── review_flow_test.dart
    └── notification_test.dart
```

## Cloud Functions

### 1. Calculate Average Rating Function
```javascript
exports.calculateAverageRating = functions.firestore
  .document('reviews/{reviewId}')
  .onCreate(async (snap, context) => {
    const review = snap.data();
    const restaurantId = review.restaurantId;
    
    // Query all reviews for this restaurant
    const reviewsSnapshot = await admin.firestore()
      .collection('reviews')
      .where('restaurantId', '==', restaurantId)
      .get();
    
    // Calculate average rating
    let totalRating = 0;
    let totalReviews = reviewsSnapshot.size;
    
    reviewsSnapshot.forEach(doc => {
      totalRating += doc.data().rating;
    });
    
    const averageRating = totalRating / totalReviews;
    
    // Update restaurant document
    await admin.firestore()
      .collection('restaurants')
      .doc(restaurantId)
      .update({
        averageRating: averageRating,
        totalReviews: totalReviews,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
  });
```

### 2. Send Notification Function
```javascript
exports.sendReviewNotification = functions.firestore
  .document('reviews/{reviewId}')
  .onCreate(async (snap, context) => {
    const review = snap.data();
    const restaurantDoc = await admin.firestore()
      .collection('restaurants')
      .doc(review.restaurantId)
      .get();
    
    const restaurant = restaurantDoc.data();
    
    const message = {
      notification: {
        title: 'Đánh giá mới',
        body: `${restaurant.name} có đánh giá mới từ ${review.userName}`
      },
      topic: `restaurant_${review.restaurantId}`
    };
    
    await admin.messaging().send(message);
  });
```

## Bảo mật

### 1. Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Anyone can read restaurants
    match /restaurants/{restaurantId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Users can read all reviews, but only write their own
    match /reviews/{reviewId} {
      allow read: if true;
      allow create: if request.auth != null && 
        request.auth.uid == resource.data.userId;
      allow update, delete: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

### 2. Storage Security Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /review_images/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null &&
        request.resource.size < 5 * 1024 * 1024 && // 5MB limit
        request.resource.contentType.matches('image/.*');
    }
  }
}
```

## Performance Optimization

### 1. Firestore Optimization
- Sử dụng composite indexes cho complex queries
- Implement pagination cho danh sách nhà hàng và đánh giá
- Cache frequently accessed data locally
- Sử dụng Firestore offline persistence

### 2. Image Optimization
- Compress images trước khi upload
- Generate thumbnails cho hiển thị danh sách
- Lazy loading cho images
- Cache images locally

### 3. State Management Optimization
- Sử dụng BLoC pattern với proper state management
- Implement proper disposal để tránh memory leaks
- Debounce search queries
- Optimize rebuild cycles

## Deployment và CI/CD

### 1. Firebase Hosting
- Deploy web version lên Firebase Hosting
- Configure custom domain
- Enable HTTPS và HTTP/2

### 2. App Distribution
- Sử dụng Firebase App Distribution cho beta testing
- Automated builds với GitHub Actions
- Code signing cho iOS và Android

### 3. Monitoring
- Firebase Crashlytics cho crash reporting
- Firebase Performance Monitoring
- Firebase Analytics cho user behavior tracking