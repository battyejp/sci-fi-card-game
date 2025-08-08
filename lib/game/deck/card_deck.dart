import 'package:flame/components.dart';
import '../card/card.dart';
import 'card_deck_controller.dart';

class CardDeck extends Component with HasGameReference {
  CardDeck({CardDeckController? controller})
      : _controller = controller ?? CardDeckController();

  final CardDeckController _controller;

  CardDeckController get controller => _controller; // for tests / inspection

  @override
  Future<void> onLoad() async {
    await _controller.buildDeck(this, game.size);
  }

  void resetAllCards() => _controller.resetAllCards(this, game.size);
  int getCardPriority(GameCard card) => _controller.getCardPriority(card);
  int get cardCount => _controller.cardCount;
  List<GameCard> get cards => _controller.cards;
  GameCard? get selectedCard => _controller.selectedCard;
}
