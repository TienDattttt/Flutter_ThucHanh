import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/string_utils.dart';
import '../../domain/entities/restaurant.dart';

class RestaurantInfoSection extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantInfoSection({
    super.key,
    required this.restaurant,
  });

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép $label'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Description
          if (restaurant.description.isNotEmpty) ...[
            _buildInfoRow(
              context,
              icon: Icons.description,
              label: 'Mô tả',
              content: restaurant.description,
              isExpandable: true,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
          ],

          // Address
          _buildInfoRow(
            context,
            icon: Icons.location_on,
            label: 'Địa chỉ',
            content: restaurant.address,
            onTap: () => _copyToClipboard(context, restaurant.address, 'địa chỉ'),
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Phone Number
          if (StringUtils.isNotNullOrEmpty(restaurant.phoneNumber)) ...[
            _buildInfoRow(
              context,
              icon: Icons.phone,
              label: 'Điện thoại',
              content: StringUtils.formatPhoneNumber(restaurant.phoneNumber!),
              onTap: () => _copyToClipboard(context, restaurant.phoneNumber!, 'số điện thoại'),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
          ],

          // Website
          if (StringUtils.isNotNullOrEmpty(restaurant.website)) ...[
            _buildInfoRow(
              context,
              icon: Icons.language,
              label: 'Website',
              content: restaurant.website!,
              onTap: () => _copyToClipboard(context, restaurant.website!, 'website'),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
          ],

          // Coordinates (for debugging/admin)
          if (restaurant.latitude != 0 && restaurant.longitude != 0) ...[
            _buildInfoRow(
              context,
              icon: Icons.gps_fixed,
              label: 'Tọa độ',
              content: '${restaurant.latitude.toStringAsFixed(6)}, ${restaurant.longitude.toStringAsFixed(6)}',
              onTap: () => _copyToClipboard(
                context,
                '${restaurant.latitude}, ${restaurant.longitude}',
                'tọa độ',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String content,
    VoidCallback? onTap,
    bool isExpandable = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.smallPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            const SizedBox(width: AppConstants.smallPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  isExpandable
                      ? _ExpandableText(content: content)
                      : Text(
                          content,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: AppConstants.smallPadding),
              Icon(
                Icons.copy,
                color: Colors.grey[600],
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExpandableText extends StatefulWidget {
  final String content;
  final int maxLines;

  const _ExpandableText({
    required this.content,
    this.maxLines = 3,
  });

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.content,
          style: Theme.of(context).textTheme.bodyMedium,
          maxLines: _isExpanded ? null : widget.maxLines,
          overflow: _isExpanded ? null : TextOverflow.ellipsis,
        ),
        if (widget.content.length > 100) // Show expand/collapse for long text
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _isExpanded ? 'Thu gọn' : 'Xem thêm',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}