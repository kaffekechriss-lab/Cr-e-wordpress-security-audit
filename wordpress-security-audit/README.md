# WordPress Security Audit & Hardening Lab

A practical, authorized security assessment of a WordPress installation running in an isolated VirtualBox lab. The project documents reconnaissance, controlled verification, hardening, and a post-hardening re-audit.

> **Scope:** Personal lab only. Target used: `192.168.2.5` (Ubuntu Server / Apache / WordPress). Do not run these checks against systems without explicit authorization.

## Objectives
- Identify exposed services and WordPress components.
- Verify directory listing and selected sensitive-file exposure.
- Review public user enumeration and XML-RPC behavior.
- Apply basic Apache hardening and restrictive file permissions.
- Re-test the application and document remaining work.

## Lab environment
| Component | Observed / configured value |
|---|---|
| Audit machine | Kali Linux |
| Target | Ubuntu Server VM |
| Target address | `192.168.2.5` |
| Web server | Apache 2.4.41 |
| PHP | 7.4.3 (observed; end-of-life) |
| CMS | WordPress 7.1.4 (scanner identification) |
| Tools | Nmap, WhatWeb, WPScan, cURL |

Versions and results are specific to this lab and the assessment date (2026-11-02).

## Methodology
1. Reconnaissance and service identification.
2. WordPress/component enumeration.
3. Misconfiguration checks.
4. Controlled security tests.
5. Apache and filesystem hardening.
6. Post-hardening verification.
7. Reporting and recommendations.

## Key findings
- Directory indexes were initially visible in selected directories, including uploads and a theme directory.
- Public author/REST responses exposed user profile information. This is information disclosure, not proof of account compromise.
- `readme.html` and `license.txt` were publicly accessible.
- PHP 7.4 was observed and is end-of-life; plan a tested upgrade.
- No `wp-config.php` source disclosure was demonstrated.
- XML-RPC returned HTTP 405 to the tested GET request. This does **not** prove XML-RPC is disabled for all methods.

## Hardening applied and verified
- Apache directory indexing disabled (`Options -Indexes`).
- HTTP access to `wp-config.php` denied.
- `wp-config.php` permissions set to `root:www-data`, mode `640`.
- Apache version detail reduced (`ServerTokens Prod`) and signature disabled (`ServerSignature Off`).

## Re-audit snapshot (2026-11-02)
| Request | Result | Interpretation |
|---|---:|---|
| `/` | 200 | Home page responds |
| `/wp-login.php` | 200 | Login page responds |
| `/wp-config.php` | 403 | HTTP access denied |
| `/wp-content/uploads/` | 403 | Directory listing blocked |
| `/wp-content/themes/twentytwentyfive/` | 403 | Directory listing blocked |
| `/xmlrpc.php` (GET) | 405 | GET not allowed; further method testing required |
| `/index.php/wp-json/wp/v2/users?per_page=10` | 200 | Public user API remains exposed |

## Remaining recommendations
1. Upgrade PHP to a supported version after checking WordPress, plugin, and theme compatibility.
2. Update WordPress core, plugins, and themes after backups and compatibility checks.
3. Review public REST user enumeration and restrict it only if compatible with site functionality.
4. Determine whether XML-RPC is required; disable it if not needed and verify behavior.
5. Review and implement appropriate HTTP security headers.
6. Add tested backups, logging, and periodic re-audits.

## Repository contents
- `rapport-audit.md` — detailed report in French.
- `evidence/` — concise observed HTTP results and scan summary.
- `scripts/` — read-only cURL checks for an authorized lab.
- `hardening/` — reference Apache configuration snippets (review before applying).

## Run the checks
Edit the target address if your lab uses another IP, then run:

```bash
chmod +x scripts/*.sh
./scripts/reaudit.sh http://192.168.2.5
```

The script sends ordinary HTTP GET requests and reports status codes. It does not exploit vulnerabilities or change the target.

## Disclaimer
This repository documents a learning lab, not a comprehensive penetration test or a certification. HTTP status codes are evidence for the specific requests made; they do not prove the complete security or insecurity of a component. Never publish real usernames, API keys, passwords, private IP details from third-party environments, or unredacted configuration files.
