import 'package:flutter/material.dart';
import '../models/public_mix.dart';
import '../utils/theme.dart';

/// Виджет карточки микса
class MixCard extends StatelessWidget {
  final PublicMix mix;
  final VoidCallback onTap;
  final bool showLikes;

  const MixCard({
    super.key,
    required this.mix,
    required this.onTap,
    this.showLikes = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardBackground,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и категория
              Row(
                children: [
                  Expanded(
                    child: Text(
                      mix.name,
                      style: const TextStyle(
                        color: AppTheme.primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentPink.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      mix.category,
                      style: const TextStyle(
                        color: AppTheme.accentPink,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ), 
              
              const SizedBox(height: 12),
              
              // Автор
              Text(
                'Автор: ${mix.authorName}',
                style: const TextStyle(
                  color: AppTheme.secondaryText,
                  fontSize: 14,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Список ингредиентов
              ...mix.tobaccoIngredients.take(3).map((ingredient) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text(
                      '• ${ingredient.brand} ${ingredient.flavor}',
                      style: const TextStyle(
                        color: AppTheme.primaryText,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${ingredient.amount}%',
                      style: const TextStyle(
                        color: AppTheme.accentPink,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )).toList(),
              
              if (mix.tobaccoIngredients.length > 3)
                const Text(
                  '...',
                  style: TextStyle(
                    color: AppTheme.secondaryText,
                    fontSize: 14,
                  ),
                ),
              
              const SizedBox(height: 12),
              
              // Лайки и действия
              Row(
                children: [
                  if (showLikes) ...[
                    Icon(
                      Icons.favorite,
                      color: AppTheme.accentPink,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${mix.likeCount}',
                      style: const TextStyle(
                        color: AppTheme.secondaryText,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Icon(
                    Icons.access_time,
                    color: AppTheme.secondaryText,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${mix.smokingTime} мин',
                    style: const TextStyle(
                      color: AppTheme.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    mix.strength,
                    style: const TextStyle(
                      color: AppTheme.accentPink,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Упрощенная версия карточки для списков
class SimpleMixCard extends StatelessWidget {
  final PublicMix mix;
  final VoidCallback? onTap;

  const SimpleMixCard({
    super.key,
    required this.mix,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: AppTheme.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      title: Text(
        mix.name,
        style: const TextStyle(
          color: AppTheme.primaryText,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        mix.authorName,
        style: const TextStyle(color: AppTheme.secondaryText),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mix.totalTobaccoAmount > 0)
            Text(
              '${mix.totalTobaccoAmount}%',
              style: const TextStyle(
                color: AppTheme.accentPink,
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right,
            color: AppTheme.accentPink,
          ),
        ],
      ),
    );
  }
}

/// Карточка для горизонтального скролла
class HorizontalMixCard extends StatelessWidget {
  final PublicMix mix;
  final VoidCallback? onTap;

  const HorizontalMixCard({
    super.key,
    required this.mix,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: AppTheme.paddingMedium),
        child: Card(
          color: AppTheme.cardBackground,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mix.name,
                  style: const TextStyle(
                    color: AppTheme.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppTheme.paddingSmall),
                Text(
                  mix.authorName,
                  style: const TextStyle(
                    color: AppTheme.secondaryText,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                if (mix.totalTobaccoAmount > 0)
                  Text(
                    '${mix.totalTobaccoAmount}%',
                    style: const TextStyle(
                      color: AppTheme.accentPink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}