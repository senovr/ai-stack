# 🧠 OpenCode AI Agent Stack (Dream-Team Framework)

Единый переносимый репозиторий для развертывания мульти-агентной среды разработки на базе [OpenCode](https://opencode.ai/). Стек спроектирован для решения Enterprise-задач: разработки плагинов Dataiku DSS, ML/LLMOps (ClearML, DSPy, Opik), Full-Stack (Vue + FastAPI) и DevOps.

## 📂 Структура репозитория

```text
ai-stack/
├── global-config/               # Системные настройки (копируются в ~/.config/opencode)
│   ├── opencode.json            # Настройки MCP-серверов
│   ├── agents/
│   │   ├── global.md            # Базовые правила (uv, ruff, git, context7)
│   │   └── architect.md         # Мета-агент для проектирования других агентов
│   └── skill/
│       └── skill-resolver/      # Система управления навыками
│           └── templates/        # Шаблоны проектов (pyproject.toml, prek.toml)
│
├── tasks/                       # 📍 Рабочие директории для макро-задач
│   ├── dataiku/
│   ├── mlops/
│   └── ...
│
├── pyproject.toml               # Python-зависимости
├── prek.toml                    # Git hooks (ruff + ty)
├── package.json                 # Node-зависимости (MCP)
├── .env.template                # Шаблон API-ключей
└── setup.sh                     # Скрипт развертывания
```

## 🚀 Быстрый старт

### Требования

- `node` (>= 18) и `npm`
- `uv` (пакетный менеджер Python)
- `prek` (git hooks — см. ниже)
- `git`

### Установка

```bash
git clone <URL_ВАШЕГО_РЕПОЗИТОРИЯ> ai-stack
cd ai-stack
chmod +x setup.sh
./setup.sh
```

Скрипт установит Python и Node зависимости, загрузит плагины OpenCode, скачает навыки (skills) и скопирует глобальные конфиги в `~/.config/opencode/`.

После установки впишите ваши API-ключи в созданный файл `.env`.

### Git Hooks (prek)

Проект использует [prek](https://prek.j178.dev/) — быстрый Rust-based заменитель pre-commit с интеграцией uv.

```bash
# Установка хуков (автоматически в setup.sh)
prek install

# Запуск вручную
prek run
```

Хуки настроены в `prek.toml`:
- **ruff** — линтер и форматтер
- **ty** — type checker от Astral

## 🛠 Рабочий процесс (Workflow)

Среда использует паттерн **Иерархии Агентов**. Под каждую новую задачу вы не пишете промпты руками — это делает Мета-Агент (Architect).

### 1. Инициализация новой задачи

```bash
mkdir -p tasks/my-new-project && cd tasks/my-new-project
opencode
```

OpenCode автоматически подгрузит `global.md` с базовыми правилами из системных настроек.

### 2. Проектирование агента через Архитектора

В чате OpenCode позовите мета-агента:

> `@architect Мне нужен агент для создания микросервиса парсинга логов на Go и PostgreSQL.`

**Что произойдет:**

1. Архитектор выкачает (git pull) вашу библиотеку `antigravity-awesome-skills`.
2. Детально прочитает исходники всех навыков, выберет лучшие под задачу.
3. Создаст файл `.opencode/agents/<name>.md` в текущей папке.
4. **Автоматически создаст базовые файлы проекта:**
   - `pyproject.toml` — с настроенными dev-зависимостями (ruff, ty)
   - `prek.toml` — с git-хуками для линтинга и type-checking
5. Сообщит, какие навыки он встроил и почему.

### 3. Работа с агентом

Переключитесь на созданного агента (`@<имя>` или Tab) и поставьте боевую задачу.  
Агент при старте загрузит назначенные ему навыки и начнет работу по стандартам домена.

## 🧠 Система Агентов (3 уровня)

| Уровень | Файл | Приоритет | Назначение |
|---------|------|-----------|------------|
| Global | `~/.config/opencode/agents/global.md` | Низкий (фоновый) | Базовые правила: uv, ruff, git, context7, MCP |
| Meta | `~/.config/opencode/agents/architect.md` | Вызывается по `@architect` | Проектирование новых агентов |
| Task | `tasks/<name>/.opencode/agents/<name>.md` | Высокий (проектный) | Специфика конкретной задачи/домена |

Проектные агенты **дополняют** глобальные правила, а не перезаписывают их.

## 🛠️ Skill Resolver

Система автоматического провижинга навыков. При создании проекта:

1. **Architect** проводит интервью и определяет технический стек
2. **Skill Resolver** анализирует требования, резолвит зависимости между навыками
3. Копирует выбранные навыки в `skills/` проекта
4. Создает базовые файлы: `pyproject.toml`, `prek.toml`, `<role>.md`

Навыки берутся из репозитория `antigravity-awesome-skills`. Каждый навык может зависеть от других — разрешение зависимостей происходит автоматически (DAG).

## 🔌 Встроенные MCP-серверы

| MCP | Назначение |
|-----|-----------|
| `context7` | Документация библиотек (единый источник правды) |
| `search` (omnisearch) | Веб-поиск (Tavily/Brave/Exa) |
| `bash` / `filesystem` | Выполнение команд и работа с ОС |
| `git` | Версионирование |
| `postgres` / `sqlite` | Интроспекция баз данных |
| `puppeteer` | Headless-браузер для визуального тестирования UI |
| `firecrawl` | Скрейпинг страниц |
| `docker` | Управление контейнерами |
| `figma` | Чтение дизайн-токенов |
| `gitlab` | Корпоративный GitLab |

МСP-серверы с `"enabled": false` не загружаются. Включайте их по мере необходимости в `opencode.json`.

## 🧩 Плагины OpenCode

| Плагин | Назначение |
|--------|-----------|
| `oh-my-opencode` | Оркестрация, LSP/AST, background agents |
| `opencode-dynamic-context-pruning` | Защита от переполнения контекста |
| `opencode-background-agents` | Асинхронный запуск долгих задач |
| `opencode-supermemory` | Персистентная память между сессиями |
| `subtask2` | Декомпозиция задач |
| `opencode-worktree` | Git worktrees для изоляции задач |
| `opencode-linter` | Валидация кода перед коммитом |
| `tokenscope` | Мониторинг расхода токенов |

## 🔑 API-ключи

Все ключи хранятся в `.env` (не коммитится). Шаблон с описанием — в `.env.template`.

| Ключ | Где получить | Бесплатно? |
|------|-------------|-----------|
| `CONTEXT7_API_KEY` | [context7.com](https://context7.com) | ✅ |
| `TAVILY_API_KEY` | [app.tavily.com](https://app.tavily.com) | ✅ (1000 req/мес) |
| `BRAVE_API_KEY` | [brave.com/search/api](https://brave.com/search/api/) | ✅ (2000 req/мес) |
| `EXA_API_KEY` | [exa.ai](https://exa.ai) | ✅ |
| `FIRECRAWL_API_KEY` | [firecrawl.dev](https://firecrawl.dev) | ✅ |
| `DKU_DSS_URL` / `DKU_API_KEY` | Dataiku DSS → Profile → API Keys | — |
| `CLEARML_API_ACCESS_KEY` | [app.clear.ml](https://app.clear.ml) | ✅ |
| `OPIK_API_KEY` | [comet.com/opik](https://www.comet.com/opik) | ✅ |

## 📦 Перенос на новую машину

```bash
git clone <URL> ai-stack && cd ai-stack && ./setup.sh && nano .env && opencode
```
