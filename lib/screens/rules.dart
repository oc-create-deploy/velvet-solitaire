import 'package:flutter/material.dart';

class Rules extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Build each tableau in alternating colors from King to Ace. '
            'Move Aces to the foundations, then build each suit upward to King.',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
