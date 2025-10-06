package seeds

import (
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

const (
	SeedPath = "seeds/mcp-ultra"
)

// StatusInfo contém informações sobre o status da seed
type StatusInfo struct {
	Path        string `json:"path"`
	HasGoMod    bool   `json:"has_go_mod"`
	HasGoSum    bool   `json:"has_go_sum"`
	Compiles    bool   `json:"compiles"`
	MainPresent bool   `json:"main_present"`
	Module      string `json:"module,omitempty"`
}

// Sync sincroniza o template para a seed interna
func Sync(templatePath string) error {
	// 1. Verificar se template existe
	if _, err := os.Stat(templatePath); os.IsNotExist(err) {
		return fmt.Errorf("template não encontrado: %s", templatePath)
	}

	// 2. Criar diretório da seed se não existir
	seedDir := filepath.Dir(SeedPath)
	if err := os.MkdirAll(seedDir, 0755); err != nil {
		return fmt.Errorf("erro ao criar diretório da seed: %w", err)
	}

	// 3. Copiar template → seed (ignorando .git)
	ignore := map[string]bool{
		".git":     true,
		".github":  true,
		".vscode":  true,
		".idea":    true,
		"node_modules": true,
	}

	if err := copyTree(templatePath, SeedPath, ignore); err != nil {
		return fmt.Errorf("erro ao copiar template: %w", err)
	}

	// 4. Ajustar go.mod da seed
	gomodPath := filepath.Join(SeedPath, "go.mod")
	if err := adjustGoMod(gomodPath); err != nil {
		return fmt.Errorf("erro ao ajustar go.mod: %w", err)
	}

	// 5. Adicionar replaces
	if err := addReplaces(gomodPath); err != nil {
		return fmt.Errorf("erro ao adicionar replaces: %w", err)
	}

	// 6. go mod tidy
	if err := runGoModTidy(); err != nil {
		return fmt.Errorf("erro em go mod tidy: %w", err)
	}

	return nil
}

// Status retorna informações sobre o estado da seed
func Status() StatusInfo {
	info := StatusInfo{
		Path: SeedPath,
	}

	// Verificar go.mod
	gomodPath := filepath.Join(SeedPath, "go.mod")
	if _, err := os.Stat(gomodPath); err == nil {
		info.HasGoMod = true

		// Tentar ler module name
		if data, err := os.ReadFile(gomodPath); err == nil {
			lines := strings.Split(string(data), "\n")
			for _, line := range lines {
				if strings.HasPrefix(strings.TrimSpace(line), "module ") {
					info.Module = strings.TrimSpace(strings.TrimPrefix(strings.TrimSpace(line), "module "))
					break
				}
			}
		}
	}

	// Verificar go.sum
	if _, err := os.Stat(filepath.Join(SeedPath, "go.sum")); err == nil {
		info.HasGoSum = true
	}

	// Verificar cmd/main.go
	mainPath := filepath.Join(SeedPath, "cmd", "main.go")
	if _, err := os.Stat(mainPath); err == nil {
		info.MainPresent = true
	}

	// Tentar compilar (teste rápido)
	cmd := exec.Command("go", "build", "./cmd")
	cmd.Dir = SeedPath
	if err := cmd.Run(); err == nil {
		info.Compiles = true
	}

	return info
}

// copyTree copia recursivamente de src para dst, ignorando diretórios especificados
func copyTree(src, dst string, ignore map[string]bool) error {
	return filepath.Walk(src, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		// Calcular caminho relativo
		rel, err := filepath.Rel(src, path)
		if err != nil {
			return err
		}

		// Ignorar diretórios marcados
		base := filepath.Base(path)
		if ignore[base] {
			if info.IsDir() {
				return filepath.SkipDir
			}
			return nil
		}

		// Caminho de destino
		target := filepath.Join(dst, rel)

		// Se é diretório, criar
		if info.IsDir() {
			return os.MkdirAll(target, 0755)
		}

		// Se é arquivo, copiar
		return copyFile(path, target)
	})
}

// copyFile copia um arquivo de src para dst
func copyFile(src, dst string) error {
	// Abrir arquivo fonte
	in, err := os.Open(src)
	if err != nil {
		return err
	}
	defer in.Close()

	// Criar diretório de destino se necessário
	if err := os.MkdirAll(filepath.Dir(dst), 0755); err != nil {
		return err
	}

	// Criar arquivo destino
	out, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer func() { _ = out.Close() }()

	// Copiar conteúdo
	if _, err := io.Copy(out, in); err != nil {
		return err
	}

	// Sync para garantir escrita
	return out.Sync()
}

// adjustGoMod ajusta o module name no go.mod
func adjustGoMod(gomodPath string) error {
	data, err := os.ReadFile(gomodPath)
	if err != nil {
		return fmt.Errorf("erro ao ler go.mod: %w", err)
	}

	content := string(data)
	lines := strings.Split(content, "\n")

	// Substituir linha do module
	for i, line := range lines {
		if strings.HasPrefix(strings.TrimSpace(line), "module ") {
			lines[i] = "module seeds/mcp-ultra"
			break
		}
	}

	newContent := strings.Join(lines, "\n")

	if err := os.WriteFile(gomodPath, []byte(newContent), 0644); err != nil {
		return fmt.Errorf("erro ao escrever go.mod: %w", err)
	}

	return nil
}

// addReplaces adiciona replaces ao go.mod
func addReplaces(gomodPath string) error {
	// Caminhos relativos (portável para Linux/Windows)
	sdkPath := "../.."
	fixPath := "../../../../.ecosistema-vertikon/shared/mcp-ultra-fix"

	replaces := fmt.Sprintf("\nreplace github.com/vertikon/mcp-ultra-sdk-custom => %s\nreplace github.com/vertikon/mcp-ultra-fix => %s\n", sdkPath, fixPath)

	f, err := os.OpenFile(gomodPath, os.O_APPEND|os.O_WRONLY, 0644)
	if err != nil {
		return fmt.Errorf("erro ao abrir go.mod: %w", err)
	}
	defer f.Close()

	if _, err := f.WriteString(replaces); err != nil {
		return fmt.Errorf("erro ao escrever replaces: %w", err)
	}

	return nil
}

// runGoModTidy executa go mod tidy na seed
func runGoModTidy() error {
	cmd := exec.Command("go", "mod", "tidy")
	cmd.Dir = SeedPath

	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("go mod tidy failed: %v\n%s", err, string(output))
	}

	return nil
}
