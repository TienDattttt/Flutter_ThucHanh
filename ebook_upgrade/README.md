# Ứng Dụng Đọc Sách Điện Tử

Ứng dụng đọc sách điện tử nâng cao được xây dựng bằng Flutter với các tính năng UI/UX chuyên nghiệp.

## Tính Năng

### 1. Quản Lý Sách
- Hiển thị danh sách sách từ API
- Cache sách để đọc offline
- Giao diện card đẹp mắt với Material Design 3

### 2. Trải Nghiệm Đọc
- Hiệu ứng lật trang mượt mà với PageView
- Điều hướng vuốt ngang tự nhiên
- Tự động lưu vị trí đọc
- Hiển thị tiến trình đọc (trang hiện tại / tổng số trang)

### 3. Tùy Chỉnh Giao Diện
- **Chế độ sáng/tối**: Chuyển đổi dễ dàng giữa light mode và dark mode
- **Kích thước chữ**: 3 tùy chọn (Nhỏ 14pt, Trung bình 18pt, Lớn 22pt)
- Xem trước thay đổi real-time
- Smooth transitions (300ms)

### 4. Lưu Trữ Bền Vững
- SQLite database cho settings và reading states
- Tự động lưu sau 2 giây khi thay đổi
- Khôi phục vị trí đọc khi mở lại sách
- Cache danh sách sách để sử dụng offline

### 5. State Management
- Provider pattern cho quản lý trạng thái
- Reactive UI updates
- Efficient re-rendering

## Kiến Trúc

Ứng dụng sử dụng kiến trúc MVVM (Model-View-ViewModel) với Repository pattern:

```
lib/
├── models/              # Data models
├── providers/           # State management (Provider)
├── repositories/        # Data access layer
├── services/           # Business logic (API, Database, Assets)
├── screens/            # UI screens
└── widgets/            # Reusable widgets
```

## Công Nghệ Sử Dụng

- **Flutter**: Framework UI
- **Provider**: State management
- **SQLite**: Local database
- **HTTP**: API calls
- **Material Design 3**: Design system

## Cài Đặt

### Yêu Cầu
- Flutter SDK >= 3.9.2
- Dart SDK >= 3.9.2

### Các Bước

1. Clone repository:
```bash
git clone <repository-url>
cd ebook_upgrade
```

2. Cài đặt dependencies:
```bash
flutter pub get
```

3. Chạy ứng dụng:
```bash
flutter run
```

4. Build APK:
```bash
flutter build apk --release
```

## Testing

### Unit Tests
```bash
flutter test test/models/
```

### Widget Tests
```bash
flutter test test/widgets/
```

### Integration Tests
```bash
flutter test integration_test/
```

### Tất Cả Tests
```bash
flutter test
```

## Sử Dụng

### Màn Hình Chính
1. Xem danh sách sách có sẵn
2. Kéo xuống để refresh danh sách
3. Nhấn vào sách để mở

### Màn Hình Đọc Sách
1. Vuốt ngang để chuyển trang
2. Nhấn vào màn hình để hiện/ẩn control panel
3. Nhấn nút settings để thay đổi theme và font size
4. Vị trí đọc được tự động lưu

### Cài Đặt
- **Toggle Theme**: Nhấn icon brightness ở home screen hoặc trong settings panel
- **Font Size**: Chọn từ 3 tùy chọn trong settings panel
- Tất cả thay đổi được lưu tự động

## Sách Mẫu

Ứng dụng đi kèm với 3 cuốn sách mẫu:
1. **Truyện Kiều** - Nguyễn Du
2. **Số Đỏ** - Vũ Trọng Phụng
3. **Chí Phèo** - Nam Cao

## Thêm Sách Mới

1. Thêm file text vào `assets/books/`
2. Cập nhật `lib/services/api_service.dart` trong method `_getMockBooks()`
3. Chạy `flutter pub get`

## Cấu Trúc Database

### reading_states
- book_id (TEXT, PRIMARY KEY)
- current_page (INTEGER)
- total_pages (INTEGER)
- last_read_at (TEXT)

### user_settings
- id (INTEGER, PRIMARY KEY)
- is_dark_mode (INTEGER)
- font_size (REAL)

### cached_books
- id (TEXT, PRIMARY KEY)
- title (TEXT)
- author (TEXT)
- description (TEXT)
- cover_image_url (TEXT)
- asset_path (TEXT)
- cached_at (TEXT)

## Performance

- Lazy loading cho book content
- Pagination caching trong memory
- Debounced save operations (2 seconds)
- Efficient widget rebuilding với Provider

## Accessibility

- Semantic labels cho screen readers
- Minimum touch target size: 48x48 dp
- High contrast ratios
- Readable font sizes

## License

MIT License

## Tác Giả

Dự án được phát triển như một ứng dụng demo cho môn học Mobile Development.
