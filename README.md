<!--
Copyright (C) 2026 MAX JEISON PRASS TECNOLOGIA LTDA (CNPJ 26.360.770/0001-39)
All rights reserved.
PROPRIETARY AND CONFIDENTIAL.
-->

# ralph-engine-installer

Instalador público do `ralph-engine-cli` (Backforend AI-Driven Development Engine).

> **Repo público sem PI.** Contém exclusivamente o script fino de bootstrap
> (`install.sh`), este README e a LICENSE. O binário e o corpus documental do
> motor permanecem em repositório **privado** (ADR-026 D1).

## O que faz

O `install.sh` é um instalador **estável** (não é reescrito a cada build) que:

1. detecta OS/arch;
2. resolve a versão do canal (`beta` por default, `stable` via `--stable`);
3. baixa o binário + `SHA256SUMS` + assinatura cosign;
4. verifica integridade/autenticidade;
5. instala em `~/.local/bin` (ou `/usr/local/bin`).

O download do binário é **autenticado** (PAT GitHub Releases do repo privado),
via `--token` ou env `RALPH_DOWNLOAD_TOKEN` (ADR-026 D2).

## Uso

```bash
# Canal beta (default) com token de download
./install.sh --token <PAT>

# Canal estável
./install.sh --stable --token <PAT>
```

## Status

R-038 (distribuição pública) — em implementação. A lógica completa de
download/verificação está sob implementação; ver ADR-026 D1/D2/D4.
