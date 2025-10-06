# CORREÇÃO FINAL - mcp-ultra-sdk-custom
# Remove arquivos duplicados e valida o projeto

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   🔧 CORREÇÃO FINAL - mcp-ultra-sdk-custom             ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$projectRoot = "E:\vertikon\business\SaaS\templates\mcp-ultra-sdk-custom"
Set-Location $projectRoot

# 1. Remover arquivo duplicado BLOQUEADOR
Write-Host "🗑️  Removendo arquivo duplicado (BLOQUEADOR)..." -ForegroundColor Yellow
$blocker = "internal\handlers\health_new.go"
if (Test-Path $blocker) {
    Remove-Item $blocker -Force
    Write-Host "   ✅ Removido: $blocker" -ForegroundColor Green
} else {
    Write-Host "   ℹ️  Arquivo já removido: $blocker" -ForegroundColor Gray
}

# 2. Remover outros duplicados
Write-Host ""
Write-Host "🗑️  Removendo outros arquivos duplicados..." -ForegroundColor Yellow
$outros = @(
    "internal\handlers\health_test_new.go",
    "cmd\main_new.go",
    "cleanup.ps1"
)

foreach ($arquivo in $outros) {
    if (Test-Path $arquivo) {
        Remove-Item $arquivo -Force
        Write-Host "   ✅ Removido: $arquivo" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "🔨 Compilando projeto..." -ForegroundColor Yellow
$buildOutput = & "E:\go1.25.0\go\bin\go.exe" build ./cmd 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ COMPILAÇÃO BEM-SUCEDIDA!" -ForegroundColor Green
    Write-Host ""

    Write-Host "🧪 Executando testes..." -ForegroundColor Yellow
    & "E:\go1.25.0\go\bin\go.exe" test ./internal/handlers -v
    Write-Host ""

    Write-Host "🔍 Re-executando validador..." -ForegroundColor Yellow
    Write-Host ""
    Set-Location "E:\vertikon\.ecosistema-vertikon\mcp-tester-system"
    & "E:\go1.25.0\go\bin\go.exe" run enhanced_validator_v4.go $projectRoot

} else {
    Write-Host "   ❌ ERRO NA COMPILAÇÃO:" -ForegroundColor Red
    Write-Host $buildOutput -ForegroundColor Red
}

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                    ✅ CONCLUÍDO                         ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Set-Location $projectRoot
