# Tài liệu Yêu cầu - Hệ thống Đánh giá Nhà hàng

## Giới thiệu

Hệ thống Đánh giá Nhà hàng là một ứng dụng di động được xây dựng bằng Flutter và Firebase, cho phép người dùng khám phá các nhà hàng, đọc và viết đánh giá kèm theo hình ảnh. Ứng dụng tích hợp các dịch vụ Firebase để cung cấp trải nghiệm thời gian thực, xác thực người dùng, lưu trữ dữ liệu và thông báo đẩy.

## Thuật ngữ

- **Restaurant_Review_System**: Ứng dụng di động chính được xây dựng bằng Flutter
- **Firebase_Authentication**: Dịch vụ xác thực người dùng của Firebase
- **Cloud_Firestore**: Cơ sở dữ liệu NoSQL thời gian thực của Firebase
- **Firebase_Storage**: Dịch vụ lưu trữ file của Firebase
- **FCM**: Firebase Cloud Messaging - dịch vụ thông báo đẩy
- **Cloud_Functions**: Dịch vụ serverless của Firebase để xử lý logic backend
- **User_Profile**: Hồ sơ cá nhân của người dùng trong hệ thống
- **Restaurant_Entity**: Thực thể nhà hàng trong cơ sở dữ liệu
- **Review_Entity**: Thực thể đánh giá của người dùng
- **Rating_Score**: Điểm số đánh giá từ 1-5 sao
- **Average_Rating**: Điểm số trung bình của nhà hàng
- **Image_Upload**: Quá trình tải ảnh lên từ thiết bị
- **Real_Time_Data**: Dữ liệu được cập nhật và đồng bộ theo thời gian thực

## Yêu cầu

### Yêu cầu 1

**User Story:** Là một người dùng mới, tôi muốn đăng ký tài khoản và đăng nhập vào ứng dụng để có thể sử dụng các tính năng đánh giá nhà hàng.

#### Tiêu chí chấp nhận

1. THE Restaurant_Review_System SHALL cung cấp giao diện đăng ký với các trường email và mật khẩu
2. WHEN người dùng nhập thông tin đăng ký hợp lệ, THE Restaurant_Review_System SHALL tạo tài khoản mới thông qua Firebase_Authentication
3. THE Restaurant_Review_System SHALL cung cấp giao diện đăng nhập với email và mật khẩu
4. WHEN người dùng đăng nhập thành công, THE Restaurant_Review_System SHALL tạo User_Profile trong Cloud_Firestore
5. THE Restaurant_Review_System SHALL lưu trữ trạng thái đăng nhập để người dùng không cần đăng nhập lại

### Yêu cầu 2

**User Story:** Là một người dùng đã đăng nhập, tôi muốn xem danh sách các nhà hàng với thông tin cơ bản và điểm đánh giá để có thể lựa chọn nhà hàng phù hợp.

#### Tiêu chí chấp nhận

1. THE Restaurant_Review_System SHALL hiển thị danh sách tất cả Restaurant_Entity từ Cloud_Firestore
2. THE Restaurant_Review_System SHALL hiển thị tên, địa chỉ và Average_Rating của mỗi nhà hàng
3. THE Restaurant_Review_System SHALL sử dụng StreamBuilder để cập nhật Real_Time_Data
4. WHEN có Restaurant_Entity mới được thêm vào Cloud_Firestore, THE Restaurant_Review_System SHALL tự động hiển thị trong danh sách
5. THE Restaurant_Review_System SHALL cho phép người dùng nhấn vào nhà hàng để xem chi tiết

### Yêu cầu 3

**User Story:** Là một người dùng, tôi muốn xem chi tiết thông tin nhà hàng và các đánh giá của người khác để có thể đưa ra quyết định.

#### Tiêu chí chấp nhận

1. WHEN người dùng chọn một Restaurant_Entity, THE Restaurant_Review_System SHALL hiển thị thông tin chi tiết nhà hàng
2. THE Restaurant_Review_System SHALL hiển thị danh sách tất cả Review_Entity liên quan đến nhà hàng
3. THE Restaurant_Review_System SHALL hiển thị Rating_Score, nội dung text và hình ảnh của mỗi đánh giá
4. THE Restaurant_Review_System SHALL sử dụng StreamBuilder để cập nhật đánh giá theo Real_Time_Data
5. THE Restaurant_Review_System SHALL hiển thị Average_Rating được tính toán tự động

### Yêu cầu 4

**User Story:** Là một người dùng, tôi muốn viết đánh giá cho nhà hàng kèm theo hình ảnh để chia sẻ trải nghiệm của mình.

#### Tiêu chí chấp nhận

1. THE Restaurant_Review_System SHALL cung cấp giao diện tạo đánh giá mới với các trường Rating_Score, nội dung text và tùy chọn thêm ảnh
2. WHEN người dùng chọn thêm ảnh, THE Restaurant_Review_System SHALL sử dụng image_picker để chọn ảnh từ thiết bị
3. WHEN người dùng chọn ảnh, THE Restaurant_Review_System SHALL thực hiện Image_Upload lên Firebase_Storage
4. WHEN người dùng gửi đánh giá, THE Restaurant_Review_System SHALL lưu Review_Entity vào Cloud_Firestore
5. THE Restaurant_Review_System SHALL liên kết Review_Entity với User_Profile và Restaurant_Entity tương ứng

### Yêu cầu 5

**User Story:** Là chủ sở hữu hệ thống, tôi muốn điểm đánh giá trung bình của nhà hàng được tính toán tự động để đảm bảo tính chính xác và bảo mật.

#### Tiêu chí chấp nhận

1. WHEN có Review_Entity mới được thêm vào Cloud_Firestore, THE Cloud_Functions SHALL tự động kích hoạt
2. THE Cloud_Functions SHALL tính toán lại Average_Rating cho Restaurant_Entity tương ứng
3. THE Cloud_Functions SHALL cập nhật Average_Rating vào Cloud_Firestore
4. THE Restaurant_Review_System SHALL hiển thị Average_Rating được cập nhật theo Real_Time_Data
5. THE Cloud_Functions SHALL đảm bảo logic tính toán chỉ chạy ở phía server

### Yêu cầu 6

**User Story:** Là một người dùng quan tâm đến nhà hàng, tôi muốn nhận thông báo khi có đánh giá mới để cập nhật thông tin kịp thời.

#### Tiêu chí chấp nhận

1. THE Restaurant_Review_System SHALL đăng ký FCM token cho mỗi thiết bị người dùng
2. WHEN có Review_Entity mới được thêm, THE Cloud_Functions SHALL gửi thông báo qua FCM
3. THE Restaurant_Review_System SHALL hiển thị thông báo đẩy khi ứng dụng đang chạy
4. THE Restaurant_Review_System SHALL xử lý thông báo khi ứng dụng đang ở background
5. WHEN người dùng nhấn vào thông báo, THE Restaurant_Review_System SHALL điều hướng đến chi tiết nhà hàng tương ứng

### Yêu cầu 7

**User Story:** Là một nhà phát triển, tôi muốn ứng dụng được xây dựng theo Clean Architecture để dễ bảo trì và mở rộng.

#### Tiêu chí chấp nhận

1. THE Restaurant_Review_System SHALL tách biệt logic UI và logic xử lý dữ liệu
2. THE Restaurant_Review_System SHALL sử dụng Repository pattern để truy cập Cloud_Firestore và Firebase_Storage
3. THE Restaurant_Review_System SHALL sử dụng Use Cases để xử lý business logic
4. THE Restaurant_Review_System SHALL sử dụng Dependency Injection để quản lý dependencies
5. THE Restaurant_Review_System SHALL có cấu trúc thư mục rõ ràng theo các layer của Clean Architecture