import 'dart:async';
import 'package:flutter/material.dart';
import '../models/weather_models.dart';
import '../services/weather_service.dart';

class CitySearchModal extends StatefulWidget {
  final WeatherService weatherService;
  final Function(CityLocation) onCitySelected;

  const CitySearchModal({
    super.key,
    required this.weatherService,
    required this.onCitySelected,
  });

  static Future<void> show(
    BuildContext context, {
    required WeatherService weatherService,
    required Function(CityLocation) onCitySelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CitySearchModal(
        weatherService: weatherService,
        onCitySelected: onCitySelected,
      ),
    );
  }

  @override
  State<CitySearchModal> createState() => _CitySearchModalState();
}

class _CitySearchModalState extends State<CitySearchModal> {
  final TextEditingController _searchController = TextEditingController();
  List<CityLocation> _results = [];
  bool _isLoading = false;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _isLoading = true);
      try {
        final cities = await widget.weatherService.searchCities(query);
        if (mounted) {
          setState(() {
            _results = cities;
            _isLoading = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Change Location',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search input field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.08),
                hintText: 'Search city (e.g., Tokyo, London, Paris)...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF64B5F6), width: 1.5),
                ),
              ),
            ),
          ),

          // Popular quick picks (horizontal chips)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'POPULAR CITIES',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: WeatherService.defaultCities.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final city = WeatherService.defaultCities[index];
                return ActionChip(
                  label: Text(
                    city.name,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onPressed: () {
                    widget.onCitySelected(city);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 12),
          const Divider(color: Colors.white12, height: 1),

          // Search results or loading
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF64B5F6)),
                  )
                : _searchController.text.trim().isEmpty
                    ? ListView.builder(
                        itemCount: WeatherService.defaultCities.length,
                        itemBuilder: (context, index) {
                          final city = WeatherService.defaultCities[index];
                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.location_city_rounded, color: Color(0xFF64B5F6), size: 20),
                            ),
                            title: Text(
                              city.name,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              city.country,
                              style: const TextStyle(color: Colors.white60, fontSize: 13),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 14),
                            onTap: () {
                              widget.onCitySelected(city);
                              Navigator.pop(context);
                            },
                          );
                        },
                      )
                    : _results.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off_rounded, size: 48, color: Colors.white.withValues(alpha: 0.3)),
                                const SizedBox(height: 12),
                                Text(
                                  'No locations found for "${_searchController.text}"',
                                  style: const TextStyle(color: Colors.white60),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: _results.length,
                            separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
                            itemBuilder: (context, index) {
                              final city = _results[index];
                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.pin_drop_rounded, color: Color(0xFFFFB74D), size: 20),
                                ),
                                title: Text(
                                  city.name,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  [
                                    if (city.admin1 != null && city.admin1!.isNotEmpty) city.admin1,
                                    city.country,
                                  ].join(', '),
                                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 14),
                                onTap: () {
                                  widget.onCitySelected(city);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
