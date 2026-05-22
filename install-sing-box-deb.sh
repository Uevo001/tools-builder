#!/usr/bin/env bash
set -euo pipefail

REPO="${REPO:-${GITHUB_REPOSITORY:-cxp106/alios-tools}}"
ASSET_PATTERN="${ASSET_PATTERN:-sing-box-thin_.*_amd64\.deb$}"
INSTALL_CMD="${INSTALL_CMD:-sudo dpkg -i}"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "[ERROR] Missing required command: $1" >&2
    exit 1
  }
}

require_cmd curl
require_cmd awk
require_cmd sed
require_cmd mktemp

api_url="https://api.github.com/repos/${REPO}/releases/latest"

tmp_json="$(mktemp)"
trap 'rm -f "$tmp_json" "$tmp_deb"' EXIT

curl -fsSL "$api_url" -o "$tmp_json"

asset_url="$({
  awk -v pattern="$ASSET_PATTERN" '
    /"name"[[:space:]]*:/ {
      if (match($0, /"name"[[:space:]]*:[[:space:]]*"([^"]+)"/, m)) {
        name=m[1]
      }
    }
    /"browser_download_url"[[:space:]]*:/ {
      if (match($0, /"browser_download_url"[[:space:]]*:[[:space:]]*"([^"]+)"/, m)) {
        url=m[1]
        if (name ~ pattern) {
          print url
          exit
        }
      }
    }
  ' "$tmp_json"
})"

if [[ -z "$asset_url" ]]; then
  echo "[ERROR] No asset matching pattern '${ASSET_PATTERN}' found in latest release of ${REPO}." >&2
  exit 1
fi

tmp_deb="$(mktemp --suffix=.deb)"
echo "[INFO] Downloading: $asset_url"
curl -fL "$asset_url" -o "$tmp_deb"

echo "[INFO] Installing package with: $INSTALL_CMD $tmp_deb"
# shellcheck disable=SC2086
$INSTALL_CMD "$tmp_deb"

echo "[INFO] Install completed."
