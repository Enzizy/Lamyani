import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import 'mock_data.dart';

class BranchMapScreen extends StatefulWidget {
  const BranchMapScreen({
    super.key,
    required this.stores,
    required this.onOrderTap,
    this.currentPosition,
    this.initialStore,
  });

  final List<StoreItem> stores;
  final VoidCallback onOrderTap;
  final Position? currentPosition;
  final StoreItem? initialStore;

  @override
  State<BranchMapScreen> createState() => _BranchMapScreenState();
}

class _BranchMapScreenState extends State<BranchMapScreen> {
  late final MapController _mapController;
  late StoreItem _selectedStore;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedStore = widget.initialStore ?? widget.stores.first;
  }

  LatLng get _initialCenter {
    final position = widget.currentPosition;
    if (position != null) {
      return LatLng(position.latitude, position.longitude);
    }
    return LatLng(_selectedStore.latitude, _selectedStore.longitude);
  }

  void _focusStore(StoreItem store) {
    setState(() => _selectedStore = store);
    _mapController.move(LatLng(store.latitude, store.longitude), 14.8);
  }

  void _focusCurrentLocation() {
    final position = widget.currentPosition;
    if (position == null) {
      return;
    }
    _mapController.move(LatLng(position.latitude, position.longitude), 14.5);
  }

  @override
  Widget build(BuildContext context) {
    final position = widget.currentPosition;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 13.4,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.lamyani',
              ),
              MarkerLayer(
                markers: [
                  if (position != null)
                    Marker(
                      point: LatLng(position.latitude, position.longitude),
                      width: 64,
                      height: 64,
                      child: const _UserLocationMarker(),
                    ),
                  for (final store in widget.stores)
                    Marker(
                      point: LatLng(store.latitude, store.longitude),
                      width: 124,
                      height: 88,
                      child: _StoreMapMarker(
                        store: store,
                        selected: store.name == _selectedStore.name,
                        onTap: () => _focusStore(store),
                      ),
                    ),
                ],
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              child: Column(
                children: [
                  Row(
                    children: [
                      Material(
                        color: AppColors.white,
                        shape: const CircleBorder(),
                        elevation: 1,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.96),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Lamyani Branch Map',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Explore stores without Google Maps billing',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (position != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FloatingActionButton.small(
                          heroTag: 'my-location',
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.primaryOrange,
                          onPressed: _focusCurrentLocation,
                          child: const Icon(Icons.my_location_rounded),
                        ),
                      ],
                    ),
                  const SizedBox(height: 14),
                  _SelectedBranchSheet(
                    store: _selectedStore,
                    currentPosition: position,
                    onDirectionsTap: () =>
                        LocationService.openDirections(_selectedStore),
                    onOrderTap: widget.onOrderTap,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreMapMarker extends StatelessWidget {
  const _StoreMapMarker({
    required this.store,
    required this.selected,
    required this.onTap,
  });

  final StoreItem store;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryOrange : AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.softShadow,
            ),
            child: Text(
              store.name.replaceFirst('Lamyani ', ''),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: selected ? AppColors.white : AppColors.darkText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primaryOrange
                  : AppColors.yellowAccent,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 3),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserLocationMarker extends StatelessWidget {
  const _UserLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: const Color(0xFF2C7CF6),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white, width: 4),
          boxShadow: AppTheme.softShadow,
        ),
      ),
    );
  }
}

class _SelectedBranchSheet extends StatelessWidget {
  const _SelectedBranchSheet({
    required this.store,
    required this.currentPosition,
    required this.onDirectionsTap,
    required this.onOrderTap,
  });

  final StoreItem store;
  final Position? currentPosition;
  final VoidCallback onDirectionsTap;
  final VoidCallback onOrderTap;

  @override
  Widget build(BuildContext context) {
    final distanceLabel = currentPosition == null
        ? store.distance
        : LocationService.formatDistanceKm(
            LocationService.distanceInKm(
              fromLatitude: currentPosition!.latitude,
              fromLongitude: currentPosition!.longitude,
              toLatitude: store.latitude,
              toLongitude: store.longitude,
            ),
          );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  store.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: store.isOpen
                      ? const Color(0x142E8B57)
                      : const Color(0x14C44D34),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  store.statusLabel,
                  style: TextStyle(
                    color: store.isOpen ? AppColors.success : AppColors.danger,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(store.address, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoPill(icon: Icons.place_outlined, label: distanceLabel),
              _InfoPill(
                icon: Icons.location_city_outlined,
                label: store.region,
              ),
              _InfoPill(
                icon: Icons.schedule_rounded,
                label: store.hours,
              ),
              if (store.productCount > 0)
                _InfoPill(
                  icon: Icons.restaurant_menu_rounded,
                  label: '${store.productCount} items',
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Branch rollout',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manager: ${store.manager}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Next promo: ${store.nextPromo}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Directions',
                  backgroundColor: AppColors.peachSurface,
                  foregroundColor: AppColors.brownAccent,
                  onPressed: onDirectionsTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  label: 'Order Here',
                  onPressed: onOrderTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
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
