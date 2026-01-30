import 'dart:async';

import 'package:demo_ai_even/controllers/pomodoro_controller.dart';
import 'package:demo_ai_even/models/pomodoro_model.dart';
import 'package:demo_ai_even/services/evenai.dart';
import 'package:demo_ai_even/services/proto.dart';
import 'package:get/get.dart';

class PomodoroService {
  static PomodoroService? _instance;
  static PomodoroService get get => _instance ??= PomodoroService._();

  PomodoroService._();

  Timer? _timer;
  DateTime? _phaseStartTime;
  int _lastDisplayedSeconds = -1;

  PomodoroController get _controller => Get.find<PomodoroController>();

  void startOrResume() {
    final controller = _controller;
    if (controller.state.value == PomodoroState.running) return;

    if (controller.state.value == PomodoroState.idle) {
      controller.currentPhase.value = PomodoroPhase.work;
      controller.remainingSeconds.value = controller.durationForPhase * 60;
      controller.workSessionsCompleted.value = 0;
      controller.currentSessionIndex.value = 0;
      _phaseStartTime = DateTime.now();
    }

    controller.state.value = PomodoroState.running;
    controller.isActive.value = true;
    _lastDisplayedSeconds = -1;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());

    _sendDisplayUpdate();
  }

  void pause() {
    final controller = _controller;
    if (controller.state.value != PomodoroState.running) return;

    controller.state.value = PomodoroState.paused;
    _timer?.cancel();
    _timer = null;

    _sendDisplayUpdate();
  }

  void toggleStartPause() {
    final controller = _controller;
    if (controller.state.value == PomodoroState.running) {
      pause();
    } else {
      startOrResume();
    }
  }

  void skipPhase() {
    final controller = _controller;
    if (controller.state.value == PomodoroState.idle) return;

    _recordSession(completed: false);
    _advancePhase();
  }

  void reset() {
    final controller = _controller;
    _timer?.cancel();
    _timer = null;

    controller.state.value = PomodoroState.idle;
    controller.currentPhase.value = PomodoroPhase.work;
    controller.remainingSeconds.value = 0;
    controller.workSessionsCompleted.value = 0;
    controller.currentSessionIndex.value = 0;
    controller.isActive.value = false;
    _phaseStartTime = null;
    _lastDisplayedSeconds = -1;
  }

  void stop() {
    if (_controller.state.value != PomodoroState.idle) {
      _recordSession(completed: false);
    }
    reset();
  }

  void _tick() {
    final controller = _controller;
    if (controller.remainingSeconds.value <= 0) {
      _onPhaseComplete();
      return;
    }

    controller.remainingSeconds.value--;

    final remaining = controller.remainingSeconds.value;
    // Update display every 30s, final 10s, or on phase changes
    if (remaining <= 10 ||
        remaining % 30 == 0 ||
        _lastDisplayedSeconds == -1) {
      _sendDisplayUpdate();
    }
  }

  void _onPhaseComplete() {
    _timer?.cancel();
    _timer = null;

    _recordSession(completed: true);
    _advancePhase();
  }

  void _advancePhase() {
    final controller = _controller;
    final wasWork = controller.currentPhase.value == PomodoroPhase.work;

    if (wasWork) {
      controller.workSessionsCompleted.value++;
      controller.currentSessionIndex.value++;

      if (controller.workSessionsCompleted.value >= controller.sessionsPerCycle) {
        controller.currentPhase.value = PomodoroPhase.longBreak;
      } else {
        controller.currentPhase.value = PomodoroPhase.shortBreak;
      }
    } else {
      if (controller.currentPhase.value == PomodoroPhase.longBreak) {
        // Cycle complete, reset
        reset();
        return;
      }
      controller.currentPhase.value = PomodoroPhase.work;
    }

    controller.remainingSeconds.value = controller.durationForPhase * 60;
    _phaseStartTime = DateTime.now();
    controller.state.value = PomodoroState.running;
    controller.isActive.value = true;
    _lastDisplayedSeconds = -1;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());

    _sendDisplayUpdate();
  }

  void _recordSession({required bool completed}) {
    final controller = _controller;
    if (_phaseStartTime == null) return;

    controller.addSession(PomodoroSession(
      phase: controller.currentPhase.value,
      durationMinutes: controller.durationForPhase,
      startTime: _phaseStartTime!,
      endTime: DateTime.now(),
      completed: completed,
    ));
  }

  void _sendDisplayUpdate() {
    // Skip display if EvenAI is actively using the glasses
    if (EvenAI.isRunning) return;

    final controller = _controller;
    _lastDisplayedSeconds = controller.remainingSeconds.value;

    final stateStr = controller.state.value == PomodoroState.paused ? ' (Paused)' : '';
    final sessionNum = controller.currentSessionIndex.value + 1;
    final text = 'Pomodoro Timer\n\n'
        '${controller.phaseLabel}: ${controller.formattedTime}$stateStr\n\n'
        'Session $sessionNum/${controller.sessionsPerCycle}';

    Proto.sendEvenAIData(
      text,
      newScreen: 0x31, // 0x01 | 0x30
      pos: 0,
      current_page_num: 1,
      max_page_num: 1,
    );
  }
}
