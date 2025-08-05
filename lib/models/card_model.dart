enum CardType {
  attack,
  defense,
  special,
  resource,
}

enum CardRarity {
  common,
  uncommon,
  rare,
  legendary,
}

class CardModel {
  final String id;
  final String name;
  final String description;
  final CardType type;
  final CardRarity rarity;
  final int cost;
  final int? attack;
  final int? defense;
  final String imageAsset;

  const CardModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.rarity,
    required this.cost,
    this.attack,
    this.defense,
    required this.imageAsset,
  });

  // Factory method for creating sample cards
  factory CardModel.sample(String id) {
    return CardModel(
      id: id,
      name: 'Sample Card $id',
      description: 'A sample sci-fi card',
      type: CardType.attack,
      rarity: CardRarity.common,
      cost: 1,
      attack: 2,
      defense: 1,
      imageAsset: 'card.png',
    );
  }

  @override
  String toString() {
    return 'CardModel(id: $id, name: $name, type: $type, cost: $cost)';
  }
}
