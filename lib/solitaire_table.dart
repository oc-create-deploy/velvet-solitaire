import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'solitaire_game.dart';

class SolitaireTable extends StatefulWidget {
  final GameMode mode;
  final SolitaireGame? initialGame;
  const SolitaireTable({super.key, required this.mode, this.initialGame});
  @override
  State<SolitaireTable> createState() => SolitaireTableState();
}

class SolitaireTableState extends State<SolitaireTable> {
  late SolitaireGame game;
  CardMove? selected;
  bool loading = true;
  SharedPreferences? preferences;
  Future<void> saveQueue = Future.value();
  String get saveKey => 'velvet-board-v1-${widget.mode.name}';
  @override
  void initState() {
    super.initState();
    game = widget.initialGame ?? SolitaireGame(widget.mode);
    _load();
  }

  Future<void> _load() async {
    preferences = await SharedPreferences.getInstance();
    final saved = preferences!.getString(saveKey);
    if (saved != null && widget.initialGame == null) {
      try {
        game = SolitaireGame.decode(saved);
      } on Object {
        /* A damaged save must not stop a new game. */
      }
    }
    if (mounted) setState(() => loading = false);
  }

  void _save() {
    if (widget.initialGame != null) return;
    final encoded = game.encode();
    saveQueue = saveQueue.then((_) async {
      await preferences?.setString(saveKey, encoded);
    });
  }

  void _changed() {
    selected = null;
    setState(() {});
    _save();
  }

  void _notice(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 2)),
    );
  }

  void _column(int target, [CardMove? drag]) {
    final from = drag ?? selected;
    if (from == null) {
      _notice('Choose a face-up card, then its destination.');
      return;
    }
    if (game.moveToColumn(from, target)) {
      _changed();
    } else {
      _notice('That move does not follow this mode’s rules.');
    }
  }

  void _foundation(int suit, [CardMove? drag]) {
    final from = drag ?? selected;
    if (from != null) {
      if (game.moveToFoundation(from, suit)) {
        _changed();
      } else {
        _notice('Move one card of this suit in foundation order.');
      }
    } else if (game.foundations[suit].isNotEmpty) {
      setState(
        () =>
            selected = CardMove(-10 - suit, game.foundations[suit].length - 1),
      );
    }
  }

  Future<void> _newDeal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start a new deal?'),
        content: const Text('This replaces your current board.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep playing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('New deal'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      game.deal();
      _changed();
    }
  }

  void _rules() {
    final text = switch (widget.mode) {
      GameMode.klondike =>
        'Build tableau columns downward in alternating colors. Only a King can fill an empty column. Move one Ace to its suit foundation, then build upward to King. Tap the stock to draw one card; tap the empty stock to recycle the waste.',
      GameMode.invert =>
        'Build tableau columns upward in alternating colors. Only an Ace can fill an empty column. Move one King to its suit foundation, then build downward to Ace. Tap the stock to draw or recycle.',
      GameMode.spider =>
        'One-suit Spider uses 104 cards in ten columns. Build downward from King to Ace; complete face-up sequences are collected automatically. Any valid descending stack can fill an empty column. Fill all empty columns before dealing a row of ten cards.',
    };
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_title()} rules'),
        content: SingleChildScrollView(
          child: Text(
            '$text\n\nDrag a card or tap it, then tap the destination. Undo reverses a move or deal. Your board is saved after each action.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  String _title() => switch (widget.mode) {
    GameMode.klondike => 'Klondike',
    GameMode.spider => 'Spider',
    GameMode.invert => 'Invert',
  };
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xff082f28),
    appBar: AppBar(
      backgroundColor: const Color(0xff082f28),
      foregroundColor: Colors.white,
      title: Text(_title()),
      actions: [
        IconButton(
          tooltip: 'Rules',
          onPressed: _rules,
          icon: const Icon(Icons.help_outline),
        ),
      ],
    ),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          game.won
                              ? 'You won! Beautifully played.'
                              : 'Moves: ${game.moves}  •  ${widget.mode == GameMode.spider ? '${game.completed}/8 runs' : '${game.foundations.fold<int>(0, (n, c) => n + c.length)}/52 home'}',
                          style: const TextStyle(color: Color(0xffdfc886)),
                        ),
                      ),
                      TextButton(
                        onPressed: game.canUndo
                            ? () {
                                game.undo();
                                _changed();
                              }
                            : null,
                        child: const Text('Undo'),
                      ),
                      TextButton(
                        onPressed: _newDeal,
                        child: const Text('New deal'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, bounds) {
                      final n = game.columns.length;
                      final width = min(70.0, (bounds.maxWidth - 16) / n - 4);
                      final height = width * 1.5;
                      final step = max(15.0, width * .38);
                      final tallest = game.columns.fold<int>(
                        1,
                        (m, c) => max(m, c.length),
                      );
                      final boardHeight = max(
                        height + (tallest - 1) * step + 16,
                        bounds.maxHeight - height - 72,
                      );
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Semantics(
                                    label:
                                        'Draw from stock, ${game.stock.length} cards',
                                    button: true,
                                    child: InkWell(
                                      key: const ValueKey('stock'),
                                      onTap: game.won
                                          ? null
                                          : () {
                                              final error = game.draw();
                                              if (error != null) {
                                                _notice(error);
                                              } else {
                                                _changed();
                                              }
                                            },
                                      child: _empty(
                                        '${game.stock.isEmpty ? '↻' : '◆'}\n${game.stock.length}',
                                        width,
                                        height,
                                      ),
                                    ),
                                  ),
                                  if (widget.mode != GameMode.spider)
                                    _waste(width, height),
                                  if (widget.mode == GameMode.spider)
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        '${game.stock.length ~/ 10} deals left\nOne-suit Spider',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                  if (widget.mode != GameMode.spider)
                                    ...List.generate(
                                      4,
                                      (suit) => _foundationWidget(
                                        suit,
                                        width,
                                        height,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: boardHeight,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(
                                    n,
                                    (column) => Expanded(
                                      child: _columnWidget(
                                        column,
                                        width,
                                        height,
                                        step,
                                        boardHeight,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  'Drag cards, or tap a card then its destination.',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
  );
  Widget _empty(String label, double width, double height) => Container(
    width: width,
    height: height,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .06),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: const Color(0xff739787)),
    ),
    child: Text(
      label,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: const Color(0xffdfc886),
        fontSize: label == 'Waste' ? width * .24 : min(width * .4, 22),
      ),
    ),
  );
  Widget _face(
    GameCard card,
    double width,
    double height, {
    bool highlight = false,
  }) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: card.faceUp ? Colors.white : const Color(0xff245f51),
      borderRadius: BorderRadius.circular(5),
      border: Border.all(
        color: highlight ? const Color(0xffffd65a) : const Color(0xffb4c7bd),
        width: highlight ? 3 : 1,
      ),
    ),
    child: card.faceUp
        ? Padding(
            padding: const EdgeInsets.all(3),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                card.label,
                style: TextStyle(
                  fontSize: max(12, width * .3),
                  height: 1,
                  color: card.red
                      ? const Color(0xffa02736)
                      : const Color(0xff16291f),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        : Center(
            child: Icon(
              Icons.diamond_outlined,
              color: Colors.white30,
              size: width * .5,
            ),
          ),
  );
  bool _selected(CardMove move) =>
      selected?.source == move.source && selected?.index == move.index;
  Widget _card(GameCard card, CardMove move, double width, double height) {
    if (!card.faceUp) return _face(card, width, height);
    final selectable = game.validRun(game.moving(move));
    final label =
        '${card.label}, ${move.source == -1 ? 'waste' : 'column ${move.source + 1}'}, card ${move.index + 1}';
    return Semantics(
      label: label,
      button: true,
      selected: _selected(move),
      child: Draggable<CardMove>(
        data: move,
        maxSimultaneousDrags: selectable && !game.won ? 1 : 0,
        feedback: Material(
          color: Colors.transparent,
          child: _face(card, width, height, highlight: true),
        ),
        childWhenDragging: Opacity(
          opacity: .4,
          child: _face(card, width, height),
        ),
        child: GestureDetector(
          key: ValueKey('card-${card.id}'),
          behavior: HitTestBehavior.opaque,
          onTap: game.won
              ? null
              : () {
                  if (selected != null &&
                      selected!.source != move.source &&
                      move.source >= 0) {
                    _column(move.source);
                    return;
                  }
                  if (selectable) {
                    setState(() => selected = _selected(move) ? null : move);
                  } else {
                    _notice('Move only a correctly ordered face-up sequence.');
                  }
                },
          child: _face(card, width, height, highlight: _selected(move)),
        ),
      ),
    );
  }

  Widget _waste(double w, double h) => game.waste.isEmpty
      ? _empty('Waste', w, h)
      : _card(game.waste.last, CardMove(-1, game.waste.length - 1), w, h);
  Widget _foundationWidget(int suit, double w, double h) => Semantics(
    label:
        'Foundation ${const ['spades', 'hearts', 'diamonds', 'clubs'][suit]}, ${game.foundations[suit].length} cards',
    button: true,
    child: DragTarget<CardMove>(
      onWillAcceptWithDetails: (d) => game.canMoveToFoundation(d.data, suit),
      onAcceptWithDetails: (d) => _foundation(suit, d.data),
      builder: (context, accepted, rejected) => GestureDetector(
        key: ValueKey('foundation-$suit'),
        onTap: () => _foundation(suit),
        child: game.foundations[suit].isEmpty
            ? _empty(const ['♠', '♥', '♦', '♣'][suit], w, h)
            : _face(
                game.foundations[suit].last,
                w,
                h,
                highlight: selected?.source == -10 - suit,
              ),
      ),
    ),
  );
  Widget _columnWidget(
    int column,
    double w,
    double h,
    double step,
    double boardHeight,
  ) => DragTarget<CardMove>(
    onWillAcceptWithDetails: (d) => game.canMoveToColumn(d.data, column),
    onAcceptWithDetails: (d) => _column(column, d.data),
    builder: (context, accepted, rejected) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _column(column),
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: w,
          height: boardHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Semantics(
                label: 'Empty column ${column + 1}',
                button: true,
                child: _empty('·', w, h),
              ),
              ...List.generate(
                game.columns[column].length,
                (i) => Positioned(
                  top: i * step,
                  left: 0,
                  child: _card(
                    game.columns[column][i],
                    CardMove(column, i),
                    w,
                    h,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
