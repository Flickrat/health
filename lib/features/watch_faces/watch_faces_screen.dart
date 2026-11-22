import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/lynio_models.dart';
import '../../state/lynio_controller.dart';
import '../../widgets/watch_face_preview.dart';

class WatchFacesScreen extends StatefulWidget {
  const WatchFacesScreen({super.key, required this.controller});

  final LynioController controller;

  @override
  State<WatchFacesScreen> createState() => _WatchFacesScreenState();
}

class _WatchFacesScreenState extends State<WatchFacesScreen> {
  String _selectedCategory = 'All';

  static const _categories = ['All', 'Data', 'Analog', 'Digital', 'Artistic', 'Photo'];
  static const _accents = [
    LynioColors.accentDark,
    Color(0xFF38BDF8),
    Color(0xFFF97316),
    Color(0xFFF43F5E),
    Color(0xFFA855F7),
    Color(0xFFEAB308),
    Color(0xFF22C55E),
    Color(0xFFFFFFFF),
  ];

  static const _availableRoles = [
    ('steps', 'Steps', Icons.directions_walk_rounded),
    ('battery', 'Watch Battery', Icons.bolt_rounded),
    ('heart_rate', 'Heart Rate', Icons.favorite_rounded),
    ('goal', 'Step Goal', Icons.flag_rounded),
    ('weather', 'Weather', Icons.wb_sunny_rounded),
    ('date', 'Date', Icons.calendar_today_rounded),
    ('empty', 'Empty', Icons.block_rounded),
  ];

  void _openSlotEditor(WatchFaceDefinition face, WatchFaceSlot slot) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            children: [
              Text(
                'Complication Slot #${slot.id} (${slot.style})',
                style: Theme.of(ctx)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              for (final (roleId, label, icon) in _availableRoles)
                ListTile(
                  leading: Icon(icon),
                  title: Text(label),
                  trailing: slot.role == roleId
                      ? Icon(Icons.check_circle_rounded,
                          color: Theme.of(ctx).colorScheme.primary)
                      : null,
                  onTap: () {
                    widget.controller.setSlotRole(face.id, slot.id, roleId);
                    Navigator.of(ctx).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _savePresetDialog() {
    final nameCtrl = TextEditingController(
      text: '${widget.controller.activeWatchFace.displayName} Custom',
    );
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Watch Face Preset'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Preset Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) {
                widget.controller.saveCurrentFaceAsPreset(name);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final ctrl = widget.controller;
        final activeFace = ctrl.activeWatchFace;
        final activeSlots = ctrl.slotsForFace(activeFace);
        final filteredFaces = _selectedCategory == 'All'
            ? ctrl.watchFaces
            : ctrl.watchFaces
                .where((f) => f.category == _selectedCategory)
                .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Watch Faces'),
            actions: [
              TextButton.icon(
                onPressed: _savePresetDialog,
                icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                label: const Text('Save Preset'),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            children: [
              // Live Studio Preview
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      WatchFacePreview(
                        face: activeFace,
                        slots: activeSlots,
                        accentColor: ctrl.activeFaceAccent,
                        watchModel: ctrl.pairedWatch,
                        size: 210,
                        steps: ctrl.health.steps,
                        stepGoal: ctrl.health.stepGoal,
                        batteryPercent: ctrl.battery.watchPercent,
                        heartRate: ctrl.health.heartRateBpm,
                        use24Hour: ctrl.use24HourTime,
                        interactive: true,
                        onSlotTap: (slot) => _openSlotEditor(activeFace, slot),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        activeFace.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activeSlots.isEmpty
                            ? 'Clean photo dial • No complication slots'
                            : '${activeSlots.length} complication slot(s) • Tap any slot on the dial to customize',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      // Accent color palette
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          for (final color in _accents)
                            GestureDetector(
                              onTap: () => ctrl.setFaceAccent(color),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: ctrl.activeFaceAccent.toARGB32() ==
                                            color.toARGB32()
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                        : Colors.black26,
                                    width: ctrl.activeFaceAccent.toARGB32() ==
                                            color.toARGB32()
                                        ? 3
                                        : 1,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Applied "${activeFace.displayName}" to ${ctrl.customWatchName}',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.watch_rounded),
                          label: const Text('Apply to Watch'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),
              // Presets
              const Text(
                'Presets',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: ctrl.savedPresets.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final preset = ctrl.savedPresets[index];
                    return ActionChip(
                      avatar: CircleAvatar(
                        backgroundColor: Color(preset.accentColorValue),
                        radius: 8,
                      ),
                      label: Text(preset.name),
                      onPressed: () => ctrl.applyPreset(preset),
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),
              // Gallery of all 40 Watch Faces
              Text(
                'All Faces (${filteredFaces.length})',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    return ChoiceChip(
                      label: Text(cat),
                      selected: _selectedCategory == cat,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = cat),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.78,
                ),
                itemCount: filteredFaces.length,
                itemBuilder: (context, index) {
                  final face = filteredFaces[index];
                  final selected = face.id == ctrl.activeWatchFaceId;
                  return GestureDetector(
                    onTap: () => ctrl.selectWatchFace(face.id),
                    child: Card(
                      color: selected
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.14)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            WatchFacePreview(
                              face: face,
                              slots: ctrl.slotsForFace(face),
                              accentColor: ctrl.activeFaceAccent,
                              watchModel: ctrl.pairedWatch,
                              size: 76,
                              steps: ctrl.health.steps,
                              stepGoal: ctrl.health.stepGoal,
                              batteryPercent: ctrl.battery.watchPercent,
                              heartRate: ctrl.health.heartRateBpm,
                              use24Hour: ctrl.use24HourTime,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              face.displayName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
