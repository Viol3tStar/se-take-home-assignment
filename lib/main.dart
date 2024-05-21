import 'package:feedme_assignment/models/bot.dart';
import 'package:feedme_assignment/models/order.dart';
import 'package:feedme_assignment/widgets/status_badge.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Bot> _bots = [];
  final List<Order> _pendingOrders = [];
  final List<Order> _completedOrders = [];

  @override
  void initState() {
    super.initState();
  }

  void _addBot() {
    setState(() {
      _bots.add(Bot(botId: DateTime.now().millisecondsSinceEpoch.toString()));
      _assignOrder();
    });
  }

  void _removeBot() {
    if (_bots.isNotEmpty) {
      setState(() {
        Bot lastBot = _bots.removeLast();
        if (lastBot.order != null) {
          lastBot.order?.status = OrderStatus.pending;
          _pendingOrders.add(lastBot.order!);
          _sortPendingOrders();
        }
      });
    }
  }

  void _addOrder(OrderType orderType) {
    setState(() {
      _pendingOrders.add(Order(
          orderId: DateTime.now().millisecondsSinceEpoch.toString(),
          orderType: orderType));
      _sortPendingOrders();
      _assignOrder();
    });
  }

  void _sortPendingOrders() {
    _pendingOrders.sort((a, b) {
      if (a.orderType == OrderType.vip && b.orderType == OrderType.normal) {
        return -1;
      } else if (a.orderType == OrderType.normal &&
          b.orderType == OrderType.vip) {
        return 1;
      } else {
        return a.orderId.compareTo(b.orderId);
      }
    });
  }

  Future<void> _assignOrder() async {
    if (_pendingOrders.isNotEmpty && _bots.isNotEmpty) {
      for (var bot in _bots) {
        if (bot.status == BotStatus.idle) {
          Order order = _pendingOrders.removeAt(0);
          await bot.processOrder(order);
          _completedOrders.add(order);
          setState(() {});
          _assignOrder();
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Available Bots',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _addBot,
                child: const Text('+ Bot'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _removeBot,
                child: const Text('- Bot'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 200,
            child: GridView.builder(
                scrollDirection: Axis.horizontal,
                physics: const PageScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 2.0,
                    crossAxisSpacing: 2.0,
                    crossAxisCount: 3,
                    childAspectRatio: 0.36),
                itemCount: _bots.length,
                itemBuilder: (context, index) =>
                    Card(
                      child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Bot ${index + 1}',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const SizedBox(width: 6,),
                                StatusBadge(
                                  status: _bots[index].status == BotStatus.active ? "ACTIVE" : "IDLE",
                                  color: _bots[index].status == BotStatus.active ? Colors.greenAccent : Colors.grey,),
                              ],
                            ),
                            if (_bots[index].order?.orderId != null)
                              Row(
                              children: [
                                const Text('Complete in: '),
                                TweenAnimationBuilder<Duration>(
                                    key: ValueKey(_bots[index].order?.orderId),
                                    duration: const Duration(seconds: 10),
                                    tween: Tween(
                                        begin: const Duration(seconds: 10),
                                        end: Duration.zero),
                                    onEnd: () {
                                      // print('Timer ended');
                                    },
                                    builder: (BuildContext context, Duration value,
                                        Widget? child) {
                                      final seconds = value.inSeconds;
                                      return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                          child: Text('$seconds',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15)));
                                    })
                              ],
                            )
                          ]),
                    )),
          ),
          const SizedBox(height: 10),
          Wrap(
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  _addOrder(OrderType.normal);
                },
                child: const Text('New Normal Order'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  _addOrder(OrderType.vip);
                },
                child: const Text('New VIP Order'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'PENDING',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          Expanded(
              child: ListView.builder(
                  itemCount: _pendingOrders.length,
                  itemBuilder: (ctx, index) {
                    return Card(
                      child: Column(
                        children: [
                          Text('Bot: ${_pendingOrders[index].orderId}'),
                          Text('Status: ${_pendingOrders[index].status}'),
                          Text('Type: ${_pendingOrders[index].orderType}')
                        ],
                      ),
                    );
                  })),
          const SizedBox(height: 30),
          Text(
            'COMPLETE',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          Expanded(
              child: ListView.builder(
                  itemCount: _completedOrders.length,
                  itemBuilder: (ctx, index) {
                    return Card(
                      child: Column(
                        children: [
                          Text('Bot: ${_completedOrders[index].orderId}'),
                          Text('Status: ${_completedOrders[index].status}'),
                          Text('Type: ${_completedOrders[index].orderType}')
                        ],
                      ),
                    );
                  })),
        ],
      ),
    );
  }
}
