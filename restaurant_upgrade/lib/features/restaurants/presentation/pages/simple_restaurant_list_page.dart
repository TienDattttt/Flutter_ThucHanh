import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';

class SimpleRestaurantListPage extends StatelessWidget {
  const SimpleRestaurantListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhà hàng (Simple)'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(AppConstants.restaurantsCollection)
            .where('isActive', isEqualTo: true)
            .orderBy('averageRating', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Lỗi: ${snapshot.error}'),
                  SizedBox(height: 16),
                  Text('Chi tiết: ${snapshot.error.toString()}'),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải danh sách nhà hàng...'),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Không có nhà hàng nào'),
                  SizedBox(height: 8),
                  Text('Hãy thêm dữ liệu mẫu từ Admin Panel'),
                ],
              ),
            );
          }

          final restaurants = snapshot.data!.docs;
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final doc = restaurants[index];
              final data = doc.data() as Map<String, dynamic>;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.restaurant, color: Colors.white),
                  ),
                  title: Text(
                    data['name'] ?? 'Tên không xác định',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['description'] ?? ''),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          SizedBox(width: 4),
                          Text('${data['averageRating'] ?? 0} (${data['totalReviews'] ?? 0} đánh giá)'),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data['address'] ?? '',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    // TODO: Navigate to restaurant detail
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Clicked on ${data['name']}')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}