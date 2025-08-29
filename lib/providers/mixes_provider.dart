import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/public_mix.dart';
import '../services/firestore_service.dart';

/// Провайдер сервиса Firestore
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Провайдер для популярных миксов
final popularMixesProvider = StreamProvider<List<PublicMix>>((ref) {
  final firestoreService = ref.read(firestoreServiceProvider);
  return firestoreService.getPopularMixes();
});

/// Провайдер для миксов по категории
final mixesByCategoryProvider = StreamProvider.family<List<PublicMix>, String>((ref, category) {
  final firestoreService = ref.read(firestoreServiceProvider);
  return firestoreService.getMixesByCategory(category);
});

/// Провайдер для поиска миксов
final searchResultsProvider = StreamProvider.family<List<PublicMix>, String>((ref, query) {
  if (query.isEmpty) return Stream.value([]);
  
  final firestoreService = ref.read(firestoreServiceProvider);
  return firestoreService.searchMixes(query);
});

/// Провайдер для избранных миксов пользователя
final favoriteMixesProvider = StreamProvider.family<List<PublicMix>, String>((ref, userId) {
  final firestoreService = ref.read(firestoreServiceProvider);
  return firestoreService.getFavoriteMixes(userId);
});

/// Провайдер для собственных миксов пользователя
final userMixesProvider = StreamProvider.family<List<PublicMix>, String>((ref, userId) {
  final firestoreService = ref.read(firestoreServiceProvider);
  return firestoreService.getUserMixes(userId);
});

/// Провайдер для лайков миксов
final likesProvider = StateNotifierProvider<LikesNotifier, Map<String, int>>((ref) {
  return LikesNotifier(ref.read(firestoreServiceProvider));
});

/// Класс для управления лайками
class LikesNotifier extends StateNotifier<Map<String, int>> {
  final FirestoreService _firestoreService;
  
  LikesNotifier(this._firestoreService) : super({});

  /// Переключает лайк для микса
  Future<void> toggleLike(String mixId, String authorUid) async {
    try {
      final result = await _firestoreService.toggleLike(mixId, authorUid);
      if (result) {
        // Обновляем счетчик лайков в состоянии
        final currentCount = state[mixId] ?? 0;
        state = {
          ...state,
          mixId: currentCount + 1, // Упрощенно, можно улучшить логику
        };
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  /// Загружает количество лайков для списка миксов
  Future<void> loadLikeCounts(List<String> mixIds) async {
    try {
      final counts = await _firestoreService.getLikeCounts(mixIds);
      state = {...state, ...counts};
    } catch (e) {
      print('Error loading like counts: $e');
    }
  }
}

/// Провайдер для управления избранным
final favoritesManagerProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier(ref.read(firestoreServiceProvider));
});

/// Класс для управления избранными миксами
class FavoritesNotifier extends StateNotifier<Set<String>> {
  final FirestoreService _firestoreService;
  
  FavoritesNotifier(this._firestoreService) : super({});

  /// Добавляет микс в избранное
  Future<void> addToFavorites(PublicMix mix) async {
    try {
      final result = await _firestoreService.addToFavorites(mix);
      if (result) {
        state = {...state, mix.id};
      }
    } catch (e) {
      print('Error adding to favorites: $e');
    }
  }

  /// Удаляет микс из избранного
  Future<void> removeFromFavorites(String mixId) async {
    try {
      final result = await _firestoreService.removeFromFavorites(mixId);
      if (result) {
        state = {...state}..remove(mixId);
      }
    } catch (e) {
      print('Error removing from favorites: $e');
    }
  }

  /// Проверяет, добавлен ли микс в избранное
  bool isFavorite(String mixId) {
    return state.contains(mixId);
  }

  /// Загружает список избранных миксов для пользователя
  Future<void> loadFavorites(String userId) async {
    try {
      final favoriteIds = await _firestoreService.getFavoriteIds(userId);
      state = Set.from(favoriteIds);
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }
}

/// Провайдер для публикации новых миксов
final mixPublisherProvider = StateNotifierProvider<MixPublisherNotifier, AsyncValue<void>>((ref) {
  return MixPublisherNotifier(ref.read(firestoreServiceProvider));
});

/// Класс для управления публикацией миксов
class MixPublisherNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _firestoreService;
  
  MixPublisherNotifier(this._firestoreService) : super(const AsyncValue.data(null));

  /// Публикует новый микс
  Future<bool> publishMix(PublicMix mix) async {
    state = const AsyncValue.loading();
    
    try {
      final result = await _firestoreService.publishMix(mix);
      state = const AsyncValue.data(null);
      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Обновляет существующий микс
  Future<bool> updateMix(PublicMix mix) async {
    state = const AsyncValue.loading();
    
    try {
      final result = await _firestoreService.updateMix(mix);
      state = const AsyncValue.data(null);
      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Удаляет микс
  Future<bool> deleteMix(String mixId) async {
    state = const AsyncValue.loading();
    
    try {
      final result = await _firestoreService.deleteMix(mixId);
      state = const AsyncValue.data(null);
      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}