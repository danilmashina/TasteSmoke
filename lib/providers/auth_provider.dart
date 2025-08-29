import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Провайдер для текущего пользователя Firebase
final authProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Провайдер для сервиса аутентификации
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Текущий пользователь
  User? get currentUser => _auth.currentUser;

  /// Stream изменений состояния аутентификации
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Вход по email и паролю
  Future<AuthResult> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null && !user.emailVerified) {
        await _auth.signOut();
        return AuthResult.failure('Email не подтвержден. Проверьте почту.');
      }

      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Произошла ошибка: $e');
    }
  }

  /// Регистрация нового пользователя
  Future<AuthResult> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // Отправляем письмо подтверждения
        await user.sendEmailVerification();
        await _auth.signOut(); // Выходим до подтверждения email
        
        return AuthResult.success(
          null,
          message: 'Регистрация успешна! Проверьте почту и подтвердите email.',
        );
      }

      return AuthResult.failure('Не удалось создать пользователя');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Произошла ошибка: $e');
    }
  }

  /// Сброс пароля
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult.success(
        null,
        message: 'Письмо для сброса пароля отправлено на $email',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Произошла ошибка: $e');
    }
  }

  /// Выход из системы
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Удаление аккаунта
  Future<AuthResult> deleteAccount() async {
    try {
      final user = currentUser;
      if (user != null) {
        await user.delete();
        return AuthResult.success(null, message: 'Аккаунт успешно удален');
      }
      return AuthResult.failure('Пользователь не найден');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Произошла ошибка: $e');
    }
  }

  /// Повторная отправка письма подтверждения
  Future<AuthResult> resendVerificationEmail() async {
    try {
      final user = currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return AuthResult.success(
          null,
          message: 'Письмо подтверждения отправлено повторно',
        );
      }
      return AuthResult.failure('Email уже подтвержден или пользователь не найден');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Произошла ошибка: $e');
    }
  }

  /// Обновление данных профиля
  Future<AuthResult> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
        await user.reload();
        return AuthResult.success(user, message: 'Профиль обновлен');
      }
      return AuthResult.failure('Пользователь не найден');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Произошла ошибка: $e');
    }
  }

  /// Получение понятного сообщения об ошибке
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Пользователь с таким email не найден';
      case 'wrong-password':
        return 'Неверный пароль';
      case 'email-already-in-use':
        return 'Этот email уже используется';
      case 'weak-password':
        return 'Пароль слишком слабый';
      case 'invalid-email':
        return 'Неверный формат email';
      case 'user-disabled':
        return 'Этот аккаунт заблокирован';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуйте позже';
      case 'network-request-failed':
        return 'Ошибка сети. Проверьте подключение к интернету';
      case 'requires-recent-login':
        return 'Для этого действия требуется повторный вход в систему';
      default:
        return e.message ?? 'Произошла неизвестная ошибка';
    }
  }

  /// Настройка языка для Firebase Auth
  Future<void> setLanguageCode(String languageCode) async {
    await _auth.setLanguageCode(languageCode);
  }
}

/// Класс для результата операций аутентификации
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? message;
  final String? error;

  const AuthResult._({
    required this.isSuccess,
    this.user,
    this.message,
    this.error,
  });

  factory AuthResult.success(User? user, {String? message}) {
    return AuthResult._(
      isSuccess: true,
      user: user,
      message: message,
    );
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(
      isSuccess: false,
      error: error,
    );
  }
}