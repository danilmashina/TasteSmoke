#!/usr/bin/env python3
"""
Firebase Configuration Checker
Проверяет наличие файлов конфигурации Firebase для iOS и Android
"""

import os
import json

def check_firebase_config():
    print("🔥 Firebase Configuration Checker")
    print("=" * 50)
    
    base_path = os.path.dirname(__file__)
    
    # Check Android configuration
    android_config = os.path.join(base_path, "android", "app", "google-services.json")
    print(f"\n📱 Android Configuration:")
    if os.path.exists(android_config):
        print(f"✅ google-services.json найден: {android_config}")
        try:
            with open(android_config, 'r') as f:
                data = json.load(f)
                project_id = data.get('project_info', {}).get('project_id', 'Unknown')
                print(f"   Project ID: {project_id}")
        except Exception as e:
            print(f"   ⚠️  Ошибка чтения файла: {e}")
    else:
        print(f"❌ google-services.json НЕ НАЙДЕН: {android_config}")
    
    # Check iOS configuration  
    ios_config = os.path.join(base_path, "ios", "Runner", "GoogleService-Info.plist")
    print(f"\n🍎 iOS Configuration:")
    if os.path.exists(ios_config):
        print(f"✅ GoogleService-Info.plist найден: {ios_config}")
    else:
        print(f"❌ GoogleService-Info.plist НЕ НАЙДЕН: {ios_config}")
        print("\n📋 Инструкции по добавлению:")
        print("1. Зайдите в Firebase Console: https://console.firebase.google.com")
        print("2. Выберите проект TasteSmoke")
        print("3. Настройки проекта → Ваши приложения")
        print("4. Добавьте iOS приложение с Bundle ID: com.example.tastesmoke_flutter")
        print("5. Скачайте GoogleService-Info.plist")
        print("6. Поместите файл в ios/Runner/GoogleService-Info.plist")
    
    print("\n" + "=" * 50)
    
    if os.path.exists(android_config) and os.path.exists(ios_config):
        print("🎉 Все файлы конфигурации Firebase найдены!")
        return True
    else:
        print("⚠️  Отсутствуют файлы конфигурации Firebase")
        return False

if __name__ == "__main__":
    check_firebase_config()