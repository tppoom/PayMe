import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/entry.dart';

class ExpenseProvider with ChangeNotifier {
  List<Entry> _entries = [];
  static const String _storageKey = 'payme_entries';
  static const String _themeKey = 'payme_theme';
  ThemeMode _themeMode = ThemeMode.dark;

  List<Entry> get entries => _entries;
  ThemeMode get themeMode => _themeMode;

  double get balance {
    double bal = 0;
    for (var entry in _entries) {
      double portion = entry.amount * (entry.percentage / 100);
      if (entry.payer == Payer.poom) {
        bal += portion;
      } else {
        bal -= portion;
      }
    }
    return bal;
  }

  ExpenseProvider() {
    loadEntries();
    _loadTheme();
  }

  void toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, _themeMode.index);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final int? themeIndex = prefs.getInt(_themeKey);
    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
      notifyListeners();
    }
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
