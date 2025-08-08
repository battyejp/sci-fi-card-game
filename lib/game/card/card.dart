import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../data/game_constants.dart';
import 'card_interaction_controller.dart';

class GameCard extends SpriteComponent with HasGameReference, TapCallbacks {
  GameCard({String? id}) : id = id ?? _nextId();

  final String id;
  static int _idCounter = 0;
  static String _nextId() => 'card_${_idCounter++}';

  Function(GameCard)? onSelectionChanged;

  CardInteractionController? _interaction; // becomes available after onLoad
  Vector2? _pendingOriginalPosition;
  double? _pendingRotation;

  // Authoritative base layout state (independent of interaction controller)
  Vector2? _originalPositionInternal;
  double _baseRotation = 0.0;

  bool get _ready => _interaction != null;

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('card.png');
    size = Vector2(GameConstants.handCardWidth, GameConstants.handCardHeight);
    anchor = Anchor.center;
    _interaction = CardInteractionController(this)..initialize();

    // Apply pending state captured before load.
    if (_pendingOriginalPosition != null) {
      _setBaseOriginalPosition(_pendingOriginalPosition!);
      _pendingOriginalPosition = null;
    } else {
      // Establish original if not preset
      _setBaseOriginalPosition(position.clone());
    }
    if (_pendingRotation != null) {
      _setBaseRotation(_pendingRotation!);
      _pendingRotation = null;
    } else {
      _setBaseRotation(angle);
    }
  }

  @override
  bool onTapDown(TapDownEvent event) => _interaction?.onTapDown(event) ?? false;
  @override
  bool onTapUp(TapUpEvent event) => _interaction?.onTapUp(event) ?? false;
  @override
  bool onTapCancel(TapCancelEvent event) => _interaction?.onTapCancel(event) ?? false;

  void setOriginalPosition(Vector2 p) {
    if (_ready) {
      _setBaseOriginalPosition(p);
    } else {
      position = p.clone();
      _pendingOriginalPosition = p.clone();
    }
  }

  void setRotation(double r) {
    if (_ready) {
      _setBaseRotation(r);
    } else {
      angle = r;
      _pendingRotation = r;
    }
  }

  void _setBaseOriginalPosition(Vector2 p) {
    _originalPositionInternal = p.clone();
    position = p.clone();
  }

  void _setBaseRotation(double r) {
    _baseRotation = r;
    angle = r;
  }

  void forceDeselect() => _interaction?.forceDeselect();

  Vector2 get originalPosition => _originalPositionInternal ?? _pendingOriginalPosition ?? position;
  double get cardRotation => _baseRotation;
  bool get isSelected => _interaction?.isSelected ?? false;
  bool get isAnimating => _interaction?.isAnimating ?? false;

  Map<String, dynamic> toJson() => {
        'id': id,
        'x': position.x,
        'y': position.y,
        'rotation': cardRotation,
        'selected': isSelected,
      };

  @override
  String toString() => 'GameCard(${toJson()})';
}
