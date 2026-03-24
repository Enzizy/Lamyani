import 'package:flutter/material.dart';

import '../services/cart_controller.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'menu_screen.dart';
import 'mock_data.dart';
import 'product_details_screen.dart';
import 'profile_screen.dart';
import 'stores_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  final CartController _cart = CartController();
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(
        onProductTap: _openProduct,
        onCartTap: _openCart,
        onViewMenuTap: () => _goToTab(1),
      ),
      MenuScreen(onProductTap: _openProduct, onCartTap: _openCart),
      StoresScreen(onOrderTap: () => _goToTab(1)),
      const ProfileScreen(),
    ];
  }

  void _openProduct(MenuProduct item) {
    Navigator.of(
      context,
    ).push(
      AppMotion.route(
        CartScope(
          notifier: _cart,
          child: ProductDetailsScreen(
            item: item,
            onCartTap: _openCart,
          ),
        ),
      ),
    );
  }

  void _openCart() {
    Navigator.of(context).push(
      AppMotion.route(
        CartScope(
          notifier: _cart,
          child: CartScreen(
            onBrowseMenu: () {
              Navigator.of(context).maybePop();
              _goToTab(1);
            },
          ),
        ),
      ),
    );
  }

  void _goToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return CartScope(
      notifier: _cart,
      child: Scaffold(
        body: Stack(
          children: List.generate(_pages.length, (index) {
            final active = index == _currentIndex;

            return IgnorePointer(
              ignoring: !active,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                opacity: active ? 1 : 0,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 360),
                  curve: Curves.easeOutCubic,
                  offset: active ? Offset.zero : const Offset(0.03, 0),
                  child: TickerMode(enabled: active, child: _pages[index]),
                ),
              ),
            );
          }),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: AppColors.peachSurface.withValues(alpha: 0.95),
                ),
                boxShadow: AppTheme.softShadow,
              ),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  backgroundColor: Colors.transparent,
                  indicatorColor: AppColors.peachSurface,
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    return TextStyle(
                      color: states.contains(WidgetState.selected)
                          ? AppColors.darkText
                          : AppColors.mutedText,
                      fontWeight: states.contains(WidgetState.selected)
                          ? FontWeight.w800
                          : FontWeight.w600,
                    );
                  }),
                ),
                child: NavigationBar(
                  selectedIndex: _currentIndex,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  height: 74,
                  indicatorShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  animationDuration: const Duration(milliseconds: 450),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_rounded),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.restaurant_menu_outlined),
                      selectedIcon: Icon(Icons.restaurant_menu_rounded),
                      label: 'Menu',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.storefront_outlined),
                      selectedIcon: Icon(Icons.storefront_rounded),
                      label: 'Stores',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline_rounded),
                      selectedIcon: Icon(Icons.person_rounded),
                      label: 'Profile',
                    ),
                  ],
                  onDestinationSelected: _goToTab,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
