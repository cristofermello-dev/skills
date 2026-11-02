#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$SKILL_DIR/config.json"

echo "=========================================================="
echo "🧙‍♂️ [Hostinger Deploy] Assistente Interativo de Configuração"
echo "=========================================================="
echo ""

read -rp "1. Domínio na Hostinger (ex: meusite.com.br): " DOMAIN
while [ -z "$DOMAIN" ]; do
    echo "⚠️ O domínio é obrigatório!"
    read -rp "1. Domínio na Hostinger (ex: meusite.com.br): " DOMAIN
done

read -rp "2. Usuário da Hospedagem (ex: u123456789): " USERNAME
while [ -z "$USERNAME" ]; do
    echo "⚠️ O usuário da hospedagem é obrigatório!"
    read -rp "2. Usuário da Hospedagem (ex: u123456789): " USERNAME
done

read -rp "3. Caminho local do projeto [padrão: .]: " PROJECT_PATH
PROJECT_PATH="${PROJECT_PATH:-.}"

read -rp "4. Branch do Git [padrão: main]: " GIT_BRANCH
GIT_BRANCH="${GIT_BRANCH:-main}"

read -rp "5. Versão do Node.js [padrão: 20]: " NODE_VERSION
NODE_VERSION="${NODE_VERSION:-20}"

read -rp "6. Arquivo de entrada [padrão: server.js]: " ENTRY_FILE
ENTRY_FILE="${ENTRY_FILE:-server.js}"

read -rp "7. Script de build [padrão: build]: " BUILD_SCRIPT
BUILD_SCRIPT="${BUILD_SCRIPT:-build}"

cat <<EOF > "$CONFIG_FILE"
{
  "domain": "$DOMAIN",
  "username": "$USERNAME",
  "project_path": "$PROJECT_PATH",
  "git_branch": "$GIT_BRANCH",
  "node_version": $NODE_VERSION,
  "app_type": "express",
  "build_script": "$BUILD_SCRIPT",
  "entry_file": "$ENTRY_FILE"
}
EOF

echo ""
echo "✅ Arquivo de configuração gravado com sucesso em:"
echo "   $CONFIG_FILE"
echo ""

if [ -f "$SCRIPT_DIR/verify_mcp.js" ]; then
    node "$SCRIPT_DIR/verify_mcp.js"
fi
