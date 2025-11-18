import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../injection_container.dart' as di;
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';

import '../bloc/review_bloc.dart';
import '../bloc/review_event.dart';
import '../bloc/review_state.dart';
import '../widgets/review_rating_input.dart';

class AddReviewPage extends StatefulWidget {
  final String restaurantId;

  const AddReviewPage({
    super.key,
    required this.restaurantId,
  });

  @override
  State<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final _imagePicker = ImagePicker();
  
  double _rating = 0.0;
  List<File> _selectedImages = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ReviewBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thêm đánh giá'),
          actions: [
            BlocConsumer<ReviewBloc, ReviewState>(
              listener: (context, state) {
                if (state is ReviewActionSuccess && state.action == 'add') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                  Navigator.of(context).pop();
                } else if (state is ReviewActionError && state.action == 'add') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                  setState(() {
                    _isSubmitting = false;
                  });
                }
              },
              builder: (context, state) {
                return TextButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Gửi'),
                );
              },
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating section
                Text(
                  'Đánh giá của bạn',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppConstants.smallPadding),
                ReviewRatingInput(
                  initialRating: _rating,
                  onRatingChanged: (rating) {
                    setState(() {
                      _rating = rating;
                    });
                  },
                ),
                
                const SizedBox(height: AppConstants.defaultPadding),
                
                // Comment section
                Text(
                  'Nhận xét',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppConstants.smallPadding),
                TextFormField(
                  controller: _commentController,
                  maxLines: 5,
                  maxLength: AppConstants.maxReviewLength,
                  decoration: const InputDecoration(
                    hintText: 'Chia sẻ trải nghiệm của bạn về nhà hàng này...',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập nhận xét';
                    }
                    if (value.trim().length < AppConstants.minReviewLength) {
                      return 'Nhận xét phải có ít nhất ${AppConstants.minReviewLength} ký tự';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: AppConstants.defaultPadding),
                
                // Images section
                Text(
                  'Hình ảnh (tùy chọn)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppConstants.smallPadding),
                _buildImageSection(),
                
                const SizedBox(height: AppConstants.largePadding),
                
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReview,
                    child: _isSubmitting
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text('Đang gửi...'),
                            ],
                          )
                        : const Text('Gửi đánh giá'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        // Selected images
        if (_selectedImages.isNotEmpty) ...[
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedImages[index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
        ],
        
        // Add image button
        if (_selectedImages.length < AppConstants.maxImagesPerReview)
          OutlinedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.add_photo_alternate),
            label: Text(
              _selectedImages.isEmpty 
                  ? 'Thêm hình ảnh' 
                  : 'Thêm hình ảnh khác',
            ),
          ),
        
        if (_selectedImages.length >= AppConstants.maxImagesPerReview)
          Text(
            'Tối đa ${AppConstants.maxImagesPerReview} hình ảnh',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Future<void> _pickImages() async {
    try {
      final images = await _imagePicker.pickMultiImage(
        maxWidth: AppConstants.maxImageWidth.toDouble(),
        maxHeight: AppConstants.maxImageHeight.toDouble(),
        imageQuality: AppConstants.imageQuality,
      );

      if (images.isNotEmpty) {
        final remainingSlots = AppConstants.maxImagesPerReview - _selectedImages.length;
        final imagesToAdd = images.take(remainingSlots).map((xFile) => File(xFile.path)).toList();
        
        setState(() {
          _selectedImages.addAll(imagesToAdd);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi chọn hình ảnh: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _submitReview() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn số sao đánh giá'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Get current user info from AuthBloc
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;
    
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để thêm đánh giá'),
        ),
      );
      return;
    }
    
    final user = authState.user;
    final userId = user.id;
    final userDisplayName = user.displayName ?? 'Người dùng';
    final userPhotoUrl = user.photoUrl;

    context.read<ReviewBloc>().add(AddReview(
      restaurantId: widget.restaurantId,
      userId: userId,
      userDisplayName: userDisplayName,
      userPhotoUrl: userPhotoUrl,
      rating: _rating.round(),
      comment: _commentController.text.trim(),
      images: _selectedImages.isNotEmpty ? _selectedImages : null,
    ));
  }
}