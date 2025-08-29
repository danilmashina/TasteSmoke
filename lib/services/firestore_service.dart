import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/public_mix.dart';
import '../models/ad_banner.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Получает популярные миксы (сортировка по лайкам)
  Stream<List<PublicMix>> getPopularMixes({int limit = 10}) {
    return _firestore
        .collection('mixes')
        .orderBy('likeCount', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PublicMix.fromMap(doc.id, doc.data()))
            .where((mix) => mix.name.isNotEmpty) // Фильтруем пустые
            .toList());
  }

  /// Получает миксы по категории
  Stream<List<PublicMix>> getMixesByCategory(String category) {
    return _firestore
        .collection('mixes')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PublicMix.fromMap(doc.id, doc.data()))
            .where((mix) => mix.name.isNotEmpty)
            .toList());
  }

  /// Поиск миксов по названию, автору или ингредиентам
  Stream<List<PublicMix>> searchMixes(String query) {
    final queryLower = query.toLowerCase().trim();
    
    // Firebase не поддерживает полнотекстовый поиск напрямую
    // Используем простой подход - получаем все миксы и фильтруем на клиенте
    return _firestore
        .collection('mixes')
        .orderBy('createdAt', descending: true)
        .limit(100) // Ограничиваем количество для производительности
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => PublicMix.fromMap(doc.id, doc.data()))
              .where((mix) {
                // Поиск по названию
                if (mix.name.toLowerCase().contains(queryLower)) return true;
                
                // Поиск по автору
                if (mix.authorName.toLowerCase().contains(queryLower)) return true;
                
                // Поиск по крепости
                if (mix.strength.toLowerCase().contains(queryLower)) return true;
                
                // Поиск по ингредиентам
                for (final ingredient in mix.tobaccoIngredients) {
                  if (ingredient.brand.toLowerCase().contains(queryLower) ||
                      ingredient.flavor.toLowerCase().contains(queryLower)) {
                    return true;
                  }
                }
                
                return false;
              })
              .toList();
        });
  }

  /// Получает избранные миксы пользователя
  Stream<List<PublicMix>> getFavoriteMixes(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .asyncMap((snapshot) async {
          final List<PublicMix> favorites = [];
          
          for (final doc in snapshot.docs) {
            final data = doc.data();
            
            // Если данные хранятся как ссылка на микс
            if (data.containsKey('mixId')) {
              final mixDoc = await _firestore
                  .collection('mixes')
                  .doc(data['mixId'])
                  .get();
              
              if (mixDoc.exists) {
                final mix = PublicMix.fromMap(mixDoc.id, mixDoc.data()!);
                favorites.add(mix);
              }
            } else {
              // Если данные микса хранятся прямо в избранном
              final mix = PublicMix.fromMap(doc.id, data);
              favorites.add(mix);
            }
          }
          
          return favorites;
        });
  }

  /// Получает миксы пользователя
  Stream<List<PublicMix>> getUserMixes(String userId) {
    return _firestore
        .collection('mixes')
        .where('authorUid', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PublicMix.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Публикует новый микс
  Future<bool> publishMix(PublicMix mix) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final docRef = _firestore.collection('mixes').doc();
      final mixData = mix.copyWith(
        id: docRef.id,
        authorUid: user.uid,
        authorName: user.displayName ?? 'Аноним',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      await docRef.set(mixData.toMap());
      return true;
    } catch (e) {
      print('Error publishing mix: $e');
      return false;
    }
  }

  /// Обновляет существующий микс
  Future<bool> updateMix(PublicMix mix) async {
    try {
      final user = _auth.currentUser;
      if (user == null || mix.authorUid != user.uid) return false;

      await _firestore
          .collection('mixes')
          .doc(mix.id)
          .update(mix.toMap());
      
      return true;
    } catch (e) {
      print('Error updating mix: $e');
      return false;
    }
  }

  /// Удаляет микс
  Future<bool> deleteMix(String mixId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Проверяем, что пользователь является автором
      final mixDoc = await _firestore.collection('mixes').doc(mixId).get();
      if (!mixDoc.exists || mixDoc.data()?['authorUid'] != user.uid) {
        return false;
      }

      await _firestore.collection('mixes').doc(mixId).delete();
      return true;
    } catch (e) {
      print('Error deleting mix: $e');
      return false;
    }
  }

  /// Переключает лайк для микса
  Future<bool> toggleLike(String mixId, String authorUid) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.uid == authorUid) return false;

      return await _firestore.runTransaction((transaction) async {
        final mixRef = _firestore.collection('mixes').doc(mixId);
        final mixDoc = await transaction.get(mixRef);
        
        if (!mixDoc.exists) return false;

        final currentLikes = mixDoc.data()?['likeCount'] ?? 0;
        transaction.update(mixRef, {'likeCount': currentLikes + 1});
        
        return true;
      });
    } catch (e) {
      print('Error toggling like: $e');
      return false;
    }
  }

  /// Получает количество лайков для списка миксов
  Future<Map<String, int>> getLikeCounts(List<String> mixIds) async {
    try {
      final Map<String, int> counts = {};
      
      for (final mixId in mixIds) {
        final doc = await _firestore.collection('mixes').doc(mixId).get();
        if (doc.exists) {
          counts[mixId] = doc.data()?['likeCount'] ?? 0;
        }
      }
      
      return counts;
    } catch (e) {
      print('Error getting like counts: $e');
      return {};
    }
  }

  /// Добавляет микс в избранное
  Future<bool> addToFavorites(PublicMix mix) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(mix.id)
          .set({
            'mixId': mix.id,
            'addedAt': FieldValue.serverTimestamp(),
            // Можно хранить полные данные микса для офлайн-доступа
            ...mix.toMap(),
          });
      
      return true;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  /// Удаляет микс из избранного
  Future<bool> removeFromFavorites(String mixId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(mixId)
          .delete();
      
      return true;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  /// Получает список ID избранных миксов
  Future<List<String>> getFavoriteIds(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();
      
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error getting favorite IDs: $e');
      return [];
    }
  }

  // МЕТОДЫ ДЛЯ РАБОТЫ С БАННЕРАМИ

  /// Получает активные баннеры по размещению
  Stream<List<AdBanner>> getBanners(String placement, {int limit = 10}) {
    return _firestore
        .collection('banners')
        .where('placement', isEqualTo: placement)
        .where('isActive', isEqualTo: true)
        .orderBy('priority', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AdBanner.fromMap(doc.id, doc.data()))
            .where((banner) => banner.isCurrentlyActive) // Дополнительная проверка времени
            .toList());
  }

  /// Создает новый баннер (админская функция)
  Future<bool> createBanner(AdBanner banner) async {
    try {
      final docRef = _firestore.collection('banners').doc();
      await docRef.set(banner.copyWith(id: docRef.id).toMap());
      return true;
    } catch (e) {
      print('Error creating banner: $e');
      return false;
    }
  }

  /// Обновляет баннер (админская функция)
  Future<bool> updateBanner(AdBanner banner) async {
    try {
      await _firestore
          .collection('banners')
          .doc(banner.id)
          .update(banner.toMap());
      return true;
    } catch (e) {
      print('Error updating banner: $e');
      return false;
    }
  }

  /// Удаляет баннер (админская функция)
  Future<bool> deleteBanner(String bannerId) async {
    try {
      await _firestore.collection('banners').doc(bannerId).delete();
      return true;
    } catch (e) {
      print('Error deleting banner: $e');
      return false;
    }
  }

  /// Переключает статус баннера (админская функция)
  Future<bool> toggleBannerStatus(String bannerId, bool isActive) async {
    try {
      await _firestore
          .collection('banners')
          .doc(bannerId)
          .update({'isActive': isActive});
      return true;
    } catch (e) {
      print('Error toggling banner status: $e');
      return false;
    }
  }
}