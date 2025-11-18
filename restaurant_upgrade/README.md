# Restaurant Review System

Hệ thống Đánh giá Nhà hàng được xây dựng bằng Flutter và Firebase, cho phép người dùng khám phá các nhà hàng, đọc và viết đánh giá kèm theo hình ảnh.

## Tính năng chính

- 🔐 Xác thực người dùng (Đăng ký/Đăng nhập)
- 🏪 Danh sách nhà hàng với thông tin chi tiết
- ⭐ Hệ thống đánh giá và bình luận
- 📸 Upload hình ảnh cho đánh giá
- 🔔 Thông báo đẩy khi có đánh giá mới
- 📱 Giao diện responsive và thân thiện

## Kiến trúc

Dự án được xây dựng theo **Clean Architecture** với 3 layer chính:

```
lib/
├── core/                    # Core utilities và constants
│   ├── constants/          # App constants
│   ├── error/              # Error handling
│   ├── network/            # Network utilities
│   ├── usecases/           # Base use case
│   └── utils/              # Utility functions
├── features/               # Feature modules
│   ├── authentication/     # Authentication module
│   ├── restaurants/        # Restaurant module
│   ├── reviews/            # Review module
│   └── notifications/      # Notification module
└── shared/                 # Shared UI components
    ├── theme/              # App theme
    └── widgets/            # Reusable widgets
```

## Dependencies chính

- **Firebase**: Core, Auth, Firestore, Storage, Messaging
- **State Management**: flutter_bloc
- **Dependency Injection**: get_it
- **Functional Programming**: dartz
- **Image Handling**: image_picker, cached_network_image

## Cài đặt

1. Clone repository
2. Chạy `flutter pub get` để cài đặt dependencies
3. Cấu hình Firebase project (xem phần Firebase Setup)
4. Chạy `flutter run` để khởi động ứng dụng

## Firebase Setup

### Android
1. Thêm file `google-services.json` vào `android/app/`
2. Cấu hình đã được thêm vào `android/build.gradle.kts` và `android/app/build.gradle.kts`

### iOS
1. Thêm file `GoogleService-Info.plist` vào `ios/Runner/`
2. Cấu hình iOS sẽ được thêm trong các task tiếp theo

## Trạng thái hiện tại

✅ **Task 1 hoàn thành**: Thiết lập cấu trúc dự án và dependencies
- Cấu trúc thư mục Clean Architecture
- Dependencies Firebase và các package cần thiết
- Cấu hình cơ bản cho Android và iOS
- Theme và shared components
- Dependency injection setup

## Các task tiếp theo

- Task 2: Triển khai Core Infrastructure
- Task 3: Triển khai Authentication Module
- Task 4: Triển khai Restaurant Module
- Task 5: Triển khai Review Module
- Task 6: Triển khai Cloud Functions
- Task 7: Triển khai Push Notifications
- Task 8: Security và Performance
- Task 9: Integration và Testing
- Task 10: Deployment và Monitoring

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
