# FoodRescue Security

## Implemented client controls

- API requests require an `https://` base URL from `.env`; HTTP endpoints are rejected.
- JWT tokens use `flutter_secure_storage`, not `SharedPreferences`.
- Admin API calls send the bearer token and rely on backend authorization responses.
- Admin role is accepted only from the authenticated API response under `data.role`.
- Local demo authentication and registration are debug-only; the local fixture cannot log in as admin.
- Credentials are not displayed in the login UI and are not committed in `.env.example`.
- Production Flutter errors use a generic message to avoid exposing internal details.

## OWASP Top 10 (2021)

| # | Risk | FoodRescue control/status |
|---|---|---|
| A01 | Broken Access Control | Client sends protected requests, but the backend must enforce role and object-level permissions on every endpoint. |
| A02 | Cryptographic Failures | HTTPS-only API and secure token storage are enabled. Backend data encryption and TLS certificate management remain required. |
| A03 | Injection | Client validates input and encodes path IDs. Backend must use parameterized queries and server-side validation. |
| A04 | Insecure Design | Admin actions need least privilege, confirmation for destructive actions, rate limits, and threat modeling in the backend. |
| A05 | Security Misconfiguration | Secrets are excluded by `.gitignore`; configure production `.env` outside source control and disable verbose server errors. |
| A06 | Vulnerable Components | Run `flutter pub outdated`, review dependency advisories, and update packages in a controlled release process. |
| A07 | Identification and Authentication Failures | Tokens are protected locally and admin role is checked from API data. Backend must add rate limiting, lockout, session expiry/refresh, MFA for admins, and password reset protections. |
| A08 | Software and Data Integrity Failures | Use signed CI artifacts, protected branches, dependency lock review, and verified release builds. |
| A09 | Security Logging and Monitoring Failures | The admin UI has audit log views, but authoritative, append-only audit logs and alerting must be implemented server-side. |
| A10 | Server-Side Request Forgery | Do not accept arbitrary server URLs from users. Backend must restrict outbound destinations and validate webhook/media URLs. |

## Required backend contract

The production API must provide HTTPS endpoints for `/login`, `/foods`, `/admin/users`, and `/admin/products/{id}`. It must validate JWT signatures, expiry, issuer, audience, and roles server-side. Never use the old demo password or any credential that has appeared in a repository or build artifact; rotate it before deployment.

## Local setup

1. Copy `.env.example` to `.env`.
2. Set `API_BASE_URL` to the real HTTPS API URL.
3. Keep `.env` out of version control and CI logs.
4. Run `flutter analyze` and `flutter test` before release.
