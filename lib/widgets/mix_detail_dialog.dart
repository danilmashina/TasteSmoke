import 'package:flutter/material.dart';
import '../models/public_mix.dart';
import '../utils/theme.dart';

/// Диалог деталей микса
class MixDetailDialog extends StatelessWidget {
  final PublicMix mix;
  final VoidCallback onClose;

  const MixDetailDialog({
    super.key,
    required this.mix,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Row(
              children: [
                Expanded(
                  child: Text(
                    mix.name,
                    style: const TextStyle(
                      color: AppTheme.primaryText,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(
                    Icons.close,
                    color: AppTheme.secondaryText,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Информация о миксе
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPink.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    mix.category,
                    style: const TextStyle(
                      color: AppTheme.accentPink,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  mix.strength,
                  style: const TextStyle(
                    color: AppTheme.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Автор и время
            Text(
              'Автор: ${mix.authorName}',
              style: const TextStyle(
                color: AppTheme.secondaryText,
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Время курения: ${mix.smokingTime} минут',
              style: const TextStyle(
                color: AppTheme.secondaryText,
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Ингредиенты
            const Text(
              'Состав:',
              style: TextStyle(
                color: AppTheme.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Expanded(
              child: ListView.builder(
                itemCount: mix.tobaccoIngredients.length,
                itemBuilder: (context, index) {
                  final ingredient = mix.tobaccoIngredients[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.darkBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ingredient.brand,
                                style: const TextStyle(
                                  color: AppTheme.accentPink,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                ingredient.flavor,
                                style: const TextStyle(
                                  color: AppTheme.primaryText,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.accentPink.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${ingredient.amount}%',
                            style: const TextStyle(
                              color: AppTheme.accentPink,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Кнопки действий
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Добавлено в избранное: ${mix.name}'),
                          backgroundColor: AppTheme.cardBackground,
                        ),
                      );
                    },
                    icon: const Icon(Icons.favorite),
                    label: const Text('В избранное'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentPink,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Поделились миксом: ${mix.name}'),
                          backgroundColor: AppTheme.cardBackground,
                        ),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Поделиться'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accentPink,
                      side: const BorderSide(color: AppTheme.accentPink),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}