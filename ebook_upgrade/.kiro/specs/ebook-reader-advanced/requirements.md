# Tài Liệu Yêu Cầu

## Giới Thiệu

Tài liệu này mô tả các yêu cầu cho ứng dụng đọc sách điện tử nâng cao được xây dựng bằng Flutter. Ứng dụng sẽ cung cấp trải nghiệm đọc chuyên nghiệp với các tính năng UI/UX tùy chỉnh, lưu trữ cài đặt người dùng bền vững, quản lý trạng thái, và tích hợp API để quản lý danh mục sách. Hệ thống hướng đến việc mang lại trải nghiệm đọc mượt mà với các tính năng như hiệu ứng lật trang, chế độ tối, tùy chỉnh font chữ, và tự động lưu dấu trang.

## Thuật Ngữ

- **EbookApp**: Hệ thống ứng dụng đọc sách điện tử được xây dựng trên Flutter
- **BookViewer**: Thành phần chịu trách nhiệm hiển thị nội dung sách với điều hướng trang
- **SettingsManager**: Thành phần quản lý tùy chọn người dùng và cấu hình đọc sách
- **BookCatalog**: Bộ sưu tập các cuốn sách có sẵn được lấy từ API
- **ReadingState**: Vị trí hiện tại và cài đặt cho một cuốn sách đang được đọc
- **LocalStorage**: Cơ sở dữ liệu SQLite được sử dụng để lưu trữ dữ liệu và cài đặt người dùng
- **BookAPI**: Dịch vụ API bên ngoài cung cấp danh sách sách và metadata
- **AssetReader**: Thành phần đọc nội dung sách từ thư mục assets của ứng dụng
- **ThemeMode**: Cài đặt giao diện hiển thị (chế độ sáng hoặc tối)
- **FontSize**: Cài đặt kích thước chữ cho hiển thị nội dung sách

## Yêu Cầu

### Yêu Cầu 1

**User Story:** Là một độc giả, tôi muốn điều hướng qua các trang sách với hiệu ứng mượt mà, để có trải nghiệm đọc sách đắm chìm tương tự như sách giấy.

#### Tiêu Chí Chấp Nhận

1. BookViewer PHẢI hiển thị nội dung sách sử dụng bố cục dựa trên trang với điều hướng vuốt ngang
2. KHI người dùng vuốt ngang, BookViewer PHẢI tạo hiệu ứng chuyển trang với hiệu ứng lật
3. BookViewer PHẢI duy trì vị trí trang hiện tại trong suốt phiên đọc
4. KHI người dùng đến trang đầu tiên và cố gắng vuốt sang phải, BookViewer PHẢI ngăn chặn điều hướng vượt ra ngoài ranh giới sách
5. KHI người dùng đến trang cuối cùng và cố gắng vuốt sang trái, BookViewer PHẢI ngăn chặn điều hướng vượt ra ngoài ranh giới sách

### Yêu Cầu 2

**User Story:** Là một độc giả, tôi muốn tùy chỉnh trải nghiệm đọc của mình với cài đặt chủ đề và font chữ, để tôi có thể đọc thoải mái trong các điều kiện ánh sáng khác nhau và theo sở thích thị giác của mình.

#### Tiêu Chí Chấp Nhận

1. SettingsManager PHẢI cung cấp tùy chọn cho chủ đề chế độ sáng và chế độ tối
2. SettingsManager PHẢI cung cấp điều chỉnh kích thước font với ít nhất ba tùy chọn kích thước (nhỏ, trung bình, lớn)
3. KHI người dùng thay đổi chế độ chủ đề, EbookApp PHẢI áp dụng chủ đề mới cho tất cả giao diện đọc trong vòng 500 mili giây
4. KHI người dùng điều chỉnh kích thước font, BookViewer PHẢI hiển thị lại trang hiện tại với kích thước font mới trong vòng 500 mili giây
5. EbookApp PHẢI hiển thị bảng điều khiển với hiệu ứng chuyển động để truy cập cài đặt chủ đề và font

### Yêu Cầu 3

**User Story:** Là một độc giả, tôi muốn tiến trình đọc và tùy chọn của mình được tự động lưu, để tôi có thể tiếp tục đọc từ nơi đã dừng lại mà không cần đánh dấu thủ công.

#### Tiêu Chí Chấp Nhận

1. KHI người dùng điều hướng đến trang khác, EbookApp PHẢI lưu số trang hiện tại vào LocalStorage trong vòng 2 giây
2. KHI người dùng thay đổi cài đặt chủ đề hoặc font, SettingsManager PHẢI lưu trữ các tùy chọn này vào LocalStorage trong vòng 2 giây
3. KHI người dùng mở một cuốn sách đã đọc trước đó, EbookApp PHẢI khôi phục trang đã đọc cuối cùng từ LocalStorage
4. KHI người dùng khởi chạy ứng dụng, EbookApp PHẢI tải tất cả tùy chọn người dùng đã lưu từ LocalStorage
5. LocalStorage PHẢI lưu trữ trạng thái đọc riêng biệt cho mỗi cuốn sách trong danh mục

### Yêu Cầu 4

**User Story:** Là một độc giả, tôi muốn duyệt danh mục các cuốn sách có sẵn từ nguồn trực tuyến, để tôi có thể khám phá và chọn sách để đọc.

#### Tiêu Chí Chấp Nhận

1. KHI ứng dụng khởi chạy, EbookApp PHẢI lấy danh mục sách từ BookAPI
2. EbookApp PHẢI hiển thị thông tin sách bao gồm tiêu đề, tác giả, và mô tả từ phản hồi API
3. NẾU yêu cầu API thất bại, THÌ EbookApp PHẢI hiển thị thông báo lỗi thân thiện với người dùng và cung cấp tùy chọn thử lại
4. EbookApp PHẢI lưu cache danh mục sách cục bộ để cho phép duyệt offline các sách đã tải trước đó
5. KHI người dùng chọn một cuốn sách từ danh mục, EbookApp PHẢI điều hướng đến BookViewer với cuốn sách đã chọn

### Yêu Cầu 5

**User Story:** Là một độc giả, tôi muốn ứng dụng tải nội dung sách từ bộ nhớ cục bộ, để tôi có thể đọc sách mà không cần kết nối internet.

#### Tiêu Chí Chấp Nhận

1. AssetReader PHẢI đọc các file nội dung sách từ thư mục assets của ứng dụng
2. AssetReader PHẢI hỗ trợ các định dạng sách dựa trên văn bản để hiển thị nội dung
3. KHI người dùng mở một cuốn sách, AssetReader PHẢI tải toàn bộ nội dung sách trong vòng 3 giây
4. NẾU file sách bị thiếu hoặc hỏng, THÌ EbookApp PHẢI hiển thị thông báo lỗi cho biết sách không khả dụng
5. BookViewer PHẢI phân tích và phân trang nội dung sách đã tải để hiển thị

### Yêu Cầu 6

**User Story:** Là một độc giả, tôi muốn ứng dụng quản lý trạng thái của nó một cách hiệu quả trên các màn hình khác nhau, để tôi trải nghiệm hành vi nhất quán và chuyển đổi mượt mà trong toàn bộ ứng dụng.

#### Tiêu Chí Chấp Nhận

1. EbookApp PHẢI triển khai giải pháp quản lý trạng thái (Provider hoặc BLoC) để quản lý cài đặt đọc
2. SettingsManager PHẢI thông báo cho tất cả các thành phần phụ thuộc khi chế độ chủ đề thay đổi
3. SettingsManager PHẢI thông báo cho tất cả các thành phần phụ thuộc khi kích thước font thay đổi
4. ReadingState PHẢI có thể truy cập từ bất kỳ màn hình nào trong ứng dụng
5. KHI người dùng điều hướng giữa các màn hình, EbookApp PHẢI bảo toàn trạng thái đọc hiện tại mà không mất dữ liệu
