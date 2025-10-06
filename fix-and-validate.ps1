# Script de Correção e Validação do mcp-ultra-sdk-custom
# Data: 2025-10-05
# Objetivo: Remover duplicatas e validar o SDK

$ErrorActionPreference = "Stop"
$projectRoot = "E:\vertikon\business\SaaS\templates\mcp-ultra-sdk-custom"
$validatorPath = "E:\vertikon\.ecosistema-vertikon\mcp-tester-system"
$goExe = "E:\go1.25.0\go\bin\go.exe"

Write-Host "🔧 Iniciando correções do mcp-ultra-sdk-custom..." -ForegroundColor Cyan
Write-Host ""

# Passo 1: Remover arquivos duplicados
Write-Host "📦 Passo 1: Removendo arquivos duplicados..." -ForegroundColor Yellow

$filesToRemove = @(
    "$projectRoot\internal\handlers\health_new.go",
    "$projectRoot\internal\handlers\health_test_new.go",
    "$projectRoot\cmd\main_new.go",
    "$projectRoot\cleanup.ps1"
)

foreach ($file in $filesToRemove) {
    if (Test-Path $file) {
        Remove-Item $file -Force
        Write-Host "  ✅ Removido: $(Split-Path $file -Leaf)" -ForegroundColor Green
    } else {
        Write-Host "  ⏭️  Não encontrado: $(Split-Path $file -Leaf)" -ForegroundColor Gray
    }
}

Write-Host ""

# Passo 2: Formatar código
Write-Host "📝 Passo 2: Formatando código Go..." -ForegroundColor Yellow
Set-Location $projectRoot
& $goExe fmt ./...
Write-Host "  ✅ Código formatado" -ForegroundColor Green
Write-Host ""

# Passo 3: Organizar dependências
Write-Host "📦 Passo 3: Organizando dependências..." -ForegroundColor Yellow
& $goExe mod tidy
Write-Host "  ✅ Dependências organizadas" -ForegroundColor Green
Write-Host ""

# Passo 4: Compilar
Write-Host "🔨 Passo 4: Compilando projeto..." -ForegroundColor Yellow
$buildResult = & $goExe build ./cmd 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✅ Compilação bem-sucedida" -ForegroundColor Green
} else {
    Write-Host "  ❌ Erro na compilação:" -ForegroundColor Red
    Write-Host $buildResult -ForegroundColor Red
    exit 1
}
Write-Host ""

# Passo 5: Executar testes
Write-Host "🧪 Passo 5: Executando testes..." -ForegroundColor Yellow
$testResult = & $goExe test ./internal/handlers -v 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✅ Testes passaram" -ForegroundColor Green
    Write-Host $testResult -ForegroundColor Gray
} else {
    Write-Host "  ⚠️  Alguns testes falharam:" -ForegroundColor Yellow
    Write-Host $testResult -ForegroundColor Yellow
}
Write-Host ""

# Passo 6: Validar com enhanced_validator_v4.go
Write-Host "🔍 Passo 6: Executando validador V4..." -ForegroundColor Yellow
Write-Host "  Validador: $validatorPath\enhanced_validator_v4.go" -ForegroundColor Gray
Write-Host "  Projeto: $projectRoot" -ForegroundColor Gray
Write-Host ""

Set-Location $validatorPath
$validationResult = & $goExe run enhanced_validator_v4.go $projectRoot 2>&1

Write-Host $validationResult
Write-Host ""

# Passo 7: Resumo
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "📊 RESUMO DA EXECUÇÃO" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Arquivos duplicados removidos" -ForegroundColor Green
Write-Host "✅ Código formatado (gofmt)" -ForegroundColor Green
Write-Host "✅ Dependências organizadas (go mod tidy)" -ForegroundColor Green
Write-Host "✅ Compilação bem-sucedida" -ForegroundColor Green
Write-Host "✅ Testes executados" -ForegroundColor Green
Write-Host "✅ Validador V4 executado" -ForegroundColor Green
Write-Host ""

# Passo 8: Instruções finais
Write-Host "🚀 PRÓXIMOS PASSOS:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Iniciar servidor:" -ForegroundColor White
Write-Host "   cd $projectRoot" -ForegroundColor Gray
Write-Host "   go run ./cmd" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Testar endpoints:" -ForegroundColor White
Write-Host "   curl http://localhost:8080/health" -ForegroundColor Gray
Write-Host "   curl http://localhost:8080/metrics" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Revisar relatório de validação acima" -ForegroundColor White
Write-Host ""

Set-Location $projectRoot
