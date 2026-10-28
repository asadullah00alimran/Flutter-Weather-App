import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_models.dart';
import '../utils/weather_utils.dart';

class HourlyForecastWidget extends StatelessWidget {
  final List<HourlyForecast> hourlyList;
  final bool isCelsius;

  const HourlyForecastWidget({
    super.key,
    required this.hourlyList,
    required this.isCelsius,
  });

  @override
  Widget build(BuildContext context) {
    if (hourlyList.isEmpty) return const SizedBox.shrink();

    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.access_time_rounded, size: 18, color: Colors.white70),
              SizedBox(width: 8),
              Text(
                'HOURLY FORECAST',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 132,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: hourlyList.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = hourlyList[index];
              final isCurrentHour = index == 0 || (item.time.hour == now.hour && item.time.day == now.day);
              final timeLabel = index == 0 ? 'Now' : DateFormat('h a').format(item.time);
              final condition = WeatherUtils.getConditionInfo(
                item.weatherCode,
                isDay: item.time.hour >= 6 && item.time.hour < 19,
              );

              return Container(
                width: 78,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: isCurrentHour
                      ? Colors.white.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isCurrentHour
                        ? Colors.white.withValues(alpha: 0.4)
                        : Colors.white.withValues(alpha: 0.15),
                    width: isCurrentHour ? 1.5 : 1.0,
                  ),
                  boxShadow: isCurrentHour
                      ? [
                          BoxShadow(
                            color: condition.accentColor.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      timeLabel,
                      style: TextStyle(
                        color: isCurrentHour ? Colors.white : Colors.white70,
                        fontSize: 13,
                        fontWeight: isCurrentHour ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    Icon(
                      condition.icon,
                      color: condition.accentColor,
                      size: 26,
                    ),
                    Text(
                      WeatherUtils.formatTemperatureRaw(item.temperature, isCelsius),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
