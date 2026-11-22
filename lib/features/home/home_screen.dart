import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/lynio_models.dart';
import '../../state/lynio_controller.dart';
import '../../widgets/watch_face_preview.dart';
import '../sync/sync_screens.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.controller,
    required this.onNavigateTab,
  });

  final LynioController controller;
  final void Function(int index) onNavigateTab;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final cs = Theme.of(context).colorScheme;
        final face = controller.activeWatchFace;
        final slots = controller.slotsForFace(face);
        final currentWeather = controller.weatherSlices.isNotEmpty
            ? controller.weatherSlices.first
            : null;
        final openReminders =
            controller.reminders.where((r) => !r.completed).length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('iHealthFit'),
            actions: [
              IconButton(
                tooltip: 'Sync Now',
                icon: const Icon(Icons.sync_rounded),
                onPressed: () {
                  controller.syncNow();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Synced with watch'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              IconButton(
                tooltip: 'Find My Watch',
                icon: Icon(
                  controller.isRingingWatch
                      ? Icons.notifications_active_rounded
                      : Icons.radar_rounded,
                  color: controller.isRingingWatch ? LynioColors.warning : null,
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => FindWatchScreen(controller: controller),
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            children: [
              // Watch Hero Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => onNavigateTab(1),
                        child: WatchFacePreview(
                          face: face,
                          slots: slots,
                          accentColor: controller.activeFaceAccent,
                          watchModel: controller.pairedWatch,
                          size: 112,
                          steps: controller.health.steps,
                          stepGoal: controller.health.stepGoal,
                          batteryPercent: controller.battery.watchPercent,
                          heartRate: controller.health.heartRateBpm,
                          weatherLabel: currentWeather != null
                              ? controller.formatTemp(currentWeather.temperatureC)
                              : '16°',
                          use24Hour: controller.use24HourTime,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ConnectionBadge(status: controller.connectionStatus),
                            const SizedBox(height: 6),
                            Text(
                              controller.customWatchName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: controller.toggleChargingSimulation,
                              child: Row(
                                children: [
                                  Icon(
                                    controller.battery.isWatchCharging
                                        ? Icons.battery_charging_full_rounded
                                        : Icons.battery_5_bar_rounded,
                                    size: 18,
                                    color: controller.battery.watchPercent < 20
                                        ? LynioColors.danger
                                        : LynioColors.success,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${controller.battery.watchPercent}%${controller.battery.isWatchCharging ? ' • Charging' : ' • ~${controller.battery.estimatedHoursLeft}h left'}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: controller.battery.watchPercent / 100.0,
                                minHeight: 6,
                                backgroundColor:
                                    cs.primary.withValues(alpha: 0.14),
                                color: controller.battery.watchPercent < 20
                                    ? LynioColors.danger
                                    : LynioColors.success,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Last sync ${DateFormat.jm().format(controller.lastSyncedAt)} • Phone ${controller.battery.phonePercent}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (controller.testNotificationStatus != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.notifications_active_rounded,
                          size: 18, color: cs.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.testNotificationStatus!,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: cs.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
              // Quick Actions Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.35,
                children: [
                  _QuickActionTile(
                    icon: controller.isRingingWatch
                        ? Icons.stop_circle_rounded
                        : Icons.ring_volume_rounded,
                    label: controller.isRingingWatch
                        ? 'Stop Ringing'
                        : 'Ring My Watch',
                    active: controller.isRingingWatch,
                    onTap: () => controller.toggleRingWatch(),
                  ),
                  _QuickActionTile(
                    icon: Icons.send_rounded,
                    label: 'Test Alert',
                    onTap: () => controller.sendTestNotification(),
                  ),
                  _QuickActionTile(
                    icon: Icons.bedtime_rounded,
                    label: controller.quietHours.enabled
                        ? 'Quiet Hours On'
                        : 'Quiet Hours Off',
                    active: controller.quietHours.enabled,
                    onTap: () => controller
                        .setQuietHoursEnabled(!controller.quietHours.enabled),
                  ),
                  _QuickActionTile(
                    icon: Icons.watch_rounded,
                    label: 'Watch Faces',
                    onTap: () => onNavigateTab(1),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              // Apple Services & Link Status
              _SectionHeader(
                title: controller.pairedWatch.isAppleWatch
                    ? 'Apple Watch Connectivity'
                    : 'Link & Apple Services',
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.pairedWatch.isAppleWatch
                        ? [
                            _ServiceChip(
                              icon: Icons.watch_rounded,
                              label: 'WCSession',
                              active: controller.appleWatchStatus.paired ||
                                  controller.connectionStatus ==
                                      WatchConnectionStatus.demoMode,
                            ),
                            const _ServiceChip(
                              icon: Icons.favorite_rounded,
                              label: 'HealthKit',
                              active: true,
                            ),
                            const _ServiceChip(
                              icon: Icons.notifications_rounded,
                              label: 'watchOS Alerts',
                              active: true,
                            ),
                            const _ServiceChip(
                              icon: Icons.widgets_rounded,
                              label: 'WidgetKit',
                              active: true,
                            ),
                          ]
                        : [
                            _ServiceChip(
                              icon: Icons.notifications_rounded,
                              label: 'ANCS Alerts',
                              active: controller.appleServices.ancsActive,
                            ),
                            _ServiceChip(
                              icon: Icons.music_note_rounded,
                              label: 'AMS Media',
                              active: controller.appleServices.amsActive,
                            ),
                            _ServiceChip(
                              icon: Icons.phone_in_talk_rounded,
                              label: 'HFP Calls',
                              active:
                                  controller.appleServices.hfpCallAudioEnabled,
                            ),
                            _ServiceChip(
                              icon: Icons.wifi_rounded,
                              label: 'Wi-Fi Fast Link',
                              active: controller.appleServices.wifiChannelReady,
                            ),
                          ],
                  ),
                ),
              ),

              const SizedBox(height: 18),
              // Health Snapshot
              _SectionHeader(
                title: 'Health Today',
                trailing: 'View all',
                onTrailingTap: () => onNavigateTab(3),
              ),
              const SizedBox(height: 8),
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => onNavigateTab(3),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _MiniMetric(
                          icon: Icons.directions_walk_rounded,
                          color: LynioColors.success,
                          value: NumberFormat.decimalPattern()
                              .format(controller.health.steps),
                          label: 'Steps',
                        ),
                        _MiniMetric(
                          icon: Icons.favorite_rounded,
                          color: LynioColors.danger,
                          value: '${controller.health.heartRateBpm}',
                          label: 'BPM',
                        ),
                        _MiniMetric(
                          icon: Icons.bedtime_rounded,
                          color: LynioColors.info,
                          value:
                              '${controller.health.sleepMinutes ~/ 60}h ${controller.health.sleepMinutes % 60}m',
                          label: 'Sleep',
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),
              // Synced Watch Apps Hub
              const _SectionHeader(title: 'Synced Watch Apps'),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const _IconBox(
                        icon: Icons.calendar_month_rounded,
                        color: Color(0xFF0EA5E9),
                      ),
                      title: const Text('Calendar',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        '${controller.calendarEvents.length} upcoming events synced',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              CalendarSyncScreen(controller: controller),
                        ),
                      ),
                    ),
                    const Divider(height: 1, indent: 68),
                    ListTile(
                      leading: const _IconBox(
                        icon: Icons.check_circle_outline_rounded,
                        color: Color(0xFFF59E0B),
                      ),
                      title: const Text('Reminders',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('$openReminders open reminders'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              RemindersSyncScreen(controller: controller),
                        ),
                      ),
                    ),
                    const Divider(height: 1, indent: 68),
                    ListTile(
                      leading: const _IconBox(
                        icon: Icons.wb_sunny_rounded,
                        color: Color(0xFF38BDF8),
                      ),
                      title: const Text('Weather Forecast',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        currentWeather != null
                            ? '${controller.weatherLocationName} • ${controller.formatTemp(currentWeather.temperatureC)}'
                            : 'Forecast ready',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              WeatherSyncScreen(controller: controller),
                        ),
                      ),
                    ),
                    const Divider(height: 1, indent: 68),
                    ListTile(
                      leading: const _IconBox(
                        icon: Icons.people_rounded,
                        color: Color(0xFF22C55E),
                      ),
                      title: const Text('Contacts & Caller ID',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        '${controller.favoriteContacts.where((c) => c.synced).length} favorites synced',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              ContactsSyncScreen(controller: controller),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ConnectionBadge extends StatelessWidget {
  const _ConnectionBadge({required this.status});

  final WatchConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      WatchConnectionStatus.connected => ('Connected', LynioColors.success),
      WatchConnectionStatus.demoMode => ('Demo Mode', LynioColors.accentDark),
      WatchConnectionStatus.connecting => ('Connecting...', LynioColors.warning),
      WatchConnectionStatus.scanning => ('Scanning...', LynioColors.info),
      WatchConnectionStatus.disconnected => ('Disconnected', LynioColors.danger),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: active ? cs.primary.withValues(alpha: 0.14) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: active ? cs.primary : cs.onSurface),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: active ? cs.primary : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  const _ServiceChip({
    required this.icon,
    required this.label,
    required this.active,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? LynioColors.success : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.trailing,
    this.onTrailingTap,
  });

  final String title;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
        if (trailing != null)
          TextButton(
            onPressed: onTrailingTap,
            child: Text(trailing!),
          ),
      ],
    );
  }
}
