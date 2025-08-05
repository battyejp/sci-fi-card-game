import '../components/card.dart';
import '../../models/card_model.dart';

class CardManager {
  final List<GameCard> _cards = [];
  final List<CardModel> _cardModels = [];
  
  // Initialize with sample cards
  void initializeCards() {
    _cardModels.clear();
    for (int i = 0; i < 5; i++) {
      _cardModels.add(CardModel.sample(i.toString()));
    }
  }
  
  // Get all card models
  List<CardModel> get cardModels => List.unmodifiable(_cardModels);
  
  // Get all game cards
  List<GameCard> get gameCards => List.unmodifiable(_cards);
  
  // Add a game card
  void addGameCard(GameCard card) {
    _cards.add(card);
  }
  
  // Remove a game card
  void removeGameCard(GameCard card) {
    _cards.remove(card);
  }
  
  // Clear all cards
  void clearCards() {
    _cards.clear();
  }
  
  // Get card model by id
  CardModel? getCardModelById(String id) {
    try {
      return _cardModels.firstWhere((card) => card.id == id);
    } catch (e) {
      return null;
    }
  }
}
