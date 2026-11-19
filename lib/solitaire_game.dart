import 'dart:convert';
import 'dart:math';

enum GameMode { klondike, spider, invert }

class GameCard {
  final int id;
  final int suit;
  final int rank;
  bool faceUp;
  GameCard(this.id, this.suit, this.rank, {this.faceUp = false});
  bool get red => suit == 1 || suit == 2;
  String get label =>
      '${const ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'][rank - 1]}${const ['♠', '♥', '♦', '♣'][suit]}';
  Map<String, dynamic> toJson() => {
    'id': id,
    'suit': suit,
    'rank': rank,
    'up': faceUp,
  };
  factory GameCard.fromJson(Map<String, dynamic> j) => GameCard(
    j['id'] as int,
    j['suit'] as int,
    j['rank'] as int,
    faceUp: j['up'] as bool,
  );
}

class CardMove {
  // -1: waste; -10..-13: foundations; >=0: tableau column.
  final int source;
  final int index;
  const CardMove(this.source, this.index);
}

class SolitaireGame {
  final GameMode mode;
  late List<List<GameCard>> columns;
  List<GameCard> stock = [], waste = [];
  List<List<GameCard>> foundations = List.generate(4, (_) => []);
  int completed = 0, moves = 0;
  final List<String> _history = [];
  bool get canUndo => _history.isNotEmpty;
  bool get won => mode == GameMode.spider
      ? completed == 8
      : foundations.fold<int>(0, (n, c) => n + c.length) == 52;
  int get cardCount =>
      stock.length +
      waste.length +
      columns.fold<int>(0, (n, c) => n + c.length) +
      foundations.fold<int>(0, (n, c) => n + c.length) +
      completed * 13;
  SolitaireGame(this.mode, {int? seed}) {
    deal(seed: seed);
  }

  void deal({int? seed}) {
    var deck = List.generate(
      mode == GameMode.spider ? 104 : 52,
      (i) => GameCard(i, mode == GameMode.spider ? 0 : i ~/ 13, i % 13 + 1),
    );
    deck.shuffle(Random(seed));
    columns = List.generate(mode == GameMode.spider ? 10 : 7, (i) {
      final count = mode == GameMode.spider ? (i < 4 ? 6 : 5) : i + 1;
      final cards = List.generate(count, (_) => deck.removeLast());
      cards.last.faceUp = true;
      return cards;
    });
    stock = deck;
    waste = [];
    foundations = List.generate(4, (_) => []);
    completed = 0;
    moves = 0;
    _history.clear();
  }

  List<GameCard> _pile(int source) => source == -1
      ? waste
      : source <= -10
      ? foundations[-source - 10]
      : columns[source];
  List<GameCard> moving(CardMove from) {
    final pile = _pile(from.source);
    if (from.index < 0 || from.index >= pile.length) return [];
    return pile.sublist(from.index);
  }

  bool validRun(List<GameCard> cards) {
    if (cards.isEmpty || cards.any((c) => !c.faceUp)) return false;
    for (int i = 1; i < cards.length; i++) {
      if (mode == GameMode.spider
          ? cards[i].suit != cards[i - 1].suit
          : cards[i].red == cards[i - 1].red)
        return false;
      if (cards[i].rank !=
          cards[i - 1].rank + (mode == GameMode.invert ? 1 : -1))
        return false;
    }
    return true;
  }

  bool canMoveToColumn(CardMove from, int target) {
    if (from.source == target) return false;
    final cards = moving(from);
    if (!validRun(cards)) return false;
    final dest = columns[target];
    if (dest.isEmpty)
      return mode == GameMode.spider ||
          cards.first.rank == (mode == GameMode.invert ? 1 : 13);
    if (!dest.last.faceUp) return false;
    return (mode == GameMode.spider || dest.last.red != cards.first.red) &&
        cards.first.rank == dest.last.rank + (mode == GameMode.invert ? 1 : -1);
  }

  bool canMoveToFoundation(CardMove from, int suit) {
    if (mode == GameMode.spider || from.source <= -10) return false;
    final cards = moving(from);
    return cards.length == 1 &&
        cards.single.faceUp &&
        cards.single.suit == suit &&
        cards.single.rank ==
            (mode == GameMode.invert
                ? 13 - foundations[suit].length
                : foundations[suit].length + 1);
  }

  void _remember() {
    _history.add(encode());
    if (_history.length > 100) _history.removeAt(0);
    moves++;
  }

  void _reveal(int source) {
    final pile = _pile(source);
    if (pile.isNotEmpty) pile.last.faceUp = true;
  }

  bool moveToColumn(CardMove from, int target) {
    if (!canMoveToColumn(from, target)) return false;
    _remember();
    final cards = moving(from);
    _pile(from.source).removeRange(from.index, _pile(from.source).length);
    columns[target].addAll(cards);
    _reveal(from.source);
    _completeSpiderRuns();
    return true;
  }

  bool moveToFoundation(CardMove from, int suit) {
    if (!canMoveToFoundation(from, suit)) return false;
    _remember();
    foundations[suit].add(_pile(from.source).removeLast());
    _reveal(from.source);
    return true;
  }

  void _completeSpiderRuns() {
    if (mode != GameMode.spider) return;
    for (final pile in columns) {
      while (pile.length >= 13) {
        final run = pile.sublist(pile.length - 13);
        if (run.first.rank != 13 || !validRun(run)) break;
        pile.removeRange(pile.length - 13, pile.length);
        completed++;
        if (pile.isNotEmpty) pile.last.faceUp = true;
      }
    }
  }

  String? draw() {
    if (mode == GameMode.spider) {
      if (stock.isEmpty)
        return 'No deals left. Move cards or start a new deal.';
      if (columns.any((c) => c.isEmpty))
        return 'Fill every empty column before dealing.';
      if (stock.length < 10) return 'Not enough cards for a complete row.';
      _remember();
      for (final pile in columns) {
        pile.add(stock.removeLast()..faceUp = true);
      }
      _completeSpiderRuns();
    } else {
      if (stock.isEmpty && waste.isEmpty) return 'No cards in the stock.';
      _remember();
      if (stock.isEmpty) {
        stock = waste.reversed.toList();
        for (final card in stock) {
          card.faceUp = false;
        }
        waste = [];
      } else {
        waste.add(stock.removeLast()..faceUp = true);
      }
    }
    return null;
  }

  void undo() {
    if (_history.isEmpty) return;
    _restore(jsonDecode(_history.removeLast()) as Map<String, dynamic>);
  }

  String encode() => jsonEncode({
    'v': 1,
    'mode': mode.name,
    'columns': columns.map((p) => p.map((c) => c.toJson()).toList()).toList(),
    'stock': stock.map((c) => c.toJson()).toList(),
    'waste': waste.map((c) => c.toJson()).toList(),
    'foundations': foundations
        .map((p) => p.map((c) => c.toJson()).toList())
        .toList(),
    'completed': completed,
    'moves': moves,
  });
  void _restore(Map<String, dynamic> j) {
    List<GameCard> cards(dynamic list) => (list as List)
        .map((c) => GameCard.fromJson(c as Map<String, dynamic>))
        .toList();
    columns = (j['columns'] as List).map(cards).toList();
    stock = cards(j['stock']);
    waste = cards(j['waste']);
    foundations = (j['foundations'] as List).map(cards).toList();
    completed = j['completed'] as int;
    moves = j['moves'] as int;
  }

  factory SolitaireGame.decode(String text) {
    final j = jsonDecode(text) as Map<String, dynamic>;
    if (j['v'] != 1) throw const FormatException('Unsupported save version');
    final game = SolitaireGame(GameMode.values.byName(j['mode'] as String));
    game._restore(j);
    final live = [
      ...game.stock,
      ...game.waste,
      ...game.columns.expand((p) => p),
      ...game.foundations.expand((p) => p),
    ];
    if (game.columns.length != (game.mode == GameMode.spider ? 10 : 7) ||
        game.foundations.length != 4 ||
        game.cardCount != (game.mode == GameMode.spider ? 104 : 52) ||
        live.map((c) => c.id).toSet().length != live.length ||
        live.any((c) => c.rank < 1 || c.rank > 13 || c.suit < 0 || c.suit > 3))
      throw const FormatException('Invalid saved board');
    return game;
  }
}
