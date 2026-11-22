import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lynio_flutter/core/theme.dart';
import 'package:lynio_flutter/main.dart';
import 'package:lynio_flutter/models/lynio_models.dart';
import 'package:lynio_flutter/services/apple_watch_service.dart';
import 'package:lynio_flutter/services/ble_watch_service.dart';
import 'package:lynio_flutter/state/lynio_controller.dart';
import 'package:lynio_flutter/widgets/watch_face_preview.dart';

class _NoopBleService extends BleWatchService {
  @override
  Future<void> stopScan() async {}
}

class _NoopAppleWatchService extends AppleWatchService {
  @override
  void listen({required void Function(Map<String, dynamic> payload) onMessage}) {}

  @override
  void dispose() {}
}

Future<void> _loadRealFonts() async {
  const fontDir =
      '/Users/macbookpro/Development/flutter/bin/cache/artifacts/material_fonts';

  final roboto = FontLoader('Roboto');
  for (final name in [
    'Roboto-Regular.ttf',
    'Roboto-Medium.ttf',
    'Roboto-Bold.ttf',
  ]) {
    final file = File('$fontDir/$name');
    if (file.existsSync()) {
      final bytes = await file.readAsBytes();
      roboto.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
  }
  await roboto.load();

  final iconsFile = File('$fontDir/MaterialIcons-Regular.otf');
  if (iconsFile.existsSync()) {
    final icons = FontLoader('MaterialIcons');
    final bytes = await iconsFile.readAsBytes();
    icons.addFont(Future.value(ByteData.view(bytes.buffer)));
    await icons.load();
  }
}

Future<LynioController> _createDemoController({
  required String watchId,
  required ThemeMode themeMode,
}) async {
  SharedPreferences.setMockInitialValues({
    'onboardingCompleted': true,
    'pairedWatchId': watchId,
    'customWatchName': WatchModelInfo.byId(watchId).name,
    'activeWatchFaceId': 'activity',
    'themeMode': themeMode == ThemeMode.dark ? 'dark' : 'light',
  });
  final controller = LynioController(
    bleService: _NoopBleService(),
    appleWatchService: _NoopAppleWatchService(),
  );
  await controller.initialize();
  return controller;
}

Future<void> _capturePhoneOrTabletSet({
  required WidgetTester tester,
  required String folder,
  required Size physicalSize,
  required double dpr,
  required String watchId,
  required ThemeMode themeMode,
}) async {
  tester.view.physicalSize = physicalSize;
  tester.view.devicePixelRatio = dpr;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final controller = await _createDemoController(
    watchId: watchId,
    themeMode: themeMode,
  );

  await tester.pumpWidget(LynioApp(controller: controller));
  await tester.pumpAndSettle();

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../screenshots/$folder/01_home_dashboard.png'),
  );

  await tester.tap(find.text('Faces'));
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../screenshots/$folder/02_watch_faces.png'),
  );

  await tester.tap(find.text('Alerts'));
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../screenshots/$folder/03_notifications_quiet_hours.png'),
  );

  await tester.tap(find.text('Health'));
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../screenshots/$folder/04_health_fitness.png'),
  );

  controller.dispose();
}

void main() {
  setUpAll(() async {
    await _loadRealFonts();
  });

  // 1. iPhone 6.1" (1179 x 2556 @3x)
  testWidgets('Screenshot iPhone 6.1 (1179x2556)', (tester) async {
    await _capturePhoneOrTabletSet(
      tester: tester,
      folder: 'iphone_6_1',
      physicalSize: const Size(1179, 2556),
      dpr: 3.0,
      watchId: 'apple-watch-ultra-2',
      themeMode: ThemeMode.dark,
    );
  });

  // 2. iPad 12.9" (2048 x 2732 @2x)
  testWidgets('Screenshot iPad 12.9 (2048x2732)', (tester) async {
    await _capturePhoneOrTabletSet(
      tester: tester,
      folder: 'ipad_12_9',
      physicalSize: const Size(2048, 2732),
      dpr: 2.0,
      watchId: 'galaxy-watch-ultra-2',
      themeMode: ThemeMode.light,
    );
  });

  // 3. New iphone_duo (2007 x 2853 @3x -> logical 669 x 951)
  testWidgets('Screenshot iphone_duo (2007x2853)', (tester) async {
    await _capturePhoneOrTabletSet(
      tester: tester,
      folder: 'iphone_duo',
      physicalSize: const Size(2007, 2853),
      dpr: 3.0,
      watchId: 'apple-watch-series-10',
      themeMode: ThemeMode.dark,
    );
  });

  // 4. Apple Watch Ultra / watchOS (410 x 502 @2x -> logical 205 x 251)
  testWidgets('Screenshot Apple Watch (410x502)', (tester) async {
    tester.view.physicalSize = const Size(410, 502);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = await _createDemoController(
      watchId: 'apple-watch-ultra-2',
      themeMode: ThemeMode.dark,
    );
    addTearDown(controller.dispose);

    // 4a. watchOS Connected Dashboard (mirrors ios/LynioWatch/ContentView.swift)
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: LynioTheme.dark(),
        home: const _AppleWatchStatusScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../screenshots/apple_watch/01_watch_connected.png'),
    );

    // 4b. watchOS Activity Dial
    final activityFace = controller.watchFaces
        .firstWhere((f) => f.id == 'activity', orElse: () => controller.watchFaces.first);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: LynioTheme.dark(),
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: WatchFacePreview(
              face: activityFace,
              slots: controller.slotsForFace(activityFace),
              accentColor: LynioColors.accentDark,
              watchModel: WatchModelInfo.byId('apple-watch-ultra-2'),
              size: 184,
              steps: 7842,
              stepGoal: 10000,
              batteryPercent: 84,
              heartRate: 68,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../screenshots/apple_watch/02_watch_face_activity.png'),
    );

    // 4c. watchOS Find My Watch
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: LynioTheme.dark(),
        home: const _AppleWatchRingScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../screenshots/apple_watch/03_watch_find_my_watch.png'),
    );
  });

  // 5. Wear OS Circular (450 x 450 @2x -> logical 225 x 225)
  testWidgets('Screenshot Wear OS (450x450)', (tester) async {
    tester.view.physicalSize = const Size(450, 450);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = await _createDemoController(
      watchId: 'galaxy-watch-7',
      themeMode: ThemeMode.dark,
    );
    addTearDown(controller.dispose);

    final activityFace = controller.watchFaces
        .firstWhere((f) => f.id == 'activity', orElse: () => controller.watchFaces.first);
    final dashboardFace = controller.watchFaces
        .firstWhere((f) => f.id == 'dashboard', orElse: () => controller.watchFaces.first);

    // 5a. Wear OS Activity Watch Face
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: LynioTheme.dark(),
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: WatchFacePreview(
              face: activityFace,
              slots: controller.slotsForFace(activityFace),
              accentColor: LynioColors.accentDark,
              watchModel: WatchModelInfo.byId('galaxy-watch-7'),
              size: 214,
              steps: 7842,
              stepGoal: 10000,
              batteryPercent: 84,
              heartRate: 68,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../screenshots/wear_os/01_wearos_activity_face.png'),
    );

    // 5b. Wear OS Dashboard Watch Face
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: LynioTheme.dark(),
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: WatchFacePreview(
              face: dashboardFace,
              slots: controller.slotsForFace(dashboardFace),
              accentColor: const Color(0xFF38BDF8),
              watchModel: WatchModelInfo.byId('pixel-watch-3'),
              size: 214,
              steps: 7842,
              stepGoal: 10000,
              batteryPercent: 84,
              heartRate: 68,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../screenshots/wear_os/02_wearos_dashboard_face.png'),
    );

    // 5c. Wear OS Companion Status Screen
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: LynioTheme.dark(),
        home: const _WearOsStatusScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../screenshots/wear_os/03_wearos_connected_status.png'),
    );
  });
}

class _AppleWatchStatusScreen extends StatelessWidget {
  const _AppleWatchStatusScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'iHealthFit',
                  style: TextStyle(
                    color: LynioColors.accentDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '10:09',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF151E1D),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  CircleAvatar(radius: 4, backgroundColor: LynioColors.success),
                  SizedBox(width: 8),
                  Text(
                    'iPhone Connected',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const _WatchRow(label: 'Steps', value: '7,842', color: LynioColors.success),
            const _WatchRow(label: 'Heart Rate', value: '68 BPM', color: LynioColors.danger),
            const _WatchRow(label: 'Battery', value: '84%', color: LynioColors.info),
            const _WatchRow(label: 'Quiet Hours', value: 'On', color: LynioColors.warning),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: LynioColors.accentDark,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  'Sync Now',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppleWatchRingScreen extends StatelessWidget {
  const _AppleWatchRingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: LynioColors.warning.withValues(alpha: 0.2),
                border: Border.all(color: LynioColors.warning, width: 2.5),
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: LynioColors.warning,
                size: 36,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Find My Watch',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ringing via WCSession',
              style: TextStyle(color: Colors.white60, fontSize: 11),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: LynioColors.danger,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  'Stop Ringing',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WearOsStatusScreen extends StatelessWidget {
  const _WearOsStatusScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 214,
          height: 214,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0E1615),
            border: Border.all(color: LynioColors.accentDark, width: 3),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.watch_rounded, color: LynioColors.accentDark, size: 28),
              SizedBox(height: 6),
              Text(
                'iHealthFit Link',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'iPhone Connected',
                style: TextStyle(
                  color: LynioColors.success,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 10),
              _WatchRow(label: 'ANCS', value: 'Active', color: LynioColors.success),
              _WatchRow(label: 'Battery', value: '84%', color: LynioColors.info),
              _WatchRow(label: 'Steps', value: '7.8k', color: LynioColors.accentDark),
            ],
          ),
        ),
      ),
    );
  }
}

class _WatchRow extends StatelessWidget {
  const _WatchRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
