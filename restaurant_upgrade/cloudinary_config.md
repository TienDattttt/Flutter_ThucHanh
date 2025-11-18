# Cấu hình Cloudinary

## Bước 1: Tạo tài khoản Cloudinary
1. Truy cập https://cloudinary.com/
2. Đăng ký tài khoản miễn phí
3. Sau khi đăng ký, bạn sẽ có:
   - Cloud Name
   - API Key
   - API Secret

## Bước 2: Tạo Upload Preset
1. Vào Dashboard Cloudinary
2. Chọn Settings > Upload
3. Tạo Upload Preset mới với tên: `restaurant_review_preset`
4. Cấu hình:
   - Signing Mode: Unsigned
   - Folder: restaurant_review_system
   - Allowed formats: jpg, png, webp
   - Max file size: 5MB
   - Image transformations: Auto optimize

## Bước 3: Cập nhật AppConstants
Thay thế `your-cloud-name` trong `lib/core/constants/app_constants.dart`:

```dart
static const String cloudinaryCloudName = 'your-actual-cloud-name';
```

## Bước 4: Cấu hình bảo mật (Tùy chọn)
Để tăng bảo mật, bạn có thể:
1. Tạo signed upload preset
2. Sử dụng server-side signature
3. Giới hạn domain upload

## Lưu ý
- Upload preset phải được cấu hình là "unsigned" để có thể upload từ client
- Cloudinary miễn phí có giới hạn 25GB storage và 25GB bandwidth/tháng
- Hình ảnh sẽ được tự động optimize và có thể resize theo nhu cầu