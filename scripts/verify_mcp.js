#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const os = require('os');

console.log('🔍 [Validador Hostinger Deploy] Verificando ambiente...');

// 1. Verifica credenciais Hostinger MCP
const hostingerCredPath = path.join(os.homedir(), '.config', 'hostinger-mcp', 'credentials.json');
let mcpAuthOk = false;

if (fs.existsSync(hostingerCredPath)) {
  try {
    const creds = JSON.parse(fs.readFileSync(hostingerCredPath, 'utf8'));
    if (creds.access_token || creds.client_id) {
      console.log('✅ Hostinger MCP: Credenciais locais detectadas com sucesso em ~/.config/hostinger-mcp/credentials.json');
      mcpAuthOk = true;
    }
  } catch (err) {
    console.warn('⚠️  Arquivo de credenciais do Hostinger MCP encontrado, mas não pôde ser lido:', err.message);
  }
}

if (!mcpAuthOk) {
  console.log('ℹ️  Aviso: Credenciais globais do Hostinger MCP não detectadas em ~/.config/hostinger-mcp/.');
  console.log('   Certifique-se de que o Hostinger MCP está autenticado antes de executar o deploy.');
}

// 2. Procura config.json
const skillDir = path.resolve(__dirname, '..');
const possibleConfigPaths = [
  path.join(skillDir, 'config.json'),
  path.join(process.cwd(), '.hostinger-deploy.json'),
  path.join(process.cwd(), 'config.json')
];

const foundConfig = possibleConfigPaths.find(p => fs.existsSync(p));

if (!foundConfig) {
  console.log('ℹ️  Status: config.json ainda não criado (Modo Wizard ativo).');
  process.exit(0);
}

try {
  const config = JSON.parse(fs.readFileSync(foundConfig, 'utf8'));
  const required = ['domain', 'username'];
  const missing = required.filter(k => !config[k]);

  if (missing.length > 0) {
    console.error('❌ Erro: Campos obrigatórios ausentes no config.json:', missing.join(', '));
    process.exit(1);
  }

  console.log('✅ Arquivo de configuração válido:', foundConfig);
  console.log(`   - Domínio: ${config.domain}`);
  console.log(`   - Usuário: ${config.username}`);
  console.log(`   - Pasta do Projeto: ${config.project_path || './'}`);
  console.log(`   - Node.js: ${config.node_version || 20}`);
} catch (err) {
  console.error('❌ Erro de sintaxe no config.json:', err.message);
  process.exit(1);
}
