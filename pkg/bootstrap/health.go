// pkg/bootstrap/health.go
package bootstrap

import (
	"net/http"
	"sync/atomic"
)

var ready atomic.Bool

// MarkReady marca aplicação como pronta
func MarkReady() {
	ready.Store(true)
}

// MarkNotReady marca aplicação como não-pronta
func MarkNotReady() {
	ready.Store(false)
}

// healthz é o endpoint de liveness
func healthz(w http.ResponseWriter, _ *http.Request) {
	w.WriteHeader(200)
	w.Write([]byte("ok"))
}

// readiness é o endpoint de readiness
func readiness(w http.ResponseWriter, _ *http.Request) {
	if !ready.Load() {
		w.WriteHeader(503)
		w.Write([]byte("not ready"))
		return
	}
	w.WriteHeader(200)
	w.Write([]byte("ready"))
}
