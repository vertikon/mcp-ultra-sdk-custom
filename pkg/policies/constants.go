// pkg/policies/constants.go
package policies

import "github.com/vertikon/mcp-ultra-sdk-custom/pkg/httpx"

// HTTP status codes (re-exported from httpx for backward compatibility)
const (
	// StatusUnauthorized representa HTTP 401
	StatusUnauthorized = httpx.StatusUnauthorized
	// StatusForbidden representa HTTP 403
	StatusForbidden = httpx.StatusForbidden
)
