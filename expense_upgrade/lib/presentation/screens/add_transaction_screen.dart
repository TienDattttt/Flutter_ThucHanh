import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/amount_input.dart';
import '../widgets/category_selector.dart';
import '../widgets/date_picker_field.dart';
import '../widgets/description_input.dart';
import '../../domain/entities/transaction.dart';
import '../../core/utils/date_formatter.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction; // null for add, non-null for edit
  
  const AddTransactionScreen({
    super.key,
    this.transaction,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  
  bool get _isEditing => widget.transaction != null;
  
  @override
  void initState() {
    super.initState();
    _initializeForm();
    
    // Load categories when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });
  }
  
  void _initializeForm() {
    if (_isEditing) {
      final transaction = widget.transaction!;
      _amountController.text = transaction.amount.toString();
      _descriptionController.text = transaction.description;
      _selectedCategoryId = transaction.category;
      _selectedDate = transaction.date;
    }
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa giao dịch' : 'Thêm giao dịch'),
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _showDeleteConfirmation,
              icon: const Icon(Icons.delete),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Amount Input
              AmountInput(
                controller: _amountController,
                onChanged: (value) {
                  setState(() {}); // Rebuild to update save button state
                },
              ),
              
              const SizedBox(height: 16),
              
              // Category Selector
              Consumer<CategoryProvider>(
                builder: (context, categoryProvider, child) {
                  return CategorySelector(
                    categories: categoryProvider.categories,
                    selectedCategoryId: _selectedCategoryId,
                    onCategorySelected: (categoryId) {
                      setState(() {
                        _selectedCategoryId = categoryId;
                      });
                    },
                    isLoading: categoryProvider.isLoading,
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Date Picker
              DatePickerField(
                selectedDate: _selectedDate,
                onDateSelected: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Description Input
              DescriptionInput(
                controller: _descriptionController,
              ),
              
              const SizedBox(height: 32),
              
              // Save Button
              Consumer<TransactionProvider>(
                builder: (context, transactionProvider, child) {
                  return ElevatedButton(
                    onPressed: (_isLoading || transactionProvider.isLoading || !_isFormValid())
                        ? null
                        : _handleSave,
                    child: _isLoading || transactionProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isEditing ? 'Cập nhật' : 'Lưu'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  bool _isFormValid() {
    return _amountController.text.isNotEmpty &&
           _descriptionController.text.isNotEmpty &&
           _selectedCategoryId != null;
  }
  
  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.trim();
      
      final transaction = Transaction(
        id: _isEditing ? widget.transaction!.id : '',
        amount: amount,
        description: description,
        category: _selectedCategoryId!,
        date: _selectedDate,
        userId: '', // Will be set by provider
        createdAt: _isEditing ? widget.transaction!.createdAt : DateTime.now(),
      );
      
      final transactionProvider = context.read<TransactionProvider>();
      
      if (_isEditing) {
        await transactionProvider.updateTransaction(transaction);
      } else {
        await transactionProvider.addTransaction(transaction);
      }
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Giao dịch đã được cập nhật' : 'Giao dịch đã được thêm'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
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
  
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa giao dịch này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleDelete();
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _handleDelete() async {
    if (!_isEditing) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final transactionProvider = context.read<TransactionProvider>();
      await transactionProvider.deleteTransaction(widget.transaction!.id);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Giao dịch đã được xóa'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xóa: ${e.toString()}'),
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
}