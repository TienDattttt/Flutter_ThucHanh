import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../../data/services/sync_service.dart';
import '../../core/theme/app_theme.dart';

class SyncStatusWidget extends StatefulWidget {
  const SyncStatusWidget({Key? key}) : super(key: key);

  @override
  State<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget> {
  SyncStatus? _syncStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSyncStatus();
  }

  Future<void> _loadSyncStatus() async {
    try {
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      final status = await transactionProvider.getSyncStatus();
      if (mounted) {
        setState(() {
          _syncStatus = status;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _syncNow() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      await transactionProvider.syncPendingTransactions();
      
      // Reload sync status
      await _loadSyncStatus();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đồng bộ thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đồng bộ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_syncStatus == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(),
            color: _getStatusColor(),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_syncStatus!.hasPendingChanges) ...[
                  Text(
                    '${_syncStatus!.pendingTransactionsCount} thay đổi chờ đồng bộ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                if (_syncStatus!.lastSyncTime != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Lần cuối: ${_formatLastSync(_syncStatus!.lastSyncTime!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_syncStatus!.hasPendingChanges && _syncStatus!.isConnected) ...[
            const SizedBox(width: 8),
            _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : InkWell(
                    onTap: _syncNow,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.sync,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (_syncStatus == null) return Colors.grey;
    
    if (!_syncStatus!.isConnected) {
      return Colors.orange;
    } else if (_syncStatus!.hasPendingChanges) {
      return Colors.blue;
    } else {
      return Colors.green;
    }
  }

  IconData _getStatusIcon() {
    if (_syncStatus == null) return Icons.sync_disabled;
    
    if (!_syncStatus!.isConnected) {
      return Icons.cloud_off;
    } else if (_syncStatus!.hasPendingChanges) {
      return Icons.cloud_sync;
    } else {
      return Icons.cloud_done;
    }
  }



  String _formatLastSync(DateTime lastSync) {
    final now = DateTime.now();
    final difference = now.difference(lastSync);
    
    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }
}