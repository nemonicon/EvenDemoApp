import 'package:demo_ai_even/models/pomodoro_model.dart';
import 'package:get/get.dart';

class PomodoroController extends GetxController {
  final state = PomodoroState.idle.obs;
  final currentPhase = PomodoroPhase.work.obs;
  final remainingSeconds = 0.obs;
  final workSessionsCompleted = 0.obs;
  final currentSessionIndex = 0.obs;
  final isActive = false.obs;
  final sessionsPerCycle = 4;

  final selectedPresetIndex = 0.obs;
  final customWorkMinutes = 25.obs;
  final customBreakMinutes = 5.obs;
  final customLongBreakMinutes = 15.obs;

  final sessionHistory = <PomodoroSession>[].obs;

  static const presets = [
    PomodoroPreset(label: '25/5/15', workMinutes: 25, breakMinutes: 5, longBreakMinutes: 15),
    PomodoroPreset(label: '50/10/30', workMinutes: 50, breakMinutes: 10, longBreakMinutes: 30),
    PomodoroPreset(label: '90/20/60', workMinutes: 90, breakMinutes: 20, longBreakMinutes: 60),
  ];

  PomodoroPreset get activePreset {
    if (selectedPresetIndex.value < presets.length) {
      return presets[selectedPresetIndex.value];
    }
    return PomodoroPreset(
      label: 'Custom',
      workMinutes: customWorkMinutes.value,
      breakMinutes: customBreakMinutes.value,
      longBreakMinutes: customLongBreakMinutes.value,
    );
  }

  String get formattedTime {
    final minutes = remainingSeconds.value ~/ 60;
    final seconds = remainingSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get phaseLabel {
    switch (currentPhase.value) {
      case PomodoroPhase.work:
        return 'Work';
      case PomodoroPhase.shortBreak:
        return 'Short Break';
      case PomodoroPhase.longBreak:
        return 'Long Break';
    }
  }

  int get durationForPhase {
    switch (currentPhase.value) {
      case PomodoroPhase.work:
        return activePreset.workMinutes;
      case PomodoroPhase.shortBreak:
        return activePreset.breakMinutes;
      case PomodoroPhase.longBreak:
        return activePreset.longBreakMinutes;
    }
  }

  void selectPreset(int index) {
    if (state.value != PomodoroState.idle) return;
    selectedPresetIndex.value = index;
  }

  void setCustomPreset(int workMin, int breakMin, int longBreakMin) {
    if (state.value != PomodoroState.idle) return;
    selectedPresetIndex.value = presets.length; // custom index
    customWorkMinutes.value = workMin;
    customBreakMinutes.value = breakMin;
    customLongBreakMinutes.value = longBreakMin;
  }

  void addSession(PomodoroSession session) {
    sessionHistory.insert(0, session);
  }

  void clearHistory() {
    sessionHistory.clear();
  }
}
