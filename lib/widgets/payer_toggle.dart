import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/entry.dart';
import '../logic/expense_provider.dart';

class PayerToggle extends StatelessWidget {
  final Payer selectedPayer;
  final ValueChanged<Payer> onPayerChanged;

  const PayerToggle({
    super.key,
    required this.selectedPayer,
    required this.onPayerChanged,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ExpenseProvider>();
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<Payer>(
        style: SegmentedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          visualDensity: VisualDensity.comfortable,
        ),
        segments: [
          ButtonSegment<Payer>(
            value: Payer.poom,
            label: Text(provider.translate('poom'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            icon: const Icon(Icons.person),
          ),
          ButtonSegment<Payer>(
            value: Payer.poy,
            label: Text(provider.translate('poy'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            icon: const Icon(Icons.person_outline),
          ),
        ],
        selected: {selectedPayer},
        onSelectionChanged: (Set<Payer> newSelection) {
          onPayerChanged(newSelection.first);
        },
      ),
    );
  }
}
