import 'package:flutter/material.dart';
import '../../core/ble_constants.dart';
import '../../core/theme.dart';
import '../../models/lynio_models.dart';
import '../../state/lynio_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final LynioController controller;

  static const _languages = [
    'English (US)',
    'Deutsch',
    'Español',
    'Français',
    'Italiano',
    '日本語',
    '한국어',
    'Português',
    'Tiếng Việt',
    '中文 (简体)',
  ];

  void _showWatchModelPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: WatchModelInfo.catalog.length,
        itemBuilder: (ctx, index) {
          final m = WatchModelInfo.catalog[index];
          final selected = m.id == controller.pairedWatch.id;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: m.caseColor,
              child: const Icon(Icons.watch_rounded,
                  size: 18, color: Colors.white),
            ),
            title: Text(m.name),
            subtitle: Text(m.brand),
            trailing: selected
                ? Icon(Icons.check_circle_rounded,
                    color: Theme.of(ctx).colorScheme.primary)
                : null,
            onTap: () {
              controller.selectWatchModel(m);
              Navigator.of(ctx).pop();
            },
          );
        },
      ),
    );
  }

  void _showSiriShortcuts(BuildContext context) {
    const phrases = [
      '"Ring my watch with iHealthFit"',
      '"Get watch battery with iHealthFit"',
      '"Get watch connection status with iHealthFit"',
      '"Turn on quiet hours with iHealthFit"',
      '"Mute Slack on the watch with iHealthFit"',
    ];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Siri & Shortcuts',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ring your watch, check its battery, or change settings by voice.',
              ),
              const SizedBox(height: 14),
              for (final p in phrases)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.mic_rounded,
                          size: 18, color: LynioColors.accentDark),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(p,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final apk = controller.companionVersion;
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            children: [
              const Text(
                'Paired Watch',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.watch_rounded),
                      title: Text(controller.customWatchName),
                      subtitle: Text(
                        '${controller.pairedWatch.brand} • Wear OS APK v${apk.versionName}',
                      ),
                      trailing: const Text('Change'),
                      onTap: () => _showWatchModelPicker(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.bluetooth_searching_rounded),
                      title: const Text('Re-run Pairing & Setup Wizard'),
                      subtitle: const Text(
                        'BLE GATT ${LynioBleConstants.lynioServiceUuid}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: controller.resetOnboarding,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                'Watch Preferences',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language_rounded),
                      title: const Text('Watch Language'),
                      trailing: DropdownButton<String>(
                        value: controller.watchLanguage,
                        underline: const SizedBox.shrink(),
                        items: _languages
                            .map((l) =>
                                DropdownMenuItem(value: l, child: Text(l)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) controller.setWatchLanguage(v);
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.schedule_rounded),
                      title: const Text('24-Hour Time Format'),
                      value: controller.use24HourTime,
                      onChanged: controller.setUse24HourTime,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.mic_rounded),
                      title: const Text('Siri & Shortcuts'),
                      subtitle: const Text('Voice commands for watch control'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _showSiriShortcuts(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                'Appearance',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('System'),
                        icon: Icon(Icons.brightness_auto_rounded),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('Light'),
                        icon: Icon(Icons.light_mode_rounded),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('Dark'),
                        icon: Icon(Icons.dark_mode_rounded),
                      ),
                    ],
                    selected: {controller.themeMode},
                    onSelectionChanged: (set) =>
                        controller.setThemeMode(set.first),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                'Support & About',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.help_outline_rounded),
                      title: const Text('Have a question?'),
                      onTap: () => _showSnack(context, 'iHealthFit – Question'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.bug_report_outlined),
                      title: const Text('Bugs or Issues'),
                      onTap: () => _showSnack(context, 'iHealthFit – Bug Report'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.lightbulb_outline_rounded),
                      title: const Text('Share an Idea'),
                      onTap: () => _showSnack(context, 'iHealthFit – Idea'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info_outline_rounded),
                      title: const Text('App Version'),
                      trailing: Text(
                        '1.2.0 (135)',
                        style: Theme.of(context).textTheme.bodySmall,
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

  void _showSnack(BuildContext context, String subject) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$subject — Support composer ready'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
