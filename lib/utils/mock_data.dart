import '../models/public_mix.dart';
import '../models/tobacco_ingredient.dart';

/// Класс для предоставления мок-данных для тестирования
class MockDataProvider {
  
  /// Возвращает список популярных миксов для тестирования
  static List<PublicMix> getPopularMixes() {
    return [
      PublicMix(
        id: 'mock1',
        name: 'Фруктовый Микс',
        category: 'Фрукты',
        authorName: 'Тестовый Автор',
        authorUid: 'test_uid',
        tobaccoIngredients: [
          TobaccoIngredient(
            brand: 'Adalya', 
            flavor: 'Lady Killer', 
            amount: 40
          ),
          TobaccoIngredient(
            brand: 'Al Fakher', 
            flavor: 'Blueberry', 
            amount: 30
          ),
          TobaccoIngredient(
            brand: 'Serbetli', 
            flavor: 'Ice Watermelon Mint', 
            amount: 30
          ),
        ],
        likeCount: 25,
        createdAt: DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch,
        smokingTime: 60,
        strength: 'Средний',
      ),
      
      PublicMix(
        id: 'mock2',
        name: 'Ягодный Взрыв',
        category: 'Ягоды',
        authorName: 'Мастер Миксов',
        authorUid: 'test_uid2',
        tobaccoIngredients: [
          TobaccoIngredient(
            brand: 'Darkside', 
            flavor: 'Berry Mix', 
            amount: 50
          ),
          TobaccoIngredient(
            brand: 'Element', 
            flavor: 'Water Blackberry', 
            amount: 25
          ),
          TobaccoIngredient(
            brand: 'Bonche', 
            flavor: 'Ice Blueberry', 
            amount: 25
          ),
        ],
        likeCount: 18,
        createdAt: DateTime.now().subtract(const Duration(days: 5)).millisecondsSinceEpoch,
        smokingTime: 45,
        strength: 'Легкий',
      ),
      
      PublicMix(
        id: 'mock3',
        name: 'Цитрусовая Свежесть',
        category: 'Цитрусовые',
        authorName: 'Кальянщик',
        authorUid: 'test_uid3',
        tobaccoIngredients: [
          TobaccoIngredient(
            brand: 'Tangiers', 
            flavor: 'Orange Soda', 
            amount: 35
          ),
          TobaccoIngredient(
            brand: 'Al Fakher', 
            flavor: 'Lemon', 
            amount: 35
          ),
          TobaccoIngredient(
            brand: 'Serbetli', 
            flavor: 'Ice Lime', 
            amount: 30
          ),
        ],
        likeCount: 32,
        createdAt: DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        smokingTime: 75,
        strength: 'Крепкий',
      ),
    ];
  }
}