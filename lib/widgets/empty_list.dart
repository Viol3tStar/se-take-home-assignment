import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmptyList extends StatelessWidget {
  final String warningMsg;
  const EmptyList({this.warningMsg = 'No orders available', super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 170,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox,
              size: 35,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              warningMsg,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
