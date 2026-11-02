#!/usr/bin/env bash
set -u

BASE_URL="${1:-http://192.168.2.5}"
BASE_URL="${BASE_URL%/}"

check() {
  local path="$1"
  local code
  code="$(curl -sS -o /dev/null -w '%{http_code}' "$BASE_URL$path" || true)"
  printf '%-58s HTTP %s\n' "$path" "${code:-000}"
}

echo "WordPress read-only re-audit: $BASE_URL"
check "/"
check "/wp-login.php"
check "/wp-config.php"
check "/wp-content/uploads/"
check "/wp-content/themes/twentytwentyfive/"
check "/xmlrpc.php"
check "/index.php/wp-json/wp/v2/users?per_page=10"
