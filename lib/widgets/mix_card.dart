import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/public_mix.dart';
import '../utils/theme.dart';
import '../providers/mixes_provider.dart';
import '../providers/auth_provider.dart';

class MixCard extends ConsumerWidget {
  final PublicMix mix;
  final VoidCallback? onTap;
  final bool showLikes;
  final bool showFavorites;

  const MixCard({
    super.key,
    required this.mix,
    this.onTap,
    this.showLikes = false,
    this.showFavorites = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider).value;
    final favorites = ref.watch(favoritesManagerProvider);
    final isFavorite = favorites.contains(mix.id);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Card(
          color: AppTheme.cardBackground,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Основная информация
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Название микса (первая строка)
                      Text(
                        _getFirstLine(mix.name),
                        style: const TextStyle(
                          color: AppTheme.primaryText,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      // Автор
                      Text(
                        'Автор: ${mix.authorName}',
                        style: const TextStyle(
                          color: AppTheme.secondaryText,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      
                      // Информация о параметрах
                      _buildInfoText(),
                      
                      // Ингредиенты (если есть место)
                      if (mix.tobaccoIngredients.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        _buildIngredientsPreview(),
                      ],
                    ],
                  ),
                ),
                
                // Правая панель с действиями
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Лайки
                    if (showLikes) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: AppTheme.accentPink,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${mix.likeCount}',
                            style: const TextStyle(
                              color: AppTheme.primaryText,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    
                    // Избранное
                    if (showFavorites && currentUser?.uid != mix.authorUid) ...[
                      IconButton(
                        onPressed: () => _toggleFavorite(ref),
                        icon: Icon(
                          isFavorite ? Icons.star : Icons.star_border,
                          color: isFavorite ? AppTheme.accentPink : AppTheme.secondaryText,
                          size: 24,
                        ),
                      ),
                    ],
                    
                    // Стрелочка для перехода
                    const Text(
                      '›',
                      style: TextStyle(
                        color: AppTheme.accentPink,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoText() {
    final infoParts = <String>[];
    
    // Общее количество табака в процентах
    if (mix.totalTobaccoAmount > 0) {
      infoParts.add('${mix.totalTobaccoAmount}%');
    }
    
    // Время курения
    if (mix.smokingTime > 0) {
      infoParts.add('${mix.smokingTime}мин');
    }
    
    final infoText = infoParts.join(' • ');
    
    if (infoText.isNotEmpty) {
      return Text(
        infoText,
        style: TextStyle(
          color: AppTheme.secondaryText.withOpacity(0.8),
          fontSize: 12,
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildIngredientsPreview() {
    // Показываем первые 2-3 ингредиента
    final visibleIngredients = mix.tobaccoIngredients.take(2).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: visibleIngredients.map((ingredient) {
        return Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${ingredient.brand} ${ingredient.flavor}',
                  style: const TextStyle(
                    color: AppTheme.secondaryText,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${ingredient.amount}%',
                style: const TextStyle(
                  color: AppTheme.accentPink,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getFirstLine(String text) {
    final lines = text.split('\n');
    return lines.isNotEmpty ? lines.first.trim() : '';
  }

  void _toggleFavorite(WidgetRef ref) {
    final favoritesManager = ref.read(favoritesManagerProvider.notifier);
    final isFavorite = ref.read(favoritesManagerProvider).contains(mix.id);
    
    if (isFavorite) {
      favoritesManager.removeFromFavorites(mix.id);
    } else {
      favoritesManager.addToFavorites(mix);
    }
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