import 'package:flutter/material.dart';
import '../../state/lynio_controller.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, required this.controller});

  final LynioController controller;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _search = '';

  Future<void> _pickQuietTime(bool isStart) async {
    final current = isStart
        ? widget.controller.quietHours.start
        : widget.controller.quietHours.end;
    final picked = await showTimePicker(
      context: context,
      initialTime: current,
    );
    if (picked != null) {
      widget.controller.setQuietHoursTime(
        start: isStart ? picked : null,
        end: isStart ? null : picked,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final ctrl = widget.controller;
        final apps = ctrl.notificationApps.where((a) {
          if (_search.isEmpty) return true;
          final q = _search.toLowerCase();
          return a.name.toLowerCase().contains(q) ||
              a.category.toLowerCase().contains(q);
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
            actions: [
              TextButton.icon(
                onPressed: () => ctrl.sendTestNotification(),
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Test'),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            children: [
              if (ctrl.testNotificationStatus != null) ...[
                Card(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.14),
                  child: ListTile(
                    leading: Icon(
                      Icons.notifications_active_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      ctrl.testNotificationStatus!,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Quiet Hours
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.bedtime_rounded),
                      title: const Text(
                        'Quiet Hours',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        ctrl.quietHours.enabled
                            ? 'Silence watch alerts from ${ctrl.quietHours.start.format(context)} to ${ctrl.quietHours.end.format(context)}'
                            : 'Watch alerts ring at any time',
                      ),
                      value: ctrl.quietHours.enabled,
                      onChanged: ctrl.setQuietHoursEnabled,
                    ),
                    if (ctrl.quietHours.enabled) ...[
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickQuietTime(true),
                                icon: const Icon(Icons.nights_stay_outlined,
                                    size: 16),
                                label: Text(
                                    'Start ${ctrl.quietHours.start.format(context)}'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickQuietTime(false),
                                icon: const Icon(Icons.wb_twilight_rounded,
                                    size: 16),
                                label: Text(
                                    'End ${ctrl.quietHours.end.format(context)}'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 14),
              // System & Call Alerts
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.phone_in_talk_rounded),
                      title: const Text(
                        'Call Audio on Watch',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle:
                          const Text('Route Bluetooth HFP calls to your watch'),
                      value: ctrl.appleServices.hfpCallAudioEnabled,
                      onChanged: ctrl.setHfpCallAudio,
                    ),
                    const Divider(height: 1, indent: 56),
                    SwitchListTile(
                      secondary: const Icon(Icons.link_off_rounded),
                      title: const Text(
                        'Disconnect Alerts',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Notify when your watch disconnects from your phone',
                      ),
                      value: ctrl.disconnectAlertsEnabled,
                      onChanged: ctrl.setDisconnectAlerts,
                    ),
                    const Divider(height: 1, indent: 56),
                    SwitchListTile(
                      secondary: const Icon(Icons.battery_alert_rounded),
                      title: const Text(
                        'Low Battery Alerts',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Notify when your watch battery drops below 20%',
                      ),
                      value: ctrl.lowBatteryAlertsEnabled,
                      onChanged: ctrl.setLowBatteryAlerts,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'App Notification Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Filter apps...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
              const SizedBox(height: 10),
              Card(
                child: Column(
                  children: [
                    for (int i = 0; i < apps.length; i++) ...[
                      if (i > 0) const Divider(height: 1, indent: 64),
                      SwitchListTile(
                        secondary: CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.12),
                          child: Icon(
                            apps[i].icon,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          apps[i].name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          apps[i].muted
                              ? 'Muted on watch'
                              : '${apps[i].category} • ${apps[i].recentCount} today',
                        ),
                        value: !apps[i].muted,
                        onChanged: (_) => ctrl.toggleAppMuted(apps[i].bundleId),
                      ),
                    ],
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
