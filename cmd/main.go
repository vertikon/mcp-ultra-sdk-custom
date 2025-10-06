package main

import (
	"log/slog"
	"net/http"
	"os"

	"github.com/prometheus/client_golang/prometheus/promhttp"
	"github.com/vertikon/mcp-ultra-sdk-custom/internal/handlers"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	mux := http.NewServeMux()

	// Health handlers
	healthHandler := handlers.NewHealthHandler()
	mux.HandleFunc("/health", healthHandler.Health)
	mux.HandleFunc("/healthz", healthHandler.Livez)
	mux.HandleFunc("/readyz", healthHandler.Readyz)

	// Seed management handlers
	mux.HandleFunc("/seed/sync", handlers.SeedSyncHandler)
	mux.HandleFunc("/seed/status", handlers.SeedStatusHandler)

	// Metrics
	mux.Handle("/metrics", promhttp.Handler())

	addr := ":8080"
	logger.Info("server starting", "addr", addr)
	if err := http.ListenAndServe(addr, logRequest(logger, mux)); err != nil {
		logger.Error("server failed", "err", err)
		os.Exit(1)
	}
}

// logging middleware simples (JSON)
func logRequest(logger *slog.Logger, next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		logger.Info("request", "method", r.Method, "path", r.URL.Path, "ua", r.UserAgent())
		next.ServeHTTP(w, r)
	})
}
