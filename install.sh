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
TOKEN="${RALPH_DOWNLOAD_TOKEN:-}"   # PAT GitHub Releases (repo privado)
INSTALL_DIR="${HOME}/.local/bin"

usage() {
  cat <<'EOF'
Uso: install.sh [opções]

Opções:
  --stable          Usa o canal estável (master/latest). Default: beta.
  --token <PAT>     PAT GitHub Releases do repo privado do binário.
                    (equivale à env RALPH_DOWNLOAD_TOKEN)
  --dir <path>      Diretório de instalação. Default: ~/.local/bin
  -h, --help        Mostra esta ajuda.
EOF
}

# --- Argument parsing ---
while [ "$#" -gt 0 ]; do
  case "$1" in
    --stable)        CHANNEL="stable"; shift ;;
    --token)         TOKEN="$2"; shift 2 ;;
    --token=*)       TOKEN="${1#--token=}"; shift ;;
    --dir)           INSTALL_DIR="$2"; shift 2 ;;
    --dir=*)         INSTALL_DIR="${1#--dir=}"; shift ;;
    -h|--help)       usage; exit 0 ;;
    *)               echo "erro: opção desconhecida: $1" >&2; usage; exit 2 ;;
  esac
done

detect_os_arch() {
  local os arch
  os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  arch="$(uname -m)"
  case "$arch" in
    x86_64)  arch="amd64" ;;
    aarch64) arch="arm64" ;;
  esac
  echo "$os/$arch"
}

main() {
  local os_arch
  os_arch="$(detect_os_arch)"

  # TODO(R-038): resolver versão do canal via GitHub API (latest/pré-release).
  # TODO(R-038): baixar binário + SHA256SUMS + assinatura cosign.
  # TODO(R-038): verificar checksum + cosign verify.
  # TODO(R-038): instalar em "$INSTALL_DIR".
  # TODO(R-038): autenticação via "$TOKEN" (PAT GitHub Releases, ADR-026 D2).

  echo "ralph-engine-installer: canal=$CHANNEL os/arch=$os_arch dir=$INSTALL_DIR"
  echo "⚠️  implementação pendente (R-038) — ver ADR-026 D1/D2/D4."
}

main "$@"
