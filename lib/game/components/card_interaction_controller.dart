import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';

import '../data/game_constants.dart';
import 'card.dart';
import 'card_deck.dart';
import 'interaction_constants.dart';

/// Handles tap interaction & selection animations for a GameCard.
class CardInteractionController {
  CardInteractionController(this.card);

  final GameCard card;

  late Vector2 _originalSize; // for scaling calculations only
  bool _isSelected = false;
  bool _isAnimating = false;

  bool get isSelected => _isSelected;
  bool get isAnimating => _isAnimating;

  void initialize() {
    _originalSize = card.size.clone();
  }

  bool onTapDown(TapDownEvent event) {
    if (!_isAnimating) {
      _selectAtPosition(event.localPosition);
    }
    return true;
  }

  bool onTapUp(TapUpEvent event) {
    if (_isSelected && !_isAnimating) {
      _deselect();
    }
    return true;
  }

  bool onTapCancel(TapCancelEvent event) {
    if (_isSelected && !_isAnimating) {
      _deselect();
    }
    return true;
  }

  void forceDeselect() {
    if (_isSelected && !_isAnimating) {
      _deselect();
    }
  }

  void _selectAtPosition(Vector2 pressPosition) {
    if (_isSelected || _isAnimating) return;

    _isSelected = true;
    _isAnimating = true;

    // Notify selection manager via callback.
    card.onSelectionChanged?.call(card);

    card.priority = InteractionConstants.selectedPriority; // bring to front

    const scale = InteractionConstants.selectedScale;
    final enlargedHeight = _originalSize.y * scale;
    final gameSize = card.game.size;
    double targetY = card.position.y;

    final bottomOfCard = card.position.y + enlargedHeight / 2;
    if (bottomOfCard > gameSize.y) {
      targetY -= (bottomOfCard - gameSize.y);
    }
    final topOfCard = targetY - enlargedHeight / 2;
    if (topOfCard < 0) {
      targetY -= topOfCard;
    }

    final moveEffect = MoveEffect.to(
      Vector2(card.position.x, targetY),
      EffectController(duration: GameConstants.cardAnimationDuration),
    );
    final scaleEffect = ScaleEffect.to(
      Vector2.all(scale),
      EffectController(duration: GameConstants.cardAnimationDuration),
    );
    final rotateEffect = RotateEffect.to(
      0.0,
      EffectController(duration: GameConstants.cardAnimationDuration),
    );

    moveEffect.onComplete = () => _isAnimating = false;

    card.add(moveEffect);
    card.add(scaleEffect);
    card.add(rotateEffect);
  }

  void _deselect() {
    if (!_isSelected || _isAnimating) return;

    _isSelected = false;
    _isAnimating = true;

    final parent = card.parent;
    if (parent is CardDeck) {
      card.priority = parent.getCardPriority(card);
    }

    final moveEffect = MoveEffect.to(
      card.originalPosition,
      EffectController(duration: GameConstants.cardAnimationDuration),
    );
    final scaleEffect = ScaleEffect.to(
      Vector2.all(1.0),
      EffectController(duration: GameConstants.cardAnimationDuration),
    );
    final rotateEffect = RotateEffect.to(
      card.cardRotation,
      EffectController(duration: GameConstants.cardAnimationDuration),
    );

    moveEffect.onComplete = () => _isAnimating = false;

    card.add(moveEffect);
    card.add(scaleEffect);
    card.add(rotateEffect);
  }
}
