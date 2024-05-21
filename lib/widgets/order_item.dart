import 'package:feedme_assignment/models/order.dart';
import 'package:flutter/cupertino.dart';

class OrderItem extends StatefulWidget {
  final OrderType orderType;

  const OrderItem({super.key, required this.orderType});

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {

  late Order order;
  @override
  void initState() {
    super.initState();
    order = Order(orderId: "1", orderType: widget.orderType);
  }

  @override
  Widget build(BuildContext context) {
    return Text("Order Type: ${order.orderType}");
  }
}
