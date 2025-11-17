# Tài liệu Yêu cầu

## Giới thiệu

Ứng dụng Quản lý Chi tiêu Cá nhân là một hệ thống quản lý tài chính toàn diện cho phép người dùng ghi lại, theo dõi và phân tích các khoản chi tiêu hàng ngày. Ứng dụng cung cấp xác thực người dùng an toàn, đồng bộ dữ liệu thời gian thực và khả năng trực quan hóa dữ liệu nâng cao để giúp người dùng hiểu được mô hình chi tiêu và đưa ra quyết định tài chính sáng suốt.

## Thuật ngữ

- **He_Thong_Quan_Ly_Chi_Tieu**: Ứng dụng Flutter hoàn chỉnh để theo dõi chi tiêu cá nhân
- **Firebase_Auth**: Dịch vụ xác thực Firebase để quản lý người dùng
- **Cloud_Firestore**: Cơ sở dữ liệu NoSQL của Firebase để lưu trữ giao dịch người dùng
- **Giao_Dich**: Bản ghi tài chính chứa số tiền, mô tả, danh mục và ngày tháng
- **Bo_Suu_Tap_Nguoi_Dung**: Bộ sưu tập Firestore riêng lẻ chứa dữ liệu giao dịch của người dùng
- **StreamBuilder**: Widget Flutter để cập nhật dữ liệu thời gian thực từ Firestore
- **CustomPainter**: Lớp Flutter để tạo biểu đồ và đồ thị tùy chỉnh
- **SliverWidgets**: Widget Flutter cho hiệu ứng cuộn nâng cao và tối ưu hiệu suất
- **Form_Giao_Dich**: Giao diện người dùng để nhập dữ liệu chi tiêu mới
- **Bang_Dieu_Khien_Phan_Tich**: Biểu diễn trực quan của mô hình chi tiêu bằng biểu đồ

## Yêu cầu

### Yêu cầu 1

**Câu chuyện người dùng:** Là một người dùng, tôi muốn đăng ký và xác thực an toàn với ứng dụng, để dữ liệu tài chính của tôi được bảo mật và chỉ tôi mới có thể truy cập.

#### Tiêu chí chấp nhận

1. WHEN người dùng mới truy cập ứng dụng, THE He_Thong_Quan_Ly_Chi_Tieu SHALL cung cấp chức năng đăng ký sử dụng Firebase_Auth
2. WHEN người dùng hiện tại cố gắng đăng nhập, THE He_Thong_Quan_Ly_Chi_Tieu SHALL xác thực thông tin đăng nhập thông qua Firebase_Auth
3. WHEN xác thực thất bại, THE He_Thong_Quan_Ly_Chi_Tieu SHALL hiển thị thông báo lỗi phù hợp cho người dùng
4. WHEN người dùng xác thực thành công, THE He_Thong_Quan_Ly_Chi_Tieu SHALL tạo hoặc truy cập Bo_Suu_Tap_Nguoi_Dung riêng của họ trong Cloud_Firestore
5. THE He_Thong_Quan_Ly_Chi_Tieu SHALL duy trì trạng thái phiên người dùng trong suốt vòng đời ứng dụng

### Yêu cầu 2

**Câu chuyện người dùng:** Là một người dùng đã xác thực, tôi muốn ghi lại các khoản chi tiêu hàng ngày với thông tin chi tiết, để tôi có thể duy trì hồ sơ tài chính chính xác.

#### Tiêu chí chấp nhận

1. WHEN người dùng truy cập tính năng nhập giao dịch, THE He_Thong_Quan_Ly_Chi_Tieu SHALL hiển thị Form_Giao_Dich với xác thực đầu vào
2. THE Form_Giao_Dich SHALL yêu cầu các trường số tiền, mô tả, danh mục và ngày tháng cho mỗi Giao_Dich
3. WHEN người dùng gửi dữ liệu giao dịch hợp lệ, THE He_Thong_Quan_Ly_Chi_Tieu SHALL lưu trữ Giao_Dich trong Bo_Suu_Tap_Nguoi_Dung Cloud_Firestore của người dùng
4. WHEN dữ liệu giao dịch không hợp lệ, THE He_Thong_Quan_Ly_Chi_Tieu SHALL hiển thị lỗi xác thực và ngăn chặn việc gửi
5. THE He_Thong_Quan_Ly_Chi_Tieu SHALL cung cấp các danh mục chi tiêu được định nghĩa trước để người dùng lựa chọn

### Yêu cầu 3

**Câu chuyện người dùng:** Là một người dùng, tôi muốn xem lịch sử giao dịch của mình theo thời gian thực, để tôi có thể thấy các khoản chi tiêu cập nhật ngay lập tức khi tôi thêm chúng.

#### Tiêu chí chấp nhận

1. THE He_Thong_Quan_Ly_Chi_Tieu SHALL sử dụng StreamBuilder để hiển thị cập nhật giao dịch thời gian thực từ Cloud_Firestore
2. WHEN giao dịch mới được thêm, THE He_Thong_Quan_Ly_Chi_Tieu SHALL tự động cập nhật danh sách giao dịch mà không cần làm mới thủ công
3. THE He_Thong_Quan_Ly_Chi_Tieu SHALL hiển thị giao dịch theo thứ tự thời gian với giao dịch gần nhất đầu tiên
4. WHEN kết nối internet của người dùng được khôi phục, THE He_Thong_Quan_Ly_Chi_Tieu SHALL đồng bộ hóa bất kỳ thay đổi ngoại tuyến nào với Cloud_Firestore
5. THE He_Thong_Quan_Ly_Chi_Tieu SHALL xử lý trạng thái tải và lỗi mạng một cách nhẹ nhàng

### Yêu cầu 4

**Câu chuyện người dùng:** Là một người dùng, tôi muốn trực quan hóa mô hình chi tiêu của mình thông qua biểu đồ và đồ thị, để tôi có thể hiểu rõ hơn về thói quen tài chính của mình.

#### Tiêu chí chấp nhận

1. THE He_Thong_Quan_Ly_Chi_Tieu SHALL cung cấp Bang_Dieu_Khien_Phan_Tich với phân tích chi tiêu trực quan
2. THE He_Thong_Quan_Ly_Chi_Tieu SHALL sử dụng CustomPainter để tạo biểu đồ đường hiển thị xu hướng chi tiêu theo thời gian
3. THE He_Thong_Quan_Ly_Chi_Tieu SHALL sử dụng CustomPainter để tạo biểu đồ tròn hiển thị phân bố chi tiêu theo danh mục
4. WHEN dữ liệu giao dịch thay đổi, THE He_Thong_Quan_Ly_Chi_Tieu SHALL cập nhật biểu đồ tự động để phản ánh dữ liệu hiện tại
5. THE Bang_Dieu_Khien_Phan_Tich SHALL cho phép người dùng lọc dữ liệu theo khoảng thời gian và danh mục

### Yêu cầu 5

**Câu chuyện người dùng:** Là một người dùng có lượng lớn dữ liệu giao dịch, tôi muốn ứng dụng hoạt động mượt mà khi cuộn qua lịch sử chi tiêu của mình, để tôi có thể điều hướng hiệu quả qua các bản ghi tài chính.

#### Tiêu chí chấp nhận

1. THE He_Thong_Quan_Ly_Chi_Tieu SHALL triển khai SliverWidgets trong CustomScrollView để tối ưu hiệu suất cuộn
2. WHEN hiển thị danh sách giao dịch lớn, THE He_Thong_Quan_Ly_Chi_Tieu SHALL sử dụng lazy loading để duy trì hiệu suất mượt mà
3. THE He_Thong_Quan_Ly_Chi_Tieu SHALL triển khai phân trang dữ liệu hiệu quả khi truy xuất giao dịch từ Cloud_Firestore
4. WHEN người dùng cuộn qua lịch sử giao dịch, THE He_Thong_Quan_Ly_Chi_Tieu SHALL duy trì hiệu suất giao diện người dùng phản hồi nhanh
5. THE He_Thong_Quan_Ly_Chi_Tieu SHALL tối ưu hóa việc sử dụng bộ nhớ khi hiển thị tập dữ liệu lớn

### Yêu cầu 6

**Câu chuyện người dùng:** Là một người dùng, tôi muốn dữ liệu của mình được cách ly an toàn khỏi người dùng khác, để thông tin tài chính của tôi được bảo mật.

#### Tiêu chí chấp nhận

1. THE He_Thong_Quan_Ly_Chi_Tieu SHALL tạo các phiên bản Bo_Suu_Tap_Nguoi_Dung riêng biệt trong Cloud_Firestore cho mỗi người dùng đã xác thực
2. THE He_Thong_Quan_Ly_Chi_Tieu SHALL triển khai quy tắc bảo mật Firestore để ngăn chặn truy cập dữ liệu chéo giữa người dùng
3. WHEN người dùng đăng xuất, THE He_Thong_Quan_Ly_Chi_Tieu SHALL xóa tất cả dữ liệu tài chính được lưu trong bộ nhớ đệm khỏi thiết bị
4. THE He_Thong_Quan_Ly_Chi_Tieu SHALL đảm bảo rằng giao dịch người dùng chỉ có thể truy cập thông qua xác thực phù hợp
5. THE He_Thong_Quan_Ly_Chi_Tieu SHALL mã hóa dữ liệu nhạy cảm trong quá trình truyền tải đến Cloud_Firestore