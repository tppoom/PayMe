import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/entry.dart';

class ExpenseProvider with ChangeNotifier {
  List<Entry> _entries = [];
  static const String _storageKey = 'payme_entries';
  
  Payer _currentPayer = Payer.poom;
  Locale _locale = const Locale('en');

  List<Entry> get entries => _entries;
  Payer get currentPayer => _currentPayer;
  Locale get locale => _locale;

  ThemeMode get themeMode => _currentPayer == Payer.poom ? ThemeMode.dark : ThemeMode.light;

  void setCurrentPayer(Payer payer) {
    _currentPayer = payer;
    notifyListeners();
  }

  void toggleLocale() {
    _locale = _locale.languageCode == 'en' ? const Locale('th') : const Locale('en');
    notifyListeners();
  }

  String translate(String key) {
    final bool isThai = _locale.languageCode == 'th';
    final Map<String, Map<String, String>> translations = {
      'who_paid': {'en': 'Who paid?', 'th': 'ใครจ่าย?'},
      'amount': {'en': 'Amount', 'th': 'จำนวนเงิน'},
      'split': {'en': 'Split', 'th': 'หาร'},
      'add_entry': {'en': 'Add Entry', 'th': 'เพิ่มรายการ'},
      'recent_entries': {'en': 'Recent Entries', 'th': 'รายการล่าสุด'},
      'all': {'en': 'All', 'th': 'ทั้งหมด'},
      'calc_balance': {'en': 'Calculate Final Balance', 'th': 'คำนวณยอดสุทธิ'},
      'poom_paid': {'en': 'Poom paid', 'th': 'ภูมิจ่าย'},
      'poy_paid': {'en': 'Poy paid', 'th': 'ปอยจ่าย'},
      'poy_owes_poom': {'en': 'Poy owes Poom', 'th': 'ปอยติดภูมิ'},
      'poom_owes_poy': {'en': 'Poom owes Poy', 'th': 'ภูมิติดปอย'},
      'all_settled': {'en': 'All settled!', 'th': 'เจ๊ากันแล้ว!'},
      'reset_all': {'en': 'Reset All', 'th': 'ล้างทั้งหมด'},
      'close': {'en': 'Close', 'th': 'ปิด'},
      'cancel': {'en': 'Cancel', 'th': 'ยกเลิก'},
      'save': {'en': 'Save', 'th': 'บันทึก'},
      'edit_entry': {'en': 'Edit Entry', 'th': 'แก้ไขรายการ'},
      'paid': {'en': 'Paid', 'th': 'จ่าย'},
      'no_entries': {'en': 'No entries yet', 'th': 'ยังไม่มีรายการ'},
      'no_entries_for': {'en': 'No entries for', 'th': 'ยังไม่มีรายการของ'},
      'full': {'en': 'Full', 'th': 'เต็ม'},
      'more': {'en': 'More', 'th': 'เพิ่มเติม'},
      'poom': {'en': 'Poom', 'th': 'ภูมิ'},
      'poy': {'en': 'Poy', 'th': 'ปอย'},
    };

    return translations[key]?[isThai ? 'th' : 'en'] ?? key;
  }

  double get balance {
    return poomTotal - poyTotal;
  }

  double get poomTotal {
    double total = 0;
    for (var entry in _entries) {
      if (entry.payer == Payer.poom) {
        total += entry.amount * (entry.percentage / 100);
      }
    }
    return total;
  }

  double get poyTotal {
    double total = 0;
    for (var entry in _entries) {
      if (entry.payer == Payer.poy) {
        total += entry.amount * (entry.percentage / 100);
      }
    }
    return total;
  }

  ExpenseProvider() {
    loadEntries();
  }

  Future<void> addEntry(double amount, double percentage, Payer payer) async {
    final entry = Entry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      percentage: percentage,
      payer: payer,
      timestamp: DateTime.now(),
    );
    _entries.insert(0, entry);
    notifyListeners();
    await _saveEntries();
  }

  Future<void> updateEntry(String id, double amount, double percentage) async {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index != -1) {
      final oldEntry = _entries[index];
      _entries[index] = Entry(
        id: oldEntry.id,
        amount: amount,
        percentage: percentage,
        payer: oldEntry.payer,
        timestamp: oldEntry.timestamp,
      );
      notifyListeners();
      await _saveEntries();
    }
  }

  Future<void> removeEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
    await _saveEntries();
  }

  Future<void> clearAll() async {
    _entries.clear();
    notifyListeners();
    await _saveEntries();
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_storageKey);
    if (encoded != null) {
      final List<dynamic> decoded = jsonDecode(encoded);
      _entries = decoded.map((e) => Entry.fromJson(e)).toList();
      notifyListeners();
    }
  }
}
