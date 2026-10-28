import 'package:flutter/material.dart';

class WeatherConditionInfo {
  final String description;
  final IconData icon;
  final List<Color> backgroundGradient;
  final Color accentColor;
  final String animationHint;

  const WeatherConditionInfo({
    required this.description,
    required this.icon,
    required this.backgroundGradient,
    required this.accentColor,
    required this.animationHint,
  });
}

class WeatherUtils {
  static double toFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  static String formatTemperature(double tempC, bool isCelsius) {
    final value = isCelsius ? tempC : toFahrenheit(tempC);
    return '${value.round()}°${isCelsius ? 'C' : 'F'}';
  }

  static String formatTemperatureRaw(double tempC, bool isCelsius) {
    final value = isCelsius ? tempC : toFahrenheit(tempC);
    return '${value.round()}°';
  }

  static WeatherConditionInfo getConditionInfo(int code, {bool isDay = true}) {
    switch (code) {
      case 0: // Clear sky
        return WeatherConditionInfo(
          description: isDay ? 'Sunny' : 'Clear Sky',
          icon: isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round,
          backgroundGradient: isDay
              ? const [Color(0xFF1E88E5), Color(0xFF42A5F5), Color(0xFFFFB300)]
              : const [Color(0xFF0D1B2A), Color(0xFF1B263B), Color(0xFF415A77)],
          accentColor: isDay ? const Color(0xFFFFD54F) : const Color(0xFF90CAF9),
          animationHint: isDay ? 'sunny' : 'clear_night',
        );
      case 1: // Mainly clear
      case 2: // Partly cloudy
        return WeatherConditionInfo(
          description: 'Partly Cloudy',
          icon: isDay ? Icons.wb_cloudy_rounded : Icons.nights_stay_rounded,
          backgroundGradient: isDay
              ? const [Color(0xFF2B5876), Color(0xFF4E4376)]
              : const [Color(0xFF141E30), Color(0xFF243B55)],
          accentColor: const Color(0xFF64B5F6),
          animationHint: 'cloudy',
        );
      case 3: // Overcast
        return WeatherConditionInfo(
          description: 'Overcast',
          icon: Icons.cloud_rounded,
          backgroundGradient: const [Color(0xFF3E5151), Color(0xFFDEC79B)],
          accentColor: const Color(0xFFB0BEC5),
          animationHint: 'overcast',
        );
      case 45: // Fog
      case 48: // Depositing rime fog
        return WeatherConditionInfo(
          description: 'Foggy',
          icon: Icons.blur_on_rounded,
          backgroundGradient: const [Color(0xFF485563), Color(0xFF29323C)],
          accentColor: const Color(0xFFCFD8DC),
          animationHint: 'fog',
        );
      case 51: // Drizzle light
      case 53: // Drizzle moderate
      case 55: // Drizzle dense
      case 56:
      case 57:
        return WeatherConditionInfo(
          description: 'Light Drizzle',
          icon: Icons.grain_rounded,
          backgroundGradient: const [Color(0xFF2C3E50), Color(0xFF3498DB)],
          accentColor: const Color(0xFF4FC3F7),
          animationHint: 'rain',
        );
      case 61: // Slight rain
      case 63: // Moderate rain
      case 80: // Slight rain showers
      case 81: // Moderate rain showers
        return WeatherConditionInfo(
          description: 'Showers & Rain',
          icon: Icons.water_drop_rounded,
          backgroundGradient: const [Color(0xFF1F4068), Color(0xFF162447), Color(0xFF1B1B2F)],
          accentColor: const Color(0xFF29B6F6),
          animationHint: 'rain',
        );
      case 65: // Heavy rain
      case 82: // Violent rain showers
        return WeatherConditionInfo(
          description: 'Heavy Downpour',
          icon: Icons.thunderstorm_rounded,
          backgroundGradient: const [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          accentColor: const Color(0xFF00E5FF),
          animationHint: 'rain',
        );
      case 71: // Snow fall slight
      case 73: // Snow fall moderate
      case 75: // Snow fall heavy
      case 77: // Snow grains
      case 85: // Snow showers
      case 86:
        return WeatherConditionInfo(
          description: 'Snow Fall',
          icon: Icons.ac_unit_rounded,
          backgroundGradient: const [Color(0xFF83A4D4), Color(0xFFB6FBFF)],
          accentColor: const Color(0xFFE0F7FA),
          animationHint: 'snow',
        );
      case 95: // Thunderstorm
      case 96:
      case 99:
        return WeatherConditionInfo(
          description: 'Thunderstorm',
          icon: Icons.flash_on_rounded,
          backgroundGradient: const [Color(0xFF141E30), Color(0xFF243B55), Color(0xFF3F2B96)],
          accentColor: const Color(0xFFFFD600),
          animationHint: 'storm',
        );
      default:
        return WeatherConditionInfo(
          description: 'Scattered Clouds',
          icon: Icons.cloud_queue_rounded,
          backgroundGradient: isDay
              ? const [Color(0xFF2193B0), Color(0xFF6DD5ED)]
              : const [Color(0xFF141E30), Color(0xFF243B55)],
          accentColor: const Color(0xFF80D8FF),
          animationHint: 'clouds',
        );
    }
  }

  static String getUvCategory(double uv) {
    if (uv <= 2) return 'Low';
    if (uv <= 5) return 'Moderate';
    if (uv <= 7) return 'High';
    if (uv <= 10) return 'Very High';
    return 'Extreme';
  }

  static Color getUvColor(double uv) {
    if (uv <= 2) return const Color(0xFF66BB6A);
    if (uv <= 5) return const Color(0xFFFFCA28);
    if (uv <= 7) return const Color(0xFFFFA726);
    if (uv <= 10) return const Color(0xFFEF5350);
    return const Color(0xFFAB47BC);
  }

  static String getHumidityEvaluation(int humidity) {
    if (humidity < 30) return 'Dry & Crisp';
    if (humidity <= 60) return 'Comfortable';
    if (humidity <= 80) return 'Humid';
    return 'Very Muggy';
  }

  static String getWindEvaluation(double speed) {
    if (speed < 5) return 'Calm breeze';
    if (speed < 15) return 'Gentle breeze';
    if (speed < 30) return 'Moderate wind';
    if (speed < 50) return 'Strong wind';
    return 'Gale force';
  }

  static List<String> getWeatherTips({
    required double tempC,
    required int weatherCode,
    required double uvIndex,
    required double windSpeed,
    required double precipitation,
  }) {
    final tips = <String>[];

    // Rain / Precipitation tips
    if (precipitation > 0 || weatherCode >= 51 && weatherCode <= 82) {
      tips.add('Carry an umbrella or raincoat — precipitation expected.');
    } else if (weatherCode >= 95) {
      tips.add('Severe thunderstorm warning: stay indoors and avoid open areas.');
    }

    // Temperature tips
    if (tempC >= 32) {
      tips.add('High heat alert: Drink plenty of water and seek shade.');
    } else if (tempC <= 5) {
      tips.add('Cold weather: Dress in warm thermal layers and keep cozy.');
    } else if (tempC >= 20 && tempC <= 26 && precipitation == 0) {
      tips.add('Pleasant weather: Perfect conditions for outdoor strolls.');
    }

    // UV tips
    if (uvIndex >= 6) {
      tips.add('High UV index: Apply SPF 30+ sunscreen and wear sunglasses.');
    }

    // Wind tips
    if (windSpeed >= 35) {
      tips.add('Breezy conditions: Secure loose outdoor items.');
    }

    if (tips.isEmpty) {
      tips.add('Great day ahead! Enjoy the weather.');
    }

    return tips;
  }
}
