# Security Policy

## Supported Versions

We actively support and provide security updates for the following versions of `mcp-ultra-sdk-custom`:

| Version | Supported          | Status |
|---------|--------------------|--------|
| 9.x     | :white_check_mark: | Active support & security updates |
| < 9.0.0 | :x:                | Not supported |

**Recommendation:** Always use the latest minor version (v9.x) to receive security patches and bug fixes.

---

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability in `mcp-ultra-sdk-custom`, please report it responsibly.

### How to Report

**Do NOT open a public issue for security vulnerabilities.**

Instead, please report privately via one of these methods:

1. **GitHub Security Advisories (Preferred)**
   - Navigate to: https://github.com/vertikon/mcp-ultra-sdk-custom/security/advisories/new
   - Click "Report a vulnerability"
   - Fill out the form with details

2. **Email**
   - Send to: security@vertikon.com
   - Subject: `[SECURITY] mcp-ultra-sdk-custom vulnerability`
   - Include:
     - Description of the vulnerability
     - Steps to reproduce
     - Affected versions
     - Potential impact
     - Suggested fix (if any)

### What to Include

When reporting a vulnerability, please provide:

- **Clear description** of the issue
- **Affected versions** (e.g., v9.0.0, all v9.x)
- **Steps to reproduce** with minimal example
- **Potential impact** (CVSS score if known)
- **Proof of concept** (if applicable)
- **Suggested remediation** (optional)

### Response Timeline

- **Acknowledgment:** Within 48 hours
- **Initial assessment:** Within 5 business days
- **Fix timeline:** Depends on severity
  - Critical: 7 days
  - High: 14 days
  - Medium: 30 days
  - Low: Next minor release

### Security Update Process

1. We will acknowledge your report within 48 hours
2. We will investigate and validate the vulnerability
3. We will develop and test a fix
4. We will release a patched version
5. We will publish a security advisory (CVE if applicable)
6. We will credit you (unless you prefer to remain anonymous)

---

## Security Best Practices

When using `mcp-ultra-sdk-custom`, follow these security recommendations:

### 1. Authentication & Authorization

```go
// Always validate JWT tokens
import "github.com/vertikon/mcp-ultra-sdk-custom/pkg/policies"

mux.Use(policies.Auth(&YourValidator{}))

// Use RBAC for sensitive endpoints
protectedHandler := policies.RequireRole("admin")(yourHandler)
```

### 2. Input Validation

```go
// Validate all user inputs
func handler(w http.ResponseWriter, r *http.Request) {
    var input struct {
        Name  string `json:"name"`
        Email string `json:"email"`
    }

    if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
        http.Error(w, "Invalid input", http.StatusBadRequest)
        return
    }

    // Validate before processing
    if input.Name == "" || !isValidEmail(input.Email) {
        http.Error(w, "Invalid data", http.StatusBadRequest)
        return
    }
}
```

### 3. Environment Variables

```bash
# Never hardcode secrets
# Use environment variables
export NATS_TOKEN="your-secret-token"
export JWT_SECRET="your-jwt-secret"
export API_KEY="your-api-key"
```

### 4. HTTPS Only

```go
// Always use HTTPS in production
server := &http.Server{
    Addr:    ":8443",
    Handler: mux,
    TLSConfig: &tls.Config{
        MinVersion: tls.VersionTLS13,
    },
}
server.ListenAndServeTLS("cert.pem", "key.pem")
```

### 5. Rate Limiting

```go
// Implement rate limiting for public APIs
import "golang.org/x/time/rate"

limiter := rate.NewLimiter(10, 20) // 10 req/s, burst 20

func rateLimitMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        if !limiter.Allow() {
            http.Error(w, "Too many requests", http.StatusTooManyRequests)
            return
        }
        next.ServeHTTP(w, r)
    })
}
```

### 6. Dependency Management

```bash
# Regularly update dependencies
go get -u ./...
go mod tidy

# Audit dependencies
go list -m all | go mod why
```

### 7. Code Scanning

Enable GitHub Advanced Security:
- CodeQL analysis
- Dependabot alerts
- Secret scanning

---

## Known Security Considerations

### NATS Authentication

When using NATS integration:
- Use token-based authentication
- Enable TLS for NATS connections
- Rotate tokens regularly

```bash
NATS_URL=nats://localhost:4222
NATS_TOKEN=your-secret-token
NATS_TLS_CERT=/path/to/cert.pem
NATS_TLS_KEY=/path/to/key.pem
```

### Plugin Isolation

Plugins run in the same process:
- Validate all plugin inputs
- Use panic recovery middleware
- Implement plugin sandboxing if needed

```go
// Recovery middleware (built-in)
mux.Use(middleware.Recovery())
```

### Seed Management

Seed synchronization endpoints (`/seed/sync`, `/seed/status`) should be:
- Protected by authentication
- Rate-limited
- Logged for audit trail

---

## Security Advisories

Published security advisories are available at:
https://github.com/vertikon/mcp-ultra-sdk-custom/security/advisories

Subscribe to notifications:
- Watch the repository
- Enable security alerts in your GitHub settings

---

## Compliance & Certifications

- **Ultra Verified:** 100% validated (Enhanced Validator V4)
- **Certificate:** VTK-SDK-CUSTOM-V9-20251005-STABLE
- **License:** MIT (see [LICENSE](LICENSE))

---

## Contact

- **Security Team:** security@vertikon.com
- **General Support:** dev@vertikon.com
- **GitHub Issues:** https://github.com/vertikon/mcp-ultra-sdk-custom/issues (non-security only)

---

## Acknowledgments

We appreciate responsible disclosure and will acknowledge security researchers who help improve our security.

Hall of Fame:
- (Your name could be here!)

---

**Last Updated:** 2025-10-05
**Version:** 1.0.0
