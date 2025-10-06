# COMMIT CODEQL FIX - Fix CodeQL analysis issue

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   COMMIT CODEQL FIX - Cross-platform Build" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$SDK = "E:\vertikon\business\SaaS\templates\mcp-ultra-sdk-custom"
Set-Location $SDK

Write-Host "Fixing CodeQL analysis issue..." -ForegroundColor Yellow
Write-Host ""

# ----------------------------------------------------------------
# Verificar mudancas
# ----------------------------------------------------------------

Write-Host "[1/4] Verificando arquivos modificados..." -ForegroundColor Yellow

$modifiedFiles = @(
    "internal/seeds/manager.go"
    ".github/workflows/codeql-analysis.yml"
)

foreach ($file in $modifiedFiles) {
    if (Test-Path $file) {
        Write-Host "      [OK] $file" -ForegroundColor Green
    } else {
        Write-Host "      [FALTA] $file" -ForegroundColor Red
    }
}

Write-Host ""

# ----------------------------------------------------------------
# Git add
# ----------------------------------------------------------------

Write-Host "[2/4] Adicionando arquivos..." -ForegroundColor Yellow

git add internal/seeds/manager.go
git add .github/workflows/codeql-analysis.yml

Write-Host "      OK" -ForegroundColor Green
Write-Host ""

# ----------------------------------------------------------------
# Verificar status
# ----------------------------------------------------------------

Write-Host "[3/4] Verificando mudancas..." -ForegroundColor Yellow

$status = git status --short
if ([string]::IsNullOrEmpty($status)) {
    Write-Host "      Nenhuma mudanca para commitar" -ForegroundColor Yellow
} else {
    Write-Host "      Arquivos a serem commitados:" -ForegroundColor Cyan
    git status --short
    Write-Host ""

    # ----------------------------------------------------------------
    # Commit
    # ----------------------------------------------------------------

    Write-Host "[4/4] Criando commit..." -ForegroundColor Yellow

    $commitMsg = @"
fix(codeql): enable cross-platform builds for CodeQL analysis

Changes made to fix CodeQL analysis on Linux:

1. internal/seeds/manager.go
   - Replace Windows-specific robocopy with Go-native file operations
   - Add copyTree() using filepath.Walk for recursive directory copy
   - Add copyFile() using io.Copy for file copying
   - Use portable ignore map instead of hardcoded flags
   - All file operations now work on Linux, macOS, and Windows

2. .github/workflows/codeql-analysis.yml
   - Change from autobuild to build-mode: manual
   - Add explicit build steps with go mod tidy and go build ./...
   - Set CGO_ENABLED=0 for static builds
   - Ensures all packages compile correctly on CI

Issue: CodeQL could not resolve internal/seeds package import
Root Cause: robocopy is Windows-only, CodeQL runs on Linux
Solution: Cross-platform Go code + manual build configuration

CodeQL analysis should now pass successfully on all platforms.
"@

    git commit -m $commitMsg

    if ($LASTEXITCODE -eq 0) {
        Write-Host "      Commit criado" -ForegroundColor Green

        # Push
        Write-Host ""
        Write-Host "      Fazendo push..." -ForegroundColor White
        git push origin main

        if ($LASTEXITCODE -eq 0) {
            Write-Host "      Push realizado" -ForegroundColor Green
        } else {
            Write-Host "      ERRO ao fazer push" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "      ERRO ao criar commit" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "   CODEQL FIX COMPLETO!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""

Write-Host "Mudancas Aplicadas:" -ForegroundColor Cyan
Write-Host "  [OK] internal/seeds/manager.go - Cross-platform file operations" -ForegroundColor Green
Write-Host "  [OK] .github/workflows/codeql-analysis.yml - Manual build mode" -ForegroundColor Green
Write-Host ""

Write-Host "Proximos Passos:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Aguarde CodeQL executar (~5-10 minutos):" -ForegroundColor White
Write-Host "   https://github.com/vertikon/mcp-ultra-sdk-custom/actions" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Verifique se CodeQL passou (verde):" -ForegroundColor White
Write-Host "   - Workflow 'CodeQL' deve mostrar checkmark verde" -ForegroundColor Gray
Write-Host "   - Sem erros de import do internal/seeds" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Continue checklist final:" -ForegroundColor White
Write-Host "   - Resolver vulnerabilidade Dependabot (./FIX-VULNERABILITY.ps1)" -ForegroundColor Gray
Write-Host "   - Criar Release v9.0.0 (CHECKLIST-FINAL.md)" -ForegroundColor Gray
Write-Host ""

Write-Host "================================================" -ForegroundColor Green
Write-Host "   Repositorio pronto para CodeQL!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
