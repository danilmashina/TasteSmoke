import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Временно работаем без аутентификации
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Профиль'),
        backgroundColor: AppTheme.cardBackground,
      ),
      body: _buildProfileContent(context, ref, 'Тестовый Пользователь'),
    );
  }

  Widget _buildProfileContent(BuildContext context, WidgetRef ref, String userName) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Информация о пользователе
          Card(
            color: AppTheme.cardBackground,
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.accentPink,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: AppTheme.primaryText,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            color: AppTheme.primaryText,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'TasteSmoke пользователь',
                          style: TextStyle(
                            color: AppTheme.secondaryText,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.paddingLarge),
          
          // Меню действий
          Card(
            color: AppTheme.cardBackground,
            child: Column(
              children: [
                _buildMenuItem(
                  icon: Icons.star,
                  title: 'Мои избранные',
                  onTap: () => _navigateToFavorites(context),
                ),
                const Divider(color: AppTheme.secondaryText, height: 1),
                _buildMenuItem(
                  icon: Icons.create,
                  title: 'Мои миксы',
                  onTap: () => _navigateToMyMixes(context),
                ),
                const Divider(color: AppTheme.secondaryText, height: 1),
                _buildMenuItem(
                  icon: Icons.settings,
                  title: 'Настройки',
                  onTap: () => _navigateToSettings(context),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Кнопка выхода
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _signOut(ref),
              icon: const Icon(Icons.logout),
              label: const Text('Выйти'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.accentPink),
      title: Text(
        title,
        style: const TextStyle(color: AppTheme.primaryText),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.secondaryText),
      onTap: onTap,
    );
  }

  void _navigateToFavorites(BuildContext context) {
    // Переключаемся на вкладку избранного
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Переход к избранному')),
    );
  }

  void _navigateToMyMixes(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Мои миксы - в разработке')),
    );
  }

  void _navigateToSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Настройки - в разработке')),
    );
  }

  void _signOut(WidgetRef ref) {
    ref.read(authServiceProvider).signOut();
  }
}