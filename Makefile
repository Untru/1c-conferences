# Makefile для проекта 1С Conferences
# Упрощает управление MkDocs проектом

.PHONY: help install serve build clean nav nav-serve watch watch-mac watch-win auto-nav check new-event show-nav restore github-test github-deploy

# Цвета для вывода
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

# Основные команды
help: ## Показать справку по командам
	@echo "$(BLUE)🚀 1С Conferences - Makefile$(NC)"
	@echo "$(BLUE)========================$(NC)"
	@echo ""
	@echo "$(GREEN)Основные команды:$(NC)"
	@echo "  make install     - Установить зависимости"
	@echo "  make serve      - Запустить локальный сервер"
	@echo "  make build      - Собрать сайт"
	@echo "  make clean      - Очистить собранные файлы"
	@echo ""
	@echo "$(GREEN)Навигация:$(NC)"
	@echo "  make nav        - Обновить навигацию"
	@echo "  make nav-serve  - Обновить навигацию и запустить сервер"
	@echo "  make auto-nav   - Автоматическое отслеживание изменений"
	@echo ""
	@echo "$(GREEN)GitHub Actions:$(NC)"
	@echo "  make github-test   - Протестировать GitHub Actions локально"
	@echo "  make github-deploy - Запустить деплой вручную"
	@echo ""
	@echo "$(GREEN)Утилиты:$(NC)"
	@echo "  make check      - Проверить качество кода"
	@echo "  make new-event  - Создать новое событие"
	@echo "  make show-nav   - Показать текущую навигацию"
	@echo "  make restore    - Восстановить из резервной копии"

install: ## Установить зависимости
	@echo "$(BLUE)📦 Устанавливаю зависимости...$(NC)"
	pip install -r requirements.txt
	@echo "$(GREEN)✅ Зависимости установлены$(NC)"

serve: ## Запустить локальный сервер MkDocs
	@echo "$(BLUE)🚀 Запускаю MkDocs сервер...$(NC)"
	@if [ -d ".venv" ]; then \
		source .venv/bin/activate && mkdocs serve; \
	else \
		mkdocs serve; \
	fi

build: ## Собрать сайт
	@echo "$(BLUE)🔨 Собираю сайт...$(NC)"
	@if [ -d ".venv" ]; then \
		source .venv/bin/activate && mkdocs build; \
	else \
		mkdocs build; \
	fi
	@echo "$(GREEN)✅ Сайт собран в папке site/$(NC)"

clean: ## Очистить собранные файлы
	@echo "$(BLUE)🧹 Очищаю собранные файлы...$(NC)"
	rm -rf site/
	rm -rf .cache/
	@echo "$(GREEN)✅ Очистка завершена$(NC)"

nav: ## Обновить навигацию
	@echo "$(BLUE)🗂️ Обновляю навигацию...$(NC)"
	@if [ -d ".venv" ]; then \
		source .venv/bin/activate && python generate_nav.py; \
	else \
		python generate_nav.py; \
	fi
	@echo "$(GREEN)✅ Навигация обновлена$(NC)"

nav-serve: ## Обновить навигацию и запустить сервер
	@echo "$(BLUE)🔄 Обновляю навигацию и запускаю сервер...$(NC)"
	@$(MAKE) nav
	@$(MAKE) serve

# Автоматическое отслеживание изменений
watch: ## Отслеживать изменения (Linux)
	@echo "$(BLUE)👀 Отслеживаю изменения в событиях...$(NC)"
	@echo "$(YELLOW)Нажмите Ctrl+C для остановки$(NC)"
	while true; do \
		inotifywait -r -e modify,create,delete docs/events/; \
		echo "$(GREEN)🔄 Изменения обнаружены, обновляю навигацию...$(NC)"; \
		python generate_nav.py; \
		sleep 2; \
	done

watch-mac: ## Отслеживать изменения (macOS)
	@echo "$(BLUE)👀 Отслеживаю изменения в событиях...$(NC)"
	@echo "$(YELLOW)Нажмите Ctrl+C для остановки$(NC)"
	./watch_events.sh

watch-win: ## Отслеживать изменения (Windows)
	@echo "$(BLUE)👀 Отслеживаю изменения в событиях...$(NC)"
	@echo "$(YELLOW)Нажмите Ctrl+C для остановки$(NC)"
	while (1) { \
		Get-ChildItem -Path "docs/events" -Recurse | ForEach-Object { \
			$_.LastWriteTime \
		} | Sort-Object -Descending | Select-Object -First 1; \
		Start-Sleep -Seconds 5; \
	}

auto-nav: ## Автоматическое обновление навигации
	@echo "$(BLUE)🤖 Запускаю автоматическое обновление навигации...$(NC)"
	@echo "$(YELLOW)Выберите вашу ОС:$(NC)"
	@echo "  make watch-mac  - для macOS"
	@echo "  make watch      - для Linux"
	@echo "  make watch-win  - для Windows"

# GitHub Actions команды
github-test: ## Протестировать GitHub Actions локально
	@echo "$(BLUE)🧪 Тестирую GitHub Actions локально...$(NC)"
	@echo "$(YELLOW)Проверяю качество кода...$(NC)"
	@if [ -d ".venv" ]; then \
		source .venv/bin/activate && python generate_nav.py && mkdocs build; \
	else \
		python generate_nav.py && mkdocs build; \
	fi
	@echo "$(GREEN)✅ Все тесты пройдены$(NC)"
	@echo "$(BLUE)💡 GitHub Actions готовы к работе!$(NC)"

github-deploy: ## Запустить деплой вручную
	@echo "$(BLUE)🚀 Запускаю деплой вручную...$(NC)"
	@echo "$(YELLOW)Создайте коммит и пушните в main/master ветку$(NC)"
	@echo "$(BLUE)GitHub Actions автоматически:$(NC)"
	@echo "  1. Обновит навигацию"
	@echo "  2. Соберет сайт"
	@echo "  3. Задеплоит на GitHub Pages"
	@echo ""
	@echo "$(GREEN)Команды для деплоя:$(NC)"
	@echo "  git add ."
	@echo "  git commit -m '🚀 Обновление сайта'"
	@echo "  git push origin main"

# Утилиты
check: ## Проверить качество кода
	@echo "$(BLUE)🔍 Проверяю качество кода...$(NC)"
	@if [ -d ".venv" ]; then \
		source .venv/bin/activate && python generate_nav.py && mkdocs build; \
	else \
		python generate_nav.py && mkdocs build; \
	fi
	@echo "$(GREEN)✅ Качество кода проверено$(NC)"

new-event: ## Создать новое событие
	@echo "$(BLUE)📝 Создание нового события...$(NC)"
	@read -p "Введите год события (например, 2025): " year; \
	read -p "Введите название события: " title; \
	read -p "Введите дату (YYYY-MM-DD): " date; \
	read -p "Введите место проведения: " location; \
	read -p "Введите тип события (конференция/митап): " type; \
	read -p "Введите формат (офлайн/онлайн/гибрид): " format; \
	\
	mkdir -p "docs/events/$$year"; \
	\
	cat > "docs/events/$$year/$$date-$$(echo $$title | tr ' ' '-').md" << EOF; \
--- \
title: "$$title" \
date: "$$date" \
location: "$$location" \
type: "$$type" \
format: "$$format" \
tags: \
  - "Разработка" \
  - "1С" \
--- \
\
# $$title \
\
**Дата:** $$date \
**Место:** $$location \
**Тип:** $$type \
**Формат:** $$format \
\
> Описание события будет добавлено позже. \
\
## 📍 Место проведения \
\
**🏢 Место проведения** \
\
- **Адрес:** $$location \
- **Время:** Уточняется \
\
## 🎤 Программа \
\
Программа будет опубликована ближе к дате события. \
\
## 📝 Регистрация \
\
Регистрация откроется позже. \
\
--- \
\
*Вернуться к [списку событий $$year](index.md) или [главной странице](../../index.md)* \
EOF; \
	\
	echo "$(GREEN)✅ Событие создано: docs/events/$$year/$$date-$$(echo $$title | tr ' ' '-').md$(NC)"; \
	echo "$(BLUE)💡 Не забудьте обновить навигацию: make nav$(NC)"

show-nav: ## Показать текущую навигацию
	@echo "$(BLUE)📋 Текущая навигация:$(NC)"
	@python -c "import yaml; config = yaml.safe_load(open('mkdocs.yml')); print(yaml.dump(config['nav'], default_flow_style=False, allow_unicode=True, sort_keys=False))"

restore: ## Восстановить из резервной копии
	@if [ -f "mkdocs.yml.backup" ]; then \
		echo "$(BLUE)🔄 Восстанавливаю из резервной копии...$(NC)"; \
		cp mkdocs.yml.backup mkdocs.yml; \
		echo "$(GREEN)✅ Восстановление завершено$(NC)"; \
	else \
		echo "$(RED)❌ Резервная копия не найдена$(NC)"; \
	fi
