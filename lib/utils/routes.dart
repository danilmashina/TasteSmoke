import 'package:flutter/material.dart';

class AppRoutes {
  // Названия роутов
  static const String home = '/';
  static const String auth = '/auth';
  static const String categories = '/categories';
  static const String categoryDetail = '/category';
  static const String fruitDetail = '/fruit';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
  static const String myMixes = '/my-mixes';
  static const String chat = '/chat';
  static const String followers = '/followers';
  static const String following = '/following';

  // Маршруты приложения
  static Map<String, WidgetBuilder> get routes {
    return {
      // Базовые маршруты будут обрабатываться в main.dart
      // Дополнительные маршруты можно добавить здесь
    };
  }

  // Генерация маршрутов с параметрами
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '');
    
    switch (uri.path) {
      case categoryDetail:
        final categoryId = uri.queryParameters['id'];
        if (categoryId != null) {
          return MaterialPageRoute(
            builder: (_) => CategoryDetailScreen(categoryId: categoryId),
            settings: settings,
          );
        }
        break;
        
      case fruitDetail:
        final fruitName = uri.queryParameters['name'];
        if (fruitName != null) {
          return MaterialPageRoute(
            builder: (_) => FruitDetailScreen(fruitName: fruitName),
            settings: settings,
          );
        }
        break;
        
      case followers:
        final uid = uri.queryParameters['uid'];
        if (uid != null) {
          return MaterialPageRoute(
            builder: (_) => FollowersScreen(uid: uid),
            settings: settings,
          );
        }
        break;
        
      case following:
        final uid = uri.queryParameters['uid'];
        if (uid != null) {
          return MaterialPageRoute(
            builder: (_) => FollowingScreen(uid: uid),
            settings: settings,
          );
        }
        break;
    }
    
    // Если маршрут не найден, возвращаем 404
    return MaterialPageRoute(
      builder: (_) => const NotFoundScreen(),
      settings: settings,
    );
  }

  // Вспомогательные методы для навигации
  static void navigateToCategory(BuildContext context, String categoryId) {
    Navigator.pushNamed(context, '$categoryDetail?id=$categoryId');
  }

  static void navigateToFruit(BuildContext context, String fruitName) {
    Navigator.pushNamed(context, '$fruitDetail?name=$fruitName');
  }

  static void navigateToFollowers(BuildContext context, String uid) {
    Navigator.pushNamed(context, '$followers?uid=$uid');
  }

  static void navigateToFollowing(BuildContext context, String uid) {
    Navigator.pushNamed(context, '$following?uid=$uid');
  }
}

// Заглушки для экранов (создадим отдельно)
class CategoryDetailScreen extends StatelessWidget {
  final String categoryId;
  
  const CategoryDetailScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Категория #$categoryId')),
      body: Center(
        child: Text('Детали категории: $categoryId'),
      ),
    );
  }
}

class FruitDetailScreen extends StatelessWidget {
  final String fruitName;
  
  const FruitDetailScreen({super.key, required this.fruitName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(fruitName)),
      body: Center(
        child: Text('Детали фрукта: $fruitName'),
      ),
    );
  }
}

class FollowersScreen extends StatelessWidget {
  final String uid;
  
  const FollowersScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Подписчики')),
      body: Center(
        child: Text('Подписчики пользователя: $uid'),
      ),
    );
  }
}

class FollowingScreen extends StatelessWidget {
  final String uid;
  
  const FollowingScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Подписки')),
      body: Center(
        child: Text('Подписки пользователя: $uid'),
      ),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Страница не найдена')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Страница не найдена',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'Проверьте правильность адреса',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}