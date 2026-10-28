import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_models.dart';
import '../utils/weather_utils.dart';

class DailyForecastWidget extends StatelessWidget {
  final List<DailyForecast> dailyList;
  final bool isCelsius;

  const DailyForecastWidget({
    super.key,
    required this.dailyList,
    required this.isCelsius,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyList.isEmpty) return const SizedBox.shrink();

    // Determine global min and max across all days for proportional range bars
    double globalMin = double.infinity;
    double globalMax = -double.infinity;
    for (final day in dailyList) {
      if (day.minTemp < globalMin) globalMin = day.minTemp;
      if (day.maxTemp > globalMax) globalMax = day.maxTemp;
    }
    final range = (globalMax - globalMin) == 0 ? 1.0 : (globalMax - globalMin);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 18, color: Colors.white70),
              SizedBox(width: 8),
              Text(
                '7-DAY FORECAST',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dailyList.length,
            separatorBuilder: (context, index) => const Divider(
              color: Colors.white10,
              height: 16,
            ),
            itemBuilder: (context, index) {
              final day = dailyList[index];
              final isToday = index == 0;
              final dayLabel = isToday ? 'Today' : DateFormat('EEE').format(day.date);
              final condition = WeatherUtils.getConditionInfo(day.weatherCode, isDay: true);

              // Proportions for temperature range bar
              final leftPaddingFraction = ((day.minTemp - globalMin) / range).clamp(0.0, 0.8);
              final barWidthFraction = ((day.maxTemp - day.minTemp) / range).clamp(0.15, 1.0 - leftPaddingFraction);

              return Row(
                children: [
                  // Day label
                  SizedBox(
                    width: 65,
                    child: Text(
                      dayLabel,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),

                  // Weather Icon
                  SizedBox(
                    width: 36,
                    child: Icon(
                      condition.icon,
                      color: condition.accentColor,
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Min temp
                  SizedBox(
                    width: 38,
                    child: Text(
                      WeatherUtils.formatTemperatureRaw(day.minTemp, isCelsius),
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Range bar
                  Expanded(
                    child: SizedBox(
                      height: 5,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final totalW = constraints.maxWidth;
                          final leftOffset = totalW * leftPaddingFraction;
                          final barW = totalW * barWidthFraction;

                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              Positioned(
                                left: leftOffset,
                                width: barW,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF64B5F6), Color(0xFFFFB74D)],
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Max temp
                  SizedBox(
                    width: 38,
                    child: Text(
                      WeatherUtils.formatTemperatureRaw(day.maxTemp, isCelsius),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
