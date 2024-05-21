enum OrderType { vip, normal }
enum OrderStatus { pending, processing, completed }

class Order {
  final String orderId;
  final OrderType orderType;
  OrderStatus status;

  Order({
    required this.orderId,
    required this.orderType,
    this.status = OrderStatus.pending,
  });

  int getDuration() {
    return 10;
  }
}