import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../data/game_constants.dart';

class DeckCard extends SpriteComponent with HasGameReference, TapCallbacks {
  DeckCard({String? id}) : id = id ?? _nextId();

  final String id;
  static int _idCounter = 0;
  static String _nextId() => 'deck_card_${_idCounter++}';

  Function(DeckCard)? onTapped;

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('card_back.png');
    size = Vector2(GameConstants.handCardWidth, GameConstants.handCardHeight);
    anchor = Anchor.center;
  }

  @override
  bool onTapDown(TapDownEvent event) {
    return true;
  }

  @override
  bool onTapUp(TapUpEvent event) {
    onTapped?.call(this);
    return true;
  }

  @override
  bool onTapCancel(TapCancelEvent event) {
    return true;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'x': position.x,
        'y': position.y,
      };

  @override
  String toString() => 'DeckCard(${toJson()})';
}