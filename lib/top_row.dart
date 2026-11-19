import 'package:flutter/material.dart';
import 'package:velvet_solitaire/playing_card.dart';
import 'bottom_columns.dart';
import 'moving_card.dart';

class TopRow extends StatefulWidget {
  final CardSuit? suit;
  final List<PlayingCard> cards;
  final CardAcceptCallback onCardAccepted;
  final int columnIndex;
  final bool isKlondike;
  final bool isSpider1;
  final bool isSpider2;
  final bool invert;

  const TopRow({
    super.key,
    this.suit,
    required this.cards,
    required this.onCardAccepted,
    required this.columnIndex,
    this.isKlondike = true,
    this.isSpider1 = false,
    this.isSpider2 = false,
    this.invert = false,
  });

  _TopRowState createState() => _TopRowState();
}

class _TopRowState extends State<TopRow> {
  @override
  Widget build(BuildContext context) {
    return DragTarget<Map<String, dynamic>>(
      builder: (context, listOne, listTwo) {
        return widget.cards.length == 0
            ? Container(
                height: 60.0,
                width: 40.0,
                decoration: BoxDecoration(
                  border: Border.all(width: 2.0, color: Colors.black),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: _suitImage(),
              )
            : TransformCard(
                playingCard: widget.cards.last,
                columnIndex: widget.columnIndex,
                isFoundation: true,
                attachedCards: [widget.cards.last],
              );
      },
      onWillAcceptWithDetails: (details) {
        final value = details.data;
        final cards = value["cards"] as List<PlayingCard>;
        if (cards.isEmpty || cards.any((card) => !card.isFaceUp)) return false;
        if (widget.isKlondike || widget.invert) {
          if (cards.length != 1) return false;
          final card = cards.single;
          if (card.suit != widget.suit) return false;
          if (widget.isKlondike) {
            return card.getValue() == widget.cards.length + 1;
          }
          return card.getValue() == 13 - widget.cards.length;
        }
        if (widget.isSpider1 || widget.isSpider2) {
          if (cards.length != 13) return false;
          for (var i = 0; i < 13; i++) {
            if (cards[i].getValue() != 13 - i ||
                cards[i].suit != cards.first.suit)
              return false;
          }
          return true;
        }
        return false;
      },
      onAcceptWithDetails: (details) {
        final value = details.data;
        widget.onCardAccepted(
          value["cards"] as List<PlayingCard>,
          value["fromIndex"] as int,
        );
      },
    );
  }

  // for diplaying top row suits

  Widget _suitImage() {
    if (widget.suit == CardSuit.clubs) {
      return Image.asset('assets/clubs.png');
    } else if (widget.suit == CardSuit.diamonds) {
      return Image.asset('assets/diamonds.png');
    } else if (widget.suit == CardSuit.spades) {
      return Image.asset('assets/spades.png');
    } else if (widget.suit == CardSuit.hearts) {
      return Image.asset('assets/heart.png');
    }
    return const SizedBox.shrink();
  }
}
