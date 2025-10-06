// pkg/router/middleware/logger.go
package middleware

import (
	"log"
	"net/http"
	"time"
)

// Logger registra requests
func Logger() func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			start := time.Now()
			log.Printf("[%s] %s %s", r.Method, r.URL.Path, r.RemoteAddr)
			next.ServeHTTP(w, r)
			log.Printf("[%s] %s completed in %v", r.Method, r.URL.Path, time.Since(start))
		})
	}
}
