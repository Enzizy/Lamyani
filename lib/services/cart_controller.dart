import 'dart:collection';

import 'package:flutter/material.dart';

import '../screens/mock_data.dart';

class CartController extends ChangeNotifier {
  final Map<String, CartEntry> _entries = {};

  UnmodifiableListView<CartEntry> get entries =>
      UnmodifiableListView(_entries.values);

  bool get isEmpty => _entries.isEmpty;

  int get totalItems =>
      _entries.values.fold<int>(0, (sum, entry) => sum + entry.quantity);

  int get uniqueItems => _entries.length;

  double get subtotal =>
      _entries.values.fold<double>(0, (sum, entry) => sum + entry.lineTotal);

  double get deliveryFee => _entries.isEmpty ? 0 : 49;

  double get total => subtotal + deliveryFee;

  void addSelection(CartSelection selection, {int quantity = 1}) {
    if (quantity <= 0) {
      return;
    }

    final existing = _entries[selection.id];
    if (existing == null) {
      _entries[selection.id] = CartEntry(selection: selection, quantity: quantity);
    } else {
      existing.quantity += quantity;
    }
    notifyListeners();
  }

  void increment(String id) {
    final entry = _entries[id];
    if (entry == null) {
      return;
    }
    entry.quantity += 1;
    notifyListeners();
  }

  void decrement(String id) {
    final entry = _entries[id];
    if (entry == null) {
      return;
    }
    if (entry.quantity <= 1) {
      remove(id);
      return;
    }
    entry.quantity -= 1;
    notifyListeners();
  }

  void remove(String id) {
    final removed = _entries.remove(id);
    if (removed != null) {
      notifyListeners();
    }
  }

  void restore(CartSelection selection, int quantity) {
    if (quantity <= 0) {
      return;
    }
    _entries[selection.id] = CartEntry(selection: selection, quantity: quantity);
    notifyListeners();
  }

  void clear() {
    if (_entries.isEmpty) {
      return;
    }
    _entries.clear();
    notifyListeners();
  }
}

class CartEntry {
  CartEntry({required this.selection, required this.quantity});

  final CartSelection selection;
  int quantity;

  double get lineTotal => selection.unitPrice * quantity;
}

class CartScope extends InheritedNotifier<CartController> {
  const CartScope({
    super.key,
    required CartController notifier,
    required super.child,
  }) : super(notifier: notifier);

  static CartController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CartScope>();
    assert(scope != null, 'CartScope is missing above this widget.');
    return scope!.notifier!;
  }
}
