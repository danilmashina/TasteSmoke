<<<<<<< HEAD
# 🚀 TasteSmoke Flutter - Полная iOS/Android версия

[![Android Build](https://github.com/your-username/your-repo/actions/workflows/android_build.yml/badge.svg)](https://github.com/your-username/your-repo/actions/workflows/android_build.yml)
[![iOS Build](https://github.com/your-username/your-repo/actions/workflows/ios_build.yml/badge.svg)](https://github.com/your-username/your-repo/actions/workflows/ios_build.yml)
[![Web Build](https://github.com/your-username/your-repo/actions/workflows/web_build.yml/badge.svg)](https://github.com/your-username/your-repo/actions/workflows/web_build.yml)
[![Code Quality](https://github.com/your-username/your-repo/actions/workflows/quality_check.yml/badge.svg)](https://github.com/your-username/your-repo/actions/workflows/quality_check.yml)

Это полная портированная версия Android приложения TasteSmoke на Flutter, которая включает в себя все функции оригинального приложения.

## 📱 Функциональность

### ✅ Реализовано:
- **Аутентификация Firebase** (вход, регистрация, сброс пароля)
- **Система уведомлений об обновлениях** (Firebase Remote Config)
- **Главный экран** с популярными миксами и категориями
- **Карусель баннеров** с автопрокруткой (10 сек)
- **Поиск миксов** по названию, автору, ингредиентам
- **Система лайков и избранного**
- **Проверка нецензурных слов** (та же логика что в Android)
- **Модели данных** (TobaccoIngredient, PublicMix, AdBanner)
- **Firebase интеграция** (Firestore, Auth, Remote Config)
- **Темная тема** (точно как в Android версии)
- **Процентное отображение** табака (как в спецификации)

### 🏗️ Архитектура:
- **Riverpod** для state management
- **Firebase SDK** для backend
- **Cached Network Image** для изображений
- **Clean Architecture** с провайдерами и сервисами

## 🛠️ Установка и запуск

### 1. Предварительные требования:
```bash
# Flutter SDK (3.16.0+)
flutter --version

# Firebase CLI
npm install -g firebase-tools
```

### 2. Настройка проекта:
```bash
# Клонировать папку flutter_version из проекта
cd flutter_version

# Установить зависимости
flutter pub get

# Генерация JSON сериализации
flutter packages pub run build_runner build
```

### 3. Настройка Firebase:
```bash
# Войти в Firebase
firebase login

# Инициализация Firebase для Flutter
dart pub global activate flutterfire_cli
flutterfire configure
```

### 4. Запуск:
```bash
# Android
flutter run

# iOS (только на Mac)
flutter run -d ios

# Web
flutter run -d chrome
```

## 📁 Структура проекта

```
flutter_version/
├── lib/
│   ├── main.dart                    # Точка входа с системой уведомлений
│   ├── models/                      # Модели данных
│   │   ├── tobacco_ingredient.dart  # Ингредиенты табака (проценты)
│   │   ├── public_mix.dart         # Публичные миксы
│   │   └── ad_banner.dart          # Рекламные баннеры (280x158dp)
│   ├── services/                    # Сервисы Firebase
│   │   ├── firestore_service.dart   # Работа с Firestore
│   │   └── remote_config_service.dart # Уведомления об обновлениях
│   ├── providers/                   # State management (Riverpod)
│   │   ├── auth_provider.dart       # Аутентификация
│   │   ├── mixes_provider.dart      # Управление миксами
│   │   └── ads_provider.dart        # Управление баннерами
│   ├── screens/                     # UI экраны
│   │   ├── auth_screen.dart         # Экран входа/регистрации
│   │   └── home_screen.dart         # Главный экран (портирован с Android)
│   ├── widgets/                     # Переиспользуемые компоненты
│   │   ├── mix_card.dart           # Карточка микса
│   │   ├── mix_detail_dialog.dart  # Детальный просмотр микса
│   │   └── banner_carousel.dart    # Карусель баннеров (автопрокрутка)
│   └── utils/                       # Утилиты
│       ├── theme.dart              # Темная тема (цвета из Android)
│       ├── profanity_checker.dart  # Проверка нецензурных слов
│       └── routes.dart             # Навигация
├── android/                        # Android конфигурация
├── ios/                           # iOS конфигурация
└── pubspec.yaml                   # Зависимости Flutter
```

## 🔧 Основные компоненты

### Модели данных (100% совместимы с Android):
- **TobaccoIngredient**: Бренд, вкус, количество в процентах
- **PublicMix**: Полная модель микса с ингредиентами
- **AdBanner**: Баннеры 280x158dp с автопрокруткой

### Провайдеры (Riverpod):
- **authProvider**: Управление аутентификацией
- **popularMixesProvider**: Популярные миксы недели
- **searchResultsProvider**: Поиск миксов
- **favoritesManagerProvider**: Избранные миксы
- **bannersProvider**: Рекламные баннеры

### Сервисы:
- **FirestoreService**: CRUD операции с Firebase
- **RemoteConfigService**: Система уведомлений об обновлениях

## 🎨 UI Компоненты

### Главный экран:
- Поисковая строка с debounce
- Горизонтальные категории фруктов
- Популярные миксы недели
- Карусель баннеров с автопрокруткой (10 сек)

### Карточки миксов:
- Название микса (первая строка)
- Автор и дата создания
- Ингредиенты с процентами
- Лайки и избранное
- Детальный просмотр в диалоге

### Система уведомлений:
- Автоматическая проверка при запуске
- Firebase Remote Config (как в Android)
- Диалог с кнопками "Обновить"/"Позже"

## 🔍 Функции поиска

### Поддерживаемые типы поиска:
- **По названию микса**
- **По имени автора**
- **По уровню крепости** (Легкий/Средний/Крепкий)
- **По брендам табака**
- **По вкусам табака**

## 🛡️ Проверка нецензурных слов

Полностью портированная система из Android версии:
- Те же запрещенные слова (RU + EN)
- Нормализация текста (замена похожих символов)
- Проверка в полях "Марка" и "Вкус"
- Блокировка публикации при обнаружении

## 📊 Спецификации (соблюдены из Android версии)

### Ограничения полей:
- **Марка табака**: максимум 20 символов
- **Вкус табака**: максимум 30 символов
- **Проценты**: только цифры, максимум 2 знака

### Размеры баннеров:
- **Ширина**: 280dp
- **Высота**: 158dp
- **Соотношение**: 16:9 (1.78:1)
- **Формат**: JPG, PNG, WebP
- **Размер файла**: до 200KB

## 🌐 Публикация

### Android:
```bash
# Сборка APK
flutter build apk --release

# Сборка Bundle для Play Store/RuStore
flutter build appbundle --release
```

### iOS:
```bash
# Сборка для App Store (только на Mac)
flutter build ios --release
```

### Web:
```bash
# Сборка для веб
flutter build web --release
```

## 🚀 CI/CD - Автоматическая сборка

### GitHub Actions Workflows:

#### 📋 Code Quality Check
- **Триггер:** Push/PR в main, develop
- **Функции:** Проверка кода, тесты, покрытие
- **Время:** ~3-5 минут

#### 🤖 Android Build
- **Триггер:** Push в main, develop
- **Результат:** APK + App Bundle
- **Время:** ~8-12 минут

#### 🍎 iOS Build 
- **Триггер:** Push в main, develop
- **Результат:** IPA файл (unsigned)
- **Время:** ~15-20 минут
- **Требует:** macOS-14

#### 🌐 Web Build
- **Триггер:** Push в main, develop
- **Результат:** Web архив + GitHub Pages
- **Время:** ~5-8 минут

#### 📦 Release Build
- **Триггер:** Git tag `v*` (например `v1.0.0`)
- **Результат:** Мульти-платформенная сборка + GitHub Release
- **Время:** ~25-35 минут

### Использование:

```bash
# Создание релиза
git tag v1.0.0
git push origin v1.0.0

# Ручная сборка через GitHub Actions UI
# Actions → выбрать workflow → "Run workflow"
```

### Артефакты:
- **Android:** APK + AAB файлы
- **iOS:** IPA файл (требует доп. подпись для App Store)
- **Web:** Готовый для деплоя архив
- **Хранение:** 30 дней (90 для релизов)

📖 **Подробная документация:** [CI_CD_DOCUMENTATION.md](CI_CD_DOCUMENTATION.md)

## 🔄 Система обновлений

### Firebase Remote Config параметры:
```json
{
  "latest_version_code": 3,
  "update_message": "Вышла новая версия 1.1! Обновитесь, чтобы увидеть исправления навигации и новую проверку нецензурных слов.",
  "update_url": "https://apps.rustore.ru/app/com.example.tastesmoketest"
}
```

### Логика работы:
1. При запуске проверяется Remote Config
2. Сравнивается `latest_version_code` с текущим
3. Если доступна новая версия → показывается диалог
4. Кнопка "Обновить" → открывает App Store/RuStore

## 📚 Дополнительная информация

### Зависимости:
- **firebase_core**: Основа Firebase
- **firebase_auth**: Аутентификация
- **cloud_firestore**: База данных
- **firebase_remote_config**: Конфигурация
- **flutter_riverpod**: State management
- **cached_network_image**: Кэширование изображений
- **url_launcher**: Открытие ссылок

### Особенности реализации:
- **Поддержка темной темы** (цвета идентичны Android)
- **Адаптивный UI** для разных размеров экрана
- **Оптимизированная загрузка** изображений
- **Debounce поиска** (400мс как в Android)
- **Автопрокрутка баннеров** (10 секунд)

---

## 🎉 Готово к использованию!

Этот Flutter проект является **полной копией** вашего Android приложения с поддержкой:
- ✅ **iOS** (нативная производительность)
- ✅ **Android** (замена текущей версии)
- ✅ **Web** (бонус - веб-версия)

Все функции работают идентично Android версии, включая Firebase интеграцию и систему уведомлений об обновлениях!
=======
# TasteSmoke
>>>>>>> 272ae21b5a114207af4036d8fc5668c02fbae542
