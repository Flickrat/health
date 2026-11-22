import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../models/lynio_models.dart';
import '../services/apple_watch_service.dart';
import '../services/ble_watch_service.dart';
import '../services/demo_data_service.dart';

class LynioController extends ChangeNotifier {
  LynioController({
    BleWatchService? bleService,
    AppleWatchService? appleWatchService,
  })  : _bleService = bleService ?? BleWatchService(),
        _appleWatchService = appleWatchService ?? AppleWatchService();

  final BleWatchService _bleService;
  final AppleWatchService _appleWatchService;
  SharedPreferences? _prefs;

  AppleWatchStatus appleWatchStatus = const AppleWatchStatus(
    supported: false,
    paired: false,
    reachable: false,
  );
  bool isCheckingAppleWatch = false;

  bool isInitialized = false;
  bool onboardingCompleted = false;
  bool isPro = false;
  ThemeMode themeMode = ThemeMode.system;

  // Watch & Connection State
  WatchModelInfo pairedWatch = WatchModelInfo.byId('galaxy-watch-7');
  String customWatchName = 'Galaxy Watch 7';
  WatchConnectionStatus connectionStatus = WatchConnectionStatus.demoMode;
  DateTime lastSyncedAt = DateTime.now();
  List<DiscoveredWatchDevice> discoveredDevices = const [];
  bool isScanningBle = false;
  String? bleStatusMessage;

  // Live Telemetry
  BatterySnapshot battery = const BatterySnapshot(
    watchPercent: 84,
    isWatchCharging: false,
    phonePercent: 91,
    estimatedHoursLeft: 34,
    temperatureC: 31.4,
  );

  AppleServicesState appleServices = const AppleServicesState(
    ancsActive: true,
    amsActive: true,
    hfpCallAudioEnabled: true,
    wifiChannelReady: true,
  );

  // Find My Watch & Test Notification
  bool isRingingWatch = false;
  ProximityLevel proximityLevel = ProximityLevel.close;
  int proximityRssi = -54;
  String? testNotificationStatus;
  Timer? _ringTimer;

  // Watch Faces
  List<WatchFaceDefinition> watchFaces = const [];
  String activeWatchFaceId = 'activity';
  Color activeFaceAccent = LynioColors.accentDark;
  final Map<String, Map<int, String>> _customSlotRoles = {};
  List<WatchFacePreset> savedPresets = [
    const WatchFacePreset(
      id: 'preset-sport',
      name: 'Morning Run',
      faceId: 'activity',
      accentColorValue: 0xFF1CA48E,
      slotRoles: {1: 'steps', 2: 'battery', 3: 'heart_rate'},
    ),
    const WatchFacePreset(
      id: 'preset-work',
      name: 'Workday',
      faceId: 'dashboard',
      accentColorValue: 0xFF38BDF8,
      slotRoles: {1: 'battery', 2: 'steps', 3: 'heart_rate', 4: 'goal'},
    ),
    const WatchFacePreset(
      id: 'preset-minimal',
      name: 'Evening Minimal',
      faceId: 'nocturne',
      accentColorValue: 0xFFF59E0B,
      slotRoles: {1: 'battery', 2: 'weather'},
    ),
  ];

  // Notifications & Alerts
  bool disconnectAlertsEnabled = true;
  bool lowBatteryAlertsEnabled = true;
  QuietHoursConfig quietHours = const QuietHoursConfig(
    enabled: true,
    start: TimeOfDay(hour: 22, minute: 30),
    end: TimeOfDay(hour: 7, minute: 0),
  );
  List<NotificationAppItem> notificationApps = [
    const NotificationAppItem(
      bundleId: 'com.apple.MobileSMS',
      name: 'Messages',
      category: 'Communication',
      icon: Icons.chat_bubble_rounded,
      muted: false,
      recentCount: 14,
    ),
    const NotificationAppItem(
      bundleId: 'net.whatsapp.WhatsApp',
      name: 'WhatsApp',
      category: 'Communication',
      icon: Icons.forum_rounded,
      muted: false,
      recentCount: 28,
    ),
    const NotificationAppItem(
      bundleId: 'com.apple.mobilemail',
      name: 'Mail',
      category: 'Productivity',
      icon: Icons.mail_rounded,
      muted: false,
      recentCount: 9,
    ),
    const NotificationAppItem(
      bundleId: 'com.tinyspeck.chatlyio',
      name: 'Slack',
      category: 'Work',
      icon: Icons.tag_rounded,
      muted: false,
      recentCount: 19,
    ),
    const NotificationAppItem(
      bundleId: 'com.apple.mobilecal',
      name: 'Calendar',
      category: 'Productivity',
      icon: Icons.calendar_today_rounded,
      muted: false,
      recentCount: 4,
    ),
    const NotificationAppItem(
      bundleId: 'com.burbn.instagram',
      name: 'Instagram',
      category: 'Social',
      icon: Icons.camera_alt_rounded,
      muted: true,
      recentCount: 31,
    ),
    const NotificationAppItem(
      bundleId: 'com.atebits.Tweetie2',
      name: 'X / Twitter',
      category: 'Social',
      icon: Icons.newspaper_rounded,
      muted: true,
      recentCount: 12,
    ),
    const NotificationAppItem(
      bundleId: 'com.ubercab.UberClient',
      name: 'Uber',
      category: 'Travel',
      icon: Icons.local_taxi_rounded,
      muted: false,
      recentCount: 2,
    ),
    const NotificationAppItem(
      bundleId: 'com.apple.Passbook',
      name: 'Apple Wallet',
      category: 'Finance',
      icon: Icons.account_balance_wallet_rounded,
      muted: false,
      recentCount: 3,
    ),
    const NotificationAppItem(
      bundleId: 'com.spotify.client',
      name: 'Spotify',
      category: 'Media',
      icon: Icons.music_note_rounded,
      muted: true,
      recentCount: 0,
    ),
  ];

  // Health & Fitness
  HealthSummary health = const HealthSummary(
    steps: 7842,
    stepGoal: 10000,
    heartRateBpm: 68,
    restingHeartRate: 58,
    sleepMinutes: 452, // 7h 32m
    activeCalories: 465,
    heartRateHistory: [61, 64, 72, 85, 78, 69, 66, 74, 92, 71, 68],
    workouts: [
      WorkoutSessionItem(
        id: 'w1',
        type: 'Outdoor Run',
        icon: Icons.directions_run_rounded,
        durationMinutes: 34,
        calories: 312,
        avgHeartRate: 148,
        dateLabel: 'Today, 07:15',
      ),
      WorkoutSessionItem(
        id: 'w2',
        type: 'Strength Training',
        icon: Icons.fitness_center_rounded,
        durationMinutes: 45,
        calories: 268,
        avgHeartRate: 124,
        dateLabel: 'Yesterday, 18:10',
      ),
      WorkoutSessionItem(
        id: 'w3',
        type: 'Brisk Walk',
        icon: Icons.directions_walk_rounded,
        durationMinutes: 28,
        calories: 142,
        avgHeartRate: 106,
        dateLabel: '2 days ago',
      ),
    ],
    syncSteps: true,
    syncHeartRate: true,
    syncSleep: true,
    syncWorkouts: true,
  );
  bool isMeasuringHeartRate = false;

  // Synced Services (loaded from bundled JSONs)
  List<CalendarInfoItem> calendars = const [];
  List<CalendarEventItem> calendarEvents = const [];
  List<ReminderListItem> reminderLists = const [];
  List<ReminderItem> reminders = const [];
  List<WeatherSlice> weatherSlices = const [];
  bool useFahrenheit = false;
  String weatherLocationName = 'San Francisco';
  CompanionApkVersion companionVersion = const CompanionApkVersion(
    versionCode: 133,
    versionName: '1.63.0',
    minSdkVersion: 30,
  );

  List<ContactFavoriteItem> favoriteContacts = [
    const ContactFavoriteItem(
      id: 'c1',
      name: 'Sam Rivera',
      phone: '+1 (415) 555-0148',
      label: 'Mobile',
      synced: true,
    ),
    const ContactFavoriteItem(
      id: 'c2',
      name: 'Mia Chen',
      phone: '+1 (415) 555-0192',
      label: 'Mobile',
      synced: true,
    ),
    const ContactFavoriteItem(
      id: 'c3',
      name: 'Alex Morgan',
      phone: '+1 (415) 555-0117',
      label: 'Work',
      synced: true,
    ),
    const ContactFavoriteItem(
      id: 'c4',
      name: 'Mom',
      phone: '+1 (415) 555-0101',
      label: 'Home',
      synced: true,
    ),
  ];

  // Watch Preferences
  String watchLanguage = 'English (US)';
  bool use24HourTime = false;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final bundle = await DemoDataService.loadAll();

    watchFaces = bundle.watchFaces;
    calendars = bundle.calendars;
    calendarEvents = bundle.events;
    reminderLists = bundle.reminderLists;
    reminders = bundle.reminders;
    weatherSlices = bundle.weatherSlices;
    companionVersion = bundle.companionVersion;

    onboardingCompleted = _prefs?.getBool('onboardingCompleted') ?? false;
    isPro = _prefs?.getBool('isPro') ?? false;
    final watchId = _prefs?.getString('pairedWatchId') ?? 'galaxy-watch-7';
    pairedWatch = WatchModelInfo.byId(watchId);
    customWatchName = _prefs?.getString('customWatchName') ?? pairedWatch.name;
    activeWatchFaceId = _prefs?.getString('activeWatchFaceId') ?? 'activity';
    final accentVal = _prefs?.getInt('activeFaceAccent');
    if (accentVal != null) activeFaceAccent = Color(accentVal);

    disconnectAlertsEnabled = _prefs?.getBool('disconnectAlerts') ?? true;
    lowBatteryAlertsEnabled = _prefs?.getBool('lowBatteryAlerts') ?? true;
    useFahrenheit = _prefs?.getBool('useFahrenheit') ?? false;
    use24HourTime = _prefs?.getBool('use24HourTime') ?? false;
    watchLanguage = _prefs?.getString('watchLanguage') ?? 'English (US)';

    final savedTheme = _prefs?.getString('themeMode') ?? 'system';
    themeMode = switch (savedTheme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    final mutedIds = _prefs?.getStringList('mutedAppIds');
    if (mutedIds != null) {
      final mutedSet = mutedIds.toSet();
      notificationApps = notificationApps
          .map((a) => a.copyWith(muted: mutedSet.contains(a.bundleId)))
          .toList();
    }

    _appleWatchService.listen(onMessage: _handleAppleWatchMessage);
    isInitialized = true;
    notifyListeners();
  }

  void _handleAppleWatchMessage(Map<String, dynamic> payload) {
    final batteryVal = payload['batteryPercent'];
    final chargingVal = payload['isCharging'];
    final hrVal = payload['heartRateBpm'];
    final stepsVal = payload['steps'];

    if (batteryVal is int) {
      battery = battery.copyWith(
        watchPercent: batteryVal.clamp(0, 100),
        isWatchCharging: chargingVal is bool ? chargingVal : null,
      );
    }
    if (hrVal is int || stepsVal is int) {
      health = health.copyWith(
        heartRateBpm: hrVal is int ? hrVal : null,
        steps: stepsVal is int ? stepsVal : null,
      );
    }
    lastSyncedAt = DateTime.now();
    notifyListeners();
  }

  Future<bool> connectAppleWatch() async {
    isCheckingAppleWatch = true;
    bleStatusMessage = 'Checking WatchConnectivity (WCSession)...';
    notifyListeners();

    final status = await _appleWatchService.checkStatus();
    appleWatchStatus = status;
    isCheckingAppleWatch = false;

    if (status.supported && status.paired) {
      connectionStatus = WatchConnectionStatus.connected;
      bleStatusMessage = status.reachable
          ? 'Apple Watch paired & reachable via WCSession.'
          : 'Apple Watch paired (background sync ready).';
      await pushContextToAppleWatch();
      notifyListeners();
      return true;
    }

    bleStatusMessage = !status.supported
        ? 'WatchConnectivity requires an iPhone with a paired Apple Watch. You can continue in Demo Mode.'
        : 'No Apple Watch is currently paired with this iPhone. Pair it in Apple\'s Watch app or try Demo Mode.';
    notifyListeners();
    return false;
  }

  Future<void> pushContextToAppleWatch() async {
    if (!pairedWatch.isAppleWatch) return;
    await _appleWatchService.updateContext({
      'type': 'syncState',
      'watchName': customWatchName,
      'faceId': activeWatchFaceId,
      'accentHex': activeFaceAccent.toARGB32(),
      'quietHoursEnabled': quietHours.enabled,
      'stepGoal': health.stepGoal,
      'use24HourTime': use24HourTime,
      'useFahrenheit': useFahrenheit,
      'openReminders': reminders.where((r) => !r.completed).length,
    });
  }

  WatchFaceDefinition get activeWatchFace {
    if (watchFaces.isEmpty) {
      return const WatchFaceDefinition(
        id: 'activity',
        displayName: 'Activity',
        category: 'Data',
        slots: [],
      );
    }
    return watchFaces.firstWhere(
      (f) => f.id == activeWatchFaceId,
      orElse: () => watchFaces.first,
    );
  }

  List<WatchFaceSlot> slotsForFace(WatchFaceDefinition face) {
    final overrides = _customSlotRoles[face.id];
    if (overrides == null) return face.slots;
    return face.slots
        .map((s) => overrides.containsKey(s.id)
            ? s.copyWith(role: overrides[s.id])
            : s)
        .toList();
  }

  Future<void> completeOnboarding({
    required WatchModelInfo model,
    bool demoMode = true,
  }) async {
    pairedWatch = model;
    customWatchName = model.name;
    onboardingCompleted = true;
    connectionStatus = demoMode
        ? WatchConnectionStatus.demoMode
        : WatchConnectionStatus.connected;
    lastSyncedAt = DateTime.now();
    await _prefs?.setBool('onboardingCompleted', true);
    await _prefs?.setString('pairedWatchId', model.id);
    await _prefs?.setString('customWatchName', customWatchName);
    notifyListeners();
  }

  Future<void> resetOnboarding() async {
    onboardingCompleted = false;
    await _prefs?.setBool('onboardingCompleted', false);
    notifyListeners();
  }

  Future<void> selectWatchModel(WatchModelInfo model) async {
    pairedWatch = model;
    customWatchName = model.name;
    await _prefs?.setString('pairedWatchId', model.id);
    await _prefs?.setString('customWatchName', customWatchName);
    notifyListeners();
  }

  Future<void> startBleScan() async {
    isScanningBle = true;
    bleStatusMessage = 'Scanning for nearby Wear OS watches...';
    discoveredDevices = const [];
    notifyListeners();

    final available = await _bleService.isBluetoothAvailable();
    if (!available) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      isScanningBle = false;
      bleStatusMessage =
          'Bluetooth adapter unavailable (Simulator or off). You can connect in Demo Mode.';
      notifyListeners();
      return;
    }

    await _bleService.startScan(
      onUpdate: (devices) {
        discoveredDevices = devices;
        notifyListeners();
      },
    );

    isScanningBle = false;
    bleStatusMessage = discoveredDevices.isEmpty
        ? 'No iHealthFit Wear OS watches found nearby. Ensure the companion app is open on your watch.'
        : 'Found ${discoveredDevices.length} nearby device(s).';
    notifyListeners();
  }

  Future<bool> connectToBleDevice(DiscoveredWatchDevice device) async {
    connectionStatus = WatchConnectionStatus.connecting;
    bleStatusMessage = 'Connecting to ${device.name}...';
    notifyListeners();

    final ok = await _bleService.connect(device);
    if (ok) {
      customWatchName = device.name;
      connectionStatus = WatchConnectionStatus.connected;
      bleStatusMessage = 'Connected to ${device.name}';
      lastSyncedAt = DateTime.now();
    } else {
      connectionStatus = WatchConnectionStatus.disconnected;
      bleStatusMessage = 'Could not connect to ${device.name}.';
    }
    notifyListeners();
    return ok;
  }

  void switchToDemoMode() {
    connectionStatus = WatchConnectionStatus.demoMode;
    lastSyncedAt = DateTime.now();
    bleStatusMessage = null;
    notifyListeners();
  }

  Future<void> syncNow() async {
    lastSyncedAt = DateTime.now();
    battery = battery.copyWith(
      watchPercent: battery.isWatchCharging
          ? min(100, battery.watchPercent + 1)
          : battery.watchPercent,
    );
    if (pairedWatch.isAppleWatch) {
      await pushContextToAppleWatch();
    }
    notifyListeners();
  }

  void toggleChargingSimulation() {
    battery = battery.copyWith(isWatchCharging: !battery.isWatchCharging);
    notifyListeners();
  }

  void toggleRingWatch() {
    if (isRingingWatch) {
      stopRingingWatch();
      return;
    }
    isRingingWatch = true;
    if (pairedWatch.isAppleWatch) {
      _appleWatchService.sendMessage({'type': 'ringWatch', 'active': true});
    }
    notifyListeners();

    final rng = Random();
    _ringTimer?.cancel();
    _ringTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      proximityRssi = -48 - rng.nextInt(26);
      if (proximityRssi > -58) {
        proximityLevel = ProximityLevel.close;
      } else if (proximityRssi > -68) {
        proximityLevel = ProximityLevel.near;
      } else {
        proximityLevel = ProximityLevel.far;
      }
      notifyListeners();
    });
  }

  void stopRingingWatch() {
    _ringTimer?.cancel();
    _ringTimer = null;
    isRingingWatch = false;
    if (pairedWatch.isAppleWatch) {
      _appleWatchService.sendMessage({'type': 'ringWatch', 'active': false});
    }
    notifyListeners();
  }

  Future<void> sendTestNotification() async {
    testNotificationStatus = pairedWatch.isAppleWatch
        ? 'Sending via WatchConnectivity...'
        : 'Sending via ANCS...';
    notifyListeners();
    if (pairedWatch.isAppleWatch) {
      await _appleWatchService.sendMessage({
        'type': 'testNotification',
        'title': 'iHealthFit Test Alert',
        'body': 'Connected to $customWatchName',
      });
    }
    await Future<void>.delayed(const Duration(milliseconds: 650));
    testNotificationStatus = 'Delivered to $customWatchName';
    notifyListeners();
    await Future<void>.delayed(const Duration(seconds: 3));
    testNotificationStatus = null;
    notifyListeners();
  }

  // Watch Face Studio actions
  Future<void> selectWatchFace(String faceId) async {
    activeWatchFaceId = faceId;
    await _prefs?.setString('activeWatchFaceId', faceId);
    notifyListeners();
  }

  Future<void> setFaceAccent(Color color) async {
    activeFaceAccent = color;
    await _prefs?.setInt('activeFaceAccent', color.toARGB32());
    notifyListeners();
  }

  void setSlotRole(String faceId, int slotId, String role) {
    _customSlotRoles.putIfAbsent(faceId, () => {});
    _customSlotRoles[faceId]![slotId] = role;
    notifyListeners();
  }

  void saveCurrentFaceAsPreset(String name) {
    final face = activeWatchFace;
    final slots = slotsForFace(face);
    final preset = WatchFacePreset(
      id: 'preset-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      faceId: face.id,
      accentColorValue: activeFaceAccent.toARGB32(),
      slotRoles: {for (final s in slots) s.id: s.role},
    );
    savedPresets = [preset, ...savedPresets];
    notifyListeners();
  }

  Future<void> applyPreset(WatchFacePreset preset) async {
    activeWatchFaceId = preset.faceId;
    activeFaceAccent = Color(preset.accentColorValue);
    _customSlotRoles[preset.faceId] = Map<int, String>.from(preset.slotRoles);
    await _prefs?.setString('activeWatchFaceId', activeWatchFaceId);
    await _prefs?.setInt('activeFaceAccent', activeFaceAccent.toARGB32());
    notifyListeners();
  }

  // Notifications & Quiet Hours
  Future<void> toggleAppMuted(String bundleId) async {
    notificationApps = notificationApps
        .map((a) => a.bundleId == bundleId ? a.copyWith(muted: !a.muted) : a)
        .toList();
    final mutedIds = notificationApps
        .where((a) => a.muted)
        .map((a) => a.bundleId)
        .toList();
    await _prefs?.setStringList('mutedAppIds', mutedIds);
    notifyListeners();
  }

  void setQuietHoursEnabled(bool value) {
    quietHours = quietHours.copyWith(enabled: value);
    notifyListeners();
  }

  void setQuietHoursTime({TimeOfDay? start, TimeOfDay? end}) {
    quietHours = quietHours.copyWith(start: start, end: end);
    notifyListeners();
  }

  Future<void> setDisconnectAlerts(bool value) async {
    disconnectAlertsEnabled = value;
    await _prefs?.setBool('disconnectAlerts', value);
    notifyListeners();
  }

  Future<void> setLowBatteryAlerts(bool value) async {
    lowBatteryAlertsEnabled = value;
    await _prefs?.setBool('lowBatteryAlerts', value);
    notifyListeners();
  }

  void setHfpCallAudio(bool value) {
    appleServices = appleServices.copyWith(hfpCallAudioEnabled: value);
    notifyListeners();
  }

  // Health
  void setStepGoal(int goal) {
    health = health.copyWith(stepGoal: goal);
    notifyListeners();
  }

  void toggleHealthSync({
    bool? steps,
    bool? heartRate,
    bool? sleep,
    bool? workouts,
  }) {
    health = health.copyWith(
      syncSteps: steps,
      syncHeartRate: heartRate,
      syncSleep: sleep,
      syncWorkouts: workouts,
    );
    notifyListeners();
  }

  Future<void> measureLiveHeartRate() async {
    if (isMeasuringHeartRate) return;
    isMeasuringHeartRate = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(seconds: 2));
    final nextBpm = 62 + Random().nextInt(18);
    final updatedHistory = [...health.heartRateHistory.skip(1), nextBpm];
    health = health.copyWith(
      heartRateBpm: nextBpm,
      heartRateHistory: updatedHistory,
    );
    isMeasuringHeartRate = false;
    notifyListeners();
  }

  // Calendar, Reminders, Weather, Contacts
  void toggleCalendarEnabled(String id) {
    calendars = calendars
        .map((c) => c.id == id ? c.copyWith(enabled: !c.enabled) : c)
        .toList();
    notifyListeners();
  }

  void toggleReminderListEnabled(String id) {
    reminderLists = reminderLists
        .map((l) => l.id == id ? l.copyWith(enabled: !l.enabled) : l)
        .toList();
    notifyListeners();
  }

  void toggleReminderCompleted(String id) {
    reminders = reminders
        .map((r) => r.id == id ? r.copyWith(completed: !r.completed) : r)
        .toList();
    notifyListeners();
  }

  Future<void> setUseFahrenheit(bool value) async {
    useFahrenheit = value;
    await _prefs?.setBool('useFahrenheit', value);
    notifyListeners();
  }

  void toggleContactSynced(String id) {
    favoriteContacts = favoriteContacts
        .map((c) => c.id == id ? c.copyWith(synced: !c.synced) : c)
        .toList();
    notifyListeners();
  }

  // Settings
  Future<void> setWatchLanguage(String lang) async {
    watchLanguage = lang;
    await _prefs?.setString('watchLanguage', lang);
    notifyListeners();
  }

  Future<void> setUse24HourTime(bool value) async {
    use24HourTime = value;
    await _prefs?.setBool('use24HourTime', value);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    await _prefs?.setString(
      'themeMode',
      switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      },
    );
    notifyListeners();
  }

  Future<void> setProUnlocked(bool value) async {
    isPro = value;
    await _prefs?.setBool('isPro', value);
    notifyListeners();
  }

  String formatTemp(double celsius) {
    if (useFahrenheit) {
      final f = (celsius * 9 / 5) + 32;
      return '${f.round()}°F';
    }
    return '${celsius.round()}°C';
  }

  @override
  void dispose() {
    _ringTimer?.cancel();
    _bleService.stopScan();
    _appleWatchService.dispose();
    super.dispose();
  }
}
