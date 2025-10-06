// pkg/bootstrap/bootstrap.go
package bootstrap

import (
	"log"

	"github.com/vertikon/mcp-ultra-sdk-custom/pkg/registry"
	"github.com/vertikon/mcp-ultra-sdk-custom/pkg/router"
	"github.com/vertikon/mcp-ultra-sdk-custom/pkg/router/middleware"
)

// Config configura bootstrap
type Config struct {
	EnableRecovery bool
	EnableLogger   bool
	CORSOrigins    []string
}

// Bootstrap inicializa SDK
// - Aplica middlewares globais
// - Registra rotas dos plugins
// - Retorna mux pronto para uso
func Bootstrap(cfg Config) *router.Mux {
	mux := router.NewMux()

	// Health endpoints
	mux.Handle("GET", "/healthz", healthz)
	mux.Handle("GET", "/readyz", readiness)
	mux.Handle("GET", "/health", healthz) // Alias
	mux.Handle("GET", "/ping", healthz)   // Alias

	// Middlewares globais
	if cfg.EnableRecovery {
		mux.Use(middleware.Recovery())
	}
	if cfg.EnableLogger {
		mux.Use(middleware.Logger())
	}
	if len(cfg.CORSOrigins) > 0 {
		mux.Use(middleware.CORS(cfg.CORSOrigins))
	}

	// Middlewares customizados (de plugins)
	for _, mi := range registry.MiddlewareInjectors() {
		log.Printf("Registrando middleware: %s (priority=%d)",
			mi.Name(), mi.Priority())
		mux.Use(mi.Middleware())
	}

	// Rotas de plugins
	for _, ri := range registry.RouteInjectors() {
		log.Printf("Registrando plugin: %s v%s", ri.Name(), ri.Version())

		for _, route := range ri.Routes() {
			log.Printf("  - %s %s", route.Method, route.Path)
			mux.Handle(route.Method, route.Path, route.Handler)
		}
	}

	// Marca como pronto
	MarkReady()

	return mux
}
