<!--
Copyright (C) 2026 MAX JEISON PRASS TECNOLOGIA LTDA (CNPJ 26.360.770/0001-39)
All rights reserved.
PROPRIETARY AND CONFIDENTIAL.
-->

# ralph-engine — Instalador

**Desenvolvimento de software autônomo, com governança e FinOps embarcadas.**

O **ralph-engine** é o motor de desenvolvimento AI-Driven da Backforend: um agente
de IA autônomo (**Ralph**) que transforma um PRD em código testado — escrevendo o
teste antes do código (TDD), aplicando YAGNI e rollback automático — orquestrado
por uma árvore de skills e um **AI Gateway** que roteia a inferência por custo/QI.

Este repositório é o **instalador público** do `ralph-engine-cli`. É fino e **não
contém propriedade intelectual**: baixa o CLI oficial (privado, assinado) e o
instala no seu host.

---

## O que o ralph-engine entrega

- **Agente autônomo (Ralph)** — implementa as stories de um PRD de ponta a ponta:
  escreve o teste (RED), implementa (GREEN), refatora e abre o PR aplicando
  Conventional Commits.
- **Governança embarcada** — SOLID, YAGNI Gate, Impact Gate, Zero Trust e FinOps
  não são sugestões: são gates aplicados pelo motor a cada iteração.
- **AI Gateway (LiteLLM) multi-provedor** — um gateway LLM onde **você configura**
  o modelo de cada tarefa: um modelo barato para tarefas mecânicas (**flash**) e
  modelos mais capazes para tarefas complexas (**pro**). Cache de prompt com hit
  rate **acima de 90%** medido em operação.
- **RAG parametrizado (GraphRAG)** — um grafo unificado dos seus repositórios para
  o Impact Gate e o roteamento semântico do agente.
- **Distribuição como serviço** — nada de clonar o motor: um CLI fino
  (`ralph-engine-cli`) orquestra uma imagem OCI imutável e assinada (cosign), com
  licença offline (ed25519).

## Como funciona

O motor roda em **4 serviços** Docker orquestrados pelo CLI:

| Serviço | Papel |
| --- | --- |
| `app` | Ambiente de desenvolvimento (Claude Code/Aider, Ralph, skills) |
| `litellm` | AI Gateway — roteia a inferência aos provedores (porta 4000) |
| `redis` | Cache e budget/rate-limit do gateway |
| `db` | PostgreSQL — estado do gateway |

> **Você só informa uma credencial:** o token do(s) seu(s) provedor(es) de IA
> (OpenAI, Anthropic, DeepSeek, …). A chave do gateway é gerada e a autenticação
> do agente é provisionada automaticamente.

## Pré-requisitos

| Requisito | Nota |
| --- | --- |
| **Docker** + Docker Compose | Orquestra os 4 serviços |
| **1+ token de provedor de IA** | OpenAI, Anthropic, DeepSeek, … |

## Instalação

Instale o `ralph-engine-cli` no seu host executando no terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/backforend/ralph-engine-installer/dev/install.sh | bash -s -- --token <PAT>
```

- `<PAT>` é o token de download do binário (repo privado), **fornecido pela
  Backforend** junto com a sua `license.lic`.
- Use a URL `raw.githubusercontent.com` — o link `github.com/.../blob/...`
  retorna HTML e não funciona com `curl`.
- O binário é instalado em `~/.local/bin`.

> **Pré-requisito de acesso:** o download do binário é autenticado. Solicite o
> token e a licença à Backforend antes de instalar.

## Primeiro uso

```bash
# 1. Prepara a instância (docker-compose + .env + licença)
ralph-engine-cli install --license /caminho/license.lic

#    Preencha o .env gerado (master key + tokens dos provedores de IA).
#    A Backforend fornece o seed de configuração declarativa.

# 2. Sobe os 4 serviços (valida a licença offline)
ralph-engine-cli up

# 3. Gera a topologia do seu projeto (auto-descoberta dos repos Git)
ralph-engine-cli onboarding --auto
#    ... revise os arquivos *.onboarding e renomeie (remova o sufixo) ...

# 4. Ativa o ecossistema (valida a topologia)
ralph-engine-cli onboarding --activate

# 5. Roda o Ralph sobre o seu PRD
ralph-engine-cli run ralph
```

> O Ralph trabalha a partir de um PRD (`ia/tasks/prd-<feature>.md`). Escreva o
> PRD antes de executar `run ralph`; o motor aplica o roteamento de modelos e a
> governança automaticamente.

## Duas formas de trabalhar

O `ralph-engine-cli` oferece dois modos de uso dentro do container `app`:

**1. Interativa — direto no harness**

```bash
ralph-engine-cli run claude   # abre o Claude Code dentro do container
ralph-engine-cli run zsh      # abre um shell (zsh) dentro do container
```

Ideal para explorar o código, discutir decisões e criar PRDs/ADRs em tempo real.

**2. Ralph loop — execução autônoma de PRDs**

```bash
ralph-engine-cli run ralph
```

Ideal para executar um PRD de ponta a ponta, sem supervisão. O Ralph aplica a
governança (TDD, YAGNI, Impact Gate e roteamento de modelos por tier), commita
cada story com Conventional Commits e registra o progresso em `progress.txt`.

### Como usar o Ralph loop

1. Na sessão interativa, crie a PRD:

   ```
   /prd crie uma prd para <sua feature>
   ```

   ou, se você já discutiu o assunto com o harness (ou tem uma ADR):

   ```
   /prd prepare uma prd do que discutimos ou da adr XPTO.
   ```

2. Prepare a PRD para execução:

   ```
   /ralph prepare a prd XPTO para execução
   ```

3. Saia da sessão do harness e execute o loop:

   ```bash
   ralph-engine-cli run ralph
   ```

4. Acompanhe o progresso em outro terminal:

   ```bash
   tail -F -n +1 progress.txt
   ```

## Comandos principais

| Comando | O que faz |
| --- | --- |
| `ralph-engine-cli install` | Cria a instância (compose + `.env` + licença) |
| `ralph-engine-cli up` | Sobe os 4 serviços |
| `ralph-engine-cli run ralph` | Executa o loop de desenvolvimento AI-Driven |
| `ralph-engine-cli onboarding` | Gera e ativa a topologia do projeto |
| `ralph-engine-cli upgrade` | Atualiza a instância para uma nova versão |

## Licença

O ralph-engine é distribuído sob **licença proprietária** (assinada, offline).
Fale com a Backforend sobre avaliação e licenciamento comercial.

## Status

> O instalador público está em **implementação ativa** (roadmap R-038). A lógica
> de download autenticado, verificação de integridade e assinatura está sendo
> finalizada; os comandos do `ralph-engine-cli` acima são o contrato de uso
> estável.

## Suporte

- Documentação técnica: repositório privado `backforend/ralph-engine`.
- Contato: Backforend.
