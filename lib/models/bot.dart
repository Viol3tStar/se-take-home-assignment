import 'dart:async';

import 'package:feedme_assignment/models/order.dart';

enum BotStatus { active, idle }

class Bot {
  final String botId;
  BotStatus status;
  Order? order;
  Completer<void>? completer;
  Timer? timer;

  Bot({
    required this.botId,
    this.status = BotStatus.idle,
    this.order,
    this.completer,
    this.timer,
  });

  Future<void> processOrder(Order order, {Duration duration = const Duration(seconds: 10)}) async {
    if (status != BotStatus.active && (order.status == OrderStatus.pending)) {
      this.order = order;
      order.status = OrderStatus.processing;
      status = BotStatus.active;

      completer = Completer<void>();
      timer = Timer(duration, () {
        if (!completer!.isCompleted) {
          completer!.complete();
          order.status = OrderStatus.completed;
          status = BotStatus.idle;
          this.order = null;
        }
      });
    }
    return completer!.future;

  }

  void stopProcess() {
    if (timer?.isActive ?? false) {
      timer?.cancel();
      timer = null;
      order?.status = OrderStatus.pending;
      if (!completer!.isCompleted) {
        completer!.completeError('Bot was cancelled');
        status = BotStatus.idle;
      }
    }
  }
}