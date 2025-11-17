import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/date_formatter.dart';

class AmountInput extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  
  const AmountInput({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  State<AmountInput> createState() => _AmountInputState();
}

class _AmountInputState extends State<AmountInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Số tiền',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: InputDecoration(
            hintText: '0',
            prefixIcon: const Icon(Icons.attach_money),
            suffixText: '₫',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          validator: Validators.validateAmount,
          onChanged: (value) {
            widget.onChanged?.call(value);
            setState(() {}); // Rebuild to show formatted preview
          },
        ),
        if (widget.controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _getFormattedAmount(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
  
  String _getFormattedAmount() {
    final amount = double.tryParse(widget.controller.text);
    if (amount == null) return '';
    
    return DateFormatter.formatCurrency(amount);
  }
}