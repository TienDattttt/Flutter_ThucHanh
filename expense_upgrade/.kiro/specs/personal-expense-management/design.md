# Tài liệu Thiết kế

## Tổng quan

Ứng dụng Quản lý Chi tiêu Cá nhân được thiết kế theo kiến trúc Clean Architecture với các lớp rõ ràng để đảm bảo khả năng bảo trì, kiểm thử và mở rộng. Ứng dụng sử dụng Flutter framework với Firebase backend để cung cấp trải nghiệm người dùng mượt mà và đồng bộ dữ liệu thời gian thực.

## Kiến trúc

### Kiến trúc tổng thể
```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐ │
│  │   Screens   │ │   Widgets   │ │      Providers      │ │
│  └─────────────┘ └─────────────┘ └─────────────────────┘ │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│                     Domain Layer                        │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐ │
│  │   Models    │ │  Use Cases  │ │    Repositories     │ │
│  └─────────────┘ └─────────────┘ └─────────────────────┘ │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│                      Data Layer                         │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐ │
│  │ Data Sources│ │   Services  │ │      Firebase       │ │
│  └─────────────┘ └─────────────┘ └─────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### Quản lý trạng thái
- **Provider Pattern**: Sử dụng Provider để quản lý trạng thái ứng dụng
- **ChangeNotifier**: Cho các trạng thái phức tạp như danh sách giao dịch và trạng thái xác thực
- **StreamBuilder**: Cho dữ liệu thời gian thực từ Firestore

## Thành phần và Giao diện

### 1. Lớp Presentation (UI)

#### AuthScreen
- **Mục đích**: Xử lý đăng nhập và đăng ký người dùng
- **Thành phần**:
  - LoginForm: Form đăng nhập với email/password
  - RegisterForm: Form đăng ký với xác thực email
  - SocialAuthButtons: Đăng nhập qua Google (tùy chọn)
- **Trạng thái**: AuthProvider quản lý trạng thái xác thực

#### HomeScreen
- **Mục đích**: Màn hình chính hiển thị tổng quan chi tiêu
- **Thành phần**:
  - ExpenseSummaryCard: Hiển thị tổng chi tiêu tháng/tuần
  - RecentTransactionsList: 5 giao dịch gần nhất
  - QuickAddButton: Nút thêm giao dịch nhanh
  - NavigationBar: Điều hướng giữa các tab

#### TransactionScreen
- **Mục đích**: Quản lý và hiển thị danh sách giao dịch
- **Thành phần**:
  - TransactionList: Danh sách giao dịch với SliverList
  - FilterBar: Lọc theo danh mục, thời gian
  - SearchBar: Tìm kiếm giao dịch
  - FloatingActionButton: Thêm giao dịch mới

#### AddTransactionScreen
- **Mục đích**: Form thêm/chỉnh sửa giao dịch
- **Thành phần**:
  - AmountInput: Nhập số tiền với validation
  - CategorySelector: Chọn danh mục chi tiêu
  - DatePicker: Chọn ngày giao dịch
  - DescriptionInput: Mô tả giao dịch
  - SubmitButton: Lưu giao dịch

#### AnalyticsScreen
- **Mục đích**: Hiển thị biểu đồ và phân tích chi tiêu
- **Thành phần**:
  - PieChart: Biểu đồ tròn phân bố theo danh mục
  - LineChart: Biểu đồ đường xu hướng chi tiêu
  - StatisticsCards: Thống kê tổng quan
  - DateRangeSelector: Chọn khoảng thời gian phân tích

### 2. Lớp Domain (Business Logic)

#### Models
```dart
class Transaction {
  final String id;
  final double amount;
  final String description;
  final String category;
  final DateTime date;
  final String userId;
}

class User {
  final String id;
  final String email;
  final String displayName;
  final DateTime createdAt;
}

class ExpenseCategory {
  final String id;
  final String name;
  final String icon;
  final Color color;
}
```

#### Use Cases
- **AuthUseCase**: Xử lý đăng nhập, đăng ký, đăng xuất
- **TransactionUseCase**: CRUD operations cho giao dịch
- **AnalyticsUseCase**: Tính toán thống kê và dữ liệu biểu đồ
- **CategoryUseCase**: Quản lý danh mục chi tiêu

#### Repository Interfaces
```dart
abstract class AuthRepository {
  Future<User?> signIn(String email, String password);
  Future<User?> signUp(String email, String password);
  Future<void> signOut();
  Stream<User?> get authStateChanges;
}

abstract class TransactionRepository {
  Future<void> addTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
  Stream<List<Transaction>> getTransactions(String userId);
  Future<List<Transaction>> getTransactionsByDateRange(
    String userId, DateTime start, DateTime end);
}
```

### 3. Lớp Data (Data Access)

#### Firebase Services
- **FirebaseAuthService**: Triển khai AuthRepository
- **FirestoreService**: Triển khai TransactionRepository
- **FirebaseStorageService**: Lưu trữ file đính kèm (tùy chọn)

#### Data Sources
- **RemoteDataSource**: Giao tiếp với Firebase
- **LocalDataSource**: Cache dữ liệu offline với Hive/SQLite
- **PreferencesDataSource**: Lưu trữ cài đặt người dùng

## Mô hình Dữ liệu

### Cấu trúc Firestore
```
users/
  {userId}/
    profile: {
      email: string,
      displayName: string,
      createdAt: timestamp
    }
    transactions/
      {transactionId}: {
        amount: number,
        description: string,
        category: string,
        date: timestamp,
        createdAt: timestamp
      }
    categories/
      {categoryId}: {
        name: string,
        icon: string,
        color: string,
        isDefault: boolean
      }
```

### Quy tắc bảo mật Firestore
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /transactions/{transactionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /categories/{categoryId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## Xử lý Lỗi

### Chiến lược xử lý lỗi
1. **Network Errors**: Hiển thị thông báo và cho phép thử lại
2. **Authentication Errors**: Chuyển hướng về màn hình đăng nhập
3. **Validation Errors**: Hiển thị lỗi trực tiếp trên form
4. **Firestore Errors**: Log lỗi và hiển thị thông báo thân thiện

### Error Classes
```dart
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

class NetworkException extends AppException {
  const NetworkException(String message) : super(message);
}

class AuthException extends AppException {
  const AuthException(String message) : super(message);
}

class ValidationException extends AppException {
  const ValidationException(String message) : super(message);
}
```

## Chiến lược Kiểm thử

### Unit Tests
- **Models**: Kiểm thử serialization/deserialization
- **Use Cases**: Kiểm thử business logic
- **Repositories**: Kiểm thử với mock data sources
- **Validators**: Kiểm thử validation logic

### Widget Tests
- **Forms**: Kiểm thử input validation và submission
- **Lists**: Kiểm thử hiển thị và tương tác
- **Charts**: Kiểm thử rendering với dữ liệu khác nhau
- **Navigation**: Kiểm thử điều hướng giữa màn hình

### Integration Tests
- **Authentication Flow**: Đăng nhập/đăng ký end-to-end
- **Transaction CRUD**: Thêm/sửa/xóa giao dịch
- **Offline Sync**: Kiểm thử đồng bộ khi có/mất kết nối
- **Performance**: Kiểm thử với dữ liệu lớn

## Tối ưu Hiệu suất

### Lazy Loading và Pagination
```dart
class TransactionPagination {
  static const int pageSize = 20;
  DocumentSnapshot? lastDocument;
  
  Future<List<Transaction>> getNextPage(String userId) async {
    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .limit(pageSize);
    
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }
    
    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      lastDocument = snapshot.docs.last;
    }
    
    return snapshot.docs.map((doc) => Transaction.fromFirestore(doc)).toList();
  }
}
```

### Custom Scroll View với Slivers
```dart
class TransactionListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          flexibleSpace: ExpenseSummaryCard(),
        ),
        SliverPersistentHeader(
          delegate: FilterBarDelegate(),
          pinned: true,
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => TransactionTile(transactions[index]),
            childCount: transactions.length,
          ),
        ),
      ],
    );
  }
}
```

### Custom Painter cho Biểu đồ
```dart
class PieChartPainter extends CustomPainter {
  final List<ChartData> data;
  final Animation<double> animation;
  
  PieChartPainter(this.data, this.animation) : super(repaint: animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.8;
    
    double startAngle = -math.pi / 2;
    final total = data.fold(0.0, (sum, item) => sum + item.value);
    
    for (final item in data) {
      final sweepAngle = (item.value / total) * 2 * math.pi * animation.value;
      
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      startAngle += sweepAngle;
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

## Bảo mật và Quyền riêng tư

### Mã hóa dữ liệu
- **In Transit**: HTTPS/TLS cho tất cả giao tiếp Firebase
- **At Rest**: Firebase tự động mã hóa dữ liệu lưu trữ
- **Local Storage**: Mã hóa dữ liệu cache với flutter_secure_storage

### Xác thực và Phân quyền
- **Multi-factor Authentication**: Tùy chọn cho bảo mật cao
- **Session Management**: Tự động đăng xuất sau thời gian không hoạt động
- **Data Isolation**: Mỗi user chỉ truy cập được dữ liệu của mình

### Compliance
- **GDPR**: Cho phép người dùng xuất và xóa dữ liệu
- **Data Retention**: Tự động xóa dữ liệu sau thời gian quy định
- **Privacy Policy**: Tích hợp trong ứng dụng