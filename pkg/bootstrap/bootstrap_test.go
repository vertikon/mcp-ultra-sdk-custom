package bootstrap

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestBootstrap(t *testing.T) {
	config := Config{
		EnableRecovery: true,
		EnableLogger:   true,
		CORSOrigins:    []string{"*"},
	}

	mux := Bootstrap(config)

	if mux == nil {
		t.Fatal("Bootstrap returned nil mux")
	}
}

func TestBootstrapMinimal(t *testing.T) {
	config := Config{}

	mux := Bootstrap(config)

	if mux == nil {
		t.Fatal("Bootstrap with minimal config returned nil mux")
	}
}

func TestMarkReady(t *testing.T) {
	MarkNotReady()

	if ready.Load() {
		t.Error("Expected ready to be false after MarkNotReady")
	}

	MarkReady()

	if !ready.Load() {
		t.Error("Expected ready to be true after MarkReady")
	}
}

func TestHealthzEndpoint(t *testing.T) {
	req := httptest.NewRequest("GET", "/healthz", nil)
	w := httptest.NewRecorder()

	healthz(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("Expected status 200, got %d", w.Code)
	}

	if w.Body.String() != "ok" {
		t.Errorf("Expected body 'ok', got '%s'", w.Body.String())
	}
}

func TestReadinessEndpoint(t *testing.T) {
	// Test not ready
	MarkNotReady()
	req := httptest.NewRequest("GET", "/readyz", nil)
	w := httptest.NewRecorder()

	readiness(w, req)

	if w.Code != http.StatusServiceUnavailable {
		t.Errorf("Expected status 503 when not ready, got %d", w.Code)
	}

	// Test ready
	MarkReady()
	req = httptest.NewRequest("GET", "/readyz", nil)
	w = httptest.NewRecorder()

	readiness(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("Expected status 200 when ready, got %d", w.Code)
	}
}
