import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/lynio_models.dart';
import '../../state/lynio_controller.dart';

class CalendarSyncScreen extends StatelessWidget {
  const CalendarSyncScreen({super.key, required this.controller});

  final LynioController controller;

  String _dayLabel(int offset) {
    if (offset == 0) return 'Today';
    if (offset == 1) return 'Tomorrow';
    final d = DateTime.now().add(Duration(days: offset));
    return DateFormat('EEE, MMM d').format(d);
  }

  String _timeRange(CalendarEventItem e) {
    if (e.allDay || e.startMinutes == null) return 'All day';
    final startH = e.startMinutes! ~/ 60;
    final startM = e.startMinutes! % 60;
    final start = DateTime(2026, 1, 1, startH, startM);
    final end = start.add(Duration(minutes: e.durationMinutes ?? 30));
    final fmt = controller.use24HourTime ? DateFormat.Hm() : DateFormat.jm();
    return '${fmt.format(start)} – ${fmt.format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final enabledCalIds =
            controller.calendars.where((c) => c.enabled).map((c) => c.id).toSet();
        final visibleEvents = controller.calendarEvents
            .where((e) => enabledCalIds.contains(e.calendarId))
            .toList()
          ..sort((a, b) => a.dayOffset.compareTo(b.dayOffset));

        return Scaffold(
          appBar: AppBar(title: const Text('Calendar Sync')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Calendars',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    for (int i = 0; i < controller.calendars.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      SwitchListTile(
                        secondary: CircleAvatar(
                          radius: 8,
                          backgroundColor: controller.calendars[i].color,
                        ),
                        title: Text(controller.calendars[i].title),
                        subtitle: Text(controller.calendars[i].source),
                        value: controller.calendars[i].enabled,
                        onChanged: (_) => controller
                            .toggleCalendarEnabled(controller.calendars[i].id),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Upcoming Events (${visibleEvents.length})',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    for (int i = 0; i < visibleEvents.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      ListTile(
                        leading: Container(
                          width: 4,
                          height: 36,
                          decoration: BoxDecoration(
                            color: controller.calendars
                                .firstWhere(
                                  (c) => c.id == visibleEvents[i].calendarId,
                                  orElse: () => controller.calendars.first,
                                )
                                .color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        title: Text(
                          visibleEvents[i].title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${_dayLabel(visibleEvents[i].dayOffset)} • ${_timeRange(visibleEvents[i])}${visibleEvents[i].location != null ? ' • ${visibleEvents[i].location}' : ''}',
                        ),
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

class RemindersSyncScreen extends StatelessWidget {
  const RemindersSyncScreen({super.key, required this.controller});

  final LynioController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final enabledListIds = controller.reminderLists
            .where((l) => l.enabled)
            .map((l) => l.id)
            .toSet();
        final visible = controller.reminders
            .where((r) => enabledListIds.contains(r.listId))
            .toList();

        return Scaffold(
          appBar: AppBar(title: const Text('Reminders Sync')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Reminder Lists',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    for (int i = 0; i < controller.reminderLists.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      SwitchListTile(
                        secondary: CircleAvatar(
                          radius: 8,
                          backgroundColor: controller.reminderLists[i].color,
                        ),
                        title: Text(controller.reminderLists[i].title),
                        subtitle: Text(controller.reminderLists[i].source),
                        value: controller.reminderLists[i].enabled,
                        onChanged: (_) => controller.toggleReminderListEnabled(
                            controller.reminderLists[i].id),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Synced Items (Tap to complete)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    for (int i = 0; i < visible.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      CheckboxListTile(
                        value: visible[i].completed,
                        onChanged: (_) =>
                            controller.toggleReminderCompleted(visible[i].id),
                        title: Text(
                          visible[i].title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            decoration: visible[i].completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: visible[i].dayOffset != null
                            ? Text(
                                visible[i].dayOffset! < 0
                                    ? 'Overdue'
                                    : visible[i].dayOffset == 0
                                        ? 'Due today'
                                        : 'In ${visible[i].dayOffset} day(s)',
                              )
                            : null,
                        secondary: visible[i].priority > 0
                            ? const Icon(Icons.priority_high_rounded,
                                color: LynioColors.danger)
                            : null,
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

class WeatherSyncScreen extends StatelessWidget {
  const WeatherSyncScreen({super.key, required this.controller});

  final LynioController controller;

  IconData _weatherIcon(String symbol) {
    if (symbol.contains('rain')) return Icons.water_drop_rounded;
    if (symbol.contains('cloud')) return Icons.cloud_rounded;
    if (symbol.contains('night')) return Icons.nights_stay_rounded;
    return Icons.wb_sunny_rounded;
  }

  String _weatherLabel(String symbol) {
    return symbol
        .replaceAll('_day', '')
        .replaceAll('_night', '')
        .replaceAll('partlycloudy', 'Partly Cloudy')
        .replaceAll('clearsky', 'Clear Sky')
        .replaceAll('heavyrain', 'Heavy Rain')
        .replaceAll('fair', 'Fair')
        .replaceAll('cloudy', 'Cloudy')
        .replaceAll('rain', 'Rain');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final slices = controller.weatherSlices;
        final nowSlice = slices.isNotEmpty ? slices.first : null;
        final hourly = slices.take(12).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Weather Forecast'),
            actions: [
              TextButton(
                onPressed: () =>
                    controller.setUseFahrenheit(!controller.useFahrenheit),
                child: Text(controller.useFahrenheit ? '°F' : '°C'),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (nowSlice != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          controller.weatherLocationName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Icon(
                          _weatherIcon(nowSlice.symbolCode),
                          size: 54,
                          color: LynioColors.warning,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.formatTemp(nowSlice.temperatureC),
                          style: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(_weatherLabel(nowSlice.symbolCode)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              const Text(
                'Hourly Forecast',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 112,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: hourly.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final s = hourly[index];
                    return Card(
                      child: SizedBox(
                        width: 78,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat.j().format(s.time.toLocal()),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Icon(
                                _weatherIcon(s.symbolCode),
                                size: 22,
                                color: LynioColors.info,
                              ),
                              Text(
                                controller.formatTemp(s.temperatureC),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              Card(
                child: SwitchListTile(
                  title: const Text('Use Fahrenheit (°F)'),
                  subtitle: const Text('Synced with watch weather complication'),
                  value: controller.useFahrenheit,
                  onChanged: controller.setUseFahrenheit,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ContactsSyncScreen extends StatelessWidget {
  const ContactsSyncScreen({super.key, required this.controller});

  final LynioController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Contacts & Caller ID')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Selected contacts appear by name on incoming calls and quick dial on your watch.',
              ),
              const SizedBox(height: 14),
              Card(
                child: Column(
                  children: [
                    for (int i = 0;
                        i < controller.favoriteContacts.length;
                        i++) ...[
                      if (i > 0) const Divider(height: 1),
                      SwitchListTile(
                        secondary: CircleAvatar(
                          child: Text(controller.favoriteContacts[i].name[0]),
                        ),
                        title: Text(
                          controller.favoriteContacts[i].name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${controller.favoriteContacts[i].label} • ${controller.favoriteContacts[i].phone}',
                        ),
                        value: controller.favoriteContacts[i].synced,
                        onChanged: (_) => controller
                            .toggleContactSynced(controller.favoriteContacts[i].id),
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

class FindWatchScreen extends StatelessWidget {
  const FindWatchScreen({super.key, required this.controller});

  final LynioController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final ringing = controller.isRingingWatch;
        final proximityText = switch (controller.proximityLevel) {
          ProximityLevel.close => 'Close',
          ProximityLevel.near => 'Near',
          ProximityLevel.far => 'Far',
          ProximityLevel.unknown => 'Searching...',
        };

        return Scaffold(
          appBar: AppBar(title: const Text('Find My Watch')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: ringing ? 190 : 150,
                    height: ringing ? 190 : 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (ringing
                              ? LynioColors.warning
                              : Theme.of(context).colorScheme.primary)
                          .withValues(alpha: 0.16),
                      border: Border.all(
                        color: ringing
                            ? LynioColors.warning
                            : Theme.of(context).colorScheme.primary,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      ringing
                          ? Icons.notifications_active_rounded
                          : Icons.watch_rounded,
                      size: 64,
                      color: ringing
                          ? LynioColors.warning
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    ringing
                        ? 'Ringing ${controller.customWatchName}...'
                        : controller.customWatchName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Proximity: $proximityText (${controller.proximityRssi} dBm)',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: ringing
                          ? FilledButton.styleFrom(
                              backgroundColor: LynioColors.danger,
                              foregroundColor: Colors.white,
                            )
                          : null,
                      onPressed: controller.toggleRingWatch,
                      icon: Icon(
                        ringing
                            ? Icons.stop_rounded
                            : Icons.ring_volume_rounded,
                      ),
                      label: Text(ringing ? 'Stop Ringing' : 'Ring My Watch'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
