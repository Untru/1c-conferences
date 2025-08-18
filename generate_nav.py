#!/usr/bin/env python3
"""
Автоматическая генерация навигации MkDocs на основе метаданных событий
"""

import os
import re
import yaml
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any

def extract_event_metadata(file_path: Path) -> Dict[str, Any]:
    """Извлекает метаданные события из Markdown файла"""
    metadata = {}
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Ищем YAML front matter
        yaml_match = re.match(r'^---\s*\n(.*?)\n---\s*\n', content, re.DOTALL)
        if yaml_match:
            yaml_content = yaml_match.group(1)
            metadata = yaml.safe_load(yaml_content) or {}
            
        # Если нет YAML, пытаемся извлечь базовую информацию
        if not metadata:
            # Ищем заголовок
            title_match = re.search(r'^#\s*(.+)$', content, re.MULTILINE)
            if title_match:
                metadata['title'] = title_match.group(1).strip()
                
            # Ищем дату в тексте
            date_match = re.search(r'(\d{4}-\d{2}-\d{2})', content)
            if date_match:
                metadata['date'] = date_match.group(1)
                
    except Exception as e:
        print(f"Ошибка при чтении {file_path}: {e}")
        
    return metadata

def scan_events_directory(events_dir: Path) -> List[Dict[str, Any]]:
    """Сканирует директорию событий и собирает информацию"""
    events = []
    
    if not events_dir.exists():
        return events
        
    for year_dir in events_dir.iterdir():
        if year_dir.is_dir() and year_dir.name.isdigit():
            year = year_dir.name
            
            for event_file in year_dir.glob('*.md'):
                if event_file.name == 'index.md':
                    continue
                    
                metadata = extract_event_metadata(event_file)
                if metadata:
                    # Добавляем путь к файлу
                    relative_path = event_file.relative_to(events_dir.parent)
                    metadata['file_path'] = str(relative_path)
                    metadata['year'] = year
                    
                    # Если нет title, используем имя файла
                    if 'title' not in metadata:
                        metadata['title'] = event_file.stem.replace('-', ' ').title()
                        
                    events.append(metadata)
    
    return events

def generate_navigation(events: List[Dict[str, Any]]) -> List[Any]:
    """Генерирует структуру навигации"""
    
    # Группируем события по годам
    events_by_year = {}
    for event in events:
        year = event.get('year', 'Unknown')
        if year not in events_by_year:
            events_by_year[year] = []
        events_by_year[year].append(event)
    
    # Сортируем события по дате
    for year in events_by_year:
        events_by_year[year].sort(key=lambda x: x.get('date', ''))
    
    # Сортируем годы по убыванию
    sorted_years = sorted(events_by_year.keys(), reverse=True)
    
    # Создаем навигацию
    nav = []
    
    # Главная страница
    nav.append({"Главная": "index.md"})
    
    # События
    events_nav = []
    for year in sorted_years:
        year_events = events_by_year[year]
        
        # Создаем индекс года
        events_nav.append({year: f"events/{year}/index.md"})
        
        # Добавляем события года (на том же уровне)
        for event in year_events:
            title = event.get('title', 'Без названия')
            file_path = event.get('file_path', '')
            if file_path:
                # Убираем лишние кавычки и 2025 из названия
                clean_title = title.replace(' 2025', '')
                # Создаем правильный формат как словарь
                events_nav.append({clean_title: file_path})
    
    nav.append({"Конференции": events_nav})
    
    # О проекте
    nav.append({"О проекте": "about.md"})
    
    return nav

def update_mkdocs_config(nav: List[Any], config_file: Path = Path('mkdocs.yml')):
    """Обновляет конфигурацию MkDocs"""
    
    if not config_file.exists():
        print(f"Файл конфигурации {config_file} не найден!")
        return
        
    try:
        # Читаем текущую конфигурацию
        with open(config_file, 'r', encoding='utf-8') as f:
            config = yaml.safe_load(f)
        
        # Обновляем навигацию
        config['nav'] = nav
        
        # Создаем резервную копию
        backup_file = config_file.with_suffix('.yml.backup')
        with open(backup_file, 'w', encoding='utf-8') as f:
            yaml.dump(config, f, default_flow_style=False, allow_unicode=True, sort_keys=False)
        
        # Записываем обновленную конфигурацию
        with open(config_file, 'w', encoding='utf-8') as f:
            yaml.dump(config, f, default_flow_style=False, allow_unicode=True, sort_keys=False)
            
        print(f"✅ Навигация обновлена в {config_file}")
        print(f"📋 Резервная копия сохранена в {backup_file}")
        
    except Exception as e:
        print(f"❌ Ошибка при обновлении конфигурации: {e}")

def main():
    """Основная функция"""
    print("🚀 Автоматическая генерация навигации MkDocs")
    print("=" * 50)
    
    # Пути
    docs_dir = Path('docs')
    events_dir = docs_dir / 'events'
    
    if not events_dir.exists():
        print(f"❌ Директория событий {events_dir} не найдена!")
        return
    
    # Сканируем события
    print("🔍 Сканирую директорию событий...")
    events = scan_events_directory(events_dir)
    
    if not events:
        print("⚠️ События не найдены!")
        return
    
    print(f"📅 Найдено {len(events)} событий:")
    for event in events:
        title = event.get('title', 'Без названия')
        date = event.get('date', 'Без даты')
        year = event.get('year', 'Неизвестный год')
        print(f"  - {title} ({date}, {year})")
    
    # Генерируем навигацию
    print("\n🗂️ Генерирую навигацию...")
    nav = generate_navigation(events)
    
    # Показываем сгенерированную навигацию
    print("\n📋 Сгенерированная навигация:")
    print(yaml.dump(nav, default_flow_style=False, allow_unicode=True, sort_keys=False))
    
    # Обновляем конфигурацию
    print("\n📝 Обновляю конфигурацию MkDocs...")
    update_mkdocs_config(nav)
    
    print("\n🎉 Готово! Навигация автоматически обновлена.")
    print("💡 Перезапустите MkDocs для применения изменений.")

if __name__ == "__main__":
    main()
