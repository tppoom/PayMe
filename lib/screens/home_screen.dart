import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../logic/expense_provider.dart';
import '../models/entry.dart';
import '../widgets/percentage_selector.dart';
import '../widgets/payer_toggle.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _amountController = TextEditingController();
  double _selectedPercentage = 50.0;
  Payer _selectedPayer = Payer.poom;
  Payer? _filterPayer; // null means "All"

  void _addEntry() {
    HapticFeedback.mediumImpact();
    final String text = _amountController.text;
    if (text.isEmpty) return;

    final double? amount = double.tryParse(text);
    if (amount == null || amount <= 0) return;

    context.read<ExpenseProvider>().addEntry(
          amount,
          _selectedPercentage,
          _selectedPayer,
        );

    _amountController.clear();
  }

  void _showResult() {
    HapticFeedback.heavyImpact();
    final provider = context.read<ExpenseProvider>();
    final balance = provider.balance;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              balance == 0
                  ? 'All settled!'
                  : balance > 0
                      ? 'Poy owes Poom'
                      : 'Poom owes Poy',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              '฿${balance.abs().toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      provider.clearAll();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Reset All'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PayMe', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Who paid?', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 8),
                  PayerToggle(
                    selectedPayer: _selectedPayer,
                    onPayerChanged: (payer) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedPayer = payer);
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text('Amount', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      prefixText: '฿ ',
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.grey),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _amountController.clear();
                          },
                        ),
                      ),
                    ),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    autofocus: true,
                  ),
                  const SizedBox(height: 24),
                  const Text('Split Percentage (Others share)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 8),
                  PercentageSelector(
                    selectedPercentage: _selectedPercentage,
                    onPercentageChanged: (pct) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedPercentage = pct);
                    },
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _addEntry,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      shadowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                    ),
                    child: const Text('Add Entry', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 40),
                  const Text('Recent Entries', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: _filterPayer == null,
                          onSelected: (_) => setState(() => _filterPayer = null),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Poom'),
                          selected: _filterPayer == Payer.poom,
                          onSelected: (_) => setState(() => _filterPayer = Payer.poom),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Poy'),
                          selected: _filterPayer == Payer.poy,
                          onSelected: (_) => setState(() => _filterPayer = Payer.poy),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _EntryList(filter: _filterPayer),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: FilledButton(
              onPressed: _showResult,
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                minimumSize: const Size.fromHeight(60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Calculate Balance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryList extends StatelessWidget {
  final Payer? filter;
  const _EntryList({this.filter});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final entries = filter == null
            ? provider.entries
            : provider.entries.where((e) => e.payer == filter).toList();

        if (entries.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest),
            ),
            child: Column(
              children: [
                const Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text(
                  filter == null ? 'No entries yet' : 'No entries for ${filter == Payer.poom ? 'Poom' : 'Poy'}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final entry = entries[index];
            return Dismissible(
              key: Key(entry.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
              ),
              onDismissed: (_) {
                HapticFeedback.mediumImpact();
                provider.removeEntry(entry.id);
              },
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: entry.payer == Payer.poom 
                            ? Theme.of(context).colorScheme.primaryContainer 
                            : Theme.of(context).colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        entry.payer == Payer.poom ? Icons.person : Icons.person_outline,
                        color: entry.payer == Payer.poom 
                            ? Theme.of(context).colorScheme.onPrimaryContainer 
                            : Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                    ),
                    title: Text(
                      '฿${entry.amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text('${entry.percentage}% split'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              entry.payer == Payer.poom ? 'Poom' : 'Poy',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const Text('Paid', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            provider.removeEntry(entry.id);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
