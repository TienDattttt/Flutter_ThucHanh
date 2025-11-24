import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: const Icon(Icons.notifications),
        title: const Text("Tiêu đề thông báo"),
        subtitle: const Text("Đây là nội dung thông báo."),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Handle tap
        },
      ),
    );
  }
}
