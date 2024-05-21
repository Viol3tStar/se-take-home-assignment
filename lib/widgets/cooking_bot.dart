import 'package:feedme_assignment/models/bot.dart';
import 'package:feedme_assignment/models/order.dart';
import 'package:flutter/material.dart';

class CookingBot extends StatefulWidget {
  const CookingBot({super.key});

  @override
  State<CookingBot> createState() => _CookingBotState();
}

class _CookingBotState extends State<CookingBot> {
  late Bot _bot;

  @override
  void initState() {
    super.initState();
    _bot = Bot(botId: "1");
  }
  @override
  Widget build(BuildContext context) {
    return const Text('Bot');
  }
}
