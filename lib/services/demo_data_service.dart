import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/lynio_models.dart';

class DemoDataBundle {
  const DemoDataBundle({
    required this.watchFaces,
    required this.calendars,
    required this.events,
    required this.reminderLists,
    required this.reminders,
    required this.weatherSlices,
    required this.companionVersion,
  });

  final List<WatchFaceDefinition> watchFaces;
  final List<CalendarInfoItem> calendars;
  final List<CalendarEventItem> events;
  final List<ReminderListItem> reminderLists;
  final List<ReminderItem> reminders;
  final List<WeatherSlice> weatherSlices;
  final CompanionApkVersion companionVersion;
}

class DemoDataService {
  static Future<DemoDataBundle> loadAll() async {
    final results = await Future.wait([
      rootBundle.loadString('assets/data/watch-face-slots.json'),
      rootBundle.loadString('assets/data/demo-calendar.json'),
      rootBundle.loadString('assets/data/demo-reminders.json'),
      rootBundle.loadString('assets/data/demo-forecast.json'),
      rootBundle.loadString('assets/data/lynio-wearos-version.json'),
    ]);

    return DemoDataBundle(
      watchFaces: _parseWatchFaces(results[0]),
      calendars: _parseCalendars(results[1]),
      events: _parseCalendarEvents(results[1]),
      reminderLists: _parseReminderLists(results[2]),
      reminders: _parseReminders(results[2]),
      weatherSlices: _parseForecast(results[3]),
      companionVersion: _parseCompanionVersion(results[4]),
    );
  }

  static List<WatchFaceDefinition> _parseWatchFaces(String raw) {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final facesMap = map['faces'] as Map<String, dynamic>;
    final list = <WatchFaceDefinition>[];

    for (final entry in facesMap.entries) {
      final id = entry.key;
      final slotsRaw = (entry.value as List<dynamic>)
          .map((e) => WatchFaceSlot.fromJson(e as Map<String, dynamic>))
          .toList();
      list.add(
        WatchFaceDefinition(
          id: id,
          displayName: _humanizeFaceName(id),
          category: _categorizeFace(id),
          slots: slotsRaw,
        ),
      );
    }
    return list;
  }

  static String _humanizeFaceName(String id) {
    switch (id) {
      case 'hicontrast':
        return 'Hi-Contrast';
      case 'largetype':
        return 'Large Type';
      case 'lcd':
        return 'LCD Retro';
      case 'monoink':
        return 'Mono Ink';
      case 'photoAnalog':
        return 'Photo Analog';
      case 'photoBottom':
        return 'Photo Bottom';
      case 'photoCenter':
        return 'Photo Center';
      case 'photoTop':
        return 'Photo Top';
      default:
        return id[0].toUpperCase() + id.substring(1);
    }
  }

  static String _categorizeFace(String id) {
    if (id.startsWith('photo')) return 'Photo';
    if (const {'activity', 'dashboard', 'infograph', 'modular', 'pulse'}
        .contains(id)) {
      return 'Data';
    }
    if (const {'chronograph', 'dive', 'field', 'flieger', 'meridian', 'world'}
        .contains(id)) {
      return 'Analog';
    }
    if (const {'lcd', 'flip', 'pixel', 'terminal', 'neon', 'largetype'}
        .contains(id)) {
      return 'Digital';
    }
    return 'Artistic';
  }

  static Color _hexColor(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    final clean = hex.replaceAll('#', '');
    final value = int.tryParse('FF$clean', radix: 16);
    return value != null ? Color(value) : fallback;
  }

  static List<CalendarInfoItem> _parseCalendars(String raw) {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final list = map['calendars'] as List<dynamic>? ?? const [];
    return list.map((e) {
      final item = e as Map<String, dynamic>;
      return CalendarInfoItem(
        id: item['id'] as String,
        title: item['title'] as String,
        source: item['source'] as String? ?? 'iCloud',
        color: _hexColor(item['color'] as String?, Colors.teal),
      );
    }).toList();
  }

  static List<CalendarEventItem> _parseCalendarEvents(String raw) {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final list = map['events'] as List<dynamic>? ?? const [];
    return list.map((e) {
      final item = e as Map<String, dynamic>;
      return CalendarEventItem(
        id: item['id'] as String,
        calendarId: item['calendar'] as String,
        title: item['title'] as String,
        dayOffset: (item['day'] as num?)?.toInt() ?? 0,
        location: item['location'] as String?,
        startMinutes: (item['start'] as num?)?.toInt(),
        durationMinutes: (item['minutes'] as num?)?.toInt(),
        allDay: item['allDay'] as bool? ?? false,
      );
    }).toList();
  }

  static List<ReminderListItem> _parseReminderLists(String raw) {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final list = map['lists'] as List<dynamic>? ?? const [];
    return list.map((e) {
      final item = e as Map<String, dynamic>;
      return ReminderListItem(
        id: item['id'] as String,
        title: item['title'] as String,
        source: item['source'] as String? ?? 'iCloud',
        color: _hexColor(item['color'] as String?, Colors.orange),
      );
    }).toList();
  }

  static List<ReminderItem> _parseReminders(String raw) {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final list = map['reminders'] as List<dynamic>? ?? const [];
    return list.map((e) {
      final item = e as Map<String, dynamic>;
      return ReminderItem(
        id: item['id'] as String,
        listId: item['list'] as String,
        title: item['title'] as String,
        dayOffset: (item['day'] as num?)?.toInt(),
        timeMinutes: (item['time'] as num?)?.toInt(),
        priority: (item['priority'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }

  static List<WeatherSlice> _parseForecast(String raw) {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final props = map['properties'] as Map<String, dynamic>?;
    final series = props?['timeseries'] as List<dynamic>? ?? const [];
    final slices = <WeatherSlice>[];

    for (final entry in series) {
      final item = entry as Map<String, dynamic>;
      final timeStr = item['time'] as String?;
      final data = item['data'] as Map<String, dynamic>?;
      final instant = data?['instant'] as Map<String, dynamic>?;
      final details = instant?['details'] as Map<String, dynamic>?;
      final temp = (details?['air_temperature'] as num?)?.toDouble();

      final next1 = data?['next_1_hours'] as Map<String, dynamic>?;
      final next6 = data?['next_6_hours'] as Map<String, dynamic>?;
      final symbol = (next1?['summary'] as Map<String, dynamic>?)?['symbol_code']
              as String? ??
          (next6?['summary'] as Map<String, dynamic>?)?['symbol_code']
              as String? ??
          'partlycloudy_day';

      if (timeStr != null && temp != null) {
        slices.add(
          WeatherSlice(
            time: DateTime.tryParse(timeStr) ?? DateTime.now(),
            temperatureC: temp,
            symbolCode: symbol,
          ),
        );
      }
    }
    return slices;
  }

  static CompanionApkVersion _parseCompanionVersion(String raw) {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return CompanionApkVersion(
      versionCode: (map['versionCode'] as num?)?.toInt() ?? 133,
      versionName: map['versionName'] as String? ?? '1.63.0',
      minSdkVersion: (map['minSdkVersion'] as num?)?.toInt() ?? 30,
    );
  }
}
