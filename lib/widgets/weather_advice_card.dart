import 'package:flutter/material.dart';
import '../models/weather_models.dart';
import '../utils/weather_utils.dart';

class WeatherAdviceCard extends StatelessWidget {
  final CurrentWeather current;
  final double uvIndex;

  const WeatherAdviceCard({
    super.key,
    required this.current,
    required this.uvIndex,
  });

  @override
  Widget build(BuildContext context) {
    final tips = WeatherUtils.getWeatherTips(
      tempC: current.temperature,
      weatherCode: current.weatherCode,
      uvIndex: uvIndex,
      windSpeed: current.windSpeed,
      precipitation: current.precipitation,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, size: 20, color: Color(0xFFFFD54F)),
              SizedBox(width: 8),
              Text(
                'WEATHER INSIGHTS & TIPS',
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
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(Icons.circle, size: 6, color: Color(0xFFFFD54F)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
