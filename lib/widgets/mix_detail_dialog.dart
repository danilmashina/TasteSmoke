import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/public_mix.dart';
import '../utils/theme.dart';
import '../providers/mixes_provider.dart';
import '../providers/auth_provider.dart';

class MixDetailDialog extends ConsumerStatefulWidget {
  final PublicMix mix;
  final VoidCallback onClose;

  const MixDetailDialog({
    super.key,
    required this.mix,
    required this.onClose,
  });

  @override
  ConsumerState<MixDetailDialog> createState() => _MixDetailDialogState();
}

class _MixDetailDialogState extends ConsumerState<MixDetailDialog> {
  bool _isLiking = false;
  bool _isFavoriting = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider).value;
    final favorites = ref.watch(favoritesManagerProvider);
    final isFavorite = favorites.contains(widget.mix.id);
    final isOwnMix = currentUser?.uid == widget.mix.authorUid;

    return AlertDialog(
      backgroundColor: AppTheme.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      title: Text(
        widget.mix.name,
        style: const TextStyle(
          color: AppTheme.primaryText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Информация об авторе и дате
            _buildAuthorInfo(),
            
            const SizedBox(height: AppTheme.paddingMedium),
            
            // Состав табака
            if (widget.mix.tobaccoIngredients.isNotEmpty) ...[
              _buildIngredientsSection(),
              const SizedBox(height: AppTheme.paddingMedium),
            ],
            
            // Параметры микса
            _buildParametersSection(),
          ],
        ),
      ),
      actions: [
        // Кнопки действий
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Левая часть - лайк и избранное
            if (!isOwnMix) ...[
              Row(
                children: [
                  // Лайк
                  IconButton(
                    onPressed: _isLiking ? null : _toggleLike,
                    icon: Icon(
                      Icons.favorite,
                      color: AppTheme.accentPink,
                      size: 24,
                    ),
                  ),
                  Text(
                    '${widget.mix.likeCount}',
                    style: const TextStyle(
                      color: AppTheme.primaryText,
                      fontSize: 16,
                    ),
                  ),
                  
                  const SizedBox(width: AppTheme.paddingSmall),
                  
                  // Избранное
                  IconButton(
                    onPressed: _isFavoriting ? null : _toggleFavorite,
                    icon: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      color: isFavorite ? AppTheme.accentPink : AppTheme.secondaryText,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox.shrink(),
            ],
            
            // Кнопка закрытия
            TextButton(
              onPressed: widget.onClose,
              child: const Text(
                'Закрыть',
                style: TextStyle(color: AppTheme.accentPink),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAuthorInfo() {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final createdDate = widget.mix.createdAtDateTime;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Автор: ${widget.mix.authorName}',
          style: const TextStyle(
            color: AppTheme.secondaryText,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dateFormat.format(createdDate),
          style: const TextStyle(
            color: AppTheme.secondaryText,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Состав табака:',
          style: TextStyle(
            color: AppTheme.primaryText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        
        ...widget.mix.tobaccoIngredients.map((ingredient) => 
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (ingredient.brand.isNotEmpty)
                        Text(
                          ingredient.brand,
                          style: const TextStyle(
                            color: AppTheme.secondaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (ingredient.flavor.isNotEmpty)
                        Text(
                          ingredient.flavor,
                          style: TextStyle(
                            color: AppTheme.secondaryText.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                if (ingredient.amount > 0)
                  Text(
                    '${ingredient.amount}%',
                    style: const TextStyle(
                      color: AppTheme.accentPink,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParametersSection() {
    final hasParameters = widget.mix.strength.isNotEmpty || 
                         widget.mix.totalTobaccoAmount > 0 || 
                         widget.mix.smokingTime > 0;
    
    if (!hasParameters) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Параметры микса:',
          style: TextStyle(
            color: AppTheme.primaryText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        
        if (widget.mix.strength.isNotEmpty)
          _buildParameterRow('Крепость:', widget.mix.strength),
        
        if (widget.mix.totalTobaccoAmount > 0)
          _buildParameterRow(
            'Общее количество:', 
            '${widget.mix.totalTobaccoAmount}%'
          ),
        
        if (widget.mix.smokingTime > 0)
          _buildParameterRow(
            'Время курения:', 
            '${widget.mix.smokingTime} мин'
          ),
      ],
    );
  }

  Widget _buildParameterRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.secondaryText,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.primaryText,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLike() async {
    setState(() {
      _isLiking = true;
    });

    final likesManager = ref.read(likesProvider.notifier);
    await likesManager.toggleLike(widget.mix.id, widget.mix.authorUid);

    if (mounted) {
      setState(() {
        _isLiking = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isFavoriting = true;
    });

    final favoritesManager = ref.read(favoritesManagerProvider.notifier);
    final isFavorite = ref.read(favoritesManagerProvider).contains(widget.mix.id);
    
    if (isFavorite) {
      await favoritesManager.removeFromFavorites(widget.mix.id);
    } else {
      await favoritesManager.addToFavorites(widget.mix);
    }

    if (mounted) {
      setState(() {
        _isFavoriting = false;
      });
    }
  }
}