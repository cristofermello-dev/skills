---
name: hostinger-deploy-template
description: |
  Universal automated deployment procedure for web applications (Node.js/Express/Next/Static) on Hostinger.
  MANDATORY AUTO-START ON INSTALL: Immediately after installing, downloading, or cloning this skill, the agent MUST automatically begin the First-Run Guided Configuration Wizard (Step 1/5) in the very same turn, without waiting for the user to ask for a deploy.
  Features a First-Run Guided Configuration Wizard (asks setup questions 1-by-1 on first run),
  and 100% autonomous zero-confirmation deployment once configured.
  Includes Visual Pipeline Stepper (stage icons, progress status) and collapsed execution console in an accordion.
  Triggers:
  - "instalar skill hostinger"
  - "baixar skill hostinger"
  - "deploy hostinger"
  - "atualizar hospedagem"
  - "configurar deploy hostinger"
  - "reconfigurar deploy"
  - "deploy no hostinger"
license: MIT
metadata:
  version: v1.1.0
  publisher: community
---

# Universal Hostinger Deploy Workflow & Wizard

> [!NOTE]
> 🎨 **Interface Visual de Saída**: O deploy apresenta um **Stepper Visual com Ícones** para cada etapa e o **Console de Execução em Acordeão Fechado** (`<details>`), eliminando poluição de logs no chat.

---

## ⚡ REGRA MANDATÓRIA: DISPARO AUTOMÁTICO NO FIM DA INSTALAÇÃO (ON-INSTALL AUTO-START)

> [!IMPORTANT]
> **AÇÃO IMEDIATA ASSIM QUE A SKILL FOR INSTALADA / BAIXADA**:
> Se o usuário pediu para instalar, baixar ou clonar esta skill para o ambiente dele:
> 1. Conclua o download/clone do repositório normalmente.
> 2. **NÃO encerre a sua resposta** apenas dizendo que a skill foi instalada.
> 3. **INICIE O WIZARD DE CONFIGURAÇÃO IMEDIATAMENTE NA MESMA RESPOSTA!**
> 4. Envie a mensagem de boas-vindas do assistente e a **Pergunta 1/5 (Domínio)**, pausando para aguardar a resposta do usuário.

---

## 🧭 Modo 1: Wizard de Primeira Execução (Configuração Passo a Passo)

### Detecção de Primeira Execução:
Antes de iniciar qualquer deploy, verifique se o arquivo de configuração `config.json` existe na pasta da skill ou como `.hostinger-deploy.json` na raiz do projeto.

**Se o arquivo `config.json` NÃO existir (ou após a instalação, ou se o usuário disser "reconfigurar deploy" / "configurar deploy"):**
Você **DEVE** pausar o fluxo de deploy e conduzir o **Wizard Interativo**.
Faça as perguntas **UMA POR UMA (1 por 1)**, aguardando a resposta do usuário antes de enviar a próxima pergunta:

1. **Pergunta 1 (Domínio):**
   > *"👋 Olá! Bem-vindo ao assistente de deploy da Hostinger. A skill foi instalada com sucesso! Para começarmos, vamos configurar seu ambiente juntos em poucos passos.*  
   > 
   > **Passo 1/5:** Qual é o domínio do seu site na Hostinger? (Exemplo: `meusite.com.br`)*"

2. **Pergunta 2 (Usuário Hostinger):**
   > *"**Passo 2/5:** Qual é o seu usuário de hospedagem na Hostinger (`username`)?*  
   > *(Dica: Geralmente começa com `u` seguido de números, como `u123456789`. Você encontra esse dado no painel hPanel da Hostinger sob 'Detalhes do Plano / Acesso SSH').*"

3. **Pergunta 3 (Diretório do Projeto):**
   > *"**Passo 3/5:** Qual é o caminho da pasta onde o projeto está localizado no seu computador? (Exemplo: `/caminho/do/projeto` ou responda `.` se for o diretório atual aberto).* "

4. **Pergunta 4 (Branch do Git):**
   > *"**Passo 4/5:** Qual branch do Git deve ser usada para o deploy? (Padrão: `main`).*"

5. **Pergunta 5 (Stack & Build):**
   > *"**Passo 5/5:** Como sua aplicação é configurada na Hostinger?*  
   > - Versão do Node: *(padrão: 20)*  
   > - Tipo de App: *(padrão: express)*  
   > - Arquivo de entrada: *(padrão: server.js)*  
   > - Script de build: *(padrão: build ou 'nenhum')*  
   > 
   > *(Se a sua aplicação utiliza os padrões recomendados acima, basta responder `padrão`).*"

### Validação e Salvamento do Wizard:
Após coletar todas as 5 respostas:
1. Valide se as ferramentas MCP `hostinger-hosting` estão disponíveis.
2. Salve os dados no arquivo `config.json` na pasta da skill (ou `.hostinger-deploy.json` na raiz do projeto).
3. Apresente a confirmação:
   > *"✅ **Configuração Salva com Sucesso!** O arquivo `config.json` foi gravado localmente. Todas as próximas vezes que você pedir 'deploy' ou 'atualizar hospedagem', o processo será 100% autônomo sem perguntas."*
4. Inicie imediatamente o primeiro deploy com o Stepper Visual.

---

## 🚀 Modo 2: Deploy Autônomo em Produção (Após Configurado)

Quando `config.json` já existir:

> [!IMPORTANT]
> **REGRA DE EXECUÇÃO AUTÔNOMA**:
> - Carregue os valores de `config.json`.
> - Não faça perguntas nem peça confirmações adicionais.
> - Execute as etapas 1 a 6 sequencialmente até o site estar no ar.

### Etapa 1: Sincronizar Git e Gerar Pacote
Execute o script local de empacotamento:
```bash
bash scripts/package.sh
```
O script lê `config.json`, executa `git fetch origin <BRANCH>` e cria o arquivo comprimido `deploy_package.tar.gz`.

### Etapa 2: Gerar URL de Upload via Hostinger MCP
Chame a ferramenta MCP `hosting_generateUploadURLV1`:
- `ServerName`: `hostinger-hosting`
- `ToolName`: `hosting_generateUploadURLV1`
- `Arguments`: `{"domain": "<DOMAIN>", "username": "<USERNAME>"}`

Em seguida, envie o arquivo `deploy_package.tar.gz` via TUS curl utilizando as credenciais retornadas pelo MCP:
```bash
FILE="<CAMINHO_DO_PACOTE>/deploy_package.tar.gz"
SIZE=$(stat -f%z "$FILE")
URL="<URL_DO_MCP>"
AUTH="<AUTH_KEY_DO_MCP>"
REST_AUTH="<REST_AUTH_KEY_DO_MCP>"

curl -s -X POST "${URL}/deploy_package.tar.gz?override=true" \
  -H "X-Auth: ${AUTH}" \
  -H "X-Auth-Rest: ${REST_AUTH}" \
  -H "Tus-Resumable: 1.0.0" \
  -H "Upload-Length: ${SIZE}" \
  -H "Upload-Offset: 0"

curl -s -X PATCH "${URL}/deploy_package.tar.gz?override=true" \
  -H "X-Auth: ${AUTH}" \
  -H "X-Auth-Rest: ${REST_AUTH}" \
  -H "Tus-Resumable: 1.0.0" \
  -H "Content-Type: application/offset+octet-stream" \
  -H "Upload-Offset: 0" \
  --data-binary "@${FILE}"
```

### Etapa 3: Iniciar Compilação Node.js
Chame a ferramenta MCP `hosting_startNode_jsBuildV1`:
- `ServerName`: `hostinger-hosting`
- `ToolName`: `hosting_startNode_jsBuildV1`
- `Arguments`:
  ```json
  {
    "domain": "<DOMAIN>",
    "username": "<USERNAME>",
    "node_version": <NODE_VERSION>,
    "app_type": "<APP_TYPE>",
    "build_script": "<BUILD_SCRIPT>",
    "entry_file": "<ENTRY_FILE>",
    "root_directory": "",
    "output_directory": "",
    "source_type": "archive",
    "source_options": {
      "archive_path": "deploy_package.tar.gz"
    }
  }
  ```

### Etapa 4: Monitorar Build
1. Use a ferramenta `schedule` com `DurationSeconds: "30"` para aguardar a compilação.
2. Consulte `hosting_listNodeJSBuildsV1` (`domain: "<DOMAIN>"`, `username: "<USERNAME>"`).
3. Aguarde até que o status retorne `completed`.

### Etapa 5: Reiniciar e Limpar Cache
1. Chame `hosting_restartNode_jsApplicationV1` (`domain: "<DOMAIN>"`, `username: "<USERNAME>"`).
2. Chame `hosting_clearWebsiteCacheV1` (`domain: "<DOMAIN>"`, `username: "<USERNAME>"`).

### Etapa 6: Verificação ao Vivo & Retorno Visual
Execute:
```bash
curl -I -s https://<DOMAIN>
```
Confirme o código `HTTP/2 200` ou redirecionamento válido.

---

## 🎨 Formato Visual Obrigatório de Retorno

```markdown
### 🚀 Deploy em Produção Concluído — <DOMAIN>

\`\`\`mermaid
graph LR
    A[📥 Git Sync] --> B[📦 Empacotamento]
    B --> C[🚀 Upload Hostinger]
    C --> D[⚙️ Build Node.js]
    D --> E[🔄 Restart & Cache]
    E --> F[🌐 200 OK Live]
    classDef done fill:#10b981,stroke:#059669,stroke-width:2px,color:#fff;
    class A,B,C,D,E,F done;
\`\`\`

| Etapa | Ícone | Ação | Status |
| :--- | :---: | :--- | :---: |
| **1. Git & Sincronização** | 📥 | *Pull `<BRANCH>` & checagem de commits* | Concluído (`<COMMIT_HASH> - <COMMIT_MSG>`) |
| **2. Empacotamento** | 📦 | *Geração do pacote `deploy_package.tar.gz` (<SIZE>)* | Concluído |
| **3. Upload Hostinger** | 🚀 | *Transmissão TUS / Hostinger Storage API* | Concluído |
| **4. Build da Aplicação** | ⚙️ | *Compilação Node.js (<NODE_VERSION>)* | Concluído (<BUILD_TIME>) |
| **5. Reinício & Cache** | 🔄 | *Restart da aplicação & Purge LiteSpeed* | Concluído |
| **6. Health Check** | 🌐 | *Verificação de integridade ao vivo* | **HTTP 200 OK** |

> [!TIP]
> 🟢 **Deploy Concluído com Sucesso em Produção!**  
> **Domínio:** [<DOMAIN>](https://<DOMAIN>) | **Ambiente:** Hostinger Cloud

<details>
<summary><b>▶ 📜 Console de Execução & Logs Técnicos (Clique para expandir)</b></summary>

\`\`\`bash
<LOGS_DA_EXECUCAO>
\`\`\`

</details>
```
