# PUSH - Script simplificado para publicar no GitHub
# Coloque na raiz do projeto e execute: .\PUSH.ps1

param(
    [string]$Org = "vertikon",
    [string]$Repo = "mcp-ultra-sdk-custom"
)

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   PUBLICACAO GITHUB" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se e repo git
if (-not (Test-Path ".git")) {
    Write-Host "[1/6] Inicializando git..." -ForegroundColor Yellow
    git init
    Write-Host "      OK" -ForegroundColor Green
} else {
    Write-Host "[1/6] Git ja inicializado" -ForegroundColor Green
}

# Branch main
Write-Host "[2/6] Configurando branch main..." -ForegroundColor Yellow
$branch = git branch --show-current 2>$null
if ([string]::IsNullOrEmpty($branch)) {
    git checkout -b main
} else {
    git branch -M main 2>$null
}
Write-Host "      OK" -ForegroundColor Green

# README
if (-not (Test-Path "README.md")) {
    Write-Host "[3/6] Criando README.md..." -ForegroundColor Yellow
    "# $Repo`n`nMCP-Ultra SDK Custom v9.0.0" | Out-File -FilePath "README.md" -Encoding UTF8
    Write-Host "      OK" -ForegroundColor Green
} else {
    Write-Host "[3/6] README.md existe" -ForegroundColor Green
}

# Add
Write-Host "[4/6] Adicionando arquivos..." -ForegroundColor Yellow
git add .
Write-Host "      OK" -ForegroundColor Green

# Status
Write-Host ""
Write-Host "Arquivos a commitar:" -ForegroundColor Cyan
git status --short | Select-Object -First 20
Write-Host ""

# Commit
Write-Host "[5/6] Criando commit..." -ForegroundColor Yellow
git commit -m "feat: mcp-ultra-sdk-custom v9.0.0" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "      OK" -ForegroundColor Green
} else {
    Write-Host "      Nada para commitar ou ja commitado" -ForegroundColor Yellow
}

# Remote
$remote = git remote get-url origin 2>$null
if ([string]::IsNullOrEmpty($remote)) {
    git remote add origin "https://github.com/$Org/$Repo.git"
    Write-Host "      Remote adicionado" -ForegroundColor Green
}

# Push
Write-Host "[6/6] Fazendo push..." -ForegroundColor Yellow
Write-Host ""
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "   SUCESSO!" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "URL: https://github.com/$Org/$Repo" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "ERRO no push" -ForegroundColor Red
    Write-Host ""
    Write-Host "Verifique:" -ForegroundColor Yellow
    Write-Host "  1. Repositorio existe no GitHub" -ForegroundColor White
    Write-Host "  2. Credenciais configuradas" -ForegroundColor White
    Write-Host ""
}
