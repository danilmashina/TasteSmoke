import 'package:json_annotation/json_annotation.dart';

part 'ad_banner.g.dart';

@JsonSerializable()
class AdBanner {
  final String id;
  final String placement;
  final String? title;
  final String? description;
  final String imageUrl;
  final String? clickUrl;
  final int priority;
  final bool isActive;
  final DateTime? startAt;
  final DateTime? endAt;
  final double? aspectRatio;
  final String? bgColor;
  final String? trackingId;

  const AdBanner({
    this.id = '',
    this.placement = '',
    this.title,
    this.description,
    this.imageUrl = '',
    this.clickUrl,
    this.priority = 0,
    this.isActive = true,
    this.startAt,
    this.endAt,
    this.aspectRatio = 1.78, // ~16:9 по умолчанию (как в Android версии)
    this.bgColor,
    this.trackingId,
  });

  // Проверка активности баннера
  bool get isCurrentlyActive {
    if (!isActive) return false;
    
    final now = DateTime.now();
    if (startAt != null && now.isBefore(startAt!)) return false;
    if (endAt != null && now.isAfter(endAt!)) return false;
    
    return true;
  }

  // JSON сериализация
  factory AdBanner.fromJson(Map<String, dynamic> json) =>
      _$AdBannerFromJson(json);

  Map<String, dynamic> toJson() => _$AdBannerToJson(this);

  // Создание из Firebase данных
  factory AdBanner.fromMap(String id, Map<String, dynamic> data) {
    try {
      // Обработка timestamp полей
      DateTime? parseTimestamp(dynamic value) {
        if (value == null) return null;
        if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
        if (value is String) {
          final parsed = int.tryParse(value);
          return parsed != null ? DateTime.fromMillisecondsSinceEpoch(parsed) : null;
        }
        return null;
      }

      return AdBanner(
        id: id,
        placement: data['placement'] as String? ?? '',
        title: data['title'] as String?,
        description: data['description'] as String?,
        imageUrl: data['imageUrl'] as String? ?? '',
        clickUrl: data['clickUrl'] as String?,
        priority: (data['priority'] as num?)?.toInt() ?? 0,
        isActive: data['isActive'] as bool? ?? true,
        startAt: parseTimestamp(data['startAt']),
        endAt: parseTimestamp(data['endAt']),
        aspectRatio: (data['aspectRatio'] as num?)?.toDouble() ?? 1.78,
        bgColor: data['bgColor'] as String?,
        trackingId: data['trackingId'] as String?,
      );
    } catch (e) {
      // В случае ошибки возвращаем пустой баннер с правильным ID
      return AdBanner(id: id);
    }
  }

  // Преобразование в Map для Firebase
  Map<String, dynamic> toMap() {
    return {
      'placement': placement,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'clickUrl': clickUrl,
      'priority': priority,
      'isActive': isActive,
      'startAt': startAt?.millisecondsSinceEpoch,
      'endAt': endAt?.millisecondsSinceEpoch,
      'aspectRatio': aspectRatio,
      'bgColor': bgColor,
      'trackingId': trackingId,
    };
  }

  // copyWith метод
  AdBanner copyWith({
    String? id,
    String? placement,
    String? title,
    String? description,
    String? imageUrl,
    String? clickUrl,
    int? priority,
    bool? isActive,
    DateTime? startAt,
    DateTime? endAt,
    double? aspectRatio,
    String? bgColor,
    String? trackingId,
  }) {
    return AdBanner(
      id: id ?? this.id,
      placement: placement ?? this.placement,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      clickUrl: clickUrl ?? this.clickUrl,
      priority: priority ?? this.priority,
      isActive: isActive ?? this.isActive,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      bgColor: bgColor ?? this.bgColor,
      trackingId: trackingId ?? this.trackingId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdBanner &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          placement == other.placement;

  @override
  int get hashCode => id.hashCode ^ placement.hashCode;

  // Размеры баннеров (как в спецификации Android версии)
  static const double bannerWidth = 280.0; // dp
  static const double bannerHeight = 158.0; // dp
  static const double defaultAspectRatio = 1.78; // 16:9

  // Типы размещения
  static const String homeBannerPlacement = 'home_popular_bottom';
}