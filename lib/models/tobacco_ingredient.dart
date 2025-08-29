import 'package:json_annotation/json_annotation.dart';

part 'tobacco_ingredient.g.dart';

@JsonSerializable()
class TobaccoIngredient {
  final String brand;   // Бренд табака (например, "MUSTHAVE", "BRUSKO")
  final String flavor;  // Вкус (например, "Клюква", "Банан")
  final int amount;     // Количество в процентах

  const TobaccoIngredient({
    this.brand = '',
    this.flavor = '',
    this.amount = 0,
  });

  // Методы для отображения
  String getDisplayName() {
    if (brand.isNotEmpty && flavor.isNotEmpty) {
      return '$brand $flavor';
    } else if (flavor.isNotEmpty) {
      return flavor;
    } else {
      return 'Табак';
    }
  }

  String getShortDisplayName() {
    if (brand.isNotEmpty && flavor.isNotEmpty) {
      return '${brand.substring(0, brand.length > 3 ? 3 : brand.length)} ${flavor.substring(0, flavor.length > 8 ? 8 : flavor.length)}';
    } else if (flavor.isNotEmpty) {
      return flavor.substring(0, flavor.length > 10 ? 10 : flavor.length);
    } else {
      return 'Табак';
    }
  }

  // JSON сериализация
  factory TobaccoIngredient.fromJson(Map<String, dynamic> json) =>
      _$TobaccoIngredientFromJson(json);

  Map<String, dynamic> toJson() => _$TobaccoIngredientToJson(this);

  // Создание из Firebase данных
  factory TobaccoIngredient.fromMap(Map<String, dynamic> map) {
    return TobaccoIngredient(
      brand: map['brand'] as String? ?? '',
      flavor: map['flavor'] as String? ?? '',
      amount: (map['amount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'flavor': flavor,
      'amount': amount,
    };
  }

  // copyWith метод
  TobaccoIngredient copyWith({
    String? brand,
    String? flavor,
    int? amount,
  }) {
    return TobaccoIngredient(
      brand: brand ?? this.brand,
      flavor: flavor ?? this.flavor,
      amount: amount ?? this.amount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TobaccoIngredient &&
          runtimeType == other.runtimeType &&
          brand == other.brand &&
          flavor == other.flavor &&
          amount == other.amount;

  @override
  int get hashCode => brand.hashCode ^ flavor.hashCode ^ amount.hashCode;

  // Популярные бренды табака (статические данные)
  static const List<String> popularBrands = [
    'ADALYA',
    'AL FAKHER',
    'BRUSKO',
    'BLACKBURN',
    'BONCHE',
    'DARKSIDE',
    'DAILY HOOKAH',
    'DOGMA',
    'DUFT',
    'ELEMENT',
    'FUMARI',
    'HLGN',
    'MUSTHAVE',
    'MATTPEAR',
    'NAKHLA',
    'NORTHERN',
    'OVERDOSE',
    'STARBUZZ',
    'SERBETLI',
    'SATYR',
    'SPECTRUM',
    'SEBERO',
    'SAPPHIRE',
    'TANGIERS',
    'TABOO',
    'TROFIMOFF',
    'Северный',
    'Наш',
  ];

  // Популярные вкусы
  static const List<String> popularFlavors = [
    'Клюква',
    'Банан',
    'Двойное яблоко',
    'Виноград',
    'Арбуз',
    'Дыня',
    'Персик',
    'Манго',
    'Киви',
    'Лимон',
    'Апельсин',
    'Грейпфрут',
    'Мята',
    'Ваниль',
    'Шоколад',
    'Кола',
    'Энергетик',
    'Жвачка',
    'Печенье',
    'Пирожное',
    'Молоко',
    'Кофе',
    'Чай',
    'Лед',
    'Холодок',
  ];
}