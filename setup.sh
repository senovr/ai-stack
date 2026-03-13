#!/bin/bash

# --- Цвета ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

set -e

print_step() {
    echo -e "\n${BLUE}➤ $1${NC}"
}

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}   🚀 Bootstrapping AI Agent Stack (Dream-Team)   ${NC}"
echo -e "${CYAN}====================================================${NC}"

# Шаг 1: Python
print_step "Синхронизация Python-зависимостей (uv sync)..."
if ! uv sync; then
    echo -e "\n${RED}❌ Ошибка при установке Python пакетов.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Python окружение (.venv) успешно создано.${NC}"

# Шаг 2: Node/npm
print_step "Установка MCP-серверов (npm install)..."
if ! npm install --no-fund --no-audit; then
    echo -e "\n${RED}❌ Ошибка при установке npm пакетов.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Node-пакеты установлены.${NC}"

# Шаг 3: Конфиги и локальные глобальные навыки OpenCode
print_step "Копирование глобальных конфигов и мета-навыков..."
mkdir -p ~/.config/opencode/agents
mkdir -p ~/.config/opencode/skills

cp global-config/opencode.json ~/.config/opencode/opencode.json
cp global-config/agents/global.md ~/.config/opencode/agents/global.md
cp global-config/agents/architect.md ~/.config/opencode/agents/architect.md

# Установка skill-resolver глобально, чтобы Архитектор мог его вызывать
if [ -d "global-config/skills" ]; then
    cp -r global-config/skills/* ~/.config/opencode/skills/
fi
echo -e "${GREEN}✓ Конфиги и мета-навыки установлены в ~/.config/opencode/${NC}"

# Шаг 4: Плагины OpenCode
print_step "Инициализация базовых плагинов OpenCode..."

# Базовые плагины (всегда устанавливаются - Bare Minimum)
CORE_PLUGINS=(
    "oh-my-opencode"
    "opencode-dynamic-context-pruning"
    "opencode-background-agents"
    "tokenscope"
)

for plugin in "${CORE_PLUGINS[@]}"; do
    echo -e "   Установка: ${YELLOW}${plugin}${NC}..."
    uv run opencode plugin add "${plugin}" || echo -e "   ${YELLOW}⚠ Замечание: Плагин ${plugin} уже существует или произошла ошибка.${NC}"
done
echo -e "${GREEN}✓ Базовые плагины установлены.${NC}"

# Шаг 5: Выбор MCP плагинов (Опционально)
echo -e "\n${CYAN}====================================================${NC}"
echo -e "${CYAN}   📦 MCP Plugins (Strictly Optional)   ${NC}"
echo -e "${CYAN}====================================================${NC}"
echo -e "Доступные MCP плагины для установки:"
echo -e ""
echo -e "  ${YELLOW}1.${NC} opencode-supermemory      — Persistent agent memory"
echo -e "  ${YELLOW}2.${NC} opencode-local-memory     — Local vector DB memory"
echo -e "  ${YELLOW}3.${NC} opencode-lmstudio         — Local LM Studio support"
echo -e "  ${YELLOW}4.${NC} plannotator               — Plan review with annotations"
echo -e "  ${YELLOW}5.${NC} subtask2                  — Lightweight agent orchestration"
echo -e "  ${YELLOW}6.${NC} opencode-worktree         — Git worktree management"
echo -e "  ${YELLOW}7.${NC} opencode-linter           — Code linting"
echo -e "  ${YELLOW}8.${NC} opencode-scheduler        — Recurring jobs (cron)"
echo -e ""
echo -e "${BLUE}Введите номера через пробел (например: 1 3 5) или 'all'.${NC}"
echo -e "${BLUE}Нажмите Enter для пропуска (РЕКОМЕНДУЕТСЯ для сохранения 'Bare Minimum'):${NC}"
read -r mcp_choice </dev/tty

if [ -n "$mcp_choice" ]; then
    OPTIONAL_PLUGINS=(
        "opencode-supermemory"
        "opencode-local-memory"
        "opencode-lmstudio"
        "plannotator"
        "subtask2"
        "opencode-worktree"
        "opencode-linter"
        "opencode-scheduler"
    )
    
    SELECTED_PLUGINS=()
    if [ "$mcp_choice" = "all" ]; then
        SELECTED_PLUGINS=("${OPTIONAL_PLUGINS[@]}")
    else
        IFS=' ' read -ra NUM_ARR <<< "$mcp_choice"
        for n in "${NUM_ARR[@]}"; do
            # Проверка, что введено число в допустимом диапазоне
            if [[ "$n" =~ ^[0-9]+$ ]] && [ "$n" -ge 1 ] && [ "$n" -le "${#OPTIONAL_PLUGINS[@]}" ]; then
                idx=$((n-1))
                SELECTED_PLUGINS+=("${OPTIONAL_PLUGINS[$idx]}")
            fi
        done
    fi
    
    for plugin in "${SELECTED_PLUGINS[@]}"; do
        echo -e "   Установка: ${YELLOW}${plugin}${NC}..."
        uv run opencode plugin add "${plugin}" || echo -e "   ${YELLOW}⚠ Замечание: ${plugin} уже существует или произошла ошибка.${NC}"
    done
    echo -e "${GREEN}✓ Выбранные MCP плагины обработаны.${NC}"
else
    echo -e "${GREEN}✓ Пропущено. Сохранен строгий Bare Minimum среды.${NC}"
fi

# Шаг 6: Скиллы (Точечная установка Bare Minimum)
print_step "Синхронизация базовой библиотеки навыков (Bare Minimum)..."
BARE_MINIMUM_SKILLS=("git-commit" "debugger" "plan-writing" "verification-before-completion")
TMP_REPO="/tmp/awesome-skills-global"

echo -e "   Клонирование: ${YELLOW}sickn33/antigravity-awesome-skills${NC}..."
rm -rf "$TMP_REPO"
if ! git clone https://github.com/sickn33/antigravity-awesome-skills.git "$TMP_REPO" --depth 1 -q; then
    echo -e "\n${RED}❌ Ошибка при скачивании репозитория скиллов.${NC}"
    exit 1
fi

for skill in "${BARE_MINIMUM_SKILLS[@]}"; do
    echo -e "   Установка глобального навыка: ${CYAN}${skill}${NC}"
    cp -r "$TMP_REPO/skills/$skill"* ~/.config/opencode/skills/ 2>/dev/null || true
done
rm -rf "$TMP_REPO"
echo -e "${GREEN}✓ Bare Minimum навыки успешно интегрированы.${NC}"

# Шаг 7: Интерактивная настройка .env
print_step "Настройка переменных окружения (API Ключи)..."

if [ -f .env ]; then
    echo -e "${GREEN}✓ Файл .env уже существует. Пропускаем настройку ключей.${NC}"
else
    echo -e "${YELLOW}Файл .env не найден. Давайте его создадим.${NC}"
    echo -e "Оставьте поле пустым и нажмите Enter, чтобы пропустить ключ.\n"
    
    > .env
    
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ -z "$line" ]] || [[ "$line" == \#* ]]; then
            echo "$line" >> .env
            continue
        fi
        
        var_name=$(echo "$line" | cut -d '=' -f 1)
        default_val=$(echo "$line" | cut -d '=' -f 2-)
        
        if [[ ! "$var_name" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
            continue
        fi

        echo -e -n "Введите ${CYAN}${var_name}${NC} [по умолчанию: ${default_val}]: "
        read -r user_input </dev/tty
        
        if [ -n "$user_input" ]; then
            echo "${var_name}=${user_input}" >> .env
        else
            echo "${var_name}=${default_val}" >> .env
        fi
    done < .env.template
    
    rm -f .env.template
    echo -e "\n${GREEN}✓ Файл .env успешно сгенерирован и сохранен!${NC}"
fi

echo -e "\n${CYAN}====================================================${NC}"
echo -e "${GREEN}✨ Установка успешно завершена! Система готова к работе.${NC}"
echo -e "${CYAN}====================================================${NC}"
