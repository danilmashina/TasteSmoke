import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'providers/auth_provider.dart';
import 'services/remote_config_service.dart';
import 'utils/theme.dart';
import 'utils/routes.dart';
import 'models/public_mix.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    print('Firebase инициализирован успешно');
  } catch (e) {
    print('Ошибка инициализации Firebase: $e');
    // Продолжаем работу даже если Firebase не инициализирован
  }
  
  runApp(const ProviderScope(child: TasteSmokeApp()));
}

class TasteSmokeApp extends ConsumerStatefulWidget {
  const TasteSmokeApp({super.key});

  @override
  ConsumerState<TasteSmokeApp> createState() => _TasteSmokeAppState();
}

class _TasteSmokeAppState extends ConsumerState<TasteSmokeApp> {
  bool _showUpdateDialog = false;
  String _updateMessage = '';
  String _updateUrl = '';

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    try {
      final updateInfo = await RemoteConfigService.checkForUpdates();
      if (updateInfo != null && mounted) {
        setState(() {
          _showUpdateDialog = true;
          _updateMessage = updateInfo['message'] ?? '';
          _updateUrl = updateInfo['url'] ?? '';
        });
      }
    } catch (e) {
      // Игнорируем ошибки Remote Config
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TasteSmoke',
      theme: AppTheme.darkTheme,
      home: Builder(
        builder: (context) {
          // Показываем диалог обновления при необходимости
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_showUpdateDialog) {
              _showUpdateDialogWidget(context);
            }
          });

          // Проверяем инициализацию Firebase
          try {
            if (Firebase.apps.isNotEmpty) {
              // Firebase инициализирован - используем полную функциональность
              final authState = ref.watch(authProvider);
              return authState.when(
                data: (user) => user != null ? const MainScreen() : const AuthScreen(),
                loading: () => const Scaffold(
                  backgroundColor: AppTheme.darkBackground,
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppTheme.accentPink),
                        SizedBox(height: 16),
                        Text(
                          'Загрузка...',
                          style: TextStyle(color: AppTheme.primaryText),
                        ),
                      ],
                    ),
                  ),
                ),
                error: (error, stack) => const AuthScreen(),
              );
            } else {
              // Firebase не инициализирован - работаем в режиме демо
              return const MainScreen();
            }
          } catch (e) {
            // Ошибка Firebase - работаем в режиме демо
            return const MainScreen();
          }
        },
      ),
      routes: {
        '/main': (context) => const MainScreen(),
        '/auth': (context) => const AuthScreen(),
      },
    );
  }

  void _showUpdateDialogWidget(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text(
          'Доступно обновление',
          style: TextStyle(color: AppTheme.primaryText),
        ),
        content: Text(
          _updateMessage,
          style: const TextStyle(color: AppTheme.primaryText),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _showUpdateDialog = false);
            },
            child: const Text(
              'Позже',
              style: TextStyle(color: AppTheme.accentPink),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _showUpdateDialog = false);
              await RemoteConfigService.openUpdateUrl(_updateUrl);
            },
            child: const Text(
              'Обновить',
              style: TextStyle(color: AppTheme.accentPink),
            ),
          ),
        ],
      ),
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CategoriesScreen(),
    const FavoritesScreen(), 
    const ProfileScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Главная',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.list),
      label: 'Категории',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.star),
      label: 'Избранное',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Профиль',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.cardBackground,
        selectedItemColor: AppTheme.accentPink,
        unselectedItemColor: AppTheme.secondaryText,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: _navItems,
      ),
    );
  }
}

// Экран категорий с контентом
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Категории'),
        backgroundColor: AppTheme.cardBackground,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: PublicMix.categories.length,
          itemBuilder: (context, index) {
            final category = PublicMix.categories[index];
            return Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentPink.withOpacity(0.3)),
              ),
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Выбрана категория: $category'),
                      backgroundColor: AppTheme.cardBackground,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      size: 40,
                      color: AppTheme.accentPink,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      category,
                      style: const TextStyle(
                        color: AppTheme.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Фрукты': return Icons.apple;
      case 'Ягоды': return Icons.circle;
      case 'Цитрусовые': return Icons.eco;
      case 'Десерты': return Icons.cake;
      case 'Напитки': return Icons.local_drink;
      case 'Мятные': return Icons.spa;
      case 'Пряные': return Icons.whatshot;
      case 'Кислые': return Icons.sentiment_very_dissatisfied;
      case 'Необычные': return Icons.star;
      default: return Icons.category;
    }
  }
}

// Экран избранного с контентом
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Избранное'),
        backgroundColor: AppTheme.cardBackground,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Информация о разделе
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.accentPink.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.favorite,
                  size: 48,
                  color: AppTheme.accentPink,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Избранные миксы',
                  style: TextStyle(
                    color: AppTheme.primaryText,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Здесь будут отображаться ваши любимые миксы',
                  style: TextStyle(
                    color: AppTheme.secondaryText,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Пример списка избранных
          const Text(
            'Популярные миксы для добавления:',
            style: TextStyle(
              color: AppTheme.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Мок-список миксов
          ...[
            'Фруктовый Микс',
            'Ягодный Взрыв',
            'Цитрусовая Свежесть',
          ].map((mixName) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.favorite_border,
                  color: AppTheme.accentPink,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    mixName,
                    style: const TextStyle(
                      color: AppTheme.primaryText,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Добавлено в избранное: $mixName'),
                        backgroundColor: AppTheme.cardBackground,
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.add,
                    color: AppTheme.accentPink,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}

}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Профиль', style: TextStyle(color: AppTheme.primaryText))),
    );
  }
}