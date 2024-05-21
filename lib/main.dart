import 'package:feedme_assignment/models/bot.dart';
import 'package:feedme_assignment/models/order.dart';
import 'package:feedme_assignment/widgets/empty_list.dart';
import 'package:feedme_assignment/widgets/status_badge.dart';
import 'package:flutter/material.dart';

import 'helpers/styles.dart';

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
      title: 'Demo Order Controller',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Demo Order Controller'),
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
          lastBot.stopProcess();
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
          await bot.processOrder(order).then((_) {
            _completedOrders.add(order);
            setState(() {});
            _assignOrder();
          }).catchError((error) {
            print("_assignOrder error: $error:");
          });
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('PENDING', style: AppStyles.headingTextStyle),
                const SizedBox(width: 5,),
                Text('(${_pendingOrders.length})', style: AppStyles.headingIndicatorTextStyle),
              ],
            ),
          ),
          _pendingOrders.isEmpty
              ? const EmptyList()
              : SizedBox(
                  width: double.infinity,
                  height: 170,
                  child: GridView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const PageScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              mainAxisSpacing: 2.0,
                              crossAxisSpacing: 2.0,
                              crossAxisCount: 2,
                              childAspectRatio: 0.36),
                      itemCount: _pendingOrders.length,
                      itemBuilder: (context, index) => Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Order ${index + 1}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    if (_pendingOrders[index].orderType ==
                                        OrderType.vip)
                                      const StatusBadge(
                                        status: "VIP",
                                        color: Colors.deepPurpleAccent,
                                      ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    const StatusBadge(
                                        status: "PENDING", color: Colors.grey),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  '#${_pendingOrders[index].orderId}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ]),
                            ),
                          )),
                ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text('Bots', style: AppStyles.headingTextStyle),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _addBot,
                  child: const Text('+ Bot'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // background color
                  ),
                  onPressed: _removeBot,
                  child: const Text('- Bot'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _bots.isEmpty
              ? const EmptyList(
                  warningMsg: 'No bots available',
                )
              : SizedBox(
                  width: double.infinity,
                  height: 170,
                  child: GridView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const PageScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              mainAxisSpacing: 2.0,
                              crossAxisSpacing: 2.0,
                              crossAxisCount: 2,
                              childAspectRatio: 0.36),
                      itemCount: _bots.length,
                      itemBuilder: (context, index) => Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Bot ${index + 1}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    StatusBadge(
                                      status: _bots[index].status ==
                                              BotStatus.active
                                          ? "ACTIVE"
                                          : "IDLE",
                                      color: _bots[index].status ==
                                              BotStatus.active
                                          ? Colors.greenAccent
                                          : Colors.grey,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                if (_bots[index].order?.orderId != null)
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '#${_bots[index].order?.orderId}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Complete in: ',
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          TweenAnimationBuilder<Duration>(
                                              key: ValueKey(
                                                  _bots[index].order?.orderId),
                                              duration:
                                                  const Duration(seconds: 10),
                                              tween: Tween(
                                                  begin: const Duration(
                                                      seconds: 10),
                                                  end: Duration.zero),
                                              onEnd: () {
                                                // print('Timer ended');
                                              },
                                              builder: (BuildContext context,
                                                  Duration value,
                                                  Widget? child) {
                                                final seconds = value.inSeconds;
                                                return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 5),
                                                    child: Text('$seconds',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 10)));
                                              })
                                        ],
                                      )
                                    ],
                                  )
                              ]),
                            ),
                          )),
                ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('COMPLETE', style: AppStyles.headingTextStyle),
                const SizedBox(width: 5,),
                Text('(${_completedOrders.length})', style: AppStyles.headingIndicatorTextStyle),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _completedOrders.isEmpty
              ? const EmptyList(
                  warningMsg: 'No orders completed',
                )
              : SizedBox(
                  width: double.infinity,
                  height: 170,
                  child: GridView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const PageScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              mainAxisSpacing: 2.0,
                              crossAxisSpacing: 2.0,
                              crossAxisCount: 2,
                              childAspectRatio: 0.36),
                      itemCount: _completedOrders.length,
                      itemBuilder: (context, index) => Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    const StatusBadge(
                                      status: "COMPLETED",
                                      color: Colors.greenAccent,
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    if (_completedOrders[index].orderType ==
                                        OrderType.vip)
                                      const StatusBadge(
                                        status: "VIP",
                                        color: Colors.deepPurpleAccent,
                                      ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  '#${_completedOrders[index].orderId}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ]),
                            ),
                          )),
                ),
        ],
      ),
    );
  }
}
