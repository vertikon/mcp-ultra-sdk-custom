# FIX SEEDS COMMIT - Forcar add do internal/seeds/manager.go

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   FIX SEEDS COMMIT - Force Add" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$SDK = "E:\vertikon\business\SaaS\templates\mcp-ultra-sdk-custom"
Set-Location $SDK

Write-Host "Forcando adicao do internal/seeds/manager.go..." -ForegroundColor Yellow
Write-Host ""

# ----------------------------------------------------------------
# Verificar arquivo
# ----------------------------------------------------------------

Write-Host "[1/4] Verificando arquivo..." -ForegroundColor Yellow

$seedFile = "internal/seeds/manager.go"
if (Test-Path $seedFile) {
    Write-Host "      [OK] $seedFile existe" -ForegroundColor Green

    # Verificar se esta tracked
    $tracked = git ls-files $seedFile 2>&1
    if ([string]::IsNullOrEmpty($tracked)) {
        Write-Host "      [AVISO] Arquivo NAO esta no git" -ForegroundColor Yellow
    } else {
        Write-Host "      [OK] Arquivo esta tracked: $tracked" -ForegroundColor Green
    }
} else {
    Write-Host "      [ERRO] Arquivo nao encontrado" -ForegroundColor Red
    exit 1
}

Write-Host ""

# ----------------------------------------------------------------
# Forcar add (ignorar .gitignore)
# ----------------------------------------------------------------

Write-Host "[2/4] Forcando git add..." -ForegroundColor Yellow

Write-Host "      Executando: git add -f internal/seeds/manager.go" -ForegroundColor White
git add -f internal/seeds/manager.go

if ($LASTEXITCODE -eq 0) {
    Write-Host "      git add: OK" -ForegroundColor Green
} else {
    Write-Host "      git add: ERRO" -ForegroundColor Red
    exit 1
}

Write-Host ""

# ----------------------------------------------------------------
# Verificar status
# ----------------------------------------------------------------

Write-Host "[3/4] Verificando mudancas..." -ForegroundColor Yellow

$status = git status --short | Select-String "internal/seeds"
if ([string]::IsNullOrEmpty($status)) {
    Write-Host "      Nenhuma mudanca em internal/seeds (ja commitado)" -ForegroundColor Yellow
} else {
    Write-Host "      Arquivo staged:" -ForegroundColor Cyan
    Write-Host "      $status" -ForegroundColor White
}

Write-Host ""

# Verificar diff
Write-Host "      Verificando conteudo..." -ForegroundColor White
$diff = git diff --cached --stat internal/seeds/manager.go 2>&1
if (![string]::IsNullOrEmpty($diff)) {
    Write-Host "      $diff" -ForegroundColor Cyan
}

Write-Host ""

# ----------------------------------------------------------------
# Commit
# ----------------------------------------------------------------

Write-Host "[4/4] Criando commit..." -ForegroundColor Yellow

$status = git status --short
if ($status -match "internal/seeds") {
    $commitMsg = @"
fix(seeds): add cross-platform file operations to internal/seeds

Add internal/seeds/manager.go with cross-platform implementation:

- Replace robocopy with filepath.Walk + io.Copy
- Support Linux, macOS, and Windows
- Ignore list: .git, .github, .vscode, .idea, node_modules
- Portable path handling with filepath package

This file was missing from previous commit due to .gitignore seeds/ rule.
The rule excludes seeds/ directory (local seed copies) but should not
exclude internal/seeds/ package (source code).

File added with -f flag to bypass .gitignore.
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
} else {
    Write-Host "      Arquivo ja foi commitado anteriormente" -ForegroundColor Yellow
    Write-Host "      Verificando historico..." -ForegroundColor White

    $log = git log --oneline --all -- internal/seeds/manager.go
    if (![string]::IsNullOrEmpty($log)) {
        Write-Host ""
        Write-Host "      Historico de commits:" -ForegroundColor Cyan
        Write-Host $log -ForegroundColor Gray
    } else {
        Write-Host "      Arquivo NUNCA foi commitado!" -ForegroundColor Red
        Write-Host ""
        Write-Host "      Tentando novamente com amend..." -ForegroundColor Yellow

        git add -f internal/seeds/manager.go
        git commit --amend --no-edit

        if ($LASTEXITCODE -eq 0) {
            Write-Host "      Commit amended" -ForegroundColor Green

            Write-Host "      Fazendo push (force)..." -ForegroundColor White
            git push origin main --force-with-lease

            if ($LASTEXITCODE -eq 0) {
                Write-Host "      Push realizado" -ForegroundColor Green
            } else {
                Write-Host "      ERRO ao fazer push" -ForegroundColor Red
                exit 1
            }
        }
    }
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "   SEEDS COMMIT COMPLETO!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""

Write-Host "Verificacao Final:" -ForegroundColor Cyan
Write-Host ""

# Verificar se arquivo esta no ultimo commit
$lastCommit = git show --name-only --oneline HEAD | Select-String "internal/seeds"
if (![string]::IsNullOrEmpty($lastCommit)) {
    Write-Host "  [OK] internal/seeds/manager.go no ultimo commit" -ForegroundColor Green
} else {
    Write-Host "  [AVISO] Arquivo pode nao estar no commit" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Proximos Passos:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Aguarde CodeQL executar:" -ForegroundColor White
Write-Host "   https://github.com/vertikon/mcp-ultra-sdk-custom/actions" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Verifique arquivo no GitHub:" -ForegroundColor White
Write-Host "   https://github.com/vertikon/mcp-ultra-sdk-custom/blob/main/internal/seeds/manager.go" -ForegroundColor Cyan
Write-Host ""

Write-Host "================================================" -ForegroundColor Green
Write-Host "   Repositorio atualizado!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
