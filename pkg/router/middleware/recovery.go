// pkg/router/middleware/recovery.go
package middleware

import (
	"log"
	"net/http"
	"runtime/debug"
)

// Recovery captura panics e retorna 500
func Recovery() func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			defer func() {
				if err := recover(); err != nil {
					log.Printf("PANIC: %v\n%s", err, debug.Stack())
					http.Error(w, "Internal Server Error", 500)
				}
			}()
			next.ServeHTTP(w, r)
		})
	}
}
