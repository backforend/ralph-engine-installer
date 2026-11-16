#!/usr/bin/env bash
# Copyright (C) 2026 MAX JEISON PRASS TECNOLOGIA LTDA (CNPJ 26.360.770/0001-39)
# All rights reserved.
# PROPRIETARY AND CONFIDENTIAL.
# No part of this software may be reproduced, distributed, or transmitted
# in any form or by any means without express written permission.

# ralph-engine-installer — install.sh
# Instalador estável do ralph-engine-cli (ADR-026 D1/D2/D4).
#
# Repo PÚBLICO: este script NÃO contém PI. O binário (com o corpus) permanece
# privado; o download é autenticado por PAT GitHub Releases (ADR-026 D2).

set -euo pipefail

# --- Defaults (ADR-026 D4: beta enquanto o produto estiver em Beta) ---
CHANNEL="beta"                      # --stable opta por master (latest)
INSTALL_DIR="${HOME}/.local/bin"
REPO="backforend/ralph-engine-releases"
API="https://api.github.com/repos/${REPO}"
TOKEN="${RALPH_DOWNLOAD_TOKEN:-}"   # PAT GitHub Releases (repo privado)

usage() {
  cat <<'EOF'
Uso: install.sh [opções]

O token de download (PAT fine-grained, repo privado backforend/ralph-engine-releases)
é lido da env RALPH_DOWNLOAD_TOKEN ou, se ausente, do stdin — nunca do argv
(evita vazar em ps/history).

Opções:
  --stable          Usa o canal estável (master/latest). Default: beta.
  --dir <path>      Diretório de instalação. Default: ~/.local/bin
  -h, --help        Mostra esta ajuda.
EOF
}

# --- Argument parsing ---
while [ "$#" -gt 0 ]; do
  case "$1" in
    --stable)        CHANNEL="stable"; shift ;;
    --dir)           INSTALL_DIR="$2"; shift 2 ;;
    --dir=*)         INSTALL_DIR="${1#--dir=}"; shift ;;
    -h|--help)       usage; exit 0 ;;
    *)               echo "erro: opção desconhecida: $1" >&2; usage; exit 2 ;;
  esac
done

# --- Token: env ou stdin (nunca argv) ---
if [ -z "${TOKEN:-}" ]; then
  IFS= read -r TOKEN || true
fi
if [ -z "${TOKEN:-}" ]; then
  echo "erro: token de download ausente (exporte RALPH_DOWNLOAD_TOKEN ou passe via stdin)" >&2
  exit 2
fi

detect_os() {
  case "$(uname -s)" in
    Linux)  echo linux ;;
    Darwin) echo darwin ;;
    *)      echo "erro: SO não suportado: $(uname -s)" >&2; exit 1 ;;
  esac
}

detect_arch() {
  case "$(uname -m)" in
    x86_64|amd64)  echo amd64 ;;
    aarch64|arm64) echo arm64 ;;
    *)             echo "erro: arquitetura não suportada: $(uname -m)" >&2; exit 1 ;;
  esac
}

# asset_url <name> <release-json>: resolve a URL de API do asset pelo nome, sem jq.
# Extrai os campos "url"/"name" linha a linha e emparelha o "url" imediatamente
# anterior ao "name" alvo (funciona com JSON compacto ou pretty-print).
asset_url() {
  printf '%s' "$2" \
    | grep -oE '"(url|name)":[[:space:]]*("[^"]*"|null)' \
    | awk -v name="$1" '
        /^"url"/  { u=$0; sub(/^"url":[[:space:]]*"/, "", u);  sub(/"$/, "", u) }
        /^"name"/ { n=$0; sub(/^"name":[[:space:]]*"/, "", n); sub(/"$/, "", n); if (n == name) { print u; exit } }
      '
}

main() {
  local os arch asset json tag tmp
  os="$(detect_os)"
  arch="$(detect_arch)"
  asset="ralph-engine-cli-${os}-${arch}"

  # canal -> release (tag) via API. stable usa /releases/latest (exclui pre-release);
  # beta usa /releases?per_page=1 (mais recente, inclui pre-release).
  local -a hdr=(-H "Authorization: Bearer ${TOKEN}" -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28")
  if [ "${CHANNEL}" = "stable" ]; then
    json="$(curl -fsSL "${hdr[@]}" "${API}/releases/latest")"
  else
    json="$(curl -fsSL "${hdr[@]}" "${API}/releases?per_page=1")"
  fi
  tag="$(printf '%s' "$json" | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"

  umask 077
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT

  # download autenticado em repo privado: browser_download_url retorna 404; usar a
  # URL de API do asset + Accept: octet-stream + -L (segue o redirect 302 p/ S3).
  curl -fsSL -H "Authorization: Bearer ${TOKEN}" -H "Accept: application/octet-stream" \
    -o "${tmp}/${asset}" "$(asset_url "${asset}" "$json")"
  curl -fsSL -H "Authorization: Bearer ${TOKEN}" -H "Accept: application/octet-stream" \
    -o "${tmp}/SHA256SUMS.txt" "$(asset_url "SHA256SUMS.txt" "$json")"

  # checksum nativo multi-OS (aborta se o digest divergir).
  cd "${tmp}"
  grep -E "[[:space:]]${asset}$" SHA256SUMS.txt > sum.txt
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum -c sum.txt
  else
    shasum -a 256 -c sum.txt
  fi

  mkdir -p "${INSTALL_DIR}"
  install -m 0755 "${tmp}/${asset}" "${INSTALL_DIR}/${asset}"
  echo "instalado: ${INSTALL_DIR}/${asset} (canal=${CHANNEL} tag=${tag})"
}

main
