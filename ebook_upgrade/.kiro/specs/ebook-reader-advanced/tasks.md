# Kế Hoạch Triển Khai

- [x] 1. Thiết lập cấu trúc dự án và dependencies


  - Thêm các dependencies cần thiết vào pubspec.yaml: provider, sqflite, path_provider, http
  - Tạo cấu trúc thư mục theo kiến trúc đã thiết kế (models, providers, repositories, services, screens, widgets)
  - Cấu hình assets trong pubspec.yaml cho book files
  - _Yêu cầu: 1.1, 2.1, 3.1, 4.1, 5.1, 6.1_




- [ ] 2. Triển khai Data Models
  - [ ] 2.1 Tạo Book model với serialization
    - Viết class Book với các thuộc tính: id, title, author, description, coverImageUrl, assetPath


    - Implement fromJson() và toJson() methods
    - _Yêu cầu: 4.2_
  


  - [ ] 2.2 Tạo ReadingState model
    - Viết class ReadingState với bookId, currentPage, totalPages, lastReadAt

    - Implement fromMap() và toMap() methods cho SQLite


    - _Yêu cầu: 3.1, 3.3_
  
  - [ ] 2.3 Tạo UserSettings model
    - Viết class UserSettings với isDarkMode và fontSize


    - Implement fromMap() và toMap() methods
    - _Yêu cầu: 2.1, 2.2, 3.2_



- [ ] 3. Triển khai Database Service
  - [ ] 3.1 Tạo DatabaseService class
    - Implement singleton pattern cho database instance


    - Viết phương thức initDatabase() để tạo các bảng: reading_states, user_settings, cached_books

    - Implement database version management và migration logic


    - _Yêu cầu: 3.1, 3.5_
  
  - [ ] 3.2 Implement CRUD operations cho reading states
    - Viết methods: saveReadingState(), getReadingState(), deleteReadingState()
    - Thêm error handling cho database operations


    - _Yêu cầu: 3.1, 3.3_
  

  - [x] 3.3 Implement CRUD operations cho user settings


    - Viết methods: saveSettings(), getSettings()
    - Set default values nếu settings chưa tồn tại
    - _Yêu cầu: 3.2, 3.4_


  
  - [ ] 3.4 Implement CRUD operations cho cached books
    - Viết methods: cacheBooks(), getCachedBooks(), clearCache()
    - _Yêu cầu: 4.4_



- [x] 4. Triển khai API Service

  - [x] 4.1 Tạo ApiService class


    - Setup HTTP client với base URL và timeout configuration
    - Implement fetchBooks() method để gọi GET /books endpoint
    - Thêm error handling cho network errors (timeout, server errors)
    - Implement retry logic với exponential backoff (3 attempts)


    - _Yêu cầu: 4.1, 4.3_
  
  - [ ] 4.2 Tạo mock API hoặc sử dụng public API
    - Tìm hoặc tạo mock API endpoint trả về danh sách sách với format JSON


    - Đảm bảo response format khớp với Book model
    - _Yêu cầu: 4.1, 4.2_

- [ ] 5. Triển khai Asset Reader Service
  - [ ] 5.1 Tạo AssetReaderService class
    - Implement loadBookContent(String assetPath) để đọc file từ assets


    - Thêm error handling cho missing hoặc corrupted files
    - _Yêu cầu: 5.1, 5.2, 5.4_
  
  - [-] 5.2 Implement pagination logic

    - Viết method paginateContent() để chia nội dung thành pages
    - Tính toán số ký tự mỗi trang dựa trên screen size và font size
    - Cache paginated content trong memory
    - _Yêu cầu: 5.5_
  
  - [ ] 5.3 Thêm sample book files vào assets
    - Tạo thư mục assets/books/
    - Thêm ít nhất 2-3 file text mẫu với nội dung sách
    - _Yêu cầu: 5.1, 5.3_

- [ ] 6. Triển khai Repositories
  - [ ] 6.1 Tạo BookRepository
    - Implement fetchBooks() với logic: try API first, fallback to cache
    - Implement getBookContent() để lấy nội dung từ AssetReaderService
    - Implement cacheBooks() để lưu books vào database
    - _Yêu cầu: 4.1, 4.3, 4.4, 5.1_
  
  - [ ] 6.2 Tạo SettingsRepository
    - Implement getSettings() và saveSettings() sử dụng DatabaseService
    - Implement getReadingState() và saveReadingState()
    - Thêm debouncing cho save operations (2 seconds)
    - _Yêu cầu: 3.1, 3.2, 3.3, 3.4_

- [ ] 7. Triển khai State Management với Providers
  - [ ] 7.1 Tạo SettingsProvider
    - Extend ChangeNotifier với state: UserSettings, isLoading
    - Implement loadSettings() để load từ repository khi app khởi động
    - Implement toggleTheme() với notifyListeners()
    - Implement setFontSize() với notifyListeners()
    - Implement saveSettings() với auto-save sau 2 giây
    - _Yêu cầu: 2.1, 2.2, 2.3, 2.4, 3.2, 3.4, 6.2, 6.3_
  
  - [ ] 7.2 Tạo BookProvider
    - Extend ChangeNotifier với state: List<Book>, isLoading, errorMessage
    - Implement loadBooks() để fetch từ BookRepository
    - Implement retryLoadBooks() cho error recovery
    - _Yêu cầu: 4.1, 4.2, 4.3, 4.5_
  
  - [x] 7.3 Tạo ReadingStateProvider

    - Extend ChangeNotifier với state: ReadingState, currentBookContent, pages
    - Implement loadBook(String bookId) để load content và reading state
    - Implement goToPage(int pageNumber) với boundary checks
    - Implement saveCurrentPage() với auto-save khi page thay đổi
    - _Yêu cầu: 1.3, 1.4, 1.5, 3.1, 3.3, 5.3, 6.4_

- [ ] 8. Triển khai UI Widgets
  - [x] 8.1 Tạo BookCard widget


    - Hiển thị book cover (placeholder nếu không có image), title, author
    - Thêm onTap callback để navigate đến BookReaderScreen
    - Style với Material Design 3
    - _Yêu cầu: 4.2, 4.5_
  
  - [x] 8.2 Tạo PageViewer widget


    - Sử dụng PageView.builder cho horizontal swipe navigation
    - Implement page flip animation với PageTransformer
    - Hiển thị page content với current font size và theme
    - Thêm boundary checks để prevent over-scrolling
    - _Yêu cầu: 1.1, 1.2, 1.4, 1.5_
  
  - [x] 8.3 Tạo ControlPanel widget


    - Tạo AnimatedContainer với slide-in/slide-out animation
    - Hiển thị page progress (current/total)
    - Thêm buttons cho settings và navigation
    - Toggle visibility khi tap vào màn hình
    - _Yêu cầu: 2.5_
  
  - [x] 8.4 Tạo AnimatedSettingsPanel widget


    - Tạo panel với theme toggle switch
    - Thêm font size selector (3 options: small, medium, large)
    - Animate transitions khi settings thay đổi (300ms duration)
    - _Yêu cầu: 2.1, 2.2, 2.3, 2.4_

- [ ] 9. Triển khai Screens
  - [x] 9.1 Tạo HomeScreen


    - Setup AppBar với title và settings button
    - Implement GridView/ListView với BookCard widgets
    - Thêm Consumer<BookProvider> để listen state changes
    - Implement pull-to-refresh functionality
    - Hiển thị loading indicator khi isLoading = true
    - Hiển thị error message với retry button khi có lỗi
    - _Yêu cầu: 4.1, 4.2, 4.3, 4.5_
  
  - [x] 9.2 Tạo BookReaderScreen


    - Setup với PageViewer widget
    - Integrate ControlPanel với tap-to-toggle
    - Thêm Consumer<ReadingStateProvider> và Consumer<SettingsProvider>
    - Implement auto-save reading state khi page thay đổi
    - Apply theme và font size từ settings
    - Thêm back button để return về HomeScreen
    - _Yêu cầu: 1.1, 1.2, 1.3, 2.3, 2.4, 2.5, 3.1, 3.3, 5.3_
  
  - [ ] 9.3 Tạo SettingsScreen (optional)




    - Hiển thị all settings trong một màn hình dedicated
    - Integrate AnimatedSettingsPanel
    - Thêm preview text để xem changes real-time
    - _Yêu cầu: 2.1, 2.2, 2.3, 2.4_

- [ ] 10. Cấu hình App Entry Point và Theme
  - [x] 10.1 Setup main.dart với MultiProvider


    - Wrap MaterialApp với MultiProvider
    - Register tất cả providers: SettingsProvider, BookProvider, ReadingStateProvider
    - Initialize providers khi app khởi động
    - _Yêu cầu: 3.4, 6.1_
  
  - [x] 10.2 Implement dynamic theming

    - Tạo ThemeData cho light và dark modes
    - Bind theme với SettingsProvider.isDarkMode
    - Ensure smooth theme transitions (300ms)
    - _Yêu cầu: 2.3, 6.2_
  
  - [x] 10.3 Setup initial route

    - Set HomeScreen làm initial route
    - Configure named routes cho navigation
    - _Yêu cầu: 4.5, 6.5_

- [ ] 11. Implement Error Handling và User Feedback
  - [x] 11.1 Thêm error handling UI

    - Tạo reusable error dialog/snackbar widgets
    - Implement retry mechanisms cho failed operations
    - Hiển thị user-friendly error messages
    - _Yêu cầu: 4.3, 5.4_
  
  - [x] 11.2 Thêm loading states

    - Implement loading indicators cho async operations
    - Ensure UI remains responsive during loading
    - _Yêu cầu: 4.1, 5.3_

- [ ] 12. Testing và Polish

  - [x] 12.1 Viết unit tests


    - Test models serialization/deserialization
    - Test repository logic
    - Test provider state management
    - _Yêu cầu: Tất cả_
  
  - [x] 12.2 Viết widget tests


    - Test individual widgets rendering
    - Test user interactions
    - Test animations
    - _Yêu cầu: 1.2, 2.3, 2.4, 2.5_
  
  - [x] 12.3 Viết integration tests


    - Test complete user flows
    - Test offline mode với cached data
    - Test settings persistence
    - _Yêu cầu: 3.3, 3.4, 4.4, 6.5_
  
  - [x] 12.4 UI/UX polish


    - Ensure consistent spacing và alignment
    - Verify color contrast ratios cho accessibility
    - Test trên different screen sizes
    - Optimize animations cho smooth 60fps
    - _Yêu cầu: Tất cả_
