@RTK.md
@WORK.md

## Writing
- NEVER EVER EVER USE EMDASHES, —, ALWAYS USE PROPER PUNCTUATION AND SENTENCES.  Don't write super long lines in markdown, wrap at 80 characters.

## Git & Commits
- NEVER commit or amend commits unless explicitly asked. Verify changes with typecheck and tests, then stop and let the user commit.

## Code Review Workflow
- When addressing PR review comments (Copilot/claude[bot]), always fetch and confirm the EXACT current comment thread before making changes; do not act on stale threads. Implement only the minimal fix requested unless asked otherwise.

## Scope Discipline
- Do not over-engineer: avoid adding guards that can't be triggered, single-use constants, explanatory comments, git worktrees, GitHub workflows, or Sentry unless explicitly requested.
- If I ask for values, JSON, a query, or an explanation, return it IN CHAT. Do not edit files unless I ask for the change to be applied.
- Make minimal diffs. Never rewrite my existing code comments, rename things, or touch unrelated modules (e.g., capacity-manager) without asking first.
- Never regenerate lockfiles from scratch. Use targeted installs so pnpm-lock.yaml only gains the needed additions.
- Before reusing an existing config or flag for a new purpose (e.g., AzBufferThresholds), ask whether that's intended.

## Shell
- Always run cd to the repo root before git diff/analysis

## Investigation & Answers
- Answer investigative questions directly with code citations; do NOT offload simple lookups to slow background research agents.

## Environment & Access
- You HAVE AWS CLI access via environment variables. For AWS questions (inventory, quotas, RDS, EC2, S3, IAM), run read-only AWS CLI commands and query live state. Do not give a generic answer first. Never run mutating AWS commands without explicit approval.
- This is macOS. Use BSD-compatible flags for ls, sed, date and similar tools, or use gnu-prefixed variants if they are installed.

## AWS
- Validate AWS API constraints (batch semantics, filter-value limits, rate limits) before shipping changes. You never have permission to run AWS commands unless you're explicitly told to. When told, credentials will be provided in your environment.

## Evidence Standard
- Before stating a root cause or a claim about code behavior, trace the actual code path or data and cite file:line, query output, or log lines as evidence.
- Label unverified hypotheses explicitly as hypotheses.
- When I push back, re-investigate from scratch rather than defending the prior answer.
- Check ALL handlers or entry points (dashboard API, public v1 API, workers) before saying 'this is where X happens'.

## Data & Tooling Gotchas
- BigQuery: never use in-progress sync snapshots. Filter to the latest completed sync time. If bq auth expires, tell me to run `gcloud auth login` rather than guessing.
- Grafana MCP is often unreachable (it returns HTML when auth or VPN is down). Check tool availability first. If it fails, say so immediately and tell me to run /mcp. Do not pretend to have Grafana data.
- For questions about my Claude/MCP setup, inspect ~/.claude.json and the local config before answering from docs.
- After TS changes, run the full unit test suite (rebuild shared/dist first if it is stale), not just the tests for the touched file.

<!-- CODEGRAPH_START -->
## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->
