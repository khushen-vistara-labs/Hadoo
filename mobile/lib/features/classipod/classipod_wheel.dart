import 'package:flutter/material.dart';

import 'classipod_controller.dart';

class ClassipodWheel extends StatefulWidget {
  const ClassipodWheel({
    super.key,
    required this.controller,
    required this.onBack,
  });

  final ClassipodController controller;
  final VoidCallback onBack;

  @override
  State<ClassipodWheel> createState() => _ClassipodWheelState();
}

class _ClassipodWheelState extends State<ClassipodWheel> {
  final _tracker = ClassipodWheelTracker();

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final transport = controller.player.hasSong && !controller.busy;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: 'Click wheel',
          hint: 'Turn to browse. Use Previous item and Next item buttons instead.',
          onIncrease: controller.itemCount > 0
              ? () => controller.move(1)
              : null,
          onDecrease: controller.itemCount > 0
              ? () => controller.move(-1)
              : null,
          child: SizedBox.square(
            dimension: 224,
            child: GestureDetector(
              key: const Key('classipod-wheel'),
              onPanStart: (details) {
                _tracker.reset();
                _tracker.update(
                  details.localPosition.dx - 112,
                  details.localPosition.dy - 112,
                  112,
                );
              },
              onPanUpdate: (details) {
                final steps = _tracker.update(
                  details.localPosition.dx - 112,
                  details.localPosition.dy - 112,
                  112,
                );
                if (steps != 0) controller.move(steps);
              },
              onPanEnd: (_) => _tracker.reset(),
              onPanCancel: _tracker.reset,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xffa2aab5)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: TextButton(
                        onPressed: widget.onBack,
                        child: const Text('MENU'),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        tooltip: 'Previous track',
                        onPressed: transport ? controller.previous : null,
                        icon: const Icon(Icons.skip_previous_rounded),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        tooltip: 'Next track',
                        onPressed: transport ? controller.next : null,
                        icon: const Icon(Icons.skip_next_rounded),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: IconButton(
                        tooltip: controller.player.isPlaying ? 'Pause' : 'Play',
                        onPressed: transport
                            ? controller.togglePlayPause
                            : null,
                        icon: Icon(
                          controller.player.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                      ),
                    ),
                    SizedBox.square(
                      dimension: 84,
                      child: IconButton.filledTonal(
                        tooltip: controller.page == ClassipodPage.nowPlaying
                            ? 'Show queue'
                            : 'Select item',
                        onPressed: controller.canSelect
                            ? controller.activate
                            : null,
                        icon: const Icon(Icons.check_rounded),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Previous item',
              onPressed: controller.selected > 0
                  ? () => controller.move(-1)
                  : null,
              icon: const Icon(Icons.keyboard_arrow_up_rounded),
            ),
            Flexible(
              child: Text(
                controller.itemCount == 0
                    ? 'Browse'
                    : '${controller.selected + 1} / ${controller.itemCount}',
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              tooltip: 'Next item',
              onPressed: controller.selected + 1 < controller.itemCount
                  ? () => controller.move(1)
                  : null,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
            ),
          ],
        ),
        const Text(
          '↑ ↓ Browse · Enter Select\nSpace Play / pause · Esc Back',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
