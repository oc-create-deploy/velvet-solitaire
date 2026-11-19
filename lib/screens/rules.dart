import 'package:flutter/material.dart';

class Rules extends StatelessWidget {
  const Rules({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('How to play')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          Text(
            'Klondike',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            'Build columns downward in alternating colors. Empty columns take Kings. Build each suit foundation from Ace to King.',
          ),
          SizedBox(height: 24),
          Text(
            'Spider — one suit',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            'Build descending sequences from King to Ace. Complete face-up runs are collected automatically. Fill all empty columns before dealing a row of ten cards.',
          ),
          SizedBox(height: 24),
          Text(
            'Invert',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            'Build columns upward in alternating colors. Empty columns take Aces. Build each suit foundation from King down to Ace.',
          ),
          SizedBox(height: 24),
          Text(
            'Controls',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            'Drag a card or tap it and then tap its destination. Tap the stock to draw. In Klondike and Invert, tap the empty stock to recycle the waste. Undo reverses a move or deal. Scroll the board to reach long columns. Each mode saves its current board automatically.',
          ),
        ],
      ),
    ),
  );
}
