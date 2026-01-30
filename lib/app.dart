

import 'package:demo_ai_even/controllers/pomodoro_controller.dart';
import 'package:demo_ai_even/services/evenai.dart';
import 'package:demo_ai_even/services/pomodoro_service.dart';
import 'package:get/get.dart';

class App {
  static App? _instance;
  static App get get => _instance ??= App._();

  App._();

  // exit features by receiving [oxf5 0]
  void exitAll({bool isNeedBackHome = true}) async {
    if (EvenAI.isEvenAIOpen.value) {
      await EvenAI.get.stopEvenAIByOS();
    }
    if (Get.isRegistered<PomodoroController>() &&
        Get.find<PomodoroController>().isActive.value) {
      PomodoroService.get.stop();
    }
  }
}