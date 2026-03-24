class ProductVariant {
  const ProductVariant({
    required this.id,
    required this.label,
    required this.price,
    required this.imageAsset,
    this.badge,
  });

  final String id;
  final String label;
  final double price;
  final String imageAsset;
  final String? badge;
}

class MenuProduct {
  const MenuProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imageAsset,
    required this.rating,
    required this.prepTime,
    required this.variants,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final String imageAsset;
  final double rating;
  final String prepTime;
  final List<ProductVariant> variants;

  bool get hasMultipleVariants => variants.length > 1;

  ProductVariant get defaultVariant => variants.first;

  double get startingPrice {
    var lowest = variants.first.price;
    for (final variant in variants.skip(1)) {
      if (variant.price < lowest) {
        lowest = variant.price;
      }
    }
    return lowest;
  }
}

class CartSelection {
  const CartSelection({required this.product, required this.variant});

  final MenuProduct product;
  final ProductVariant variant;

  String get id => '${product.id}:${variant.id}';
  String get name => product.name;
  String get imageAsset => variant.imageAsset;
  double get unitPrice => variant.price;
  String? get variantLabel =>
      product.hasMultipleVariants ? variant.label : null;
}

class PromoItem {
  const PromoItem({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
}

class StoreItem {
  const StoreItem({
    required this.name,
    required this.address,
    required this.distance,
    required this.isOpen,
    required this.statusLabel,
    required this.region,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    this.hours = '10:00 AM - 10:00 PM',
    this.manager = 'Lamyani Team',
    this.productCount = 0,
    this.nextPromo = 'No live campaign',
  });

  final String name;
  final String address;
  final String distance;
  final bool isOpen;
  final String statusLabel;
  final String region;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String hours;
  final String manager;
  final int productCount;
  final String nextPromo;
}

class OnboardingSlide {
  const OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.emoji,
  });

  final String title;
  final String subtitle;
  final String emoji;
}

class MockData {
  static const categories = [
    'All',
    'Lechon Belly',
    'Rice Meals',
    'Silog Meals',
    'Solo Orders',
    'Sides',
    'Drinks',
  ];

  static const quickCategories = [
    'Lechon Belly',
    'Rice Meals',
    'Silog Meals',
    'Solo Orders',
  ];

  static const onboardingSlides = [
    OnboardingSlide(
      title: 'Authentic Cebuano Flavor',
      subtitle:
          'Roasted specialties made for everyday cravings and family feasts.',
      emoji: '🔥',
    ),
    OnboardingSlide(
      title: 'Find the nearest Lamyani',
      subtitle:
          'Browse nearby stores and get your order faster with fewer taps.',
      emoji: '📍',
    ),
    OnboardingSlide(
      title: 'Earn rewards with every meal',
      subtitle: 'Collect points on every order and unlock premium meal perks.',
      emoji: '🎁',
    ),
    OnboardingSlide(
      title: 'Order in just a few taps',
      subtitle: 'Build your cart, choose your store, and check out in seconds.',
      emoji: '🛵',
    ),
  ];

  static const promos = [
    PromoItem(
      title: '₱100 OFF Lechon',
      subtitle: 'Hot weekend roast deals for pickup and delivery.',
      imageUrl:
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=900&q=80',
    ),
    PromoItem(
      title: 'Weekend Specials',
      subtitle: 'Bundle rice meals and barkada platters for less.',
      imageUrl:
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=900&q=80',
    ),
    PromoItem(
      title: 'Free Iced Tea',
      subtitle: 'Add any liempo meal and enjoy a refreshing side drink.',
      imageUrl:
          'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=900&q=80',
    ),
  ];

  // Catalog sourced from the public Lamyani Odoo self-order POS catalog on
  // March 23, 2026. Variations that differ only by weight are grouped into a
  // single app product so the selection happens inside product details.
  static const products = [
    MenuProduct(
      id: 'lechon-belly',
      name: 'Lechon Belly',
      description:
          'Lamyani signature roasted pork belly with crisp skin, rich drippings, and size options for solo cravings or sharing trays.',
      category: 'Lechon Belly',
      imageAsset: 'assets/products/lechon-belly-1kg.png',
      rating: 4.9,
      prepTime: '20-30 min',
      variants: [
        ProductVariant(
          id: 'quarter-kg',
          label: '1/4 kg',
          price: 275,
          imageAsset: 'assets/products/lechon-belly-1-4.png',
        ),
        ProductVariant(
          id: 'half-kg',
          label: '1/2 kg',
          price: 550,
          imageAsset: 'assets/products/lechon-belly-1-2.png',
        ),
        ProductVariant(
          id: 'three-quarter-kg',
          label: '3/4 kg',
          price: 825,
          imageAsset: 'assets/products/lechon-belly-3-4.png',
        ),
        ProductVariant(
          id: 'one-kg',
          label: '1 kg',
          price: 1100,
          imageAsset: 'assets/products/lechon-belly-1kg.png',
        ),
        ProductVariant(
          id: 'one-kg-sunday',
          label: '1 kg Sunday Special',
          price: 999,
          imageAsset: 'assets/products/lechon-belly-1kg-sunday.png',
          badge: 'Sunday Deal',
        ),
      ],
    ),
    MenuProduct(
      id: 'lechon-baka-meal',
      name: 'Lechon Baka Meal',
      description:
          'Roasted beef served with rice and savory drippings for a filling Cebuano lunch plate.',
      category: 'Rice Meals',
      imageAsset: 'assets/products/lechon-baka-meal.png',
      rating: 4.7,
      prepTime: '12 min',
      variants: [
        ProductVariant(
          id: 'regular',
          label: 'Regular',
          price: 169,
          imageAsset: 'assets/products/lechon-baka-meal.png',
        ),
      ],
    ),
    MenuProduct(
      id: 'chicken-leg-quarter-meal',
      name: 'Chicken Leg Quarter Meal',
      description:
          'Juicy roasted chicken leg quarter with rice and house sauce for an easy everyday meal.',
      category: 'Rice Meals',
      imageAsset: 'assets/products/chicken-leg-quarter-meal.png',
      rating: 4.8,
      prepTime: '12 min',
      variants: [
        ProductVariant(
          id: 'regular',
          label: 'Regular',
          price: 165,
          imageAsset: 'assets/products/chicken-leg-quarter-meal.png',
        ),
      ],
    ),
    MenuProduct(
      id: 'lechon-belly-meal',
      name: 'Lechon Belly Meal',
      description:
          'Crisp lechon belly slices with rice and drippings made for a fast comfort meal.',
      category: 'Rice Meals',
      imageAsset: 'assets/products/lechon-belly-meal.png',
      rating: 4.8,
      prepTime: '12 min',
      variants: [
        ProductVariant(
          id: 'regular',
          label: 'Regular',
          price: 165,
          imageAsset: 'assets/products/lechon-belly-meal.png',
        ),
      ],
    ),
    MenuProduct(
      id: 'chicken-skin-meal',
      name: 'Chicken Skin Meal',
      description:
          'Crunchy seasoned chicken skin with rice for a quick, salty-satisfying bite.',
      category: 'Rice Meals',
      imageAsset: 'assets/products/chicken-skin-meal.png',
      rating: 4.5,
      prepTime: '10 min',
      variants: [
        ProductVariant(
          id: 'regular',
          label: 'Regular',
          price: 75,
          imageAsset: 'assets/products/chicken-skin-meal.png',
        ),
      ],
    ),
    MenuProduct(
      id: 'tuna-panga-meal',
      name: 'Tuna Panga Meal',
      description:
          'Smoky grilled tuna panga paired with rice and bright, savory dipping sauce.',
      category: 'Rice Meals',
      imageAsset: 'assets/products/tuna-panga-meal.png',
      rating: 4.8,
      prepTime: '14 min',
      variants: [
        ProductVariant(
          id: 'regular',
          label: 'Regular',
          price: 205,
          imageAsset: 'assets/products/tuna-panga-meal.png',
        ),
      ],
    ),
    MenuProduct(
      id: 'tuna-belly-meal',
      name: 'Tuna Belly Meal',
      description:
          'Rich tuna belly cut served with rice and char-grilled flavor from the roaster.',
      category: 'Rice Meals',
      imageAsset: 'assets/products/tuna-belly-meal.png',
      rating: 4.8,
      prepTime: '14 min',
      variants: [
        ProductVariant(
          id: 'regular',
          label: 'Regular',
          price: 205,
          imageAsset: 'assets/products/tuna-belly-meal.png',
        ),
      ],
    ),
    MenuProduct(
      id: 'lamyani-ribs-meal',
      name: 'Lamyani Ribs Meal',
      description:
          'Tender signature ribs glazed for a premium rice meal with extra roast flavor.',
      category: 'Rice Meals',
      imageAsset: 'assets/products/lamyani-ribs-meal.png',
      rating: 4.9,
      prepTime: '16 min',
      variants: [
        ProductVariant(
          id: 'regular',
          label: 'Regular',
          price: 300,
          imageAsset: 'assets/products/lamyani-ribs-meal.png',
        ),
      ],
    ),
    MenuProduct(
      id: 'pater-meal',
      name: 'Pater Meal',
      description:
          'A warm rice-based favorite with comforting seasoning and easy everyday value.',
      category: 'Rice Meals',
      imageAsset: 'assets/products/pater-meal.png',
      rating: 4.6,
      prepTime: '10 min',
      variants: [
        ProductVariant(
          id: 'regular',
          label: 'Regular',
          price: 75,
          imageAsset: 'assets/products/pater-meal.png',
        ),
      ],
    ),
    MenuProduct(
      id: 'longsilog',
      name: 'Longsilog',
      description:
          'Classic sweet-savory longganisa with egg and rice for a dependable silog breakfast.',
      category: 'Silog Meals',
      imageAsset: 'assets/products/longsilog.png',
      rating: 4.7,
      prepTime: '10 min',
      variants: [
        ProductVariant(
          id: 'regular',
          label: 'Regular',
          price: 60,
          imageAsset: 'assets/products/longsilog.png',
        ),
      ],
    ),
    MenuProduct(
      id: 'tocilog',
      name: 'Tocilog',
      description:
          'Sweet cured pork, egg, and rice finished with that familiar silog comfort.',
      category: 'Silog Meals',
      imageAsset: 'assets/products/tocilog.png',
      rating: 4.7,
      prepTime: '10 min',
      variants: [
        ProductVariant(
          id: 'regular',
          label: 'Regular',
          price: 110,
          imageAsset: 'assets/products/tocilog.png',
        ),
      ],
    ),
    MenuProduct(
      id: 'baconsilog',
      name: 'Baconsilog',
      description:
          'Crisp bacon strips, sunny egg, and rice for an easy all-day favorite.',
      category: 'Silog Meals',
      imageAsset: 'assets/products/baconsilog.png',
      rating: 4.7,
      prepTime: '10 min',
      variants: [
        ProductVariant(
          id: 'regular',
          label: 'Regular',
          price: 100,
          imageAsset: 'assets/products/baconsilog.png',
        ),
      ],
    ),
    MenuProduct(
      id: 'chorizilog',
      name: 'Chorizilog',
      description:
          'Bold chorizo, egg, and rice with rich seasoning built for heavier appetites.',
      category: 'Silog Meals',
      imageAsset: 'assets/products/chorizilog.png',
      rating: 4.7,
      prepTime: '10 min',
      variants: [
        ProductVariant(
          id: 'regular',
          label: 'Regular',
          price: 110,
          imageAsset: 'assets/products/chorizilog.png',
        ),
      ],
    ),
    MenuProduct(
      id: 'sisigsilog',
      name: 'Sisigsilog',
      description:
          'Sizzling sisig paired with egg and rice for a savory, crunchy silog combo.',
      category: 'Silog Meals',
      imageAsset: 'assets/products/sisigsilog.png',
      rating: 4.8,
      prepTime: '11 min',
      variants: [
        ProductVariant(
          id: 'regular',
          label: 'Regular',
          price: 99,
          imageAsset: 'assets/products/sisigsilog.png',
        ),
      ],
    ),
    MenuProduct(
      id: 'lechon-manok',
      name: 'Lechon Manok',
      description:
          'Whole roasted chicken with juicy meat and citrus-garlic flavor for sharing.',
      category: 'Solo Orders',
      imageAsset: 'assets/products/lechon-manok.png',
      rating: 4.8,
      prepTime: '18 min',
      variants: [
        ProductVariant(
          id: 'whole',
          label: 'Whole',
          price: 320,
          imageAsset: 'assets/products/lechon-manok.png',
        ),
      ],
    ),
    MenuProduct(
      id: 'liempo',
      name: 'Liempo',
      description:
          'Char-roasted pork belly with smoky edges and tender slices ready for solo orders.',
      category: 'Solo Orders',
      imageAsset: 'assets/products/liempo.png',
      rating: 4.8,
      prepTime: '16 min',
      variants: [
        ProductVariant(
          id: 'regular',
          label: 'Regular',
          price: 270,
          imageAsset: 'assets/products/liempo.png',
        ),
      ],
    ),
    MenuProduct(
      id: 'chicken-skin',
      name: 'Chicken Skin',
      description:
          'Crispy roasted chicken skin portion with deep seasoning and extra crunch.',
      category: 'Solo Orders',
      imageAsset: 'assets/products/chicken-skin.png',
      rating: 4.6,
      prepTime: '10 min',
      variants: [
        ProductVariant(
          id: 'regular',
          label: 'Regular',
          price: 150,
          imageAsset: 'assets/products/chicken-skin.png',
        ),
      ],
    ),
    MenuProduct(
      id: 'ginabot',
      name: 'Ginabot',
      description:
          'Crispy pork intestine bites with bold texture and classic street-food flavor.',
      category: 'Solo Orders',
      imageAsset: 'assets/products/ginabot.png',
      rating: 4.6,
      prepTime: '11 min',
      variants: [
        ProductVariant(
          id: 'regular',
          label: 'Regular',
          price: 150,
          imageAsset: 'assets/products/ginabot.png',
        ),
      ],
    ),
    MenuProduct(
      id: 'tuna-belly-regular',
      name: 'Tuna Belly Regular',
      description:
          'A rich grilled tuna belly order with roast marks and fresh-off-the-grill finish.',
      category: 'Solo Orders',
      imageAsset: 'assets/products/tuna-belly-regular.png',
      rating: 4.7,
      prepTime: '14 min',
      variants: [
        ProductVariant(
          id: 'regular',
          label: 'Regular',
          price: 200,
          imageAsset: 'assets/products/tuna-belly-regular.png',
        ),
      ],
    ),
    MenuProduct(
      id: 'lamyani-ribs-solo',
      name: 'Lamyani Ribs Solo',
      description:
          'Premium roasted ribs with a meatier cut and bold glaze for the full ribs experience.',
      category: 'Solo Orders',
      imageAsset: 'assets/products/lamyani-ribs-solo.png',
      rating: 4.9,
      prepTime: '18 min',
      variants: [
        ProductVariant(
          id: 'regular',
          label: 'Regular',
          price: 599,
          imageAsset: 'assets/products/lamyani-ribs-solo.png',
        ),
      ],
    ),
    MenuProduct(
      id: 'sisig',
      name: 'Sisig',
      description:
          'Savory chopped sisig with crisp edges and a punchy finish made for sharing or rice pairings.',
      category: 'Solo Orders',
      imageAsset: 'assets/products/sisig.png',
      rating: 4.8,
      prepTime: '13 min',
      variants: [
        ProductVariant(
          id: 'regular',
          label: 'Regular',
          price: 260,
          imageAsset: 'assets/products/sisig.png',
        ),
      ],
    ),
    MenuProduct(
      id: 'calamares',
      name: 'Calamares',
      description:
          'Crisp fried squid rings with a seafood-forward bite and easy snackability.',
      category: 'Solo Orders',
      imageAsset: 'assets/products/calamares.png',
      rating: 4.7,
      prepTime: '12 min',
      variants: [
        ProductVariant(
          id: 'regular',
          label: 'Regular',
          price: 230,
          imageAsset: 'assets/products/calamares.png',
        ),
      ],
    ),
    MenuProduct(
      id: 'bbq-squid-rings',
      name: 'BBQ Squid Rings',
      description:
          'Tender squid rings with a smoky barbecue finish for a more savory seafood order.',
      category: 'Solo Orders',
      imageAsset: 'assets/products/bbq-squid-rings.png',
      rating: 4.7,
      prepTime: '12 min',
      variants: [
        ProductVariant(
          id: 'regular',
          label: 'Regular',
          price: 230,
          imageAsset: 'assets/products/bbq-squid-rings.png',
        ),
      ],
    ),
    MenuProduct(
      id: 'lechon-baka',
      name: 'Lechon Baka',
      description:
          'Roasted beef order with deep drippings and hearty slices for sharing or pairing.',
      category: 'Solo Orders',
      imageAsset: 'assets/products/lechon-baka.png',
      rating: 4.7,
      prepTime: '16 min',
      variants: [
        ProductVariant(
          id: 'regular',
          label: 'Regular',
          price: 350,
          imageAsset: 'assets/products/lechon-baka.png',
        ),
      ],
    ),
    MenuProduct(
      id: 'extra-rice',
      name: 'Extra Rice',
      description:
          'Extra steamed rice to complete heavier roast orders and sharing trays.',
      category: 'Sides',
      imageAsset: 'assets/products/extra-rice.png',
      rating: 4.6,
      prepTime: '5 min',
      variants: [
        ProductVariant(
          id: 'cup',
          label: 'Cup',
          price: 30,
          imageAsset: 'assets/products/extra-rice.png',
        ),
      ],
    ),
    MenuProduct(
      id: 'coke',
      name: 'Coke',
      description:
          'Cold Coca-Cola ready to pair with roasted meals and barkada orders.',
      category: 'Drinks',
      imageAsset: 'assets/products/coke.png',
      rating: 4.6,
      prepTime: '2 min',
      variants: [
        ProductVariant(
          id: 'regular',
          label: 'Bottle',
          price: 35,
          imageAsset: 'assets/products/coke.png',
        ),
      ],
    ),
    MenuProduct(
      id: 'sprite',
      name: 'Sprite',
      description:
          'A chilled lemon-lime drink that cuts through richer roast and grill flavors.',
      category: 'Drinks',
      imageAsset: 'assets/products/sprite.png',
      rating: 4.6,
      prepTime: '2 min',
      variants: [
        ProductVariant(
          id: 'regular',
          label: 'Bottle',
          price: 35,
          imageAsset: 'assets/products/sprite.png',
        ),
      ],
    ),
    MenuProduct(
      id: 'royal',
      name: 'Royal',
      description:
          'Classic orange soda with a sweet citrus finish for combo-ready meals.',
      category: 'Drinks',
      imageAsset: 'assets/products/royal.png',
      rating: 4.6,
      prepTime: '2 min',
      variants: [
        ProductVariant(
          id: 'regular',
          label: 'Bottle',
          price: 35,
          imageAsset: 'assets/products/royal.png',
        ),
      ],
    ),
    MenuProduct(
      id: 'mineral-water',
      name: 'Mineral Water',
      description:
          'Cold bottled water for a clean, neutral drink option with any meal.',
      category: 'Drinks',
      imageAsset: 'assets/products/mineral-water.png',
      rating: 4.5,
      prepTime: '2 min',
      variants: [
        ProductVariant(
          id: 'regular',
          label: 'Bottle',
          price: 30,
          imageAsset: 'assets/products/mineral-water.png',
        ),
      ],
    ),
  ];

  static final featuredProducts = [
    productById('lechon-belly'),
    productById('lechon-manok'),
    productById('liempo'),
    productById('lamyani-ribs-solo'),
  ];

  static MenuProduct productById(String id) =>
      products.firstWhere((product) => product.id == id);

  // Coordinates are approximate where the official site only lists the branch
  // area or landmark instead of a full street address.
  static const stores = [
    StoreItem(
      name: 'Lamyani Kasambagan',
      address: 'Kasambagan, Cebu City',
      distance: 'Cebu branch',
      isOpen: true,
      statusLabel: 'Open',
      region: 'Cebu',
      imageUrl:
          'https://images.unsplash.com/photo-1552566626-52f8b828add9?auto=format&fit=crop&w=900&q=80',
      latitude: 10.3250945,
      longitude: 123.9113295,
      hours: '9:00 AM - 10:00 PM',
      manager: 'Ariel Migallen',
      productCount: 29,
      nextPromo: 'Weekend Lechon Push',
    ),
    StoreItem(
      name: 'Lamyani Minglanilla',
      address: 'Minglanilla, Cebu',
      distance: 'Cebu branch',
      isOpen: false,
      statusLabel: 'Temporarily Closed',
      region: 'Cebu',
      imageUrl:
          'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=900&q=80',
      latitude: 10.2460294,
      longitude: 123.7960578,
      hours: 'Temporarily Closed',
      manager: 'Pending reassignment',
      productCount: 12,
      nextPromo: 'No live campaign',
    ),
    StoreItem(
      name: 'Lamyani C. Rodriguez',
      address: 'Back of Chong Hua Hospital, Cebu City',
      distance: 'Cebu branch',
      isOpen: true,
      statusLabel: 'Open',
      region: 'Cebu',
      imageUrl:
          'https://images.unsplash.com/photo-1559339352-11d035aa65de?auto=format&fit=crop&w=900&q=80',
      latitude: 10.3100529,
      longitude: 123.8911150,
      hours: '10:00 AM - 9:30 PM',
      manager: 'Joan Villarin',
      productCount: 24,
      nextPromo: 'Silog Morning Set',
    ),
    StoreItem(
      name: 'Lamyani Calapan',
      address: 'Calapan, Oriental Mindoro',
      distance: 'Mindoro branch',
      isOpen: true,
      statusLabel: 'Open',
      region: 'Mindoro',
      imageUrl:
          'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=900&q=80',
      latitude: 13.4145513,
      longitude: 121.1795430,
      hours: '9:30 AM - 9:00 PM',
      manager: 'Denise Salarda',
      productCount: 19,
      nextPromo: 'Family Roast Launch',
    ),
    StoreItem(
      name: 'Lamyani Naujan',
      address: 'Naujan, Oriental Mindoro',
      distance: 'Mindoro branch',
      isOpen: true,
      statusLabel: 'Open',
      region: 'Mindoro',
      imageUrl:
          'https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?auto=format&fit=crop&w=900&q=80',
      latitude: 13.3242390,
      longitude: 121.3030659,
      hours: '9:00 AM - 8:30 PM',
      manager: 'Miko Aralar',
      productCount: 18,
      nextPromo: 'Breakfast Combo Push',
    ),
    StoreItem(
      name: 'Lamyani Baco',
      address: 'Baco, Oriental Mindoro',
      distance: 'Mindoro branch',
      isOpen: true,
      statusLabel: 'Open',
      region: 'Mindoro',
      imageUrl:
          'https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?auto=format&fit=crop&w=900&q=80',
      latitude: 13.3581031,
      longitude: 121.0963319,
      hours: '10:00 AM - 8:30 PM',
      manager: 'Cris Mamaril',
      productCount: 16,
      nextPromo: 'Barkada Grill Bundle',
    ),
    StoreItem(
      name: 'Lamyani Signal Village',
      address: 'Central Signal Village, Taguig',
      distance: 'Metro Manila branch',
      isOpen: true,
      statusLabel: 'Open',
      region: 'Metro Manila',
      imageUrl:
          'https://images.unsplash.com/photo-1552566626-52f8b828add9?auto=format&fit=crop&w=900&q=80',
      latitude: 14.5116817,
      longitude: 121.0559372,
      hours: '10:00 AM - 10:00 PM',
      manager: 'J. de Leon',
      productCount: 21,
      nextPromo: 'Metro Pilot Drop',
    ),
    StoreItem(
      name: 'Lamyani Carmona',
      address: 'Carmona, Cavite',
      distance: 'Cavite branch',
      isOpen: false,
      statusLabel: 'Opening Soon',
      region: 'Cavite',
      imageUrl:
          'https://images.unsplash.com/photo-1514933651103-005eec06c04b?auto=format&fit=crop&w=900&q=80',
      latitude: 14.3134594,
      longitude: 121.0574345,
      hours: 'Opening Soon',
      manager: 'Pending launch team',
      productCount: 0,
      nextPromo: 'Grand opening soon',
    ),
  ];
}
