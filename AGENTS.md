<!--
Copyright (C) 2026 MAX JEISON PRASS TECNOLOGIA LTDA (CNPJ 26.360.770/0001-39)
All rights reserved.
PROPRIETARY AND CONFIDENTIAL.
-->

# AGENTS.md — ralph-engine-installer

> Repo **público** da Backforend para distribuição do `ralph-engine-cli` via
> instalador `install.sh` (ADR-026 D1). **Não contém PI** — apenas o script fino
> de bootstrap + README + LICENSE.

## Contexto

- **Persona:** `ralph-engine-installer-dev` (ver `PERSONAS.md` §3.16)
- **Family:** `core` — LICENSE **sem** a cláusula "Powered by Backforend"
- **PI:** nenhuma — o binário e o corpus permanecem no repo privado `ralph-engine`

## Regras locais

- `install.sh` é **estável** (não reescrito a cada build) — ADR-026 D1.
- Download do binário é **autenticado** (PAT GitHub Releases) — ADR-026 D2.
- Default do canal é `beta` enquanto o produto estiver em Beta — ADR-026 D4.
- **Nunca** commitar secrets, PATs ou tokens.
- Header de copyright obrigatório em `install.sh` (backforend-copyright §5.1).
