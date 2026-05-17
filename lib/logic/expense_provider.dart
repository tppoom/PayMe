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
