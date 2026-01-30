enum PomodoroPhase { work, shortBreak, longBreak }

enum PomodoroState { idle, running, paused }

class PomodoroPreset {
  final String label;
  final int workMinutes;
  final int breakMinutes;
  final int longBreakMinutes;

  const PomodoroPreset({
    required this.label,
    required this.workMinutes,
    required this.breakMinutes,
    required this.longBreakMinutes,
  });
}

class PomodoroSession {
  final PomodoroPhase phase;
  final int durationMinutes;
  final DateTime startTime;
  final DateTime endTime;
  final bool completed;

  PomodoroSession({
    required this.phase,
    required this.durationMinutes,
    required this.startTime,
    required this.endTime,
    required this.completed,
  });
}
