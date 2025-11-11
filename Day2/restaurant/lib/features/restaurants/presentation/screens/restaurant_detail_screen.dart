import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/review.dart';
import '../providers/review_provider.dart';
import '../widgets/review_tile.dart';
import '../../../restaurants/data/datasources/image_uploader.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;
  const RestaurantDetailScreen({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final _content = TextEditingController();
  double _rating = 4.0;
  File? _image;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    context.read<ReviewProvider>().subscribe(widget.restaurantId);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (_content.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung đánh giá')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      String? imageUrl;
      if (_image != null) {
        // 👉 Nhập thông tin Cloudinary thật của bạn ở đây:
        final uploader = ImageUploader.fromEnv();
        imageUrl = await uploader.uploadImage(_image!);
      }

      await context.read<ReviewProvider>().add(
        restaurantId: widget.restaurantId,
        content: _content.text.trim(),
        rating: _rating,
        imageUrl: imageUrl,
      );

      _content.clear();
      setState(() {
        _image = null;
        _rating = 4.0;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi đánh giá thành công!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi gửi đánh giá: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviews = context.watch<ReviewProvider>().reviews;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurantName),
        backgroundColor: Colors.orange.shade700,
      ),
      body: Column(
        children: [
          // Form viết đánh giá
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chấm điểm', style: TextStyle(fontWeight: FontWeight.bold)),
                Slider(
                  value: _rating,
                  divisions: 8,
                  min: 1,
                  max: 5,
                  label: _rating.toStringAsFixed(1),
                  activeColor: Colors.orange,
                  onChanged: (v) => setState(() => _rating = v),
                ),
                TextField(
                  controller: _content,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Viết cảm nhận của bạn...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo),
                      label: const Text('Chọn ảnh'),
                    ),
                    const SizedBox(width: 8),
                    if (_image != null)
                      Expanded(
                        child: Text(
                          _image!.path.split('/').last,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _loading ? null : _submit,
                  icon: const Icon(Icons.send),
                  label: Text(_loading ? 'Đang gửi...' : 'Gửi đánh giá'),
                ),
              ],
            ),
          ),

          const Divider(height: 0),
          Expanded(
            child: reviews.isEmpty
                ? const Center(child: Text('Chưa có đánh giá nào'))
                : ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (_, i) => ReviewTile(review: reviews[i]),
            ),
          ),
        ],
      ),
    );
  }
}
