import 'package:flutter/material.dart';
import '../../core/ble_constants.dart';
import '../../core/theme.dart';
import '../../models/lynio_models.dart';
import '../../state/lynio_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.controller});

  final LynioController controller;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _step = 0;
  WatchModelInfo _selectedModel = WatchModelInfo.byId('galaxy-watch-7');
  String _searchQuery = '';

  void _nextStep() {
    if (_step < 3) {
      setState(() => _step++);
      _pageController.animateToPage(
        _step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _prevStep() {
    if (_step > 0) {
      setState(() => _step--);
      _pageController.animateToPage(
        _step,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: _prevStep,
              )
            : null,
        title: Text('Step ${_step + 1} of 4'),
        actions: [
          TextButton(
            onPressed: () => widget.controller.completeOnboarding(
              model: _selectedModel,
              demoMode: true,
            ),
            child: const Text('Demo Mode'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (_step + 1) / 4,
                minHeight: 5,
                backgroundColor: cs.primary.withValues(alpha: 0.14),
              ),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildWelcomeStep(context),
                _buildWatchPickerStep(context),
                _buildCompanionInstallStep(context),
                _buildPairStep(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeStep(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 12),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/images/app_icon.png',
              width: 84,
              height: 84,
              errorBuilder: (_, _, _) => Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.watch_rounded,
                    size: 44, color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Connect your Smart Watch',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Supports Apple Watch (watchOS via WatchConnectivity) and Wear OS watches (Galaxy, Pixel, OnePlus, Xiaomi & more).',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 28),
        const _BenefitTile(
          icon: Icons.notifications_active_rounded,
          title: 'Notifications & Quiet Hours',
          subtitle: 'Per-app ANCS filters, mute controls, and call audio.',
        ),
        const _BenefitTile(
          icon: Icons.favorite_rounded,
          title: 'Health & Fitness Sync',
          subtitle: 'Steps, heart rate, sleep, and workouts synced automatically.',
        ),
        const _BenefitTile(
          icon: Icons.watch_rounded,
          title: '40 Custom Watch Faces',
          subtitle: 'Interactive complications, accents, and photo faces.',
        ),
        const _BenefitTile(
          icon: Icons.calendar_month_rounded,
          title: 'Calendar, Reminders & Weather',
          subtitle: 'Your schedule and forecast stay on-device and private.',
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _nextStep,
          child: const Text('Get Started'),
        ),
      ],
    );
  }

  Widget _buildWatchPickerStep(BuildContext context) {
    final filtered = WatchModelInfo.catalog.where((w) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return w.name.toLowerCase().contains(q) ||
          w.brand.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose your watch',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search Apple Watch, Galaxy, Pixel, OnePlus...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final watch = filtered[index];
              final selected = watch.id == _selectedModel.id;
              return Card(
                color: selected
                    ? Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.12)
                    : null,
                child: ListTile(
                  onTap: () => setState(() => _selectedModel = watch),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: watch.isSquare
                          ? BoxShape.rectangle
                          : BoxShape.circle,
                      borderRadius:
                          watch.isSquare ? BorderRadius.circular(11) : null,
                      color: watch.caseColor,
                      border: Border.all(color: watch.bezelColor, width: 3),
                    ),
                    child: const Icon(Icons.watch_rounded,
                        size: 18, color: Colors.white),
                  ),
                  title: Text(
                    watch.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${watch.brand} • ${watch.isAppleWatch ? 'watchOS' : 'Wear OS'}',
                  ),
                  trailing: selected
                      ? Icon(Icons.check_circle_rounded,
                          color: Theme.of(context).colorScheme.primary)
                      : null,
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _nextStep,
              child: Text('Continue with ${_selectedModel.name}'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompanionInstallStep(BuildContext context) {
    if (_selectedModel.isAppleWatch) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Set up iHealthFit on Apple Watch',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Apple Watch connects directly over Apple\'s native WatchConnectivity (WCSession) — no Wireless ADB or APK sideloading needed.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          const _SetupStepCard(
            stepNumber: '1',
            title: 'Pair with Apple Watch App',
            detail:
                'Make sure your Apple Watch is paired with this iPhone in Apple\'s built-in Watch app.',
          ),
          const SizedBox(height: 12),
          const _SetupStepCard(
            stepNumber: '2',
            title: 'Install iHealthFit Watch Companion',
            detail:
                'Open the Watch app on iPhone → scroll to iHealthFit → tap Install.',
          ),
          const SizedBox(height: 12),
          const _SetupStepCard(
            stepNumber: '3',
            title: 'Automatic WCSession Sync',
            detail:
                'Health stats, quiet hours, reminders, ring alerts, and watch state sync securely over WatchConnectivity.',
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _nextStep,
            child: const Text('Continue to Connect'),
          ),
        ],
      );
    }

    final apk = widget.controller.companionVersion;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Install iHealthFit on your watch',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'iHealthFit installs its lightweight Wear OS companion (v${apk.versionName}, Wear OS 3+ / API ${apk.minSdkVersion}) over local Wi-Fi using Wireless Debugging.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        const _SetupStepCard(
          stepNumber: '1',
          title: 'Enable Developer Options',
          detail:
              'On your watch, open Settings → About watch → Software info and tap Build number 7 times.',
        ),
        const SizedBox(height: 12),
        const _SetupStepCard(
          stepNumber: '2',
          title: 'Turn on Wireless Debugging',
          detail:
              'Connect your watch to the same Wi-Fi network as your phone, then enable ADB & Wireless debugging in Developer options.',
        ),
        const SizedBox(height: 12),
        _SetupStepCard(
          stepNumber: '3',
          title: 'Pair via Local Network',
          detail:
              'iHealthFit discovers ${LynioBleConstants.adbTlsPairingService} automatically and pairs with your Wear OS watch.',
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _nextStep,
          child: const Text('Watch App Is Ready → Pair'),
        ),
      ],
    );
  }

  Widget _buildPairStep(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final ctrl = widget.controller;
        final isAppleWatch = _selectedModel.isAppleWatch;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Pair ${_selectedModel.name}',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              isAppleWatch
                  ? 'Connect to your paired Apple Watch via Apple WatchConnectivity (WCSession) or launch interactive Demo Mode.'
                  : 'Scan for your watch over Bluetooth Low Energy (GATT Service E7A20001) or jump straight into interactive Demo Mode.',
            ),
            const SizedBox(height: 20),
            if (isAppleWatch)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.watch_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Apple WatchConnectivity',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          FilledButton.tonal(
                            onPressed: ctrl.isCheckingAppleWatch
                                ? null
                                : () async {
                                    final ok = await ctrl.connectAppleWatch();
                                    if (ok) {
                                      await ctrl.completeOnboarding(
                                        model: _selectedModel,
                                        demoMode: false,
                                      );
                                    }
                                  },
                            child: Text(ctrl.isCheckingAppleWatch
                                ? 'Checking...'
                                : 'Connect'),
                          ),
                        ],
                      ),
                      if (ctrl.bleStatusMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          ctrl.bleStatusMessage!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              )
            else
              Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.bluetooth_searching_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Nearby Bluetooth Devices',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: ctrl.isScanningBle
                              ? null
                              : () => ctrl.startBleScan(),
                          icon: ctrl.isScanningBle
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Icon(Icons.refresh_rounded, size: 18),
                          label: Text(ctrl.isScanningBle ? 'Scanning' : 'Scan'),
                        ),
                      ],
                    ),
                    if (ctrl.bleStatusMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        ctrl.bleStatusMessage!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (ctrl.discoveredDevices.isNotEmpty) ...[
                      const Divider(height: 20),
                      for (final dev in ctrl.discoveredDevices)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            dev.advertisesLynio
                                ? Icons.watch_rounded
                                : Icons.bluetooth_rounded,
                            color: dev.advertisesLynio
                                ? LynioColors.success
                                : null,
                          ),
                          title: Text(dev.name),
                          subtitle: Text(
                            'RSSI ${dev.rssi} dBm${dev.advertisesLynio ? ' • iHealthFit Ready' : ''}',
                          ),
                          trailing: FilledButton.tonal(
                            onPressed: () async {
                              final ok = await ctrl.connectToBleDevice(dev);
                              if (ok) {
                                await ctrl.completeOnboarding(
                                  model: _selectedModel,
                                  demoMode: false,
                                );
                              }
                            },
                            child: const Text('Connect'),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => ctrl.completeOnboarding(
                model: _selectedModel,
                demoMode: true,
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Launch Interactive Demo Mode'),
            ),
          ],
        );
      },
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: cs.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
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
    );
  }
}

class _SetupStepCard extends StatelessWidget {
  const _SetupStepCard({
    required this.stepNumber,
    required this.title,
    required this.detail,
  });

  final String stepNumber;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              child: Text(
                stepNumber,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    detail,
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
    );
  }
}
