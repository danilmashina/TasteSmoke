# TasteSmoke CI/CD Documentation

## Обзор

Проект TasteSmoke использует GitHub Actions для автоматической сборки мультиплатформенного приложения на Flutter для iOS, Android и Web.

## Workflows

### 1. Code Quality Check (`quality_check.yml`)
**Триггеры:** Push и Pull Request в `main`, `develop`
**Функции:**
- Проверка форматирования кода
- Статический анализ кода
- Запуск тестов с покрытием
- Проверка зависимостей

### 2. Android Build (`android_build.yml`)
**Триггеры:** Push в `main`, `develop`; Pull Request в `main`
**Результат:**
- APK файл: `build/app/outputs/flutter-apk/app-release.apk`
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`
- Артефакты сохраняются на 30 дней

### 3. iOS Build (`ios_build.yml`)
**Триггеры:** Push в `main`, `develop`; Pull Request в `main`
**Результат:**
- IPA файл (без подписи): `TasteSmoke-iOS.ipa`
- Артефакт сохраняется на 30 дней
- Требует macOS для сборки

### 4. Web Build (`web_build.yml`)
**Триггеры:** Push в `main`, `develop`; Pull Request в `main`
**Результат:**
- Web архив: `TasteSmoke-Web.tar.gz`
- Автоматический деплой на GitHub Pages (для main ветки)

### 5. Complete Multi-Platform Build (`release_build.yml`)
**Триггеры:** 
- Создание тега `v*` (например, `v1.0.0`)
- Ручной запуск
**Результат:**
- Сборка для всех платформ одновременно
- Создание GitHub Release с артефактами
- Расширенное время хранения (90 дней)

## Требования

### Системные требования
- **Android:** Ubuntu + Java 17
- **iOS:** macOS-14 + Xcode
- **Web:** Ubuntu + Flutter Web support
- **Flutter:** версия 3.35.2 (stable)

### Секреты и переменные
Для полной функциональности нужны:
- `GITHUB_TOKEN` (автоматически доступен)
- Для деплоя на GitHub Pages настроить в Settings → Pages

## Использование

### Автоматические сборки
1. **Разработка:** Push в `develop` → запуск всех workflow кроме release
2. **Интеграция:** Pull Request в `main` → проверка качества кода
3. **Релиз:** Push в `main` → полная сборка всех платформ

### Создание релиза
```bash
# Создать и запушить тег
git tag v1.0.0
git push origin v1.0.0
```

### Ручная сборка
1. Перейти в Actions на GitHub
2. Выбрать нужный workflow
3. Нажать "Run workflow"

## Скачивание артефактов

### Из Actions
1. Открыть completed workflow run
2. Секция "Artifacts" → скачать нужный файл

### Из Releases (для тегов)
1. Перейти в Releases
2. Скачать нужный файл из Assets

## Структура артефактов

```
TasteSmoke-Android-APK/
├── app-release.apk

TasteSmoke-Android-AAB/
├── app-release.aab

TasteSmoke-iOS/
├── TasteSmoke-iOS.ipa

TasteSmoke-Web/
├── TasteSmoke-Web.tar.gz
```

## Время сборки (примерное)

- **Code Quality:** 3-5 минут
- **Android:** 8-12 минут
- **iOS:** 15-20 минут
- **Web:** 5-8 минут
- **Multi-Platform:** 25-35 минут

## Troubleshooting

### Частые проблемы

1. **Генерация кода не удалась**
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

2. **Анализ кода с ошибками**
   ```bash
   flutter analyze --no-fatal-infos
   ```

3. **Тесты падают**
   ```bash
   flutter test
   ```

### Логи и отладка
- Проверить логи в конкретном workflow run
- Использовать `flutter doctor` для диагностики
- Проверить совместимость версий Flutter

## Настройка GitHub Pages (опционально)

1. Settings → Pages
2. Source: "GitHub Actions"
3. Web приложение будет доступно по адресу: `https://[username].github.io/[repository-name]/`

## Обновление workflows

При изменении конфигурации CI/CD:
1. Обновить соответствующий `.yml` файл
2. Протестировать на ветке `develop`
3. Создать Pull Request в `main`

## Мониторинг

- **Status:** Badge можно добавить в README
- **Покрытие кода:** Интеграция с Codecov
- **Уведомления:** Настроить в Settings → Notifications