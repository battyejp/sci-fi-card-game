import 'package:flame/components.dart';
import '../card/card.dart';
import 'card_hand_controller.dart';

class CardHand extends Component with HasGameReference {
  CardHand({CardHandController? controller})
      : _controller = controller ?? CardHandController();

  final CardHandController _controller;

  CardHandController get controller => _controller; // for tests / inspection

  @override
  Future<void> onLoad() async {
    await _controller.buildHand(this, game.size);
  }

  void resetAllCards() => _controller.resetAllCards(this, game.size);
  int getCardPriority(GameCard card) => _controller.getCardPriority(card);
  int get cardCount => _controller.cardCount;
  List<GameCard> get cards => _controller.cards;
  GameCard? get selectedCard => _controller.selectedCard;
}
