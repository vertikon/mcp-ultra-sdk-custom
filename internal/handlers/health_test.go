package handlers

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestHealthHandler(t *testing.T) {
	handler := NewHealthHandler()
	req := httptest.NewRequest(http.MethodGet, "/health", nil)
	rr := httptest.NewRecorder()
	handler.Health(rr, req)

	if rr.Code != http.StatusOK {
		t.Fatalf("status = %d; want %d", rr.Code, http.StatusOK)
	}
	var p map[string]string
	if err := json.Unmarshal(rr.Body.Bytes(), &p); err != nil {
		t.Fatalf("invalid json: %v", err)
	}
	if p["status"] != "ok" {
		t.Fatalf(`status=%q; want "ok"`, p["status"])
	}
}

func TestHealthHandler_Live(t *testing.T) {
	handler := NewHealthHandler()
	req := httptest.NewRequest(http.MethodGet, "/healthz", nil)
	rr := httptest.NewRecorder()
	handler.Live(rr, req)

	if rr.Code != http.StatusOK {
		t.Fatalf("status = %d; want %d", rr.Code, http.StatusOK)
	}
	var p map[string]string
	if err := json.Unmarshal(rr.Body.Bytes(), &p); err != nil {
		t.Fatalf("invalid json: %v", err)
	}
	if p["status"] != "alive" {
		t.Fatalf(`status=%q; want "alive"`, p["status"])
	}
}

func TestHealthHandler_Ready(t *testing.T) {
	handler := NewHealthHandler()
	req := httptest.NewRequest(http.MethodGet, "/readyz", nil)
	rr := httptest.NewRecorder()
	handler.Ready(rr, req)

	if rr.Code != http.StatusOK {
		t.Fatalf("status = %d; want %d", rr.Code, http.StatusOK)
	}
	var p map[string]string
	if err := json.Unmarshal(rr.Body.Bytes(), &p); err != nil {
		t.Fatalf("invalid json: %v", err)
	}
	if p["status"] != "ready" {
		t.Fatalf(`status=%q; want "ready"`, p["status"])
	}
}
