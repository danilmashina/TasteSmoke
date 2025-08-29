# iOS Firebase Configuration

Для работы Firebase на iOS нужно добавить файл GoogleService-Info.plist:

1. Зайдите в Firebase Console
2. Проект TasteSmoke → Настройки проекта → Ваши приложения
3. Добавьте iOS приложение с Bundle ID: com.example.tastesmoke_flutter  
4. Скачайте GoogleService-Info.plist
5. Поместите файл в: ios/Runner/GoogleService-Info.plist

Без этого файла iOS приложение не может подключиться к Firebase.