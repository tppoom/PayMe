import 'package:flutter/material.dart';
import '../models/entry.dart';

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
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<Payer>(
        style: SegmentedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          visualDensity: VisualDensity.comfortable,
        ),
        segments: const [
          ButtonSegment<Payer>(
            value: Payer.poom,
            label: Text('Poom', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            icon: Icon(Icons.person),
          ),
          ButtonSegment<Payer>(
            value: Payer.poy,
            label: Text('Poy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            icon: Icon(Icons.person_outline),
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
