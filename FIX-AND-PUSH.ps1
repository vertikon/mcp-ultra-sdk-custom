# FIX AND PUSH - Remove arquivo problemático e publica

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   FIX AND PUSH" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Ir para o diretorio do SDK
$SDK = "E:\vertikon\business\SaaS\templates\mcp-ultra-sdk-custom"
Set-Location $SDK

# Remover .git anterior (se existir)
Write-Host "[1/8] Limpando git anterior..." -ForegroundColor Yellow
if (Test-Path ".git") {
    Remove-Item -Path ".git" -Recurse -Force
    Write-Host "      OK - Git removido" -ForegroundColor Green
} else {
    Write-Host "      OK - Nenhum git anterior" -ForegroundColor Green
}

# Remover arquivo 'nul' problemático
Write-Host "[2/8] Removendo arquivo 'nul' (reservado Windows)..." -ForegroundColor Yellow
if (Test-Path "nul") {
    try {
        Remove-Item -Path "nul" -Force -ErrorAction SilentlyContinue
        Write-Host "      OK - Arquivo nul removido" -ForegroundColor Green
    } catch {
        Write-Host "      Arquivo nul nao pode ser removido (pode nao existir)" -ForegroundColor Yellow
    }
} else {
    Write-Host "      OK - Arquivo nul nao existe" -ForegroundColor Green
}

# Criar/atualizar .gitignore
Write-Host "[3/8] Criando .gitignore..." -ForegroundColor Yellow
$gitignoreContent = @"
# Binaries
*.exe
*.dll
*.so
*.dylib
cmd/cmd
cmd/cmd.exe

# Test binaries
*.test
*.out

# Go workspace
go.work
go.work.sum

# Seeds (local copies)
seeds/
!seeds/.gitkeep

# Logs
logs/
*.log

# Backups
backup-*/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db
nul

# Environment
.env
.env.local

# Temporary
tmp/
temp/
"@

Set-Content -Path ".gitignore" -Value $gitignoreContent
Write-Host "      OK" -ForegroundColor Green

# Inicializar git
Write-Host "[4/8] Inicializando git..." -ForegroundColor Yellow
git init
git branch -M main
Write-Host "      OK" -ForegroundColor Green

# Criar README se nao existir
Write-Host "[5/8] Verificando README.md..." -ForegroundColor Yellow
if (-not (Test-Path "README.md")) {
    $readme = @"
# mcp-ultra-sdk-custom

**Versao:** 9.0.0
**Status:** ULTRA VERIFIED CERTIFIED

MCP-Ultra SDK Custom - Go SDK completo para o ecossistema MCP-Ultra.

## Quick Start

``````bash
git clone https://github.com/vertikon/mcp-ultra-sdk-custom.git
cd mcp-ultra-sdk-custom
go mod download
go build ./cmd
./cmd
``````

Servidor inicia em http://localhost:8080

## Endpoints

- GET /health - Health check
- GET /metrics - Prometheus metrics
- POST /seed/sync - Sincronizar seed
- GET /seed/status - Status da seed

## Documentacao

- [CONFIG.md](CONFIG.md) - Configuracao
- [docs/](docs/) - Documentacao completa

---

Desenvolvido por Vertikon Team
"@
    Set-Content -Path "README.md" -Value $readme
    Write-Host "      README.md criado" -ForegroundColor Green
} else {
    Write-Host "      README.md ja existe" -ForegroundColor Green
}

# Git add
Write-Host "[6/8] Adicionando arquivos..." -ForegroundColor Yellow
git add .

if ($LASTEXITCODE -ne 0) {
    Write-Host "      ERRO ao adicionar arquivos" -ForegroundColor Red
    Write-Host ""
    Write-Host "Tente manualmente:" -ForegroundColor Yellow
    Write-Host "  git add ." -ForegroundColor White
    exit 1
}

Write-Host "      OK" -ForegroundColor Green

# Mostrar status
Write-Host ""
Write-Host "Arquivos a serem commitados:" -ForegroundColor Cyan
git status --short | Select-Object -First 30
Write-Host ""

# Commit
Write-Host "[7/8] Criando commit..." -ForegroundColor Yellow
git commit -m "feat: mcp-ultra-sdk-custom v9.0.0 - initial release"

if ($LASTEXITCODE -ne 0) {
    Write-Host "      ERRO no commit" -ForegroundColor Red
    exit 1
}

Write-Host "      OK" -ForegroundColor Green

# Remote e Push
Write-Host "[8/8] Configurando remote e fazendo push..." -ForegroundColor Yellow
git remote add origin https://github.com/vertikon/mcp-ultra-sdk-custom.git

Write-Host ""
Write-Host "Fazendo push para GitHub..." -ForegroundColor White
Write-Host ""

git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "   SUCESSO! Publicado no GitHub" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "URL: https://github.com/vertikon/mcp-ultra-sdk-custom" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Proximos passos:" -ForegroundColor Yellow
    Write-Host "  1. Acesse o repositorio no GitHub" -ForegroundColor White
    Write-Host "  2. Configure Settings > Description e Topics" -ForegroundColor White
    Write-Host "  3. Habilite GitHub Actions (se necessario)" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Red
    Write-Host "   ERRO NO PUSH" -ForegroundColor Red
    Write-Host "================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Possiveis causas:" -ForegroundColor Yellow
    Write-Host "  1. Repositorio nao existe no GitHub" -ForegroundColor White
    Write-Host "     Crie em: https://github.com/new" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  2. Credenciais nao configuradas" -ForegroundColor White
    Write-Host "     Configure: git config --global user.name 'Seu Nome'" -ForegroundColor Gray
    Write-Host "                git config --global user.email 'seu@email.com'" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  3. Sem permissao para push" -ForegroundColor White
    Write-Host "     Use Personal Access Token" -ForegroundColor Gray
    Write-Host "     https://github.com/settings/tokens" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Depois de resolver, execute novamente:" -ForegroundColor Yellow
    Write-Host "  .\FIX-AND-PUSH.ps1" -ForegroundColor White
    Write-Host ""
}
