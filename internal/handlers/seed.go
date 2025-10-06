package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/vertikon/mcp-ultra-sdk-custom/internal/seeds"
)

// SeedSyncRequest representa uma solicitação de sincronização de seed
type SeedSyncRequest struct {
	TemplatePath string `json:"template_path,omitempty"`
}

// SeedSyncResponse representa a resposta de sincronização
type SeedSyncResponse struct {
	Status  string `json:"status"`
	Seed    string `json:"seed,omitempty"`
	Message string `json:"message,omitempty"`
}

// SeedSyncHandler sincroniza o template para a seed interna
func SeedSyncHandler(w http.ResponseWriter, r *http.Request) {
	var req SeedSyncRequest

	// Decodificar request (se houver body)
	if r.Body != nil {
		_ = json.NewDecoder(r.Body).Decode(&req)
	}

	// Usar caminho padrão se não especificado
	if req.TemplatePath == "" {
		req.TemplatePath = `E:\vertikon\business\SaaS\templates\mcp-ultra`
	}

	// Executar sincronização
	err := seeds.Sync(req.TemplatePath)
	if err != nil {
		w.WriteHeader(http.StatusBadGateway)
		w.Header().Set("Content-Type", "application/json")
		resp := SeedSyncResponse{
			Status:  "error",
			Message: err.Error(),
		}
		_ = json.NewEncoder(w).Encode(resp)
		return
	}

	// Sucesso
	w.Header().Set("Content-Type", "application/json")
	resp := SeedSyncResponse{
		Status: "ok",
		Seed:   "seeds/mcp-ultra",
	}
	_ = json.NewEncoder(w).Encode(resp)
}

// SeedStatusHandler retorna o status da seed interna
func SeedStatusHandler(w http.ResponseWriter, r *http.Request) {
	status := seeds.Status()

	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(status)
}
