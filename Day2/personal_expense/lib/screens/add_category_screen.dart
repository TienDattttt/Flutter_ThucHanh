import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/category_model.dart';
import '../providers/transaction_provider.dart';

// Danh sách icon cho phép chọn (giả lập)
const List<IconData> _icons = [
  Icons.restaurant, Icons.shopping_bag, Icons.phone_android, Icons.water_drop,
  Icons.directions_car, Icons.home, Icons.fitness_center, Icons.school,
  Icons.medical_services, Icons.pets, Icons.local_gas_station, Icons.movie,
  Icons.wallet, Icons.work, Icons.music_note, Icons.flight,
];

// Danh sách màu sắc cho phép chọn (giả lập)
final List<Color> _colors = [
  const Color(0xFFFF6F61), const Color(0xFFFF9800), const Color(0xFF81C784),
  const Color(0xFF4FC3F7), const Color(0xFF7B61FF), Colors.pink,
  Colors.teal, Colors.indigo, Colors.brown, Colors.purple,
  Colors.deepOrange, Colors.lightBlue, Colors.amber, Colors.green,
];

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _limitController = TextEditingController();
  IconData _selectedIcon = _icons.first;
  Color _selectedColor = _colors.first;
  bool _showColorPicker = true;

  void _saveCategory() {
    if (!_formKey.currentState!.validate()) return;

    final limit = double.tryParse(_limitController.text.replaceAll('.', '')) ?? 0.0;

    final newCategory = CategoryModel(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      icon: _selectedIcon,
      color: _selectedColor,
      limit: limit,
    );

    Provider.of<TransactionProvider>(context, listen: false)
        .addCategory(newCategory);

    Navigator.pop(context);
  }

  // ... (Phần xây dựng UI _buildIconPicker, _buildColorPicker, _tabButton giống code trước)
  Widget _buildIconPicker() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _icons.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final icon = _icons[index];
        return GestureDetector(
          onTap: () => setState(() => _selectedIcon = icon),
          child: Container(
            decoration: BoxDecoration(
              color: _selectedIcon == icon
                  ? _selectedColor.withOpacity(0.2)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _selectedIcon == icon ? _selectedColor : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(icon, color: _selectedColor, size: 30),
          ),
        );
      },
    );
  }

  Widget _buildColorPicker() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _colors.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final color = _colors[index];
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(
                color: _selectedColor == color ? Colors.black : Colors.transparent,
                width: 3,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tabButton(String title, bool isSelected) {
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _showColorPicker = title == 'Màu sắc'),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
  // ...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo Mục Chi Tiêu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon mẫu
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_selectedIcon, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Tên mục chi tiêu (ví dụ: Tiền nhà)',
                            fillColor: Colors.white,
                          ),
                          validator: (v) => v!.isEmpty ? 'Nhập tên' : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _limitController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Hạn mức (ví dụ: 1.000.000)',
                            fillColor: Colors.white,
                          ),
                          validator: (v) => v!.isEmpty ? 'Nhập hạn mức' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 5)
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _tabButton('Biểu tượng', !_showColorPicker),
                        _tabButton('Màu sắc', _showColorPicker),
                      ],
                    ),
                    const Divider(height: 1, thickness: 1),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _showColorPicker ? _buildColorPicker() : _buildIconPicker(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: _saveCategory,
                    child: const Text('ĐỒNG Ý', style: TextStyle(fontSize: 18)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}