// pkg/bootstrap/health.go
package bootstrap

import (
	"log"
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
	if _, err := w.Write([]byte("ok")); err != nil {
		log.Printf("Error writing healthz response: %v", err)
	}
}

// readiness é o endpoint de readiness
func readiness(w http.ResponseWriter, _ *http.Request) {
	if !ready.Load() {
		w.WriteHeader(503)
		if _, err := w.Write([]byte("not ready")); err != nil {
			log.Printf("Error writing readiness not-ready response: %v", err)
		}
		return
	}
	w.WriteHeader(200)
	if _, err := w.Write([]byte("ready")); err != nil {
		log.Printf("Error writing readiness ready response: %v", err)
	}
}
