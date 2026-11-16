---
project: ralph-engine-installer
---

# PRD: R-038 (2/2) — install.sh download nativo + README

> Parte 2 da quebra da R-038 (ADR-026 Emenda D2) em PRDs mono-repo (Caminho A).
> Esta PRD cobre apenas o repo `ralph-engine-installer` (`install.sh` + `README.md`).
> Executar após a parte 1 (`release.yml`, repo `ralph-engine`) ter publicado os binários.

## User Stories

### US-001: install.sh download nativo via API de assets + token via env/stdin

**type:** feature

**required_intelligence:** pro

**Description:** Como usuário do instalador público, quero baixar o binário correto (OS/arch + canal) do repo `backforend/ralph-engine-releases` de forma autenticada e segura, sem expor o token em `ps`/history, de modo que o download autenticado funcione em repo privado e a integridade seja verificada sem dependências externas.

**Acceptance Criteria:**
- [x] O token é lido de `RALPH_DOWNLOAD_TOKEN` (env) ou `stdin`; o flag `--token <PAT>` é removido do `argv` e do `usage()`.
- [x] A resolução canal→release usa a API GitHub (`/releases/latest` para stable; `/releases?per_page=1` para beta), extraindo `tag_name` sem `jq`.
- [x] O download resolve a URL de API do asset (`${API}/releases/assets/<id>`) no JSON da release e baixa com header `Accept: application/octet-stream` e `-L` (segue o redirect 302 do S3) — **não** via `releases/download` (404 em privado).
- [x] O checksum é verificado nativamente: `sha256sum -c` (Linux) → `shasum -a 256 -c` (macOS), abortando o script se o digest divergir.
- [x] Nenhuma dependência extra é exigida (`jq`, `oras`, `docker`, `tar`).
- [x] O token nunca é impresso em log/echo/erro.

### US-002: README.md documenta token via env/stdin

**type:** docs

**required_intelligence:** flash

**Description:** Como usuário, quero instruções de instalação que reflitam o fluxo real (token via env/stdin, sem `--token` no argv), de modo que o comando documentado funcione sem vazar a credencial.

**Acceptance Criteria:**
- [x] O comando de instalação deixa de usar `--token <PAT>`; passa a instruir `export RALPH_DOWNLOAD_TOKEN=...` (ou stdin) antes do `curl ... | bash`.
- [x] Toda menção a `--token` no `README.md` é removida/substituída.
- [x] O `README.md` referencia o repo de releases `backforend/ralph-engine-releases` e o requisito de token de download fornecido pela Backforend.

---

## Não-Objetivos (fora de escopo desta PRD)

- `release.yml` (repo `ralph-engine`) — PRD-1 da quebra.
- Verificação de assinatura cosign no `install.sh` — responsabilidade do `ralph-engine-cli verify` (ADR-026 D2.8).
- Emissão de tokens 1:1 por tenant (D2.9b — processo operacional, não código).

## Considerações Técnicas

- `curl -L` derruba o header `Authorization` no redirect cross-host para o S3 — por isso o download autenticado resolve a URL de API do asset (com `asset_id`) em vez de `releases/download`.
- O `install.sh` é estável (não reescrito a cada build); resolve canal/versão via GitHub Releases API, não por branch.
