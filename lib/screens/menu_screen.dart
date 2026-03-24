import 'package:flutter/material.dart';

import '../services/catalog_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cart_action_button.dart';
import '../widgets/category_chip.dart';
import '../widgets/food_card.dart';
import 'mock_data.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({
    super.key,
    required this.onProductTap,
    required this.onCartTap,
  });

  final ValueChanged<MenuProduct> onProductTap;
  final VoidCallback onCartTap;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  _MenuSortOption _sortOption = _MenuSortOption.bestSellers;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Menu'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CartActionButton(
              onTap: widget.onCartTap,
              size: 46,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: StreamBuilder<List<MenuProduct>>(
            stream: CatalogService.streamProducts(),
            builder: (context, snapshot) {
              final products = snapshot.data ?? MockData.products;
              final categories = CatalogService.categoriesFor(products);
              final selectedCategory = categories.contains(_selectedCategory)
                  ? _selectedCategory
                  : 'All';
              final query = _searchController.text.toLowerCase();
              final filteredItems = products.where((item) {
                final matchesCategory = selectedCategory == 'All' ||
                    item.category == selectedCategory;
                final matchesQuery =
                    item.name.toLowerCase().contains(query) ||
                    item.description.toLowerCase().contains(query) ||
                    item.variants.any(
                      (variant) => variant.label.toLowerCase().contains(query),
                    );
                return matchesCategory && matchesQuery;
              }).toList()
                ..sort((left, right) => _compareProducts(left, right));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search lechon, liempo, rice meals...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(right: 20),
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return CategoryChip(
                      label: category,
                      selected: selectedCategory == category,
                      compact: true,
                      onTap: () => setState(() => _selectedCategory = category),
                    );
                  },
                ),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.peachSurface.withValues(alpha: 0.95),
                  ),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${filteredItems.length} items available',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: AppColors.brownAccent),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Sorted by ${_sortOption.label.toLowerCase()}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.mutedText,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    PopupMenuButton<_MenuSortOption>(
                      initialValue: _sortOption,
                      onSelected: (value) => setState(() => _sortOption = value),
                      itemBuilder: (context) => _MenuSortOption.values
                          .map(
                            (option) => PopupMenuItem<_MenuSortOption>(
                              value: option,
                              child: Text(option.label),
                            ),
                          )
                          .toList(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.peachSurface.withValues(
                              alpha: 0.95,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.swap_vert_rounded,
                              size: 16,
                              color: AppColors.primaryOrange,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _sortOption.shortLabel,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.darkText,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filteredItems.isEmpty
                    ? _EmptyMenuState(
                        onReset: () {
                          _searchController.clear();
                          setState(() {
                            _selectedCategory = 'All';
                          });
                        },
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          const spacing = 12.0;
                          final cardWidth =
                              (constraints.maxWidth - spacing) / 2;
                          final mainAxisExtent = cardWidth +
                              (constraints.maxWidth < 380 ? 128 : 136);

                          return GridView.builder(
                            padding: const EdgeInsets.only(bottom: 12),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: spacing,
                              mainAxisExtent: mainAxisExtent,
                            ),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              return FoodCard(
                                item: item,
                                compact: true,
                                onTap: () => widget.onProductTap(item),
                                onAddTap: () => widget.onProductTap(item),
                              );
                            },
                          );
                        },
                      ),
              ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  int _compareProducts(MenuProduct left, MenuProduct right) {
    switch (_sortOption) {
      case _MenuSortOption.bestSellers:
        return right.rating.compareTo(left.rating);
      case _MenuSortOption.priceLowToHigh:
        return left.startingPrice.compareTo(right.startingPrice);
      case _MenuSortOption.priceHighToLow:
        return right.startingPrice.compareTo(left.startingPrice);
      case _MenuSortOption.fastestPrep:
        return _prepMinutes(
          left.prepTime,
        ).compareTo(_prepMinutes(right.prepTime));
    }
  }

  int _prepMinutes(String prepTime) {
    final match = RegExp(r'\d+').firstMatch(prepTime);
    return int.tryParse(match?.group(0) ?? '') ?? 999;
  }
}

class _EmptyMenuState extends StatelessWidget {
  const _EmptyMenuState({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.peachSurface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: AppColors.primaryOrange,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No menu items found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Try another search or clear the category filter to see more Lamyani meals.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedText,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reset Filters'),
            ),
          ],
        ),
      ),
    );
  }
}

enum _MenuSortOption {
  bestSellers('Best Sellers', 'Best'),
  priceLowToHigh('Price: Low to High', 'Low'),
  priceHighToLow('Price: High to Low', 'High'),
  fastestPrep('Fastest Prep', 'Fast');

  const _MenuSortOption(this.label, this.shortLabel);

  final String label;
  final String shortLabel;
}
