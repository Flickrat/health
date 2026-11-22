import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../state/lynio_controller.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key, required this.controller});

  final LynioController controller;

  void _editStepGoal(BuildContext context) {
    double goal = controller.health.stepGoal.toDouble();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Daily Step Goal',
                  style: Theme.of(ctx)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Text(
                  '${NumberFormat.decimalPattern().format(goal.round())} steps',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Slider(
                  value: goal,
                  min: 3000,
                  max: 20000,
                  divisions: 34,
                  onChanged: (v) => setState(() => goal = v),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      controller.setStepGoal(goal.round());
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Update Goal'),
                  ),
                ),
              ],
            ),
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
        final h = controller.health;
        final progress = (h.steps / max(1, h.stepGoal)).clamp(0.0, 1.0);
        final sleepH = h.sleepMinutes ~/ 60;
        final sleepM = h.sleepMinutes % 60;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Health'),
            actions: [
              TextButton(
                onPressed: () => _editStepGoal(context),
                child: const Text('Step Goal'),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            children: [
              // Steps Hero Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 96,
                        height: 96,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 10,
                              strokeCap: StrokeCap.round,
                              backgroundColor:
                                  LynioColors.success.withValues(alpha: 0.16),
                              color: LynioColors.success,
                            ),
                            Center(
                              child: Text(
                                '${(progress * 100).round()}%',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Daily Steps',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              NumberFormat.decimalPattern().format(h.steps),
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Goal: ${NumberFormat.decimalPattern().format(h.stepGoal)} • ${h.activeCalories} kcal',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),
              // Live Heart Rate + Sparkline
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.favorite_rounded,
                              color: LynioColors.danger),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Heart Rate',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: controller.isMeasuringHeartRate
                                ? null
                                : controller.measureLiveHeartRate,
                            icon: controller.isMeasuringHeartRate
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.sensors_rounded, size: 16),
                            label: Text(controller.isMeasuringHeartRate
                                ? 'Sensing...'
                                : 'Live Sense'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${h.heartRateBpm}',
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('BPM'),
                          const Spacer(),
                          Text(
                            'Resting ${h.restingHeartRate} BPM',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 54,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: _SparklinePainter(
                            values: h.heartRateHistory,
                            color: LynioColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),
              // Sleep Card
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: LynioColors.info.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child:
                        const Icon(Icons.bedtime_rounded, color: LynioColors.info),
                  ),
                  title: const Text(
                    'Last Night\'s Sleep',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Deep 1h 48m • REM 1h 52m • Light 3h 52m'),
                  trailing: Text(
                    '${sleepH}h ${sleepM}m',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),
              // Recent Workouts
              const Text(
                'Recent Workouts',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    for (int i = 0; i < h.workouts.length; i++) ...[
                      if (i > 0) const Divider(height: 1, indent: 64),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.12),
                          child: Icon(
                            h.workouts[i].icon,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          h.workouts[i].type,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${h.workouts[i].dateLabel} • Avg ${h.workouts[i].avgHeartRate} BPM',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${h.workouts[i].durationMinutes} min',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '${h.workouts[i].calories} kcal',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 18),
              const Text(
                'Apple Health / Health Connect Sync',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Sync Steps'),
                      value: h.syncSteps,
                      onChanged: (v) => controller.toggleHealthSync(steps: v),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Sync Heart Rate'),
                      value: h.syncHeartRate,
                      onChanged: (v) =>
                          controller.toggleHealthSync(heartRate: v),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Sync Sleep'),
                      value: h.syncSleep,
                      onChanged: (v) => controller.toggleHealthSync(sleep: v),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Sync Workouts'),
                      value: h.syncWorkouts,
                      onChanged: (v) =>
                          controller.toggleHealthSync(workouts: v),
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

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({required this.values, required this.color});

  final List<int> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minVal = values.reduce(min).toDouble() - 5;
    final maxVal = values.reduce(max).toDouble() + 5;
    final span = max(1.0, maxVal - minVal);

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final y = size.height - ((values[i] - minVal) / span) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}
