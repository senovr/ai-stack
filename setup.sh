#!/bin/bash
set -e
echo "🚀 Bootstrapping AI Agent Stack..."

uv sync
npm install

mkdir -p ~/.config/opencode/agents
cp global-config/opencode.json ~/.config/opencode/opencode.json
cp global-config/agents/global.md ~/.config/opencode/agents/global.md
echo "✅ Глобальный конфиг → ~/.config/opencode/"

opencode plugin add oh-my-opencode
opencode plugin add opencode-dynamic-context-pruning
opencode plugin add opencode-background-agents
opencode plugin add opencode-supermemory
opencode plugin add subtask2
opencode plugin add opencode-worktree
opencode plugin add opencode-linter
opencode plugin add tokenscope

npx openskills install sickn33/antigravity-awesome-skills

if [ ! -f .env ]; then
    cp .env.template .env
    echo "⚠️  Заполните .env перед запуском!"
fi

echo ""
echo "✅ Готово."
echo "Новая задача: mkdir -p tasks/<name>/.opencode/agents && cd tasks/<name> && opencode agents create"
echo "Запуск:       cd tasks/<name> && opencode"
