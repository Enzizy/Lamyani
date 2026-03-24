import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../screens/mock_data.dart';

class CatalogService {
  CatalogService._();

  static bool get _hasFirebaseApp => Firebase.apps.isNotEmpty;

  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  static Stream<List<MenuProduct>> streamProducts() {
    if (!_hasFirebaseApp) {
      return Stream.value(MockData.products);
    }

    return _firestore.collection('products').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return MockData.products;
      }

      final products = snapshot.docs
          .map(_mapProduct)
          .whereType<MenuProduct>()
          .where((product) => product.variants.isNotEmpty)
          .toList(growable: false);

      if (products.isEmpty) {
        return MockData.products;
      }

      products.sort((left, right) => right.rating.compareTo(left.rating));
      return products;
    });
  }

  static Stream<List<PromoItem>> streamPromos() {
    if (!_hasFirebaseApp) {
      return Stream.value(MockData.promos);
    }

    return _firestore.collection('promos').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return MockData.promos;
      }

      final promos = snapshot.docs
          .map(_mapPromo)
          .whereType<PromoItem>()
          .toList(growable: false);

      return promos.isEmpty ? MockData.promos : promos;
    });
  }

  static Stream<List<StoreItem>> streamStores() {
    if (!_hasFirebaseApp) {
      return Stream.value(MockData.stores);
    }

    return _firestore.collection('branches').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return MockData.stores;
      }

      final stores = snapshot.docs
          .map(_mapStore)
          .whereType<StoreItem>()
          .toList(growable: false);

      return stores.isEmpty ? MockData.stores : stores;
    });
  }

  static List<String> categoriesFor(List<MenuProduct> products) {
    final categories = <String>{'All'};
    for (final product in products) {
      categories.add(product.category);
    }
    return categories.toList(growable: false);
  }

  static List<MenuProduct> featuredProductsFor(List<MenuProduct> products) {
    final featured = products.take(4).toList(growable: false);
    return featured.isEmpty ? MockData.featuredProducts : featured;
  }

  static MenuProduct? _mapProduct(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    final status = (data['status'] as String?)?.trim().toLowerCase() ?? 'active';
    if (status == 'draft') {
      return null;
    }

    final rootImage = _readString(data, ['imageUrl', 'imageAsset']) ??
        MockData.products.first.imageAsset;
    final rawVariants = (data['variants'] as List<dynamic>? ?? const []);
    final variants = rawVariants
        .whereType<Map<String, dynamic>>()
        .map((variant) => _mapVariant(variant, rootImage))
        .whereType<ProductVariant>()
        .toList(growable: false);

    if (variants.isEmpty) {
      final fallbackPrice = (data['price'] as num?)?.toDouble();
      if (fallbackPrice == null) {
        return null;
      }

      return MenuProduct(
        id: _readString(data, ['id']) ?? snapshot.id,
        name: _readString(data, ['name']) ?? 'Lamyani Meal',
        description: _readString(data, ['description']) ?? 'Freshly roasted meal.',
        category: _readString(data, ['category']) ?? 'Menu',
        imageAsset: rootImage,
        rating: (data['rating'] as num?)?.toDouble() ?? 4.7,
        prepTime: _readString(data, ['prepTime']) ?? '15 min',
        variants: [
          ProductVariant(
            id: 'regular',
            label: 'Regular',
            price: fallbackPrice,
            imageAsset: rootImage,
          ),
        ],
      );
    }

    return MenuProduct(
      id: _readString(data, ['id']) ?? snapshot.id,
      name: _readString(data, ['name']) ?? 'Lamyani Meal',
      description: _readString(data, ['description']) ?? 'Freshly roasted meal.',
      category: _readString(data, ['category']) ?? 'Menu',
      imageAsset: rootImage,
      rating: (data['rating'] as num?)?.toDouble() ?? 4.7,
      prepTime: _readString(data, ['prepTime']) ?? '15 min',
      variants: variants,
    );
  }

  static ProductVariant? _mapVariant(
    Map<String, dynamic> data,
    String fallbackImage,
  ) {
    final label = _readString(data, ['label', 'name']);
    final price = (data['price'] as num?)?.toDouble();
    if (label == null || price == null) {
      return null;
    }

    return ProductVariant(
      id: _readString(data, ['id']) ?? label.toLowerCase().replaceAll(' ', '-'),
      label: label,
      price: price,
      imageAsset: _readString(data, ['imageUrl', 'imageAsset']) ?? fallbackImage,
      badge: _readString(data, ['badge']),
    );
  }

  static PromoItem? _mapPromo(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    final status = (data['status'] as String?)?.trim().toLowerCase() ?? 'live';
    if (status == 'draft') {
      return null;
    }

    final title = _readString(data, ['title']);
    final subtitle = _readString(data, ['subtitle']);
    final imageUrl = _readString(data, ['imageUrl']) ?? MockData.promos.first.imageUrl;
    if (title == null || subtitle == null) {
      return null;
    }

    return PromoItem(title: title, subtitle: subtitle, imageUrl: imageUrl);
  }

  static StoreItem? _mapStore(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    final name = _readString(data, ['name']);
    final address = _readString(data, ['address']);
    final region = _readString(data, ['region']);
    final latitude = (data['latitude'] as num?)?.toDouble();
    final longitude = (data['longitude'] as num?)?.toDouble();
    if (name == null ||
        address == null ||
        region == null ||
        latitude == null ||
        longitude == null) {
      return null;
    }

    final status = (data['status'] as String?)?.trim().toLowerCase() ?? 'open';
    final isOpen = status == 'open';

    return StoreItem(
      name: name,
      address: address,
      distance: '$region branch',
      isOpen: isOpen,
      statusLabel: _statusLabel(status),
      region: region,
      imageUrl: _readString(data, ['imageUrl']) ?? _fallbackBranchImage(region),
      latitude: latitude,
      longitude: longitude,
      hours: _readString(data, ['hours']) ?? '10:00 AM - 10:00 PM',
      manager: _readString(data, ['manager']) ?? 'Lamyani Team',
      productCount: (data['productCount'] as num?)?.toInt() ?? 0,
      nextPromo: _readString(data, ['nextPromo']) ?? 'No live campaign',
    );
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'closed':
        return 'Closed';
      case 'opening-soon':
        return 'Opening Soon';
      default:
        return 'Open';
    }
  }

  static String _fallbackBranchImage(String region) {
    final lowerRegion = region.toLowerCase();
    if (lowerRegion.contains('cebu')) {
      return MockData.stores[0].imageUrl;
    }
    if (lowerRegion.contains('mindoro')) {
      return MockData.stores[3].imageUrl;
    }
    if (lowerRegion.contains('metro')) {
      return MockData.stores[6].imageUrl;
    }
    return MockData.stores.first.imageUrl;
  }

  static String? _readString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }
}
