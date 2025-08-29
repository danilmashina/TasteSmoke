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

          // Временно отключаем authProvider для тестирования
          return SafeArea(
            child: Scaffold(
              backgroundColor: AppTheme.darkBackground,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.smoke_free,
                      size: 80,
                      color: AppTheme.accentPink,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'TasteSmoke',
                      style: TextStyle(
                        color: AppTheme.primaryText,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Приложение запущено!',
                      style: TextStyle(
                        color: AppTheme.secondaryText,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 30),
                    TestButton(),
                  ],
                ),
              ),
            ),
          );

          /*
          final authState = ref.watch(authProvider);
          return authState.when(
            data: (user) => user != null ? const MainScreen() : const AuthScreen(),
            loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => const AuthScreen(),
          );
          */
        },
      ),
      routes: AppRoutes.routes,
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

// Заглушки для экранов (создадим отдельно)
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Категории', style: TextStyle(color: AppTheme.primaryText))),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Избранное', style: TextStyle(color: AppTheme.primaryText))),
    );
  }
}

class TestButton extends StatelessWidget {
  const TestButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentPink,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      ),
      child: const Text(
        'Перейти к приложению',
        style: TextStyle(color: Colors.white),
      ),
    );
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