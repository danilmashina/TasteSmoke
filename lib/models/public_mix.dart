import 'package:json_annotation/json_annotation.dart';
import 'tobacco_ingredient.dart';

part 'public_mix.g.dart';

@JsonSerializable()
class PublicMix {
  final String id;                              // Firestore id
  final String name;                            // название микса
  final String category;                        // категория
  final String authorUid;                       // ID автора
  final String authorName;                      // имя автора
  final int createdAt;                         // timestamp
  final int likeCount;                         // количество лайков
  final List<TobaccoIngredient> tobaccoIngredients; // список табаков
  final int smokingTime;                       // время курения в минутах
  final String strength;                       // крепость: Легкий/Средний/Крепкий
  final int tobaccoAmount;                     // deprecated, для обратной совместимости

  const PublicMix({
    this.id = '',
    this.name = '',
    this.category = '',
    this.authorUid = '',
    this.authorName = '',
    this.createdAt = 0,
    this.likeCount = 0,
    this.tobaccoIngredients = const [],
    this.smokingTime = 0,
    this.strength = 'Средний',
    this.tobaccoAmount = 0,
  });

  // Вычисляемое свойство для общего количества табака
  int get totalTobaccoAmount {
    if (tobaccoIngredients.isNotEmpty) {
      return tobaccoIngredients.fold(0, (sum, ingredient) => sum + ingredient.amount);
    } else {
      return tobaccoAmount; // fallback для старых записей
    }
  }

  // Форматированная дата создания
  DateTime get createdAtDateTime => DateTime.fromMillisecondsSinceEpoch(createdAt);

  // JSON сериализация
  factory PublicMix.fromJson(Map<String, dynamic> json) =>
      _$PublicMixFromJson(json);

  Map<String, dynamic> toJson() => _$PublicMixToJson(this);

  // Создание из Firebase данных
  factory PublicMix.fromMap(String id, Map<String, dynamic> data) {
    try {
      // Обработка createdAt (может быть Timestamp или long)
      int createdAtLong;
      final createdAtRaw = data['createdAt'];
      if (createdAtRaw is int) {
        createdAtLong = createdAtRaw;
      } else if (createdAtRaw is String) {
        createdAtLong = int.tryParse(createdAtRaw) ?? DateTime.now().millisecondsSinceEpoch;
      } else {
        createdAtLong = DateTime.now().millisecondsSinceEpoch;
      }

      // Парсим список табаков
      List<TobaccoIngredient> tobaccoIngredients = [];
      final ingredientsRaw = data['tobaccoIngredients'] as List<dynamic>?;
      if (ingredientsRaw != null) {
        tobaccoIngredients = ingredientsRaw
            .where((item) => item is Map<String, dynamic>)
            .map((item) => TobaccoIngredient.fromMap(item as Map<String, dynamic>))
            .toList();
      }

      return PublicMix(
        id: id,
        name: data['name'] as String? ?? '',
        category: data['category'] as String? ?? '',
        authorUid: data['authorUid'] as String? ?? '',
        authorName: data['authorName'] as String? ?? '',
        createdAt: createdAtLong,
        likeCount: (data['likeCount'] as num?)?.toInt() ?? 0,
        tobaccoIngredients: tobaccoIngredients,
        smokingTime: (data['smokingTime'] as num?)?.toInt() ?? 0,
        strength: data['strength'] as String? ?? 'Средний',
        tobaccoAmount: (data['tobaccoAmount'] as num?)?.toInt() ?? 0,
      );
    } catch (e) {
      // В случае ошибки возвращаем пустой микс с правильным ID
      return PublicMix(id: id);
    }
  }

  // Преобразование в Map для Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'authorUid': authorUid,
      'authorName': authorName,
      'createdAt': createdAt,
      'likeCount': likeCount,
      'tobaccoIngredients': tobaccoIngredients.map((ingredient) => ingredient.toMap()).toList(),
      'smokingTime': smokingTime,
      'strength': strength,
      'tobaccoAmount': tobaccoAmount,
    };
  }

  // copyWith метод
  PublicMix copyWith({
    String? id,
    String? name,
    String? category,
    String? authorUid,
    String? authorName,
    int? createdAt,
    int? likeCount,
    List<TobaccoIngredient>? tobaccoIngredients,
    int? smokingTime,
    String? strength,
    int? tobaccoAmount,
  }) {
    return PublicMix(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      authorUid: authorUid ?? this.authorUid,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      likeCount: likeCount ?? this.likeCount,
      tobaccoIngredients: tobaccoIngredients ?? this.tobaccoIngredients,
      smokingTime: smokingTime ?? this.smokingTime,
      strength: strength ?? this.strength,
      tobaccoAmount: tobaccoAmount ?? this.tobaccoAmount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PublicMix &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          category == other.category &&
          authorUid == other.authorUid;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ category.hashCode ^ authorUid.hashCode;

  // Категории миксов
  static const List<String> categories = [
    'Фрукты',
    'Ягоды', 
    'Цитрусовые',
    'Десерты',
    'Напитки',
    'Мятные',
    'Пряные',
    'Кислые',
    'Необычные',
  ];

  // Уровни крепости
  static const List<String> strengthLevels = [
    'Легкий',
    'Средний', 
    'Крепкий',
  ];
}