import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../card/card.dart';
import '../data/game_constants.dart';

class CardPile extends Component with HasGameReference, TapCallbacks {
  CardPile({required this.onPileClicked});

  final VoidCallback onPileClicked;
  late GameCard _topCard;
  bool _hasCards = true;

  bool get hasCards => _hasCards;

  @override
  Future<void> onLoad() async {
    // Create a card back to represent the pile
    _topCard = GameCard(showBack: true);
    
    // Position the pile on the right side of the screen
    final pileX = game.size.x - GameConstants.handCardWidth / 2 - GameConstants.safeAreaPadding;
    final pileY = game.size.y / 2;
    
    _topCard.setOriginalPosition(Vector2(pileX, pileY));
    _topCard.setRotation(0.0);
    _topCard.priority = 100; // High priority so it's always on top
    
    add(_topCard);
    
    // Set up the hit area for the pile
    size = Vector2(GameConstants.handCardWidth, GameConstants.handCardHeight);
    position = Vector2(pileX, pileY);
    anchor = Anchor.center;
  }

  @override
  bool onTapUp(TapUpEvent event) {
    if (_hasCards) {
      onPileClicked();
      return true;
    }
    return false;
  }

  void removeCards(int count) {
    // In a real implementation, we might show fewer cards in the pile
    // For now, we'll just track if the pile is empty
    if (count >= GameConstants.cardsToDealt) {
      _hasCards = false;
      if (_topCard.isMounted) {
        _topCard.removeFromParent();
      }
    }
  }

  void reset() {
    _hasCards = true;
    if (!_topCard.isMounted && isMounted) {
      add(_topCard);
    }
  }
}