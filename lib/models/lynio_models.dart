import 'dart:math' as math;
import 'package:flutter/material.dart';

enum WatchPlatform { wearOS, watchOS }

enum WatchConnectionStatus {
  disconnected,
  scanning,
  connecting,
  connected,
  demoMode,
}

enum ProximityLevel { close, near, far, unknown }

class WatchModelInfo {
  const WatchModelInfo({
    required this.id,
    required this.name,
    required this.brand,
    required this.caseColor,
    required this.bezelColor,
    this.isSquare = false,
    this.platform = WatchPlatform.wearOS,
  });

  final String id;
  final String name;
  final String brand;
  final Color caseColor;
  final Color bezelColor;
  final bool isSquare;
  final WatchPlatform platform;

  bool get isAppleWatch => platform == WatchPlatform.watchOS;

  /// Apple Watch (watchOS) + all 26 Wear OS watch models from Lynio.app.
  static const List<WatchModelInfo> catalog = [
    WatchModelInfo(
      id: 'apple-watch-ultra-2',
      name: 'Apple Watch Ultra 2',
      brand: 'Apple',
      caseColor: Color(0xFF475569),
      bezelColor: Color(0xFFF97316),
      isSquare: true,
      platform: WatchPlatform.watchOS,
    ),
    WatchModelInfo(
      id: 'apple-watch-ultra',
      name: 'Apple Watch Ultra',
      brand: 'Apple',
      caseColor: Color(0xFF64748B),
      bezelColor: Color(0xFFEA580C),
      isSquare: true,
      platform: WatchPlatform.watchOS,
    ),
    WatchModelInfo(
      id: 'apple-watch-series-10',
      name: 'Apple Watch Series 10',
      brand: 'Apple',
      caseColor: Color(0xFF0F172A),
      bezelColor: Color(0xFF334155),
      isSquare: true,
      platform: WatchPlatform.watchOS,
    ),
    WatchModelInfo(
      id: 'apple-watch-series-9',
      name: 'Apple Watch Series 9',
      brand: 'Apple',
      caseColor: Color(0xFF1E293B),
      bezelColor: Color(0xFF475569),
      isSquare: true,
      platform: WatchPlatform.watchOS,
    ),
    WatchModelInfo(
      id: 'apple-watch-se-2',
      name: 'Apple Watch SE (2nd Gen)',
      brand: 'Apple',
      caseColor: Color(0xFF334155),
      bezelColor: Color(0xFF64748B),
      isSquare: true,
      platform: WatchPlatform.watchOS,
    ),
    WatchModelInfo(
      id: 'galaxy-watch-ultra-2',
      name: 'Galaxy Watch Ultra 2',
      brand: 'Samsung',
      caseColor: Color(0xFF334155),
      bezelColor: Color(0xFFF97316),
    ),
    WatchModelInfo(
      id: 'galaxy-watch-ultra',
      name: 'Galaxy Watch Ultra',
      brand: 'Samsung',
      caseColor: Color(0xFF475569),
      bezelColor: Color(0xFFEA580C),
    ),
    WatchModelInfo(
      id: 'galaxy-watch-9',
      name: 'Galaxy Watch 9',
      brand: 'Samsung',
      caseColor: Color(0xFF1E293B),
      bezelColor: Color(0xFF334155),
    ),
    WatchModelInfo(
      id: 'galaxy-watch-8-classic',
      name: 'Galaxy Watch 8 Classic',
      brand: 'Samsung',
      caseColor: Color(0xFFCBD5E1),
      bezelColor: Color(0xFF1E293B),
    ),
    WatchModelInfo(
      id: 'galaxy-watch-8',
      name: 'Galaxy Watch 8',
      brand: 'Samsung',
      caseColor: Color(0xFF334155),
      bezelColor: Color(0xFF0F172A),
    ),
    WatchModelInfo(
      id: 'galaxy-watch-7',
      name: 'Galaxy Watch 7',
      brand: 'Samsung',
      caseColor: Color(0xFF3F4E4F),
      bezelColor: Color(0xFF1E293B),
    ),
    WatchModelInfo(
      id: 'galaxy-watch-6-classic',
      name: 'Galaxy Watch 6 Classic',
      brand: 'Samsung',
      caseColor: Color(0xFF94A3B8),
      bezelColor: Color(0xFF0F172A),
    ),
    WatchModelInfo(
      id: 'galaxy-watch-6',
      name: 'Galaxy Watch 6',
      brand: 'Samsung',
      caseColor: Color(0xFF334155),
      bezelColor: Color(0xFF1E293B),
    ),
    WatchModelInfo(
      id: 'galaxy-watch-fe',
      name: 'Galaxy Watch FE',
      brand: 'Samsung',
      caseColor: Color(0xFF475569),
      bezelColor: Color(0xFF1E293B),
    ),
    WatchModelInfo(
      id: 'galaxy-watch-5-pro',
      name: 'Galaxy Watch 5 Pro',
      brand: 'Samsung',
      caseColor: Color(0xFF3F3F46),
      bezelColor: Color(0xFF18181B),
    ),
    WatchModelInfo(
      id: 'galaxy-watch-5',
      name: 'Galaxy Watch 5',
      brand: 'Samsung',
      caseColor: Color(0xFF334155),
      bezelColor: Color(0xFF1E293B),
    ),
    WatchModelInfo(
      id: 'galaxy-watch-4-classic',
      name: 'Galaxy Watch 4 Classic',
      brand: 'Samsung',
      caseColor: Color(0xFF64748B),
      bezelColor: Color(0xFF0F172A),
    ),
    WatchModelInfo(
      id: 'galaxy-watch-4',
      name: 'Galaxy Watch 4',
      brand: 'Samsung',
      caseColor: Color(0xFF334155),
      bezelColor: Color(0xFF1E293B),
    ),
    WatchModelInfo(
      id: 'pixel-watch-5',
      name: 'Pixel Watch 5',
      brand: 'Google',
      caseColor: Color(0xFF18181B),
      bezelColor: Color(0xFF27272A),
    ),
    WatchModelInfo(
      id: 'pixel-watch-4',
      name: 'Pixel Watch 4',
      brand: 'Google',
      caseColor: Color(0xFF27272A),
      bezelColor: Color(0xFF18181B),
    ),
    WatchModelInfo(
      id: 'pixel-watch-3',
      name: 'Pixel Watch 3',
      brand: 'Google',
      caseColor: Color(0xFF1E293B),
      bezelColor: Color(0xFF0F172A),
    ),
    WatchModelInfo(
      id: 'pixel-watch-2',
      name: 'Pixel Watch 2',
      brand: 'Google',
      caseColor: Color(0xFF94A3B8),
      bezelColor: Color(0xFF1E293B),
    ),
    WatchModelInfo(
      id: 'pixel-watch-1',
      name: 'Pixel Watch',
      brand: 'Google',
      caseColor: Color(0xFF334155),
      bezelColor: Color(0xFF0F172A),
    ),
    WatchModelInfo(
      id: 'oneplus-watch-3',
      name: 'OnePlus Watch 3',
      brand: 'OnePlus',
      caseColor: Color(0xFF1E3A34),
      bezelColor: Color(0xFF0F7664),
    ),
    WatchModelInfo(
      id: 'oppo-watch-x',
      name: 'OPPO Watch X',
      brand: 'OPPO',
      caseColor: Color(0xFF334155),
      bezelColor: Color(0xFF475569),
    ),
    WatchModelInfo(
      id: 'xiaomi-watch-5',
      name: 'Xiaomi Watch 5',
      brand: 'Xiaomi',
      caseColor: Color(0xFF1E293B),
      bezelColor: Color(0xFF334155),
    ),
    WatchModelInfo(
      id: 'xiaomi-watch-2-pro',
      name: 'Xiaomi Watch 2 Pro',
      brand: 'Xiaomi',
      caseColor: Color(0xFF78716C),
      bezelColor: Color(0xFF1C1917),
    ),
    WatchModelInfo(
      id: 'xiaomi-watch-2',
      name: 'Xiaomi Watch 2',
      brand: 'Xiaomi',
      caseColor: Color(0xFF334155),
      bezelColor: Color(0xFF1E293B),
    ),
    WatchModelInfo(
      id: 'ticwatch-pro-5',
      name: 'TicWatch Pro 5',
      brand: 'Mobvoi',
      caseColor: Color(0xFF1F2937),
      bezelColor: Color(0xFF111827),
    ),
    WatchModelInfo(
      id: 'ticwatch-pro-3',
      name: 'TicWatch Pro 3',
      brand: 'Mobvoi',
      caseColor: Color(0xFF374151),
      bezelColor: Color(0xFF111827),
    ),
    WatchModelInfo(
      id: 'ticwatch-e3',
      name: 'TicWatch E3',
      brand: 'Mobvoi',
      caseColor: Color(0xFF4B5563),
      bezelColor: Color(0xFF1F2937),
    ),
    WatchModelInfo(
      id: 'fossil-gen-6',
      name: 'Fossil Gen 6',
      brand: 'Luxury & Other',
      caseColor: Color(0xFF57534E),
      bezelColor: Color(0xFF292524),
    ),
    WatchModelInfo(
      id: 'tag-heuer-calibre-e4',
      name: 'TAG Heuer Calibre E4',
      brand: 'Luxury & Other',
      caseColor: Color(0xFF18181B),
      bezelColor: Color(0xFF3F3F46),
    ),
    WatchModelInfo(
      id: 'hublot-big-bang-e',
      name: 'Hublot Big Bang e',
      brand: 'Luxury & Other',
      caseColor: Color(0xFF27272A),
      bezelColor: Color(0xFF52525B),
    ),
    WatchModelInfo(
      id: 'montblanc-summit',
      name: 'Montblanc Summit',
      brand: 'Luxury & Other',
      caseColor: Color(0xFF1C1917),
      bezelColor: Color(0xFF44403C),
    ),
    WatchModelInfo(
      id: 'other-wear-os',
      name: 'Other Wear OS Watch',
      brand: 'Luxury & Other',
      caseColor: Color(0xFF334155),
      bezelColor: Color(0xFF0F7664),
    ),
  ];

  static WatchModelInfo byId(String id) {
    return catalog.firstWhere(
      (m) => m.id == id,
      orElse: () => catalog.first,
    );
  }
}

class BatterySnapshot {
  const BatterySnapshot({
    required this.watchPercent,
    required this.isWatchCharging,
    required this.phonePercent,
    required this.estimatedHoursLeft,
    required this.temperatureC,
  });

  final int watchPercent;
  final bool isWatchCharging;
  final int phonePercent;
  final int estimatedHoursLeft;
  final double temperatureC;

  BatterySnapshot copyWith({
    int? watchPercent,
    bool? isWatchCharging,
    int? phonePercent,
    int? estimatedHoursLeft,
    double? temperatureC,
  }) {
    return BatterySnapshot(
      watchPercent: watchPercent ?? this.watchPercent,
      isWatchCharging: isWatchCharging ?? this.isWatchCharging,
      phonePercent: phonePercent ?? this.phonePercent,
      estimatedHoursLeft: estimatedHoursLeft ?? this.estimatedHoursLeft,
      temperatureC: temperatureC ?? this.temperatureC,
    );
  }
}

class AppleServicesState {
  const AppleServicesState({
    required this.ancsActive,
    required this.amsActive,
    required this.hfpCallAudioEnabled,
    required this.wifiChannelReady,
  });

  final bool ancsActive;
  final bool amsActive;
  final bool hfpCallAudioEnabled;
  final bool wifiChannelReady;

  AppleServicesState copyWith({
    bool? ancsActive,
    bool? amsActive,
    bool? hfpCallAudioEnabled,
    bool? wifiChannelReady,
  }) {
    return AppleServicesState(
      ancsActive: ancsActive ?? this.ancsActive,
      amsActive: amsActive ?? this.amsActive,
      hfpCallAudioEnabled: hfpCallAudioEnabled ?? this.hfpCallAudioEnabled,
      wifiChannelReady: wifiChannelReady ?? this.wifiChannelReady,
    );
  }
}

class WatchFaceSlot {
  const WatchFaceSlot({
    required this.id,
    required this.role,
    required this.style,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });

  final int id;
  final String role;
  final String style;
  final double x;
  final double y;
  final double w;
  final double h;

  factory WatchFaceSlot.fromJson(Map<String, dynamic> json) {
    double x;
    double y;
    double w;
    double h;

    if (json.containsKey('x') && json.containsKey('y')) {
      x = (json['x'] as num).toDouble();
      y = (json['y'] as num).toDouble();
      w = (json['w'] as num? ?? 80).toDouble();
      h = (json['h'] as num? ?? 80).toDouble();
    } else {
      // Polar edge complication: {start, span, rOut, thickness} on 450x450 canvas
      final start = (json['start'] as num? ?? 0).toDouble();
      final span = (json['span'] as num? ?? 60).toDouble();
      final rOut = (json['rOut'] as num? ?? 210).toDouble();
      final thickness = (json['thickness'] as num? ?? 46).toDouble();
      final midDeg = start + span / 2;
      final rad = (midDeg - 90) * math.pi / 180.0;
      final rMid = rOut - thickness / 2;
      w = 104;
      h = thickness;
      x = 225 + rMid * math.cos(rad) - w / 2;
      y = 225 + rMid * math.sin(rad) - h / 2;
    }

    return WatchFaceSlot(
      id: (json['id'] as num).toInt(),
      role: json['role'] as String? ?? 'empty',
      style: json['style'] as String? ?? 'ring',
      x: x,
      y: y,
      w: w,
      h: h,
    );
  }

  WatchFaceSlot copyWith({String? role}) {
    return WatchFaceSlot(
      id: id,
      role: role ?? this.role,
      style: style,
      x: x,
      y: y,
      w: w,
      h: h,
    );
  }
}

class WatchFaceDefinition {
  const WatchFaceDefinition({
    required this.id,
    required this.displayName,
    required this.category,
    required this.slots,
  });

  final String id;
  final String displayName;
  final String category;
  final List<WatchFaceSlot> slots;
}

class WatchFacePreset {
  const WatchFacePreset({
    required this.id,
    required this.name,
    required this.faceId,
    required this.accentColorValue,
    required this.slotRoles,
  });

  final String id;
  final String name;
  final String faceId;
  final int accentColorValue;
  final Map<int, String> slotRoles;
}

class NotificationAppItem {
  const NotificationAppItem({
    required this.bundleId,
    required this.name,
    required this.category,
    required this.icon,
    required this.muted,
    required this.recentCount,
  });

  final String bundleId;
  final String name;
  final String category;
  final IconData icon;
  final bool muted;
  final int recentCount;

  NotificationAppItem copyWith({bool? muted, int? recentCount}) {
    return NotificationAppItem(
      bundleId: bundleId,
      name: name,
      category: category,
      icon: icon,
      muted: muted ?? this.muted,
      recentCount: recentCount ?? this.recentCount,
    );
  }
}

class QuietHoursConfig {
  const QuietHoursConfig({
    required this.enabled,
    required this.start,
    required this.end,
  });

  final bool enabled;
  final TimeOfDay start;
  final TimeOfDay end;

  QuietHoursConfig copyWith({
    bool? enabled,
    TimeOfDay? start,
    TimeOfDay? end,
  }) {
    return QuietHoursConfig(
      enabled: enabled ?? this.enabled,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }
}

class WorkoutSessionItem {
  const WorkoutSessionItem({
    required this.id,
    required this.type,
    required this.icon,
    required this.durationMinutes,
    required this.calories,
    required this.avgHeartRate,
    required this.dateLabel,
  });

  final String id;
  final String type;
  final IconData icon;
  final int durationMinutes;
  final int calories;
  final int avgHeartRate;
  final String dateLabel;
}

class HealthSummary {
  const HealthSummary({
    required this.steps,
    required this.stepGoal,
    required this.heartRateBpm,
    required this.restingHeartRate,
    required this.sleepMinutes,
    required this.activeCalories,
    required this.heartRateHistory,
    required this.workouts,
    required this.syncSteps,
    required this.syncHeartRate,
    required this.syncSleep,
    required this.syncWorkouts,
  });

  final int steps;
  final int stepGoal;
  final int heartRateBpm;
  final int restingHeartRate;
  final int sleepMinutes;
  final int activeCalories;
  final List<int> heartRateHistory;
  final List<WorkoutSessionItem> workouts;
  final bool syncSteps;
  final bool syncHeartRate;
  final bool syncSleep;
  final bool syncWorkouts;

  HealthSummary copyWith({
    int? steps,
    int? stepGoal,
    int? heartRateBpm,
    int? restingHeartRate,
    int? sleepMinutes,
    int? activeCalories,
    List<int>? heartRateHistory,
    List<WorkoutSessionItem>? workouts,
    bool? syncSteps,
    bool? syncHeartRate,
    bool? syncSleep,
    bool? syncWorkouts,
  }) {
    return HealthSummary(
      steps: steps ?? this.steps,
      stepGoal: stepGoal ?? this.stepGoal,
      heartRateBpm: heartRateBpm ?? this.heartRateBpm,
      restingHeartRate: restingHeartRate ?? this.restingHeartRate,
      sleepMinutes: sleepMinutes ?? this.sleepMinutes,
      activeCalories: activeCalories ?? this.activeCalories,
      heartRateHistory: heartRateHistory ?? this.heartRateHistory,
      workouts: workouts ?? this.workouts,
      syncSteps: syncSteps ?? this.syncSteps,
      syncHeartRate: syncHeartRate ?? this.syncHeartRate,
      syncSleep: syncSleep ?? this.syncSleep,
      syncWorkouts: syncWorkouts ?? this.syncWorkouts,
    );
  }
}

class CalendarInfoItem {
  const CalendarInfoItem({
    required this.id,
    required this.title,
    required this.source,
    required this.color,
    this.enabled = true,
  });

  final String id;
  final String title;
  final String source;
  final Color color;
  final bool enabled;

  CalendarInfoItem copyWith({bool? enabled}) {
    return CalendarInfoItem(
      id: id,
      title: title,
      source: source,
      color: color,
      enabled: enabled ?? this.enabled,
    );
  }
}

class CalendarEventItem {
  const CalendarEventItem({
    required this.id,
    required this.calendarId,
    required this.title,
    required this.dayOffset,
    this.location,
    this.startMinutes,
    this.durationMinutes,
    this.allDay = false,
  });

  final String id;
  final String calendarId;
  final String title;
  final int dayOffset;
  final String? location;
  final int? startMinutes;
  final int? durationMinutes;
  final bool allDay;
}

class ReminderListItem {
  const ReminderListItem({
    required this.id,
    required this.title,
    required this.source,
    required this.color,
    this.enabled = true,
  });

  final String id;
  final String title;
  final String source;
  final Color color;
  final bool enabled;

  ReminderListItem copyWith({bool? enabled}) {
    return ReminderListItem(
      id: id,
      title: title,
      source: source,
      color: color,
      enabled: enabled ?? this.enabled,
    );
  }
}

class ReminderItem {
  const ReminderItem({
    required this.id,
    required this.listId,
    required this.title,
    this.dayOffset,
    this.timeMinutes,
    this.priority = 0,
    this.completed = false,
  });

  final String id;
  final String listId;
  final String title;
  final int? dayOffset;
  final int? timeMinutes;
  final int priority;
  final bool completed;

  ReminderItem copyWith({bool? completed}) {
    return ReminderItem(
      id: id,
      listId: listId,
      title: title,
      dayOffset: dayOffset,
      timeMinutes: timeMinutes,
      priority: priority,
      completed: completed ?? this.completed,
    );
  }
}

class WeatherSlice {
  const WeatherSlice({
    required this.time,
    required this.temperatureC,
    required this.symbolCode,
  });

  final DateTime time;
  final double temperatureC;
  final String symbolCode;
}

class ContactFavoriteItem {
  const ContactFavoriteItem({
    required this.id,
    required this.name,
    required this.phone,
    required this.label,
    required this.synced,
  });

  final String id;
  final String name;
  final String phone;
  final String label;
  final bool synced;

  ContactFavoriteItem copyWith({bool? synced}) {
    return ContactFavoriteItem(
      id: id,
      name: name,
      phone: phone,
      label: label,
      synced: synced ?? this.synced,
    );
  }
}

class CompanionApkVersion {
  const CompanionApkVersion({
    required this.versionCode,
    required this.versionName,
    required this.minSdkVersion,
  });

  final int versionCode;
  final String versionName;
  final int minSdkVersion;
}
