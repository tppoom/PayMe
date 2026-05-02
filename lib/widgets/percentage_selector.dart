import 'package:flutter/material.dart';

class PercentageSelector extends StatelessWidget {
  final double selectedPercentage;
  final ValueChanged<double> onPercentageChanged;

  const PercentageSelector({
    super.key,
    required this.selectedPercentage,
    required this.onPercentageChanged,
  });

  // Use exact fractions for 1/3 and 2/3 to avoid rounding issues
  static const double oneThird = 100 / 3;
  static const double twoThirds = 200 / 3;

  static const List<double> secondaryPercentages = [25, oneThird, twoThirds, 75];

  String _getLabel(double pct) {
    if (pct == 50.0) return '/2';
    if (pct == 100.0) return 'Full';
    if (pct == 25.0) return '/4';
    if ((pct - oneThird).abs() < 0.01) return '/3';
    if ((pct - twoThirds).abs() < 0.01) return '2/3';
    if (pct == 75.0) return '3/4';
    return '${pct.toInt()}';
  }

  @override
  Widget build(BuildContext context) {
    // Check if the selected percentage is one of the secondary options
    // Using a small epsilon comparison for floating point numbers
    final bool isSecondarySelected = secondaryPercentages.any((p) => (p - selectedPercentage).abs() < 0.01);

    return Row(
      children: [
        Expanded(
          child: _PercentageButton(
            label: '/2',
            isSelected: selectedPercentage == 50.0,
            onTap: () => onPercentageChanged(50.0),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PercentageButton(
            label: 'Full',
            isSelected: selectedPercentage == 100.0,
            onTap: () => onPercentageChanged(100.0),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: isSecondarySelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSecondarySelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton<double>(
                  // If secondary is selected, we need to match the exact value from the list
                  value: isSecondarySelected 
                    ? secondaryPercentages.firstWhere((p) => (p - selectedPercentage).abs() < 0.01) 
                    : null,
                  hint: Text(
                    'More',
                    style: TextStyle(
                      color: isSecondarySelected
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: isSecondarySelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  borderRadius: BorderRadius.circular(12),
                  items: secondaryPercentages.map((double value) {
                    return DropdownMenuItem<double>(
                      value: value,
                      child: Text(_getLabel(value)),
                    );
                  }).toList(),
                  onChanged: (double? newValue) {
                    if (newValue != null) onPercentageChanged(newValue);
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PercentageButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PercentageButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
