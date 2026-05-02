import 'package:flutter/material.dart';

class PercentageSelector extends StatelessWidget {
  final double selectedPercentage;
  final ValueChanged<double> onPercentageChanged;

  const PercentageSelector({
    super.key,
    required this.selectedPercentage,
    required this.onPercentageChanged,
  });

  static const List<double> secondaryPercentages = [25, 33.33, 66.66, 75];

  @override
  Widget build(BuildContext context) {
    final bool isSecondarySelected = secondaryPercentages.contains(selectedPercentage);

    return Row(
      children: [
        Expanded(
          child: _PercentageButton(
            label: '50%',
            isSelected: selectedPercentage == 50.0,
            onTap: () => onPercentageChanged(50.0),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PercentageButton(
            label: '100%',
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
                  value: isSecondarySelected ? selectedPercentage : null,
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
                      child: Text('${value == 33.33 || value == 66.66 ? value.toStringAsFixed(2) : value.toInt()}%'),
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
            fontSize: 16,
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
