# 🛠️ Tools - Scripts de Integração e Automação

**Versão:** 1.0.0
**SDK:** mcp-ultra-sdk-custom v9.0.0

---

## 📋 Scripts Disponíveis

### 1. `setup-go-work.ps1`
**Finalidade:** Cria/atualiza go.work para workspace unificado

**Uso:**
```powershell
.\tools\setup-go-work.ps1
```

**O que faz:**
- Cria go.work na raiz do Vertikon
- Adiciona 3 módulos ao workspace:
  - mcp-ultra-fix
  - mcp-ultra (template)
  - mcp-ultra-sdk-custom
- Executa `go work sync`

---

### 2. `seed-sync.ps1`
**Finalidade:** Sincroniza template mcp-ultra como seed interna do SDK

**Uso:**
```powershell
# Usar caminho padrão
.\tools\seed-sync.ps1

# Especificar caminho do template
.\tools\seed-sync.ps1 -TemplatePath "E:\custom\path\mcp-ultra"

# Forçar sincronização (sobrescrever)
.\tools\seed-sync.ps1 -Force
```

**O que faz:**
1. Espelha template → `seeds/mcp-ultra` (via robocopy)
2. Ajusta module name para `seeds/mcp-ultra`
3. Adiciona replaces para SDK e FIX
4. Executa `go mod tidy`
5. Valida integridade

**Saída:**
- Seed em: `E:\vertikon\business\SaaS\templates\mcp-ultra-sdk-custom\seeds\mcp-ultra`

---

### 3. `seed-run.ps1`
**Finalidade:** Executa SDK + Seed simultaneamente

**Uso:**
```powershell
# Executar ambos (padrão)
.\tools\seed-run.ps1

# Apenas SDK
.\tools\seed-run.ps1 -SDKOnly

# Apenas Seed
.\tools\seed-run.ps1 -SeedOnly

# Portas customizadas
.\tools\seed-run.ps1 -SDKPort 9000 -SeedPort 9001
```

**O que faz:**
- Inicia SDK na porta 8080 (padrão)
- Inicia Seed na porta 8081 (padrão)
- Abre janelas separadas do PowerShell
- Verifica se portas estão em uso

**Endpoints SDK:**
- `http://localhost:8080/health`
- `http://localhost:8080/healthz`
- `http://localhost:8080/readyz`
- `http://localhost:8080/metrics`
- `http://localhost:8080/seed/sync`
- `http://localhost:8080/seed/status`

---

### 4. `integracao-full.ps1` ⭐
**Finalidade:** **Script master** de integração completa

**Uso:**
```powershell
# Execução completa (recomendado)
.\tools\integracao-full.ps1

# Pular fases específicas
.\tools\integracao-full.ps1 -SkipGoWork
.\tools\integracao-full.ps1 -SkipSync
.\tools\integracao-full.ps1 -SkipTest
.\tools\integracao-full.ps1 -SkipRun

# Modo verbose
.\tools\integracao-full.ps1 -Verbose
```

**O que faz (5 fases):**

#### FASE 1: Setup go.work
- Executa `setup-go-work.ps1`
- Cria workspace unificado

#### FASE 2: Sincronização de Seed
- Executa `seed-sync.ps1`
- Espelha template para seed

#### FASE 3: Compilação e Testes
- Compila SDK
- Executa testes unitários
- Compila Seed (se possível)

#### FASE 4: Auditoria via HTTP
- Inicia servidor SDK (background)
- Testa endpoint `/health`
- Testa endpoint `/seed/status`
- Gera relatório de auditoria JSON
- Para servidor

#### FASE 5: Validação Final
- Executa Enhanced Validator V4
- Gera relatório de validação

**Logs gerados:**
- `logs/integracao-YYYYMMDD-HHMMSS.log` - Log principal
- `logs/audit-report-YYYYMMDD-HHMMSS.json` - Auditoria HTTP
- `logs/validator-YYYYMMDD-HHMMSS.log` - Validação V4

---

## 🚀 Fluxo de Uso Recomendado

### Primeira Vez (Setup Inicial)

```powershell
# 1. Setup do workspace
.\tools\setup-go-work.ps1

# 2. Sincronizar seed
.\tools\seed-sync.ps1

# 3. Executar integração completa
.\tools\integracao-full.ps1
```

### Uso Diário (Desenvolvimento)

```powershell
# Sincronizar seed (se template foi atualizado)
.\tools\seed-sync.ps1

# Executar SDK + Seed
.\tools\seed-run.ps1
```

### Antes de Commit/Deploy

```powershell
# Validação completa
.\tools\integracao-full.ps1
```

---

## 📊 Endpoints de Seed Management

O SDK expõe 2 endpoints para gerenciar a seed:

### `POST /seed/sync`
Sincroniza o template para a seed interna

**Request:**
```json
{
  "template_path": "E:\\vertikon\\business\\SaaS\\templates\\mcp-ultra"
}
```

**Response (Sucesso):**
```json
{
  "status": "ok",
  "seed": "seeds/mcp-ultra"
}
```

**Response (Erro):**
```json
{
  "status": "error",
  "message": "template não encontrado: ..."
}
```

**Exemplo:**
```powershell
$body = @{ template_path = "E:\vertikon\business\SaaS\templates\mcp-ultra" } | ConvertTo-Json
Invoke-RestMethod -Uri http://localhost:8080/seed/sync -Method POST -Body $body -ContentType "application/json"
```

---

### `GET /seed/status`
Retorna o status da seed interna

**Response:**
```json
{
  "path": "E:\\vertikon\\business\\SaaS\\templates\\mcp-ultra-sdk-custom\\seeds\\mcp-ultra",
  "has_go_mod": true,
  "has_go_sum": true,
  "compiles": true,
  "main_present": true,
  "module": "seeds/mcp-ultra"
}
```

**Exemplo:**
```powershell
Invoke-RestMethod -Uri http://localhost:8080/seed/status -Method GET
```

---

## 🔧 Configuração

### Caminhos Padrão

Todos os scripts usam os seguintes caminhos padrão:

```powershell
$SDK = "E:\vertikon\business\SaaS\templates\mcp-ultra-sdk-custom"
$TPL = "E:\vertikon\business\SaaS\templates\mcp-ultra"
$FIX = "E:\vertikon\.ecosistema-vertikon\shared\mcp-ultra-fix"
$SEED = "$SDK\seeds\mcp-ultra"
```

Para customizar, edite os scripts ou passe parâmetros.

---

## 🐛 Troubleshooting

### Erro: "Template não encontrado"

**Causa:** Caminho do template incorreto

**Solução:**
```powershell
.\tools\seed-sync.ps1 -TemplatePath "E:\seu\caminho\mcp-ultra"
```

---

### Erro: "Porta já em uso"

**Causa:** SDK ou Seed já está rodando

**Solução:**
```powershell
# Verificar processos
Get-Process | Where-Object {$_.ProcessName -like "*go*"}

# Ou usar porta diferente
.\tools\seed-run.ps1 -SDKPort 9000 -SeedPort 9001
```

---

### Erro: "go.work não encontrado"

**Causa:** Workspace não foi criado

**Solução:**
```powershell
.\tools\setup-go-work.ps1
```

---

### Erro: "robocopy failed"

**Causa:** Permissões ou template inacessível

**Solução:**
1. Executar PowerShell como Administrador
2. Verificar se template existe
3. Verificar permissões de arquivo

---

## 📚 Documentação Relacionada

- `../docs/INTEGRACAO_ORQUESTRADOR.md` - Especificação de integração
- `../docs/INTEGRACAO_STATUS.md` - Status de preparação
- `../docs/NATS_SUBJECTS.md` - Subjects NATS
- `../README.md` - Documentação principal do SDK

---

## 🔄 Automação (Agendador)

Para sincronização automática diária:

### Windows Task Scheduler

```powershell
# Criar task
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-File E:\vertikon\business\SaaS\templates\mcp-ultra-sdk-custom\tools\seed-sync.ps1"

$trigger = New-ScheduledTaskTrigger -Daily -At 3am

Register-ScheduledTask -TaskName "MCP-Ultra-Seed-Sync" `
    -Action $action -Trigger $trigger -Description "Sincronização diária da seed mcp-ultra"
```

---

## ✅ Checklist de Validação

Após executar `integracao-full.ps1`:

- [ ] ✅ go.work criado em `E:\vertikon\go.work`
- [ ] ✅ Seed em `seeds/mcp-ultra`
- [ ] ✅ Seed compila sem erros
- [ ] ✅ SDK compila sem erros
- [ ] ✅ Testes passando (3/3)
- [ ] ✅ `/health` retorna `{"status":"ok"}`
- [ ] ✅ `/seed/status` retorna informações corretas
- [ ] ✅ Validador V4 aprova (score >= 85%)
- [ ] ✅ Logs gerados em `logs/`

---

**Criado em:** 2025-10-05
**Versão:** 1.0.0
**Autor:** Claude Sonnet 4.5 (Autonomous Mode)
