// pkg/registry/registry.go
package registry

import (
	"fmt"
	"sort"
	"sync"

	"github.com/vertikon/mcp-ultra-sdk-custom/pkg/contracts"
)

// Registry gerencia plugins registrados com tipos segregados
type Registry struct {
	mu          sync.RWMutex
	routes      map[string]contracts.RouteInjector
	middlewares map[string]contracts.MiddlewareInjector
	jobs        map[string]contracts.Job
	services    map[string]contracts.Service
}

var global = &Registry{
	routes:      map[string]contracts.RouteInjector{},
	middlewares: map[string]contracts.MiddlewareInjector{},
	jobs:        map[string]contracts.Job{},
	services:    map[string]contracts.Service{},
}

// Register adiciona plugin(s) ao registry
// Um pacote pode implementar vários contratos
func Register(name string, plugin any) error {
	global.mu.Lock()
	defer global.mu.Unlock()

	registered := false

	// Cada capability pode coexistir sob o mesmo "name"
	if ri, ok := plugin.(contracts.RouteInjector); ok {
		if _, exists := global.routes[name]; exists {
			return fmt.Errorf("route plugin %s já registrado", name)
		}
		global.routes[name] = ri
		registered = true
	}

	if mi, ok := plugin.(contracts.MiddlewareInjector); ok {
		if _, exists := global.middlewares[name]; exists {
			return fmt.Errorf("middleware plugin %s já registrado", name)
		}
		global.middlewares[name] = mi
		registered = true
	}

	if j, ok := plugin.(contracts.Job); ok {
		if _, exists := global.jobs[name]; exists {
			return fmt.Errorf("job %s já registrado", name)
		}
		global.jobs[name] = j
		registered = true
	}

	if s, ok := plugin.(contracts.Service); ok {
		if _, exists := global.services[name]; exists {
			return fmt.Errorf("service %s já registrado", name)
		}
		global.services[name] = s
		registered = true
	}

	if !registered {
		return fmt.Errorf("plugin %s não implementa nenhum contrato conhecido", name)
	}

	return nil
}

// RouteInjectors retorna todos plugins de rota
func RouteInjectors() []contracts.RouteInjector {
	global.mu.RLock()
	defer global.mu.RUnlock()

	var injectors []contracts.RouteInjector
	for _, ri := range global.routes {
		injectors = append(injectors, ri)
	}
	return injectors
}

// MiddlewareInjectors retorna middlewares ordenados por prioridade
func MiddlewareInjectors() []contracts.MiddlewareInjector {
	global.mu.RLock()
	defer global.mu.RUnlock()

	var injectors []contracts.MiddlewareInjector
	for _, mi := range global.middlewares {
		injectors = append(injectors, mi)
	}

	// Sort por prioridade (menor = primeiro)
	sort.Slice(injectors, func(i, j int) bool {
		return injectors[i].Priority() < injectors[j].Priority()
	})

	return injectors
}

// Jobs retorna todos jobs registrados
func Jobs() []contracts.Job {
	global.mu.RLock()
	defer global.mu.RUnlock()

	var jobs []contracts.Job
	for _, j := range global.jobs {
		jobs = append(jobs, j)
	}
	return jobs
}

// Services retorna serviços customizados
func Services() []contracts.Service {
	global.mu.RLock()
	defer global.mu.RUnlock()

	var services []contracts.Service
	for _, s := range global.services {
		services = append(services, s)
	}
	return services
}

// Reset limpa o registry (para testes)
func Reset() {
	global.mu.Lock()
	defer global.mu.Unlock()

	global.routes = map[string]contracts.RouteInjector{}
	global.middlewares = map[string]contracts.MiddlewareInjector{}
	global.jobs = map[string]contracts.Job{}
	global.services = map[string]contracts.Service{}
}
