#!/bin/bash
set -e

# Procura o arquivo de configuração config.json ou .hostinger-deploy.json
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"

CONFIG_FILE=""
if [ -f "$SKILL_DIR/config.json" ]; then
    CONFIG_FILE="$SKILL_DIR/config.json"
elif [ -f "./.hostinger-deploy.json" ]; then
    CONFIG_FILE="./.hostinger-deploy.json"
elif [ -f "./config.json" ]; then
    CONFIG_FILE="./config.json"
fi

if [ -z "$CONFIG_FILE" ]; then
    echo "❌ Erro: Arquivo de configuração não encontrado!"
    echo "💡 Execute o assistente de configuração dizendo no chat: 'configurar deploy hostinger'"
    exit 1
fi

# Extrai os dados do JSON usando node
PROJECT_PATH=$(node -e "const c = require('$CONFIG_FILE'); console.log(c.project_path || '.');")
GIT_BRANCH=$(node -e "const c = require('$CONFIG_FILE'); console.log(c.git_branch || 'main');")
ARCHIVE_NAME="deploy_package.tar.gz"
OUTPUT_ARCHIVE="$SKILL_DIR/$ARCHIVE_NAME"

echo "==> 📁 Carregando configurações de: $CONFIG_FILE"
echo "==> 🚀 Diretório do projeto: $PROJECT_PATH"
echo "==> 🌿 Branch: $GIT_BRANCH"

cd "$PROJECT_PATH"

if [ -d ".git" ]; then
    echo "==> 1. Sincronizando repositório Git local ($GIT_BRANCH)..."
    if git remote | grep -q "^origin$"; then
        git fetch origin "$GIT_BRANCH" || true
        git reset --hard "origin/$GIT_BRANCH" || true
    else
        echo "==> ℹ️  Remote 'origin' não configurado. Utilizando versão do branch local ($GIT_BRANCH)."
    fi
    COMMIT=$(git log -1 --format="%h - %s" 2>/dev/null || echo "Sem commits")
    echo "==> Commit mais recente: $COMMIT"
else
    echo "==> ⚠️  Aviso: Diretório não é um repositório Git (.git ausente). Empacotando arquivos locais..."
fi

echo "==> 2. Gerando pacote de deploy limpo ($OUTPUT_ARCHIVE)..."
rm -f "$OUTPUT_ARCHIVE"
tar --exclude='.git' \
    --exclude='node_modules' \
    --exclude='dist' \
    --exclude='.env' \
    --exclude='.DS_Store' \
    --exclude='*.tar.gz' \
    -czf "$OUTPUT_ARCHIVE" .

SIZE=$(ls -lh "$OUTPUT_ARCHIVE" | awk '{print $5}')
echo "==> ✅ Pacote gerado com sucesso: $ARCHIVE_NAME ($SIZE)"
