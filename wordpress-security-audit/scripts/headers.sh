#!/usr/bin/env bash
set -euo pipefail
BASE_URL="${1:-http://192.168.2.5}"
curl -sSI "$BASE_URL" | grep -Ei '^(HTTP/|Server:|X-Frame-Options:|Content-Security-Policy:|Referrer-Policy:|X-Content-Type-Options:)' || true
