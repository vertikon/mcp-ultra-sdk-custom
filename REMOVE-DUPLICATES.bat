@echo off
echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║   🗑️  REMOVENDO ARQUIVOS DUPLICADOS                     ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

cd /d "E:\vertikon\business\SaaS\templates\mcp-ultra-sdk-custom"

echo 🗑️  Removendo health_new.go...
if exist "internal\handlers\health_new.go" (
    del /F "internal\handlers\health_new.go"
    echo    ✅ Removido: internal\handlers\health_new.go
) else (
    echo    ℹ️  Arquivo não encontrado: health_new.go
)

echo 🗑️  Removendo health_test_new.go...
if exist "internal\handlers\health_test_new.go" (
    del /F "internal\handlers\health_test_new.go"
    echo    ✅ Removido: internal\handlers\health_test_new.go
) else (
    echo    ℹ️  Arquivo não encontrado: health_test_new.go
)

echo 🗑️  Removendo main_new.go...
if exist "cmd\main_new.go" (
    del /F "cmd\main_new.go"
    echo    ✅ Removido: cmd\main_new.go
) else (
    echo    ℹ️  Arquivo não encontrado: main_new.go
)

echo 🗑️  Removendo cleanup.ps1...
if exist "cleanup.ps1" (
    del /F "cleanup.ps1"
    echo    ✅ Removido: cleanup.ps1
) else (
    echo    ℹ️  Arquivo não encontrado: cleanup.ps1
)

echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║                ✅ LIMPEZA CONCLUÍDA                      ║
echo ╚══════════════════════════════════════════════════════════╝
echo.
echo Próximos passos:
echo 1. Compilar: E:\go1.25.0\go\bin\go.exe build .\cmd
echo 2. Testar:   E:\go1.25.0\go\bin\go.exe test .\internal\handlers -v
echo 3. Validar:  cd E:\vertikon\.ecosistema-vertikon\mcp-tester-system
echo              E:\go1.25.0\go\bin\go.exe run enhanced_validator_v4.go E:\vertikon\business\SaaS\templates\mcp-ultra-sdk-custom
echo.
pause
