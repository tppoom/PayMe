import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
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
  final FocusNode _amountFocusNode = FocusNode();
  
  // Unfocusable focus nodes for buttons to prevent keyboard from closing
  final FocusNode _addButtonFocusNode = FocusNode(canRequestFocus: false, skipTraversal: true);
  final FocusNode _calcButtonFocusNode = FocusNode(canRequestFocus: false, skipTraversal: true);

  double _selectedPercentage = 50.0;
  Payer? _filterPayer; // null means "All"

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    _addButtonFocusNode.dispose();
    _calcButtonFocusNode.dispose();
    super.dispose();
  }

  void _addEntry() {
    // Prevent keyboard from dropping - focus remains on textfield
    HapticFeedback.mediumImpact();
    final String text = _amountController.text;
    if (text.isEmpty) {
      _amountFocusNode.requestFocus();
      return;
    }

    final double? amount = double.tryParse(text);
    if (amount == null || amount <= 0) {
      _amountFocusNode.requestFocus();
      return;
    }

    final provider = context.read<ExpenseProvider>();
    provider.addEntry(
          amount,
          _selectedPercentage,
          provider.currentPayer,
        );

    _amountController.clear();
    // Explicitly re-request focus just in case, though canRequestFocus: false should handle it
    _amountFocusNode.requestFocus();
  }

  void _editEntry(Entry entry) {
    final provider = context.read<ExpenseProvider>();
    final TextEditingController editAmountController =
        TextEditingController(text: entry.amount.toString());
    double editPercentage = entry.percentage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('${provider.translate('edit_entry')} (${entry.payer == Payer.poom ? provider.translate('poom') : provider.translate('poy')})'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: editAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: '${provider.translate('amount')} (฿)',
                  border: const OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 24),
              Text(provider.translate('split'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 8),
              PercentageSelector(
                selectedPercentage: editPercentage,
                onPercentageChanged: (pct) {
                  HapticFeedback.selectionClick();
                  setDialogState(() => editPercentage = pct);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(provider.translate('cancel')),
            ),
            FilledButton(
              onPressed: () {
                final double? amount = double.tryParse(editAmountController.text);
                if (amount != null && amount > 0) {
                  context.read<ExpenseProvider>().updateEntry(
                        entry.id,
                        amount,
                        editPercentage,
                      );
                  Navigator.pop(context);
                }
              },
              child: Text(provider.translate('save')),
            ),
          ],
        ),
      ),
    );
  }

  void _showResult() {
    HapticFeedback.heavyImpact();
    final provider = context.read<ExpenseProvider>();
    final balance = provider.balance;
    final poomTotal = provider.poomTotal;
    final poyTotal = provider.poyTotal;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _TotalItem(label: provider.translate('poom_paid'), amount: poomTotal, color: Colors.blue),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                _TotalItem(label: provider.translate('poy_paid'), amount: poyTotal, color: Colors.pink),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              balance == 0
                  ? provider.translate('all_settled')
                  : balance > 0
                      ? provider.translate('poy_owes_poom')
                      : provider.translate('poom_owes_poy'),
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
                    child: Text(provider.translate('reset_all')),
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
                    child: Text(provider.translate('close')),
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
    final provider = context.watch<ExpenseProvider>();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('PayMe', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              context.read<ExpenseProvider>().toggleLocale();
            },
            child: Text(
              provider.locale.languageCode == 'en' ? 'TH' : 'EN',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(provider.translate('who_paid'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 8),
                  PayerToggle(
                    selectedPayer: provider.currentPayer,
                    onPayerChanged: (payer) {
                      HapticFeedback.selectionClick();
                      provider.setCurrentPayer(payer);
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(provider.translate('amount'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 8),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            focusNode: _amountFocusNode,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onSubmitted: kIsWeb ? (_) => _addEntry() : null,
                            decoration: InputDecoration(
                              hintText: '0.00',
                              prefixText: '฿ ',
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: IconButton(
                                  icon: const Icon(Icons.cancel, color: Colors.grey, size: 20),
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    _amountController.clear();
                                    _amountFocusNode.requestFocus();
                                  },
                                ),
                              ),
                            ),
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                            autofocus: true,
                          ),
                        ),
                        if (kIsWeb) ...[
                          const SizedBox(width: 12),
                          AspectRatio(
                            aspectRatio: 1,
                            child: IconButton.filled(
                              focusNode: _addButtonFocusNode,
                              onPressed: _addEntry,
                              icon: const Icon(Icons.add, size: 32),
                              style: IconButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  if (kIsWeb) ...[
                    Text(provider.translate('split'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    PercentageSelector(
                      selectedPercentage: _selectedPercentage,
                      onPercentageChanged: (pct) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedPercentage = pct);
                        _amountFocusNode.requestFocus();
                      },
                    ),
                    const SizedBox(height: 40),
                  ],

                  FilledButton.icon(
                    focusNode: _calcButtonFocusNode,
                    onPressed: _showResult,
                    icon: const Icon(Icons.account_balance_wallet_outlined),
                    label: Text(provider.translate('calc_balance'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(context).colorScheme.onSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(provider.translate('recent_entries'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: Text(provider.translate('all')),
                          selected: _filterPayer == null,
                          onSelected: (_) => setState(() => _filterPayer = null),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: Text(provider.translate('poom')),
                          selected: _filterPayer == Payer.poom,
                          onSelected: (_) => setState(() => _filterPayer = Payer.poom),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: Text(provider.translate('poy')),
                          selected: _filterPayer == Payer.poy,
                          onSelected: (_) => setState(() => _filterPayer = Payer.poy),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _EntryList(
                    filter: _filterPayer,
                    onEdit: _editEntry,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (!kIsWeb)
            SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(provider.translate('split'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    PercentageSelector(
                      selectedPercentage: _selectedPercentage,
                      onPercentageChanged: (pct) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedPercentage = pct);
                        _amountFocusNode.requestFocus();
                      },
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      focusNode: _addButtonFocusNode,
                      onPressed: _addEntry,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        shadowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                      ),
                      child: Text(provider.translate('add_entry'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EntryList extends StatelessWidget {
  final Payer? filter;
  final Function(Entry)? onEdit;
  const _EntryList({this.filter, this.onEdit});

  String _getFractionLabel(double pct, ExpenseProvider provider) {
    const double oneThird = 100 / 3;
    const double twoThirds = 200 / 3;
    if (pct == 50.0) return '/2';
    if (pct == 100.0) return provider.translate('full');
    if (pct == 25.0) return '/4';
    if ((pct - oneThird).abs() < 0.01) return '/3';
    if ((pct - twoThirds).abs() < 0.01) return '2/3';
    if (pct == 75.0) return '3/4';
    return pct.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
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
              filter == null 
                  ? provider.translate('no_entries') 
                  : '${provider.translate('no_entries_for')} ${filter == Payer.poom ? provider.translate('poom') : provider.translate('poy')}',
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
            child: InkWell(
              onTap: () => onEdit?.call(entry),
              borderRadius: BorderRadius.circular(16),
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
                  subtitle: Text(_getFractionLabel(entry.percentage, provider)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            entry.payer == Payer.poom ? provider.translate('poom') : provider.translate('poy'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Text(provider.translate('paid'), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                        onPressed: () => onEdit?.call(entry),
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          provider.removeEntry(entry.id);
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TotalItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _TotalItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          '฿${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
