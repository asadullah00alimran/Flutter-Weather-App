import 'package:flutter/material.dart';
import '../models/weather_models.dart';
import '../utils/weather_utils.dart';

class WeatherDetailsGrid extends StatelessWidget {
  final CurrentWeather current;
  final double uvIndex;
  final bool isCelsius;

  const WeatherDetailsGrid({
    super.key,
    required this.current,
    required this.uvIndex,
    required this.isCelsius,
  });

  @override
  Widget build(BuildContext context) {
    final windSpeedDisplay = isCelsius
        ? '${current.windSpeed.toStringAsFixed(1)} km/h'
        : '${(current.windSpeed * 0.621371).toStringAsFixed(1)} mph';

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.45,
      children: [
        // Feels Like
        _buildMetricCard(
          icon: Icons.thermostat_rounded,
          iconColor: const Color(0xFFFF8A65),
          title: 'FEELS LIKE',
          value: WeatherUtils.formatTemperature(current.apparentTemperature, isCelsius),
          subtitle: (current.apparentTemperature - current.temperature).abs() < 1.0
              ? 'Similar to actual temp'
              : current.apparentTemperature > current.temperature
                  ? 'Humidity makes it feel warmer'
                  : 'Wind makes it feel cooler',
        ),

        // Humidity
        _buildMetricCard(
          icon: Icons.water_drop_rounded,
          iconColor: const Color(0xFF4FC3F7),
          title: 'HUMIDITY',
          value: '${current.relativeHumidity}%',
          subtitle: WeatherUtils.getHumidityEvaluation(current.relativeHumidity),
        ),

        // Wind
        _buildMetricCard(
          icon: Icons.air_rounded,
          iconColor: const Color(0xFF81C784),
          title: 'WIND SPEED',
          value: windSpeedDisplay,
          subtitle: WeatherUtils.getWindEvaluation(current.windSpeed),
        ),

        // UV Index
        _buildMetricCard(
          icon: Icons.wb_sunny_rounded,
          iconColor: WeatherUtils.getUvColor(uvIndex),
          title: 'UV INDEX',
          value: uvIndex.toStringAsFixed(1),
          subtitle: WeatherUtils.getUvCategory(uvIndex),
        ),

        // Air Pressure
        _buildMetricCard(
          icon: Icons.speed_rounded,
          iconColor: const Color(0xFFBA68C8),
          title: 'AIR PRESSURE',
          value: '${current.surfacePressure.round()} hPa',
          subtitle: current.surfacePressure >= 1013 ? 'Normal / High pressure' : 'Low pressure system',
        ),

        // Precipitation
        _buildMetricCard(
          icon: Icons.umbrella_rounded,
          iconColor: const Color(0xFF4DD0E1),
          title: 'PRECIPITATION',
          value: '${current.precipitation.toStringAsFixed(1)} mm',
          subtitle: current.precipitation > 0 ? 'Active precipitation' : 'No rain observed',
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
