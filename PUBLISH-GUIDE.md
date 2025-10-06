# 📦 Guia de Publicação no GitHub

**Versão:** 1.0.0
**SDK:** mcp-ultra-sdk-custom v9.0.0
**Data:** 2025-10-05

---

## 🎯 Objetivo

Este guia descreve o processo completo para sanitizar e publicar o mcp-ultra-sdk-custom no GitHub, removendo caminhos internos e tornando-o pronto para uso público.

---

## ⚡ Quick Start (Automático)

Execute o script automatizado que faz tudo:

```powershell
cd E:\vertikon\business\SaaS\templates\mcp-ultra-sdk-custom

# Opção 1: Publicação completa (sanitização + git push)
.\tools\git-publish.ps1 -GitHubOrg "vertikon" -RepoName "mcp-ultra-sdk-custom"

# Opção 2: Apenas sanitização (sem push)
.\tools\publish-github.ps1 -GitHubOrg "vertikon" -RepoName "mcp-ultra-sdk-custom"
```

---

## 📋 Processo Manual (Passo a Passo)

Se preferir executar manualmente ou entender cada etapa:

### ETAPA 1: Sanitização

```powershell
cd E:\vertikon\business\SaaS\templates\mcp-ultra-sdk-custom

# Executar sanitização (remove caminhos internos)
.\tools\publish-github.ps1 -GitHubOrg "vertikon" -RepoName "mcp-ultra-sdk-custom" -SkipPush

# Revisar alterações
git status
git diff
```

**O que a sanitização faz:**

1. ✅ Atualiza `go.mod` para `module github.com/vertikon/mcp-ultra-sdk-custom`
2. ✅ Remove replace directives locais (E:\vertikon\...)
3. ✅ Substitui caminhos hardcoded por variáveis de ambiente em `.go` files
4. ✅ Substitui caminhos hardcoded em scripts `.ps1`
5. ✅ Cria `.gitignore` (exclui seeds/, logs/, go.work, etc.)
6. ✅ Cria GitHub Actions CI workflow (`.github/workflows/ci.yml`)
7. ✅ Cria `CONFIG.md` (documentação de configuração)
8. ✅ Cria backup em `backup-pre-publish-TIMESTAMP/`

### ETAPA 2: Validar Compilação

```powershell
# Limpar cache
go clean -cache -modcache

# Baixar dependências
go mod download

# Compilar
go build ./cmd

# Executar testes
go test ./...
```

**Resultado esperado:**
- ✅ Compilação sem erros
- ✅ Testes passando

### ETAPA 3: Inicializar Git (se necessário)

```powershell
# Verificar se já é repositório git
git status

# Se não for, inicializar
git init
git branch -M main
```

### ETAPA 4: Criar README.md (se não existir)

O script `git-publish.ps1` cria automaticamente. Se preferir manual:

```powershell
# Verificar se README existe
if (!(Test-Path README.md)) {
    echo "# mcp-ultra-sdk-custom" > README.md
}
```

### ETAPA 5: Git Add e Commit

```powershell
# Adicionar todos os arquivos
git add .

# Verificar o que será commitado
git status

# Criar commit
git commit -m "feat: sanitize for GitHub publication (v9.0.0)

- Remove hardcoded internal paths
- Add environment variable configuration
- Create GitHub Actions CI workflow
- Add .gitignore for local files
- Create CONFIG.md documentation
- Update go.mod to github.com/vertikon/mcp-ultra-sdk-custom

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### ETAPA 6: Adicionar Remote e Push

```powershell
# Adicionar remote
git remote add origin https://github.com/vertikon/mcp-ultra-sdk-custom.git

# Ou, se remote já existe, atualizar URL
git remote set-url origin https://github.com/vertikon/mcp-ultra-sdk-custom.git

# Push para GitHub
git push -u origin main
```

**Se o push falhar:**

```powershell
# Opção 1: Force push (se você for o único desenvolvedor)
git push -u origin main --force

# Opção 2: Pull e merge primeiro (se há colaboradores)
git pull origin main --rebase
git push -u origin main
```

---

## 🔍 Verificação Pós-Publicação

Após o push, execute estas verificações:

### 1. Clone em Ambiente Limpo

```powershell
# Em outro diretório/máquina
cd C:\temp
git clone https://github.com/vertikon/mcp-ultra-sdk-custom.git
cd mcp-ultra-sdk-custom

# Tentar compilar
go mod download
go build ./cmd

# Se compilar = ✅ Publicação bem-sucedida!
```

### 2. Configurar Variáveis de Ambiente

```powershell
# Copiar exemplo
cp .env.example .env

# Editar .env com caminhos locais
notepad .env

# Configurar PowerShell (sessão atual)
$env:SEED_PATH = "C:\path\to\seeds\mcp-ultra"
$env:SDK_PATH = "C:\path\to\mcp-ultra-sdk-custom"
$env:FIX_PATH = "C:\path\to\mcp-ultra-fix"
$env:TEMPLATE_PATH = "C:\path\to\mcp-ultra"
```

### 3. Testar Execução

```powershell
# Executar SDK
go run ./cmd

# Em outro terminal, testar endpoints
curl http://localhost:8080/health
curl http://localhost:8080/seed/status
```

### 4. Verificar GitHub Actions

1. Acesse: https://github.com/vertikon/mcp-ultra-sdk-custom/actions
2. Verifique se o workflow CI executou com sucesso
3. Se falhar, revisar logs e corrigir

---

## 📊 Checklist de Publicação

Antes de fazer push:

- [ ] ✅ Backup criado em `backup-pre-publish-*/`
- [ ] ✅ `go.mod` atualizado para `github.com/vertikon/mcp-ultra-sdk-custom`
- [ ] ✅ Replace directives locais removidos
- [ ] ✅ Caminhos hardcoded substituídos por variáveis de ambiente
- [ ] ✅ `.gitignore` criado/atualizado
- [ ] ✅ GitHub Actions CI criado (`.github/workflows/ci.yml`)
- [ ] ✅ `CONFIG.md` criado
- [ ] ✅ `README.md` existe
- [ ] ✅ `.env.example` criado
- [ ] ✅ Compilação sem erros (`go build ./cmd`)
- [ ] ✅ Testes passando (`go test ./...`)

Após push:

- [ ] ✅ Repositório acessível no GitHub
- [ ] ✅ Clone em ambiente limpo compila
- [ ] ✅ GitHub Actions CI executou com sucesso
- [ ] ✅ README.md renderizado corretamente
- [ ] ✅ Arquivos sensíveis não foram commitados (checar .gitignore)

---

## 🛠️ Troubleshooting

### Erro: "go.mod contains replace directive"

**Causa:** Replaces locais não foram removidos

**Solução:**
```powershell
# Re-executar sanitização
.\tools\publish-github.ps1 -Force
```

### Erro: "module not found"

**Causa:** Dependências não encontradas após sanitização

**Solução:**
```powershell
go clean -modcache
go mod tidy
go mod download
```

### Erro: "permission denied" no push

**Causa:** Credenciais do Git incorretas

**Solução:**
```powershell
# Verificar credenciais
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Ou usar token de acesso pessoal (recomendado)
# https://github.com/settings/tokens
```

### Erro: "path contains backslash"

**Causa:** Caminhos Windows não foram sanitizados corretamente

**Solução:**
```powershell
# Verificar arquivos .go com caminhos hardcoded
Get-ChildItem -Recurse -Filter *.go | Select-String -Pattern '[E-Z]:\\'

# Corrigir manualmente ou re-executar sanitização
.\tools\publish-github.ps1 -Force
```

---

## 📚 Arquivos Criados pela Sanitização

| Arquivo | Descrição |
|---------|-----------|
| `.gitignore` | Exclusões do git (seeds/, logs/, go.work) |
| `.github/workflows/ci.yml` | GitHub Actions CI |
| `CONFIG.md` | Documentação de configuração |
| `.env.example` | Exemplo de variáveis de ambiente |
| `seeds/.gitkeep` | Placeholder para diretório seeds |
| `README.md` | Criado se não existir |

---

## 🔄 Rollback (Reverter Sanitização)

Se algo der errado, você pode reverter:

```powershell
# Restaurar do backup
$BACKUP_DIR = (Get-ChildItem backup-pre-publish-* | Sort-Object -Descending | Select-Object -First 1).FullName

Copy-Item "$BACKUP_DIR\go.mod" -Destination . -Force
Copy-Item "$BACKUP_DIR\internal" -Destination . -Recurse -Force
Copy-Item "$BACKUP_DIR\tools" -Destination . -Recurse -Force
Copy-Item "$BACKUP_DIR\docs" -Destination . -Recurse -Force

# Ou usar git reset (se já commitou mas não fez push)
git reset --hard HEAD~1
```

---

## 🎯 Próximos Passos Após Publicação

1. **Configurar GitHub Settings:**
   - Adicionar description: "MCP-Ultra SDK Custom - Go SDK for MCP-Ultra ecosystem"
   - Adicionar topics: `go`, `sdk`, `mcp`, `nats`, `microservices`
   - Habilitar Discussions
   - Configurar branch protection rules para `main`

2. **Documentação:**
   - Revisar README.md
   - Adicionar exemplos de uso
   - Criar wiki (opcional)

3. **CI/CD:**
   - Verificar se GitHub Actions está habilitado
   - Configurar secrets necessários (se houver)
   - Adicionar badges ao README (build status, coverage)

4. **Releases:**
   - Criar release v9.0.0
   - Adicionar changelog
   - Tagear commit

---

## 🤝 Manutenção Futura

Para futuras atualizações:

```powershell
# 1. Fazer alterações
# 2. Re-sanitizar (se necessário)
.\tools\publish-github.ps1

# 3. Commit e push
git add .
git commit -m "feat: your changes"
git push origin main

# 4. Criar release (se nova versão)
git tag -a v9.1.0 -m "Release v9.1.0"
git push origin v9.1.0
```

---

## ✅ Resumo Executivo

**Para publicar rapidamente:**

```powershell
cd E:\vertikon\business\SaaS\templates\mcp-ultra-sdk-custom

# Opção automática (recomendado)
.\tools\git-publish.ps1

# Ou manual
.\tools\publish-github.ps1
git add .
git commit -m "feat: sanitize for GitHub publication (v9.0.0)"
git remote add origin https://github.com/vertikon/mcp-ultra-sdk-custom.git
git push -u origin main
```

**Verificação:**
- Acesse: https://github.com/vertikon/mcp-ultra-sdk-custom
- Clone e compile para validar

---

**Criado em:** 2025-10-05
**Versão:** 1.0.0
**Autor:** Claude Sonnet 4.5 (Autonomous Mode)
**Status:** ✅ Pronto para Publicação
