import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/catalog_service.dart';
import '../services/cart_controller.dart';
import '../services/order_service.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import '../widgets/app_image.dart';
import '../widgets/primary_button.dart';
import 'login_screen.dart';
import 'mock_data.dart';
import 'order_history_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.onBrowseMenu});

  final VoidCallback onBrowseMenu;

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);

    return AnimatedBuilder(
      animation: cart,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Your Cart')),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                children: [
                  _CartHero(cart: cart),
                  const SizedBox(height: 18),
                  Expanded(
                    child: cart.isEmpty
                        ? _EmptyCart(onContinueTap: onBrowseMenu)
                        : ListView.separated(
                            itemCount: cart.entries.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final entry = cart.entries[index];
                              return Dismissible(
                                key: ValueKey(entry.selection.id),
                                direction: DismissDirection.endToStart,
                                background: const _SwipeRemoveBackground(),
                                onDismissed: (_) => _removeEntry(
                                  context,
                                  cart,
                                  entry,
                                ),
                                child: _CartItemCard(
                                  entry: entry,
                                  onIncrement: () =>
                                      cart.increment(entry.selection.id),
                                  onDecrement: entry.quantity > 1
                                      ? () => cart.decrement(entry.selection.id)
                                      : null,
                                  onRemove: () =>
                                      _removeEntry(context, cart, entry),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 18),
                  _CartSummary(
                    cart: cart,
                    onCheckout: cart.isEmpty
                        ? null
                        : () => _checkout(context, cart),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _removeEntry(
    BuildContext context,
    CartController cart,
    CartEntry entry,
  ) {
    final removedQuantity = entry.quantity;
    cart.remove(entry.selection.id);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${entry.selection.name}${entry.selection.variantLabel == null ? '' : ' (${entry.selection.variantLabel})'} removed from cart',
          ),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              cart.restore(entry.selection, removedQuantity);
            },
          ),
        ),
      );
  }

  Future<void> _checkout(BuildContext context, CartController cart) async {
    if (!AuthService.isAvailable || AuthService.currentUser == null) {
      await _showGuestCheckoutSheet(context);
      return;
    }

    final result = await showModalBottomSheet<_CheckoutResult>(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => _CheckoutSheet(cart: cart),
    );

    if (result == null || !context.mounted) {
      return;
    }

    cart.clear();
    await _showOrderPlacedSheet(context, result);
    if (context.mounted) {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _showGuestCheckoutSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.peachSurface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: AppColors.peachSurface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.lock_person_rounded,
                    color: AppColors.primaryOrange,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Sign in to place your order',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Guest browsing is enabled, but checkout and order history are tied to your Lamyani account.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Log In',
                  icon: Icons.login_rounded,
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(AppMotion.route(const LoginScreen()));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showOrderPlacedSheet(
    BuildContext context,
    _CheckoutResult result,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.peachSurface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.peachSurface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 40,
                    color: AppColors.primaryOrange,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Order placed',
                  style: Theme.of(sheetContext).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${result.itemCount} item${result.itemCount == 1 ? '' : 's'} sent to ${result.branchName}. You can follow the order in your history.',
                  textAlign: TextAlign.center,
                  style: Theme.of(sheetContext).textTheme.bodyLarge?.copyWith(
                    color: AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    children: [
                      _CheckoutSummaryRow(
                        label: 'Order ID',
                        value: result.orderId.substring(0, 6).toUpperCase(),
                      ),
                      const SizedBox(height: 10),
                      _CheckoutSummaryRow(
                        label: 'Total',
                        value: '\u20B1${result.total.toStringAsFixed(0)}',
                        highlight: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'View Orders',
                  icon: Icons.receipt_long_rounded,
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context)
                        .push(AppMotion.route(const OrderHistoryScreen()));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CheckoutSheet extends StatefulWidget {
  const _CheckoutSheet({required this.cart});

  final CartController cart;

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  StoreItem? _selectedStore;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return StreamBuilder<List<StoreItem>>(
      stream: CatalogService.streamStores(),
      builder: (context, snapshot) {
        final stores = snapshot.data ?? const <StoreItem>[];
        final openStores = stores.where((store) => store.isOpen).toList(growable: false);
        final availableStores = openStores.isEmpty ? stores : openStores;

        if (availableStores.isNotEmpty &&
            (_selectedStore == null ||
                !availableStores.any((store) => store.name == _selectedStore!.name))) {
          _selectedStore = availableStores.first;
        }

        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              24 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Center(
              child: Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.peachSurface,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text('Checkout', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Confirm the branch handling your order before we send it to Firebase.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.mutedText,
              ),
            ),
            const SizedBox(height: 18),
            _CheckoutPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ordering as',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user?.email ?? 'Guest',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Choose branch',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            if (availableStores.isEmpty)
              _CheckoutPanel(
                child: Text(
                  'No branches are available yet. Add branch records in Firestore or keep the local fallback active.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.mutedText,
                  ),
                ),
              )
            else
              DropdownButtonFormField<StoreItem>(
                initialValue: _selectedStore,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                items: availableStores
                    .map(
                      (store) => DropdownMenuItem<StoreItem>(
                        value: store,
                        child: Text('${store.name} - ${store.region}'),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() => _selectedStore = value);
                },
              ),
            const SizedBox(height: 18),
            if (_selectedStore != null) ...[
              _CheckoutPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedStore!.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_selectedStore!.region} • ${_selectedStore!.hours}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Next promo: ${_selectedStore!.nextPromo}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.darkText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],
            _CheckoutPanel(
              child: Column(
                children: [
                  _CheckoutSummaryRow(
                    label: 'Items',
                    value:
                        '${widget.cart.totalItems} across ${widget.cart.uniqueItems} selections',
                  ),
                  const SizedBox(height: 10),
                  _CheckoutSummaryRow(
                    label: 'Subtotal',
                    value: '\u20B1${widget.cart.subtotal.toStringAsFixed(0)}',
                  ),
                  const SizedBox(height: 10),
                  _CheckoutSummaryRow(
                    label: 'Delivery',
                    value: '\u20B1${widget.cart.deliveryFee.toStringAsFixed(0)}',
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _CheckoutSummaryRow(
                    label: 'Total',
                    value: '\u20B1${widget.cart.total.toStringAsFixed(0)}',
                    highlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: _submitting ? 'Placing Order...' : 'Place Order',
              icon: Icons.check_circle_outline_rounded,
              onPressed: _submitting || _selectedStore == null
                  ? null
                  : () => _placeOrder(_selectedStore!),
            ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _placeOrder(StoreItem selectedStore) async {
    setState(() => _submitting = true);

    try {
      final result = await OrderService.placeOrder(
        entries: widget.cart.entries.toList(growable: false),
        branch: selectedStore,
        subtotal: widget.cart.subtotal,
        deliveryFee: widget.cart.deliveryFee,
        total: widget.cart.total,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(
        _CheckoutResult(
          orderId: result.orderId,
          branchName: result.branchName,
          itemCount: result.itemCount,
          total: result.total,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(AuthService.messageFor(error))),
        );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}

class _CheckoutResult {
  const _CheckoutResult({
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

class _CartHero extends StatelessWidget {
  const _CartHero({required this.cart});

  final CartController cart;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.white, Color(0xFFFFFCF1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cart.isEmpty ? 'Your cart is empty' : 'Ready for checkout',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            cart.isEmpty
                ? 'Add your favorite roasted meals and they will show up here.'
                : '${cart.totalItems} items packed across ${cart.uniqueItems} selections.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.mutedText),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _CartMetaPill(
                icon: Icons.schedule_rounded,
                label: cart.isEmpty ? 'No delivery yet' : '25-35 min',
              ),
              _CartMetaPill(
                icon: Icons.local_shipping_outlined,
                label: cart.deliveryFee == 0
                    ? 'No delivery fee'
                    : '\u20B1${cart.deliveryFee.toStringAsFixed(0)} delivery',
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.peachSurface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: Text(
                '\u20B1${cart.total.toStringAsFixed(0)}',
                key: ValueKey(cart.total.toStringAsFixed(0)),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primaryOrange,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.entry,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final CartEntry entry;
  final VoidCallback onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AppImage(
                  source: entry.selection.imageAsset,
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            entry.selection.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _RemoveButton(onTap: onRemove),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            entry.selection.product.category,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.brownAccent,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        if (entry.selection.variantLabel != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.peachSurface,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              entry.selection.variantLabel!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.primaryOrange,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.selection.product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedText.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\u20B1${entry.selection.unitPrice.toStringAsFixed(0)} each',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\u20B1${entry.lineTotal.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CartQuantityButton(
                      icon: Icons.remove_rounded,
                      backgroundColor: entry.quantity <= 1
                          ? AppColors.peachSurface
                          : AppColors.white,
                      foregroundColor: entry.quantity <= 1
                          ? AppColors.mutedText
                          : AppColors.darkText,
                      onTap: onDecrement,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '${entry.quantity}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    _CartQuantityButton(
                      icon: Icons.add_rounded,
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: AppColors.white,
                      onTap: onIncrement,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CartMetaPill extends StatelessWidget {
  const _CartMetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryOrange),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFEEE9),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(
            Icons.delete_outline_rounded,
            size: 20,
            color: AppColors.danger,
          ),
        ),
      ),
    );
  }
}

class _CartQuantityButton extends StatelessWidget {
  const _CartQuantityButton({
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 18, color: foregroundColor),
        ),
      ),
    );
  }
}

class _SwipeRemoveBackground extends StatelessWidget {
  const _SwipeRemoveBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEE9),
        borderRadius: BorderRadius.circular(24),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 24),
          SizedBox(height: 6),
          Text(
            'Remove',
            style: TextStyle(
              color: AppColors.danger,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.cart, required this.onCheckout});

  final CartController cart;
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Subtotal', value: cart.subtotal),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Delivery Fee', value: cart.deliveryFee),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _SummaryRow(label: 'Total', value: cart.total, highlight: true),
          const SizedBox(height: 18),
          PrimaryButton(
            label: cart.isEmpty ? 'Cart is Empty' : 'Checkout',
            icon: Icons.arrow_forward_rounded,
            onPressed: onCheckout,
          ),
        ],
      ),
    );
  }
}

class _CheckoutPanel extends StatelessWidget {
  const _CheckoutPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: child,
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onContinueTap});

  final VoidCallback onContinueTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28),
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
                Icons.shopping_bag_outlined,
                size: 34,
                color: AppColors.primaryOrange,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No meals in your cart yet',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your favorite lechon, liempo, or rice meals to continue.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Continue Ordering',
              expanded: false,
              onPressed: onContinueTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final double value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final style = highlight
        ? Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: AppColors.primaryOrange)
        : Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            color: AppColors.darkText,
          );

    return Row(
      children: [
        Text(label, style: style),
        const Spacer(),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Text(
            '\u20B1${value.toStringAsFixed(0)}',
            key: ValueKey('$label-${value.toStringAsFixed(0)}'),
            style: style,
          ),
        ),
      ],
    );
  }
}

class _CheckoutSummaryRow extends StatelessWidget {
  const _CheckoutSummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: highlight ? AppColors.primaryOrange : AppColors.darkText,
            fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: highlight ? AppColors.primaryOrange : AppColors.darkText,
          ),
        ),
      ],
    );
  }
}
