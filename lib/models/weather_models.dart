class CityLocation {
  final String name;
  final String country;
  final String? admin1;
  final double latitude;
  final double longitude;

  const CityLocation({
    required this.name,
    required this.country,
    this.admin1,
    required this.latitude,
    required this.longitude,
  });

  String get displayName {
    if (admin1 != null && admin1!.isNotEmpty && admin1 != name) {
      return '$name, $admin1, $country';
    }
    return '$name, $country';
  }

  factory CityLocation.fromJson(Map<String, dynamic> json) {
    return CityLocation(
      name: json['name'] as String? ?? 'Unknown',
      country: json['country'] as String? ?? '',
      admin1: json['admin1'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'country': country,
    'admin1': admin1,
    'latitude': latitude,
    'longitude': longitude,
  };
}

class CurrentWeather {
  final double temperature;
  final double apparentTemperature;
  final int relativeHumidity;
  final double windSpeed;
  final double surfacePressure;
  final double precipitation;
  final int weatherCode;
  final bool isDay;
  final DateTime time;

  const CurrentWeather({
    required this.temperature,
    required this.apparentTemperature,
    required this.relativeHumidity,
    required this.windSpeed,
    required this.surfacePressure,
    required this.precipitation,
    required this.weatherCode,
    required this.isDay,
    required this.time,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      apparentTemperature: (json['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      relativeHumidity: (json['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      surfacePressure: (json['surface_pressure'] as num?)?.toDouble() ?? 1013.0,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      isDay: ((json['is_day'] as num?)?.toInt() ?? 1) == 1,
      time: DateTime.tryParse(json['time'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final int weatherCode;

  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
  });
}

class DailyForecast {
  final DateTime date;
  final int weatherCode;
  final double maxTemp;
  final double minTemp;
  final DateTime? sunrise;
  final DateTime? sunset;
  final double uvIndex;

  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.maxTemp,
    required this.minTemp,
    this.sunrise,
    this.sunset,
    required this.uvIndex,
  });
}

class FullWeatherData {
  final CityLocation location;
  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final DateTime fetchedAt;

  const FullWeatherData({
    required this.location,
    required this.current,
    required this.hourly,
    required this.daily,
    required this.fetchedAt,
  });
}
