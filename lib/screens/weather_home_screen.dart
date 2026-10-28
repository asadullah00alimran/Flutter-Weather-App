import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_models.dart';
import '../services/weather_service.dart';
import '../utils/weather_utils.dart';
import '../widgets/hourly_forecast_widget.dart';
import '../widgets/daily_forecast_widget.dart';
import '../widgets/weather_details_grid.dart';
import '../widgets/sun_card.dart';
import '../widgets/weather_advice_card.dart';
import '../widgets/city_search_modal.dart';

class WeatherHomeScreen extends StatefulWidget {
  const WeatherHomeScreen({super.key});

  @override
  State<WeatherHomeScreen> createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends State<WeatherHomeScreen> with SingleTickerProviderStateMixin {
  final WeatherService _weatherService = WeatherService();

  CityLocation _selectedCity = WeatherService.defaultCities[0]; // London default
  FullWeatherData? _weatherData;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isCelsius = true;

  late AnimationController _refreshAnimController;

  @override
  void initState() {
    super.initState();
    _refreshAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _loadWeather();
  }

  @override
  void dispose() {
    _refreshAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadWeather({bool isRefresh = false}) async {
    if (isRefresh) {
      _refreshAnimController.repeat();
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final data = await _weatherService.fetchWeather(_selectedCity);
      if (mounted) {
        setState(() {
          _weatherData = data;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not fetch weather. Showing cached data.';
          _isLoading = false;
        });
      }
    } finally {
      if (mounted && isRefresh) {
        _refreshAnimController.stop();
        _refreshAnimController.reset();
      }
    }
  }

  void _onCityChanged(CityLocation city) {
    if (_selectedCity.name == city.name && _selectedCity.country == city.country) return;
    setState(() {
      _selectedCity = city;
    });
    _loadWeather();
  }

  void _openCitySearch() {
    CitySearchModal.show(
      context,
      weatherService: _weatherService,
      onCitySelected: _onCityChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentWeather = _weatherData?.current;
    final conditionInfo = currentWeather != null
        ? WeatherUtils.getConditionInfo(currentWeather.weatherCode, isDay: currentWeather.isDay)
        : WeatherUtils.getConditionInfo(0, isDay: true);

    final todayForecast = _weatherData != null && _weatherData!.daily.isNotEmpty
        ? _weatherData!.daily[0]
        : null;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: conditionInfo.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: _isLoading && _weatherData == null
                  ? _buildLoadingState()
                  : RefreshIndicator(
                      onRefresh: () => _loadWeather(isRefresh: true),
                      color: Colors.white,
                      backgroundColor: const Color(0xFF1E293B),
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        slivers: [
                          // App Bar with search and actions
                          SliverToBoxAdapter(
                            child: _buildTopBar(),
                          ),

                          if (_errorMessage != null)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: const TextStyle(color: Colors.white, fontSize: 13),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.white70, size: 16),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () => setState(() => _errorMessage = null),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          // Quick pick city chips
                          SliverToBoxAdapter(
                            child: _buildQuickCityPills(),
                          ),

                          // Main Weather Hero
                          if (_weatherData != null && currentWeather != null) ...[
                            SliverToBoxAdapter(
                              child: _buildHeroWeather(currentWeather, conditionInfo, todayForecast),
                            ),

                            // Hourly forecast
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: HourlyForecastWidget(
                                  hourlyList: _weatherData!.hourly,
                                  isCelsius: _isCelsius,
                                ),
                              ),
                            ),

                            // 7-day forecast
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: DailyForecastWidget(
                                  dailyList: _weatherData!.daily,
                                  isCelsius: _isCelsius,
                                ),
                              ),
                            ),

                            // Weather metrics grid
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: WeatherDetailsGrid(
                                  current: currentWeather,
                                  uvIndex: todayForecast?.uvIndex ?? 0.0,
                                  isCelsius: _isCelsius,
                                ),
                              ),
                            ),

                            // Sunrise / Sunset card
                            if (todayForecast?.sunrise != null && todayForecast?.sunset != null)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: SunCardWidget(
                                    sunrise: todayForecast!.sunrise,
                                    sunset: todayForecast.sunset,
                                  ),
                                ),
                              ),

                            // Smart Weather Tips
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: WeatherAdviceCard(
                                  current: currentWeather,
                                  uvIndex: todayForecast?.uvIndex ?? 0.0,
                                ),
                              ),
                            ),

                            // Last updated footnote
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 16, bottom: 32),
                                child: Center(
                                  child: Text(
                                    'Updated: ${DateFormat('hh:mm a, MMM d').format(_weatherData!.fetchedAt)} • Open-Meteo',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.5),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Fetching live weather for ${_selectedCity.name}...',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          // City selector button
          Expanded(
            child: InkWell(
              onTap: _openCitySearch,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _selectedCity.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 20),
                            ],
                          ),
                          Text(
                            _selectedCity.country,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Unit toggle pill (°C / °F)
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildUnitButton('°C', _isCelsius, () {
                  if (!_isCelsius) setState(() => _isCelsius = true);
                }),
                _buildUnitButton('°F', !_isCelsius, () {
                  if (_isCelsius) setState(() => _isCelsius = false);
                }),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Search button
          IconButton(
            tooltip: 'Search City',
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            onPressed: _openCitySearch,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.15),
            ),
          ),

          const SizedBox(width: 4),

          // Refresh button with rotation
          RotationTransition(
            turns: _refreshAnimController,
            child: IconButton(
              tooltip: 'Refresh Weather',
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: () => _loadWeather(isRefresh: true),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF1E293B) : Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCityPills() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: WeatherService.defaultCities.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final city = WeatherService.defaultCities[index];
          final isSelected = city.name == _selectedCity.name;
          return GestureDetector(
            onTap: () => _onCityChanged(city),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Center(
                child: Text(
                  city.name,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroWeather(
    CurrentWeather current,
    WeatherConditionInfo conditionInfo,
    DailyForecast? todayForecast,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          // Animated / Glowing Weather Condition Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
              boxShadow: [
                BoxShadow(
                  color: conditionInfo.accentColor.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              conditionInfo.icon,
              size: 58,
              color: conditionInfo.accentColor,
            ),
          ),
          const SizedBox(height: 12),

          // Condition Name Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: Text(
              conditionInfo.description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Big Temperature Text
          Text(
            WeatherUtils.formatTemperatureRaw(current.temperature, _isCelsius),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 78,
              fontWeight: FontWeight.w200,
              height: 1.05,
              letterSpacing: -2,
            ),
          ),

          const SizedBox(height: 4),

          // High / Low & Feels Like info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (todayForecast != null) ...[
                Text(
                  'H: ${WeatherUtils.formatTemperatureRaw(todayForecast.maxTemp, _isCelsius)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '•',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                ),
                const SizedBox(width: 8),
                Text(
                  'L: ${WeatherUtils.formatTemperatureRaw(todayForecast.minTemp, _isCelsius)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '|',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                ),
                const SizedBox(width: 12),
              ],
              Text(
                'Feels like ${WeatherUtils.formatTemperatureRaw(current.apparentTemperature, _isCelsius)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
