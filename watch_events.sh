#!/bin/bash

# Скрипт для автоматического обновления навигации MkDocs при изменении событий
# Для macOS

echo "🚀 Запускаю автоматическое обновление навигации для macOS"
echo "📁 Слежу за изменениями в директории docs/events/"
echo "💡 Нажмите Ctrl+C для остановки"
echo ""

# Проверяем наличие fswatch
if ! command -v fswatch &> /dev/null; then
    echo "⚠️  fswatch не установлен. Устанавливаю..."
    brew install fswatch
fi

# Функция для обновления навигации
update_navigation() {
    echo "🔄 Обнаружены изменения, обновляю навигацию..."
    python3 generate_nav.py
    echo "✅ Навигация обновлена в $(date)"
    echo ""
}

# Основной цикл
while true; do
    echo "👀 Ожидаю изменения файлов событий..."
    
    # Используем fswatch для отслеживания изменений
    fswatch -o docs/events/ | head -1 > /dev/null
    
    # Обновляем навигацию
    update_navigation
    
    # Небольшая задержка
    sleep 2
done
