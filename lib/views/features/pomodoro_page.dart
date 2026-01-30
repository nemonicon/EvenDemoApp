import 'package:demo_ai_even/controllers/pomodoro_controller.dart';
import 'package:demo_ai_even/models/pomodoro_model.dart';
import 'package:demo_ai_even/services/pomodoro_service.dart';
import 'package:demo_ai_even/views/features/pomodoro_history_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PomodoroPage extends StatelessWidget {
  const PomodoroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PomodoroController>();
    final service = PomodoroService.get;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PomodoroHistoryPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Phase label
            Obx(() => Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _phaseColor(controller.currentPhase.value),
                borderRadius: BorderRadius.circular(5),
              ),
              alignment: Alignment.center,
              child: Text(
                controller.phaseLabel,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )),
            const SizedBox(height: 24),

            // Large countdown
            Obx(() => Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(
                    controller.state.value == PomodoroState.idle
                        ? '${controller.durationForPhase.toString().padLeft(2, '0')}:00'
                        : controller.formattedTime,
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Session ${controller.currentSessionIndex.value + 1}/${controller.sessionsPerCycle}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 24),

            // Control buttons
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Start/Pause button
                GestureDetector(
                  onTap: () => service.toggleStartPause(),
                  child: Container(
                    width: 80,
                    height: 48,
                    decoration: BoxDecoration(
                      color: controller.state.value == PomodoroState.running
                          ? Colors.orange
                          : Colors.green,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      controller.state.value == PomodoroState.running
                          ? 'Pause'
                          : 'Start',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Skip button
                GestureDetector(
                  onTap: controller.state.value == PomodoroState.idle
                      ? null
                      : () => service.skipPhase(),
                  child: Container(
                    width: 80,
                    height: 48,
                    decoration: BoxDecoration(
                      color: controller.state.value == PomodoroState.idle
                          ? Colors.grey[300]
                          : Colors.blue,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: controller.state.value == PomodoroState.idle
                            ? Colors.grey[500]
                            : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Reset button
                GestureDetector(
                  onTap: controller.state.value == PomodoroState.idle
                      ? null
                      : () => service.reset(),
                  child: Container(
                    width: 80,
                    height: 48,
                    decoration: BoxDecoration(
                      color: controller.state.value == PomodoroState.idle
                          ? Colors.grey[300]
                          : Colors.red,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        color: controller.state.value == PomodoroState.idle
                            ? Colors.grey[500]
                            : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            )),
            const SizedBox(height: 32),

            // Preset selector
            Obx(() {
              final isIdle = controller.state.value == PomodoroState.idle;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Presets (work/break/long)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (var i = 0; i < PomodoroController.presets.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: isIdle ? () => controller.selectPreset(i) : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: controller.selectedPresetIndex.value == i
                                    ? Colors.blue
                                    : (isIdle ? Colors.white : Colors.grey[200]),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: controller.selectedPresetIndex.value == i
                                      ? Colors.blue
                                      : Colors.grey[300]!,
                                ),
                              ),
                              child: Text(
                                PomodoroController.presets[i].label,
                                style: TextStyle(
                                  color: controller.selectedPresetIndex.value == i
                                      ? Colors.white
                                      : (isIdle ? Colors.black87 : Colors.grey[500]),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      GestureDetector(
                        onTap: isIdle ? () => _showCustomDialog(context, controller) : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: controller.selectedPresetIndex.value >= PomodoroController.presets.length
                                ? Colors.blue
                                : (isIdle ? Colors.white : Colors.grey[200]),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: controller.selectedPresetIndex.value >= PomodoroController.presets.length
                                  ? Colors.blue
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            'Custom',
                            style: TextStyle(
                              color: controller.selectedPresetIndex.value >= PomodoroController.presets.length
                                  ? Colors.white
                                  : (isIdle ? Colors.black87 : Colors.grey[500]),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _phaseColor(PomodoroPhase phase) {
    switch (phase) {
      case PomodoroPhase.work:
        return Colors.red[400]!;
      case PomodoroPhase.shortBreak:
        return Colors.green[400]!;
      case PomodoroPhase.longBreak:
        return Colors.blue[400]!;
    }
  }

  void _showCustomDialog(BuildContext context, PomodoroController controller) {
    final workCtrl = TextEditingController(text: controller.customWorkMinutes.value.toString());
    final breakCtrl = TextEditingController(text: controller.customBreakMinutes.value.toString());
    final longBreakCtrl = TextEditingController(text: controller.customLongBreakMinutes.value.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Custom Duration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: workCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Work (minutes)'),
            ),
            TextField(
              controller: breakCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Break (minutes)'),
            ),
            TextField(
              controller: longBreakCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Long Break (minutes)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final work = int.tryParse(workCtrl.text) ?? 25;
              final brk = int.tryParse(breakCtrl.text) ?? 5;
              final longBrk = int.tryParse(longBreakCtrl.text) ?? 15;
              controller.setCustomPreset(
                work.clamp(1, 120),
                brk.clamp(1, 60),
                longBrk.clamp(1, 60),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }
}
