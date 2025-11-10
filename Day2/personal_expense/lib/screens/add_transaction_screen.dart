import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import 'package:uuid/uuid.dart';

class AddTransactionScreen extends StatefulWidget {
  final String? categoryId;

  const AddTransactionScreen({super.key, this.categoryId});

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  String? _selectedCategoryId;
  DateTime _transactionDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final categories = provider.categories;

    // Nếu có categoryId truyền vào từ màn hình chi tiết
    if (widget.categoryId != null) {
      _selectedCategoryId = widget.categoryId;
    } else if (categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
    }
  }

  void _save() {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      final amount = double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0.0;
      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Số tiền phải lớn hơn 0!')),
        );
        return;
      }

      final newTx = TransactionModel(
        id: const Uuid().v4(),
        categoryId: _selectedCategoryId!,
        amount: amount,
        description: _descController.text,
        date: _transactionDate,
      );

      Provider.of<TransactionProvider>(context, listen: false)
          .addTransaction(newTx);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final categories = provider.categories;

    if (categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Thêm giao dịch')),
        body: const Center(child: Text('Vui lòng tạo mục chi tiêu trước.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Thêm giao dịch')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(labelText: 'Mục chi tiêu'),
                items: categories.map((e) {
                  return DropdownMenuItem<String>(
                    value: e.id,
                    child: Row(
                      children: [
                        Icon(e.icon, color: e.color),
                        const SizedBox(width: 10),
                        Text(e.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v),
                validator: (v) => v == null ? 'Chọn mục chi tiêu' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số tiền',
                  prefixIcon: Icon(Icons.money),
                ),
                validator: (v) => v!.isEmpty ? 'Nhập số tiền' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  'Thời gian: ${DateFormat('HH:mm dd/MM/yyyy').format(_transactionDate)}',
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Lưu giao dịch'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
