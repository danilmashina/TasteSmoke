class ProfanityChecker {
  // Список запрещенных слов (тот же что в Android версии)
  static const List<String> _profanityStems = [
    // Русские слова
    'хер', 'хуй', 'пизд', 'ебат', 'ебал', 'ебан', 'ебло', 
    'сука', 'бля', 'залуп', 'сиськ', 'ахуенн', 'хуев', 
    'ебуч', 'невьеб', 'невъеб', 'уебан', 'суч', 'уебск',
    'чмо', 'пенис', 'член', 'ебей', 'жопа', 'анус',
    
    // Английские слова
    'fuck', 'shit', 'ass', 'dick', 'cunt',
  ];

  /// Проверяет содержит ли текст нецензурную брань
  static bool containsProfanity(String text) {
    if (text.isEmpty) return false;
    
    final normalized = _normalizeForProfanity(text);
    return _profanityStems.any((stem) => 
        normalized.toLowerCase().contains(stem.toLowerCase()));
  }

  /// Нормализует текст для проверки (убирает пробелы, заменяет похожие символы)
  static String _normalizeForProfanity(String input) {
    // Карта замен для обхода простых трюков
    const Map<String, String> leetMap = {
      '0': 'o', '1': 'i', '3': 'e', '4': 'a', '5': 's', '7': 't',
      '@': 'a', '\$': 's',
      'ё': 'е',
      // Английские буквы на русские
      'o': 'о', 'a': 'а', 'e': 'е', 'p': 'р', 'c': 'с', 
      'y': 'у', 'x': 'х',
    };
    
    final lowered = input.toLowerCase();
    final filtered = StringBuffer();
    
    // Убираем пробелы и знаки препинания, заменяем похожие символы
    for (int i = 0; i < lowered.length; i++) {
      final char = lowered[i];
      
      // Пропускаем пробелы и знаки препинания
      if (_isPunctuation(char)) continue;
      
      // Заменяем похожие символы
      filtered.write(leetMap[char] ?? char);
    }
    
    // Схлопываем повторяющиеся символы (например, "поооохо" -> "похо")
    final collapsed = StringBuffer();
    String? prevChar;
    
    for (int i = 0; i < filtered.length; i++) {
      final char = filtered.toString()[i];
      if (char != prevChar) {
        collapsed.write(char);
        prevChar = char;
      }
    }
    
    return collapsed.toString();
  }

  /// Проверяет является ли символ знаком препинания или пробелом
  static bool _isPunctuation(String char) {
    const punctuation = [
      ' ', '\t', '\n', '.', ',', '-', '_', '!', '?', ':', ';', 
      '"', "'", '(', ')', '[', ']', '{', '}', '|', '*', '#',
    ];
    
    return punctuation.contains(char);
  }

  /// Получает список найденных нецензурных слов в тексте
  static List<String> getProfanityWords(String text) {
    if (text.isEmpty) return [];
    
    final normalized = _normalizeForProfanity(text);
    final foundWords = <String>[];
    
    for (final stem in _profanityStems) {
      if (normalized.toLowerCase().contains(stem.toLowerCase())) {
        foundWords.add(stem);
      }
    }
    
    return foundWords;
  }

  /// Очищает текст от нецензурных слов (заменяет звездочками)
  static String censorText(String text) {
    if (text.isEmpty) return text;
    
    String censored = text;
    final foundWords = getProfanityWords(text);
    
    for (final word in foundWords) {
      final regex = RegExp(word, caseSensitive: false);
      censored = censored.replaceAll(regex, '*' * word.length);
    }
    
    return censored;
  }

  /// Проверяет список строк на наличие нецензурной брани
  static bool containsProfanityInList(List<String> texts) {
    return texts.any((text) => containsProfanity(text));
  }
}