import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../services/catalog_service.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../widgets/section_title.dart';
import '../widgets/store_card.dart';
import 'branch_map_screen.dart';
import 'mock_data.dart';

class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key, required this.onOrderTap});

  final VoidCallback onOrderTap;

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  final TextEditingController _searchController = TextEditingController();

  Position? _currentPosition;
  bool _loadingLocation = true;
  String? _locationMessage;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLocation() async {
    setState(() {
      _loadingLocation = true;
      _locationMessage = null;
    });

    try {
      final position = await LocationService.getCurrentPosition();
      if (!mounted) return;
      setState(() => _currentPosition = position);
    } catch (error) {
      if (!mounted) return;
      final message = error is LocationException
          ? error.message
          : 'Unable to get your current location right now.';
      setState(() => _locationMessage = message);
    } finally {
      if (mounted) {
        setState(() => _loadingLocation = false);
      }
    }
  }

  double? _distanceInKm(StoreItem store) {
    final position = _currentPosition;
    if (position == null) {
      return null;
    }

    return LocationService.distanceInKm(
      fromLatitude: position.latitude,
      fromLongitude: position.longitude,
      toLatitude: store.latitude,
      toLongitude: store.longitude,
    );
  }

  String _distanceLabel(StoreItem store) {
    final distanceKm = _distanceInKm(store);
    if (distanceKm == null) {
      return store.distance;
    }
    return '${LocationService.formatDistanceKm(distanceKm)} from you';
  }

  void _openMap(List<StoreItem> stores, {StoreItem? initialStore}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BranchMapScreen(
          stores: stores,
          currentPosition: _currentPosition,
          initialStore: initialStore,
          onOrderTap: widget.onOrderTap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Stores')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: StreamBuilder<List<StoreItem>>(
            stream: CatalogService.streamStores(),
            builder: (context, snapshot) {
              final stores = snapshot.data ?? MockData.stores;
              final query = _searchController.text.toLowerCase();
              final filteredStores = stores.where((store) {
                return store.name.toLowerCase().contains(query) ||
                    store.address.toLowerCase().contains(query);
              }).toList()
                ..sort((a, b) {
                  final aDistance = _distanceInKm(a);
                  final bDistance = _distanceInKm(b);

                  if (aDistance == null && bDistance == null) return 0;
                  if (aDistance == null) return 1;
                  if (bDistance == null) return -1;
                  return aDistance.compareTo(bDistance);
                });

              final mapCenter = _currentPosition != null
                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  : LatLng(stores.first.latitude, stores.first.longitude);
              final openCount =
                  filteredStores.where((store) => store.isOpen).length;
              final regionCounts = <String, int>{};
              for (final store in filteredStores) {
                regionCounts.update(
                  store.region,
                  (count) => count + 1,
                  ifAbsent: () => 1,
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.peachSurface.withValues(alpha: 0.9),
                      ),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(
                          title: 'Visit a branch',
                          subtitle:
                              'Official branch list based on Lamyani website locations',
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _RegionChip(
                              label: 'Visible branches',
                              count: filteredStores.length,
                            ),
                            _RegionChip(
                              label: 'Open today',
                              count: openCount,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SizedBox(
                            height: 210,
                            child: Stack(
                              children: [
                                IgnorePointer(
                                  child: FlutterMap(
                                    options: MapOptions(
                                      initialCenter: mapCenter,
                                      initialZoom: 12.8,
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        userAgentPackageName:
                                            'com.example.lamyani',
                                      ),
                                      MarkerLayer(
                                        markers: [
                                          if (_currentPosition != null)
                                            Marker(
                                              point: LatLng(
                                                _currentPosition!.latitude,
                                                _currentPosition!.longitude,
                                              ),
                                              width: 20,
                                              height: 20,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFF2C7CF6,
                                                  ),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: AppColors.white,
                                                    width: 3,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          for (final store in filteredStores)
                                            Marker(
                                              point: LatLng(
                                                store.latitude,
                                                store.longitude,
                                              ),
                                              width: 64,
                                              height: 64,
                                              child: const Icon(
                                                Icons.location_on_rounded,
                                                color: AppColors.primaryOrange,
                                                size: 34,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.darkText.withValues(
                                          alpha: 0.08,
                                        ),
                                        Colors.transparent,
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  right: 12,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.white.withValues(
                                              alpha: 0.96,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Text(
                                            _loadingLocation
                                                ? 'Finding your location...'
                                                : _locationMessage ??
                                                    'Showing nearest Lamyani branches',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: AppColors.darkText,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Material(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        child: InkWell(
                                          onTap: () => _openMap(filteredStores),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Icon(
                                              Icons.open_in_full_rounded,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: regionCounts.entries
                              .map(
                                (entry) => _RegionChip(
                                  label: entry.key,
                                  count: entry.value,
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed:
                                    _loadingLocation ? null : _loadLocation,
                                icon: const Icon(Icons.my_location_rounded),
                                label: const Text('Use My Location'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () => _openMap(filteredStores),
                                icon: const Icon(Icons.map_rounded),
                                label: const Text('Open Map'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search by branch or area',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.peachSurface.withValues(alpha: 0.95),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${filteredStores.length} stores found',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppColors.brownAccent),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Nearest branches are ranked using your current device location when available.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.mutedText,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filteredStores.isEmpty
                        ? _EmptyStoresState(
                            onReset: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : ListView.separated(
                            itemCount: filteredStores.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 20),
                            itemBuilder: (context, index) {
                              final store = filteredStores[index];
                              return StoreCard(
                                store: store,
                                distanceLabel: _distanceLabel(store),
                                onDirectionsTap: () =>
                                    LocationService.openDirections(store),
                                onOrderTap: widget.onOrderTap,
                                onMapTap: () =>
                                    _openMap(filteredStores, initialStore: store),
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
}

class _RegionChip extends StatelessWidget {
  const _RegionChip({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label · $count',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.darkText,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyStoresState extends StatelessWidget {
  const _EmptyStoresState({required this.onReset});

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
                Icons.storefront_rounded,
                color: AppColors.primaryOrange,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No branches found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different branch or area search to see nearby Lamyani locations.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedText,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reset Search'),
            ),
          ],
        ),
      ),
    );
  }
}
