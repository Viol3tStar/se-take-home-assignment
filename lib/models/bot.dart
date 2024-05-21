import 'package:feedme_assignment/models/order.dart';

enum BotStatus { active, idle }

class Bot {
  final String botId;
  BotStatus status;
  Order? order;

  Bot({
    required this.botId,
    this.status = BotStatus.idle,
    this.order,
  });

  Future<void> processOrder(Order order) async {
    // TODO: Add time left for completing order
    if (status != BotStatus.active && (order.status == OrderStatus.pending)) {
      this.order = order;
      order.status = OrderStatus.processing;
      status = BotStatus.active;
      await Future.delayed(const Duration(seconds: 10));
      order.status = OrderStatus.completed;
      status = BotStatus.idle;
      this.order = null;
    }
  }
}