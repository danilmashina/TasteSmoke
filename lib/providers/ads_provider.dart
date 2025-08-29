import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ad_banner.dart';
import '../services/firestore_service.dart';

/// Провайдер для рекламных баннеров на главной странице
final bannersProvider = StreamProvider<List<AdBanner>>((ref) {
  final firestoreService = ref.read(firestoreServiceProvider);
  return firestoreService.getBanners(AdBanner.homeBannerPlacement);
});

/// Провайдер для баннеров по размещению
final bannersByPlacementProvider = StreamProvider.family<List<AdBanner>, String>((ref, placement) {
  final firestoreService = ref.read(firestoreServiceProvider);
  return firestoreService.getBanners(placement);
});

/// Провайдер для управления баннерами (если нужны CRUD операции)
final bannerManagerProvider = StateNotifierProvider<BannerManagerNotifier, AsyncValue<void>>((ref) {
  return BannerManagerNotifier(ref.read(firestoreServiceProvider));
});

/// Класс для управления баннерами (админские функции)
class BannerManagerNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _firestoreService;
  
  BannerManagerNotifier(this._firestoreService) : super(const AsyncValue.data(null));

  /// Создает новый баннер
  Future<bool> createBanner(AdBanner banner) async {
    state = const AsyncValue.loading();
    
    try {
      final result = await _firestoreService.createBanner(banner);
      state = const AsyncValue.data(null);
      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Обновляет существующий баннер
  Future<bool> updateBanner(AdBanner banner) async {
    state = const AsyncValue.loading();
    
    try {
      final result = await _firestoreService.updateBanner(banner);
      state = const AsyncValue.data(null);
      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Удаляет баннер
  Future<bool> deleteBanner(String bannerId) async {
    state = const AsyncValue.loading();
    
    try {
      final result = await _firestoreService.deleteBanner(bannerId);
      state = const AsyncValue.data(null);
      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Активирует/деактивирует баннер
  Future<bool> toggleBannerStatus(String bannerId, bool isActive) async {
    state = const AsyncValue.loading();
    
    try {
      final result = await _firestoreService.toggleBannerStatus(bannerId, isActive);
      state = const AsyncValue.data(null);
      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

// Импорт из mixes_provider для firestoreServiceProvider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});