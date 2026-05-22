#!/usr/bin/env bash
set -euo pipefail

REPO="${REPO:-cxp106/alios-tools}"
BRANCH="${BRANCH:-gh-pages}"
DIST="${DIST:-stable}"
COMPONENT="${COMPONENT:-main}"
ARCH="${ARCH:-amd64}"
LIST_FILE="${LIST_FILE:-/etc/apt/sources.list.d/sing-box-thin.list}"

BASE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}/apt-repo"
SOURCE_LINE="deb [trusted=yes arch=${ARCH}] ${BASE_URL} ${DIST} ${COMPONENT}"

echo "[INFO] Adding apt source: ${SOURCE_LINE}"
echo "${SOURCE_LINE}" | sudo tee "${LIST_FILE}" >/dev/null

sudo apt update
sudo apt install -y sing-box-thin

echo "[INFO] Done. You can update later with: sudo apt update && sudo apt upgrade"
