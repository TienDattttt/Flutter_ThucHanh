class User {
  final String id;
  final String email;
  final String displayName;
  final DateTime createdAt;
  
  const User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.createdAt,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.displayName == displayName &&
        other.createdAt == createdAt;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        createdAt.hashCode;
  }
  
  @override
  String toString() {
    return 'User(id: $id, email: $email, displayName: $displayName, createdAt: $createdAt)';
  }
}