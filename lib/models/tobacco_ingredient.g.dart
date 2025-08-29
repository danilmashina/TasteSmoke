// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tobacco_ingredient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TobaccoIngredient _$TobaccoIngredientFromJson(Map<String, dynamic> json) =>
    TobaccoIngredient(
      brand: json['brand'] as String? ?? '',
      flavor: json['flavor'] as String? ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TobaccoIngredientToJson(TobaccoIngredient instance) =>
    <String, dynamic>{
      'brand': instance.brand,
      'flavor': instance.flavor,
      'amount': instance.amount,
    };
