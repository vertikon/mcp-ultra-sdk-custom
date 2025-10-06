# Quick Start - Publicar no GitHub

## PROBLEMA DETECTADO

Os scripts `integracao-full.ps1` e `git-publish.ps1` tinham caracteres Unicode que causavam erros no PowerShell.

## SOLUCAO

Foram criados scripts corrigidos:

### 1. quick-push.ps1 (MAIS SIMPLES - RECOMENDADO)

Script minimalista que faz apenas git add/commit/push SEM sanitizacao.

**Uso:**
```powershell
cd E:\vertikon\business\SaaS\templates\mcp-ultra-sdk-custom
.\tools\quick-push.ps1
```

**O que faz:**
1. Inicializa git (se necessario)
2. Cria branch main
3. Cria README.md basico (se nao existir)
4. git add .
5. Mostra status e pede confirmacao
6. git commit
7. Adiciona remote (se necessario)
8. git push -u origin main

**AVISO:** Este script NAO remove caminhos internos (E:\vertikon\...). Use apenas se quiser publicar como esta.

---

### 2. git-publish-fixed.ps1 (COM SANITIZACAO)

Script completo que sanitiza E depois faz push.

**Uso:**
```powershell
cd E:\vertikon\business\SaaS\templates\mcp-ultra-sdk-custom
.\tools\git-publish-fixed.ps1
```

**O que faz:**
1. Executa publish-github.ps1 (sanitiza caminhos)
2. Verifica git
3. Cria README.md completo
4. git add/commit
5. git push

---

## RECOMENDACAO

### SE VOCE QUER PUBLICAR RAPIDAMENTE (SEM SANITIZAR):

```powershell
cd E:\vertikon\business\SaaS\templates\mcp-ultra-sdk-custom

# Script rapido
.\tools\quick-push.ps1
```

### SE VOCE QUER SANITIZAR ANTES (REMOVER CAMINHOS E:\vertikon):

**PASSO 1:** Execute integracao-full.ps1 (corrigido)
```powershell
cd E:\vertikon\business\SaaS\templates\mcp-ultra-sdk-custom
.\tools\integracao-full.ps1
```

**PASSO 2:** Publique com git-publish-fixed.ps1
```powershell
.\tools\git-publish-fixed.ps1
```

---

## CORRECOES APLICADAS

### integracao-full.ps1
- Removido emoji `⏭️` das mensagens
- Trocado `--SkipGoWork` por `-SkipGoWork` (sem duplo hifen)
- Mantem todas as funcionalidades

### git-publish.ps1
- Criada versao `git-publish-fixed.ps1`
- Sem caracteres Unicode problematicos
- Sem emojis
- Mensagens ASCII puras

### quick-push.ps1 (NOVO)
- Script minimalista
- Sem sanitizacao
- Apenas git operations
- Perfeito para testes rapidos

---

## COMANDOS GIT MANUAIS (SE PREFERIR)

Se os scripts ainda derem problema, execute manualmente:

```powershell
cd E:\vertikon\business\SaaS\templates\mcp-ultra-sdk-custom

# 1. Init git
git init

# 2. Criar README basico
echo "# mcp-ultra-sdk-custom" > README.md

# 3. Add e commit
git add .
git commit -m "feat: initial commit mcp-ultra-sdk-custom v9.0.0"

# 4. Branch main
git branch -M main

# 5. Remote
git remote add origin https://github.com/vertikon/mcp-ultra-sdk-custom.git

# 6. Push
git push -u origin main
```

---

## STATUS DOS SCRIPTS

| Script | Status | Recomendacao |
|--------|--------|--------------|
| `integracao-full.ps1` | CORRIGIDO | Use para testes completos |
| `git-publish.ps1` | ERRO (Unicode) | NAO USE |
| `git-publish-fixed.ps1` | CORRIGIDO | Use para publicacao com sanitizacao |
| `quick-push.ps1` | NOVO (OK) | Use para publicacao rapida sem sanitizacao |
| `publish-github.ps1` | OK | Use separadamente para sanitizar |

---

## TESTE RAPIDO AGORA

Execute este comando AGORA:

```powershell
cd E:\vertikon\business\SaaS\templates\mcp-ultra-sdk-custom
.\tools\quick-push.ps1
```

Ele vai:
1. Mostrar os arquivos que serao commitados
2. Pedir confirmacao (S/N)
3. Se confirmar, faz commit e push
4. Mostra URL do repositorio

**Tempo estimado:** 30 segundos

---

## PROXIMOS PASSOS APOS PUSH

1. Acesse: https://github.com/vertikon/mcp-ultra-sdk-custom
2. Configure GitHub Settings
3. Habilite GitHub Actions
4. Adicione description e topics

---

**Criado:** 2025-10-05
**Versao:** 1.0.0
**Status:** Scripts corrigidos e prontos para uso
