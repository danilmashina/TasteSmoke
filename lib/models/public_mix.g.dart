// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_mix.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicMix _$PublicMixFromJson(Map<String, dynamic> json) => PublicMix(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      authorUid: json['authorUid'] as String? ?? '',
      authorName: json['authorName'] as String? ?? '',
      createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      tobaccoIngredients: (json['tobaccoIngredients'] as List<dynamic>?)?.map((e) => TobaccoIngredient.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
      smokingTime: (json['smokingTime'] as num?)?.toInt() ?? 0,
      strength: json['strength'] as String? ?? 'Средний',
      tobaccoAmount: (json['tobaccoAmount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PublicMixToJson(PublicMix instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'authorUid': instance.authorUid,
      'authorName': instance.authorName,
      'createdAt': instance.createdAt,
      'likeCount': instance.likeCount,
      'tobaccoIngredients': instance.tobaccoIngredients,
      'smokingTime': instance.smokingTime,
      'strength': instance.strength,
      'tobaccoAmount': instance.tobaccoAmount,
    };
