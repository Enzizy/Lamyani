import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../screens/mock_data.dart';
import 'auth_service.dart';
import 'cart_controller.dart';

class OrderService {
  OrderService._();

  static bool get _hasFirebaseApp => Firebase.apps.isNotEmpty;

  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  static Stream<List<AppOrder>> streamCurrentUserOrders() {
    final user = AuthService.currentUser;
    if (!_hasFirebaseApp || user == null) {
      return Stream.value(const []);
    }

    return _firestore
        .collection('orders')
        .where('customerId', isEqualTo: user.uid)
        .orderBy('placedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(AppOrder.fromSnapshot)
              .toList(growable: false),
        );
  }

  static Future<OrderPlacementResult> placeOrder({
    required List<CartEntry> entries,
    required StoreItem branch,
    required double subtotal,
    required double deliveryFee,
    required double total,
  }) async {
    final user = AuthService.currentUser;
    if (!_hasFirebaseApp) {
      throw StateError('Firebase is not initialized.');
    }
    if (user == null) {
      throw StateError('Sign in to place an order.');
    }
    if (entries.isEmpty) {
      throw StateError('Your cart is empty.');
    }

    final profileSnapshot = await _firestore.collection('users').doc(user.uid).get();
    final profile = profileSnapshot.data();
    final fullName = (profile?['fullName'] as String?)?.trim();
    final customerName = fullName != null && fullName.isNotEmpty
        ? fullName
        : user.displayName?.trim().isNotEmpty == true
            ? user.displayName!.trim()
            : user.email?.split('@').first ?? 'Lamyani Customer';

    final orderRef = _firestore.collection('orders').doc();
    final itemMaps = entries
        .map(
          (entry) => {
            'selectionId': entry.selection.id,
            'productId': entry.selection.product.id,
            'productName': entry.selection.name,
            'variantId': entry.selection.variant.id,
            'variantLabel': entry.selection.variantLabel ?? 'Regular',
            'quantity': entry.quantity,
            'unitPrice': entry.selection.unitPrice,
            'lineTotal': entry.lineTotal,
          },
        )
        .toList(growable: false);

    await orderRef.set({
      'customerId': user.uid,
      'customerName': customerName,
      'branchId': branch.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-'),
      'branchName': branch.name,
      'items': itemMaps,
      'itemsSummary': _buildItemsSummary(entries),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'status': 'preparing',
      'placedAt': FieldValue.serverTimestamp(),
    });

    return OrderPlacementResult(
      orderId: orderRef.id,
      branchName: branch.name,
      itemCount: entries.fold<int>(
        0,
        (runningTotal, entry) => runningTotal + entry.quantity,
      ),
      total: total,
    );
  }

  static String _buildItemsSummary(List<CartEntry> entries) {
    final names = <String>[];
    for (final entry in entries) {
      if (!names.contains(entry.selection.name)) {
        names.add(entry.selection.name);
      }
    }

    if (names.length <= 2) {
      return names.join(', ');
    }

    return '${names.take(2).join(', ')} +${names.length - 2} more';
  }
}

class AppOrder {
  const AppOrder({
    required this.id,
    required this.customerName,
    required this.branchName,
    required this.itemsSummary,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.placedAt,
  });

  final String id;
  final String customerName;
  final String branchName;
  final String itemsSummary;
  final List<AppOrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String status;
  final DateTime? placedAt;

  int get totalItems =>
      items.fold<int>(0, (runningTotal, item) => runningTotal + item.quantity);

  factory AppOrder.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    final rawItems = (data['items'] as List<dynamic>? ?? const []);

    return AppOrder(
      id: snapshot.id,
      customerName: (data['customerName'] as String?)?.trim().isNotEmpty == true
          ? (data['customerName'] as String).trim()
          : 'Lamyani Customer',
      branchName: (data['branchName'] as String?)?.trim() ?? 'Lamyani Branch',
      itemsSummary: (data['itemsSummary'] as String?)?.trim() ?? 'Order items',
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(AppOrderItem.fromMap)
          .toList(growable: false),
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0,
      total: (data['total'] as num?)?.toDouble() ?? 0,
      status: (data['status'] as String?)?.trim() ?? 'preparing',
      placedAt: (data['placedAt'] as Timestamp?)?.toDate(),
    );
  }
}

class AppOrderItem {
  const AppOrderItem({
    required this.productName,
    required this.variantLabel,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  final String productName;
  final String variantLabel;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  factory AppOrderItem.fromMap(Map<String, dynamic> data) {
    return AppOrderItem(
      productName: (data['productName'] as String?)?.trim() ?? 'Menu item',
      variantLabel: (data['variantLabel'] as String?)?.trim() ?? 'Regular',
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (data['unitPrice'] as num?)?.toDouble() ?? 0,
      lineTotal: (data['lineTotal'] as num?)?.toDouble() ?? 0,
    );
  }
}

class OrderPlacementResult {
  const OrderPlacementResult({
    required this.orderId,
    required this.branchName,
    required this.itemCount,
    required this.total,
  });

  final String orderId;
  final String branchName;
  final int itemCount;
  final double total;
}
