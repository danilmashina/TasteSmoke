// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ad_banner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdBanner _$AdBannerFromJson(Map<String, dynamic> json) => AdBanner(
      id: json['id'] as String? ?? '',
      placement: json['placement'] as String? ?? '',
      title: json['title'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String? ?? '',
      clickUrl: json['clickUrl'] as String?,
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      startAt: json['startAt'] == null
          ? null
          : DateTime.parse(json['startAt'] as String),
      endAt: json['endAt'] == null
          ? null
          : DateTime.parse(json['endAt'] as String),
      aspectRatio: (json['aspectRatio'] as num?)?.toDouble() ?? 1.78,
      bgColor: json['bgColor'] as String?,
      trackingId: json['trackingId'] as String?,
    );

Map<String, dynamic> _$AdBannerToJson(AdBanner instance) => <String, dynamic>{
      'id': instance.id,
      'placement': instance.placement,
      'title': instance.title,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'clickUrl': instance.clickUrl,
      'priority': instance.priority,
      'isActive': instance.isActive,
      'startAt': instance.startAt?.toIso8601String(),
      'endAt': instance.endAt?.toIso8601String(),
      'aspectRatio': instance.aspectRatio,
      'bgColor': instance.bgColor,
      'trackingId': instance.trackingId,
    };
