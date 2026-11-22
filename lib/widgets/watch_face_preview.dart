import 'dart:math';
import 'package:flutter/material.dart';
import '../models/lynio_models.dart';

/// Renders any of Lynio's 40 watch faces on a circular Wear OS bezel,
/// placing each complication slot using the exact 450x450 coordinates
/// from `watch-face-slots.json`.
class WatchFacePreview extends StatelessWidget {
  const WatchFacePreview({
    super.key,
    required this.face,
    required this.slots,
    required this.accentColor,
    required this.watchModel,
    this.size = 220,
    this.steps = 7842,
    this.stepGoal = 10000,
    this.batteryPercent = 84,
    this.heartRate = 68,
    this.weatherLabel = '16°',
    this.use24Hour = false,
    this.interactive = false,
    this.onSlotTap,
  });

  final WatchFaceDefinition face;
  final List<WatchFaceSlot> slots;
  final Color accentColor;
  final WatchModelInfo watchModel;
  final double size;
  final int steps;
  final int stepGoal;
  final int batteryPercent;
  final int heartRate;
  final String weatherLabel;
  final bool use24Hour;
  final bool interactive;
  final void Function(WatchFaceSlot slot)? onSlotTap;

  @override
  Widget build(BuildContext context) {
    final bezelWidth = size * 0.065;
    final dialSize = size - bezelWidth * 2;
    final scale = dialSize / 450.0;
    final isSquare = watchModel.isSquare;
    final cornerRadius = size * 0.24;
    final dialCornerRadius = dialSize * 0.22;

    final dial = SizedBox(
      width: dialSize,
      height: dialSize,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _WatchFaceDialPainter(
                face: face,
                accentColor: accentColor,
                use24Hour: use24Hour,
              ),
            ),
          ),
          for (final slot in slots)
            Positioned(
              left: slot.x * scale,
              top: slot.y * scale,
              width: slot.w * scale,
              height: slot.h * scale,
              child: _SlotWidget(
                slot: slot,
                accentColor: accentColor,
                steps: steps,
                stepGoal: stepGoal,
                batteryPercent: batteryPercent,
                heartRate: heartRate,
                weatherLabel: weatherLabel,
                interactive: interactive,
                onTap: onSlotTap == null ? null : () => onSlotTap!(slot),
              ),
            ),
        ],
      ),
    );

    final body = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: isSquare ? BorderRadius.circular(cornerRadius) : null,
        color: watchModel.caseColor,
        border: Border.all(
          color: watchModel.bezelColor,
          width: bezelWidth * 0.65,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: size * 0.12,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: Center(
        child: isSquare
            ? ClipRRect(
                borderRadius: BorderRadius.circular(dialCornerRadius),
                child: dial,
              )
            : ClipOval(child: dial),
      ),
    );

    if (!isSquare) return body;

    // Add Apple Watch Digital Crown + side button on the right edge
    final crownWidth = max(4.0, size * 0.045);
    return SizedBox(
      width: size + crownWidth,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          body,
          Positioned(
            right: 0,
            top: size * 0.24,
            child: Container(
              width: crownWidth,
              height: size * 0.16,
              decoration: BoxDecoration(
                color: watchModel.bezelColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Positioned(
            right: crownWidth * 0.25,
            top: size * 0.48,
            child: Container(
              width: crownWidth * 0.65,
              height: size * 0.22,
              decoration: BoxDecoration(
                color: watchModel.caseColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotWidget extends StatelessWidget {
  const _SlotWidget({
    required this.slot,
    required this.accentColor,
    required this.steps,
    required this.stepGoal,
    required this.batteryPercent,
    required this.heartRate,
    required this.weatherLabel,
    required this.interactive,
    this.onTap,
  });

  final WatchFaceSlot slot;
  final Color accentColor;
  final int steps;
  final int stepGoal;
  final int batteryPercent;
  final int heartRate;
  final String weatherLabel;
  final bool interactive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isConcentric = slot.w > 220;
    if (isConcentric) {
      final progress = switch (slot.role) {
        'steps' => (steps / max(1, stepGoal)).clamp(0.05, 1.0),
        'battery' => (batteryPercent / 100.0).clamp(0.05, 1.0),
        'heart_rate' => (heartRate / 180.0).clamp(0.1, 1.0),
        _ => 0.72,
      };
      final ringColor = switch (slot.role) {
        'steps' => const Color(0xFF22C55E),
        'battery' => const Color(0xFF38BDF8),
        'heart_rate' => const Color(0xFFF43F5E),
        _ => accentColor,
      };
      return IgnorePointer(
        ignoring: !interactive,
        child: CustomPaint(
          painter: _ConcentricRingPainter(
            progress: progress,
            color: ringColor,
          ),
        ),
      );
    }

    final (icon, text, color) = switch (slot.role) {
      'steps' => (
          Icons.directions_walk_rounded,
          '${(steps / 1000).toStringAsFixed(1)}k',
          const Color(0xFF22C55E),
        ),
      'battery' => (
          Icons.bolt_rounded,
          '$batteryPercent%',
          const Color(0xFF38BDF8),
        ),
      'heart_rate' => (
          Icons.favorite_rounded,
          '$heartRate',
          const Color(0xFFF43F5E),
        ),
      'goal' => (
          Icons.flag_rounded,
          '${((steps / max(1, stepGoal)) * 100).round()}%',
          const Color(0xFFF59E0B),
        ),
      'weather' => (
          Icons.wb_sunny_rounded,
          weatherLabel,
          const Color(0xFFFBBF24),
        ),
      'date' => (
          Icons.calendar_today_rounded,
          '${DateTime.now().day}',
          Colors.white,
        ),
      _ => (
          Icons.add_rounded,
          interactive ? 'Slot' : '',
          Colors.white54,
        ),
    };

    final child = Container(
      decoration: BoxDecoration(
        shape: slot.style == 'ring' ? BoxShape.circle : BoxShape.rectangle,
        borderRadius:
            slot.style == 'ring' ? null : BorderRadius.circular(100),
        color: slot.role == 'empty' && !interactive
            ? Colors.transparent
            : Colors.black.withValues(alpha: 0.42),
        border: Border.all(
          color: slot.role == 'empty'
              ? (interactive
                  ? accentColor.withValues(alpha: 0.7)
                  : Colors.transparent)
              : color.withValues(alpha: 0.55),
          width: interactive ? 1.5 : 1.0,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: slot.style == 'ring'
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14, color: color),
                    if (text.isNotEmpty)
                      Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 12, color: color),
                    if (text.isNotEmpty) ...[
                      const SizedBox(width: 2),
                      Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );

    if (!interactive || onTap == null) return child;
    return GestureDetector(onTap: onTap, child: child);
  }
}

class _ConcentricRingPainter extends CustomPainter {
  const _ConcentricRingPainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = max(4.0, size.width * 0.055);
    final rect = Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);

    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawOval(rect, trackPaint);

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _ConcentricRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class _WatchFaceDialPainter extends CustomPainter {
  const _WatchFaceDialPainter({
    required this.face,
    required this.accentColor,
    required this.use24Hour,
  });

  final WatchFaceDefinition face;
  final Color accentColor;
  final bool use24Hour;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background style per face family
    final bgGradient = _backgroundForFace(face.id, accentColor);
    final bgPaint = Paint()
      ..shader = bgGradient.createShader(Offset.zero & size);
    canvas.drawCircle(center, radius, bgPaint);

    final now = DateTime.now();
    final isAnalog = face.category == 'Analog' ||
        face.id == 'photoAnalog' ||
        face.id == 'bauhaus' ||
        face.id == 'nocturne' ||
        face.id == 'moon';

    // Tick marks for analog or sport faces
    if (isAnalog || face.id == 'chronograph' || face.id == 'dive') {
      final tickPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < 12; i++) {
        final angle = (i * 30) * pi / 180;
        final inner = radius * (i % 3 == 0 ? 0.78 : 0.85);
        final outer = radius * 0.92;
        canvas.drawLine(
          center + Offset(cos(angle) * inner, sin(angle) * inner),
          center + Offset(cos(angle) * outer, sin(angle) * outer),
          tickPaint..strokeWidth = i % 3 == 0 ? 2.4 : 1.2,
        );
      }

      // Analog hands (10:09 style or live time)
      final hourAngle =
          ((now.hour % 12) + now.minute / 60.0) * 30 * pi / 180 - pi / 2;
      final minuteAngle = (now.minute + now.second / 60.0) * 6 * pi / 180 - pi / 2;

      final hourPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = size.width * 0.032
        ..strokeCap = StrokeCap.round;
      final minutePaint = Paint()
        ..color = accentColor
        ..strokeWidth = size.width * 0.022
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        center,
        center + Offset(cos(hourAngle) * radius * 0.48, sin(hourAngle) * radius * 0.48),
        hourPaint,
      );
      canvas.drawLine(
        center,
        center + Offset(cos(minuteAngle) * radius * 0.70, sin(minuteAngle) * radius * 0.70),
        minutePaint,
      );
      canvas.drawCircle(center, size.width * 0.032, Paint()..color = accentColor);
    } else {
      // Digital clock readout
      final hour = use24Hour
          ? now.hour.toString().padLeft(2, '0')
          : (now.hour % 12 == 0 ? 12 : now.hour % 12).toString().padLeft(2, '0');
      final minute = now.minute.toString().padLeft(2, '0');
      final timeText = '$hour:$minute';

      final tp = TextPainter(
        text: TextSpan(
          text: timeText,
          style: TextStyle(
            fontFamily: 'Roboto',
            color: face.id == 'terminal' || face.id == 'neon'
                ? accentColor
                : Colors.white,
            fontSize: size.width * (face.id == 'largetype' ? 0.28 : 0.21),
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final yOffset = switch (face.id) {
        'photoTop' => center.dy - radius * 0.45 - tp.height / 2,
        'photoBottom' => center.dy + radius * 0.35 - tp.height / 2,
        _ => center.dy - tp.height / 2,
      };
      tp.paint(canvas, Offset(center.dx - tp.width / 2, yOffset));

      // Subtle face label beneath time
      final subTp = TextPainter(
        text: TextSpan(
          text: face.displayName.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Roboto',
            color: accentColor.withValues(alpha: 0.9),
            fontSize: max(7.0, size.width * 0.048),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      subTp.paint(
        canvas,
        Offset(center.dx - subTp.width / 2, yOffset + tp.height + 2),
      );
    }
  }

  Gradient _backgroundForFace(String id, Color accent) {
    if (id.startsWith('photo')) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accent.withValues(alpha: 0.75),
          const Color(0xFF0F172A),
          const Color(0xFF1E293B),
        ],
      );
    }
    if (id == 'solar' || id == 'dusk') {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF7C2D12), Color(0xFF1E1B4B), Color(0xFF090D16)],
      );
    }
    if (id == 'forest' || id == 'botanical') {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF064E3B), Color(0xFF022C22)],
      );
    }
    if (id == 'blossom' || id == 'koi') {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4C1D95), Color(0xFF1E1B4B)],
      );
    }
    return RadialGradient(
      colors: [
        accent.withValues(alpha: 0.22),
        const Color(0xFF090D12),
      ],
    );
  }

  @override
  bool shouldRepaint(covariant _WatchFaceDialPainter oldDelegate) {
    return oldDelegate.face.id != face.id ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.use24Hour != use24Hour;
  }
}
