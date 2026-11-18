@RTK.md
@WORK.md

## Writing
- Never use emdashes. Use proper punctuation and sentences.
- Wrap markdown at 80 characters.

## Git & Commits
- NEVER commit or amend commits unless explicitly asked. Run the repo's
  checks (typecheck, tests), then stop and let the user commit.

## Code Review Workflow
- When addressing PR review comments (Copilot/claude[bot]), always fetch and
  confirm the EXACT current comment thread before making changes; do not act
  on stale threads. Implement only the minimal fix requested unless asked
  otherwise.

## Scope Discipline
- Do not over-engineer: avoid adding guards that can't be triggered,
  single-use constants, explanatory comments, git worktrees, GitHub
  workflows, or Sentry unless explicitly requested.
- If I ask for values, JSON, a query, or an explanation, return it IN CHAT.
  Do not edit files unless I ask for the change to be applied.
- Make minimal diffs. Never rewrite my existing code comments, rename things,
  or touch unrelated modules without asking first.
- Never regenerate lockfiles from scratch. Use targeted installs so the
  lockfile only gains the needed additions.
- Before reusing an existing config or flag for a new purpose, ask whether
  that's intended.

## Shell
- This is macOS. Use BSD-compatible flags for ls, sed, date and similar
  tools, or use gnu-prefixed variants if they are installed.
- Use `git -C <repo root>` for git diff/analysis instead of cd.

## Investigation & Answers
- Answer investigative questions directly with code citations; do NOT
  offload simple lookups to slow background research agents.

## AWS
- Run read-only AWS CLI only when I say so or when credentials are in the
  environment. Never run mutating commands without explicit approval.
- For AWS questions (inventory, quotas, RDS, EC2, S3, IAM), query live state
  rather than giving a generic answer first.
- Validate AWS API constraints (batch semantics, filter-value limits, rate
  limits) before shipping changes.

## Evidence Standard
- Before stating a root cause or a claim about code behavior, trace the
  actual code path or data and cite file:line, query output, or log lines as
  evidence.
- Label unverified hypotheses explicitly as hypotheses.
- When I push back, re-investigate from scratch rather than defending the
  prior answer.
- Check ALL handlers or entry points (dashboard API, public v1 API, workers)
  before saying 'this is where X happens'.

## Tooling
- For questions about my Claude/MCP setup, inspect ~/.claude.json and the
  local config before answering from docs.
- After code changes, run the repo's full unit test suite (rebuild stale
  build artifacts first), not just the tests for the touched file.
- For Google Drive, Sheets and Docs, prefer the claude.ai Google MCP tools
  (e.g. get_values, update_values, update_spreadsheet). Use gcloud tokens or
  curl against the Google APIs only as a last resort, when the MCP cannot do
  the job.

## General
- Don't re-read a file after editing it or re-verify after a tool call
  already confirmed success.
- Read targeted line ranges or use grep to locate code before reading a
  whole large file.
- Delegate only multi-step or parallel work to subagents. Do direct lookups
  inline.
- Batch independent tool calls into a single turn instead of one call per
  turn.
- Keep responses concise by default; don't restate what a diff or tool
  output already shows.

## Executor MCP
- For any third-party service or integration, check the executor MCP first.
  Call `mcp__executor__skills` with name `execute`, then
  use `tools.search` and `tools.executor.coreTools.connections.list({})` in
  `mcp__executor__execute` to find what is connected.
- Do not conclude a service is unavailable until you have searched executor.
- Narrow searches with `namespace` when several integrations overlap.
- Use read tools freely. Ask before calling any create, update, delete, or
  replace tool.

<!-- CODEGRAPH_START -->
## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->
