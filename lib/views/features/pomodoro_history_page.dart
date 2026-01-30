import 'package:demo_ai_even/controllers/pomodoro_controller.dart';
import 'package:demo_ai_even/models/pomodoro_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PomodoroHistoryPage extends StatelessWidget {
  const PomodoroHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PomodoroController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session History'),
        actions: [
          Obx(() => controller.sessionHistory.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Clear History'),
                        content: const Text('Remove all session records?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              controller.clearHistory();
                              Navigator.pop(ctx);
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.sessionHistory.isEmpty) {
          return const Center(
            child: Text(
              'No sessions yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.sessionHistory.length,
          itemBuilder: (context, index) {
            final session = controller.sessionHistory[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border(
                  left: BorderSide(
                    color: _phaseColor(session.phase),
                    width: 4,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _phaseLabel(session.phase),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _phaseColor(session.phase),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${session.durationMinutes} min',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_formatDate(session.startTime)}  ${_formatTime(session.startTime)} - ${_formatTime(session.endTime)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: session.completed
                          ? Colors.green[50]
                          : Colors.orange[50],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      session.completed ? 'Completed' : 'Skipped',
                      style: TextStyle(
                        fontSize: 12,
                        color: session.completed
                            ? Colors.green[700]
                            : Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
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

  String _phaseLabel(PomodoroPhase phase) {
    switch (phase) {
      case PomodoroPhase.work:
        return 'Work';
      case PomodoroPhase.shortBreak:
        return 'Short Break';
      case PomodoroPhase.longBreak:
        return 'Long Break';
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day}';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
