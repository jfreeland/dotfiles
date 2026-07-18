@RTK.md

## Git & Commits
NEVER commit or amend commits unless explicitly asked. Verify changes with typecheck and tests, then stop and let the user commit.

## Code Review Workflow
When addressing PR review comments (Copilot/claude[bot]), always fetch and confirm the EXACT current comment thread before making changes; do not act on stale threads. Implement only the minimal fix requested unless asked otherwise.

## Scope Discipline
Do not over-engineer: avoid adding guards that can't be triggered, single-use constants, explanatory comments, git worktrees, GitHub workflows, or Sentry unless explicitly requested.

## Shell
Always run cd to the repo root before git diff/analysis

## AWS
Validate AWS API constraints (batch semantics, filter-value limits, rate limits) before shipping changes. You never have permission to run AWS commands unless you're explicitly told to. When told, credentials will be provided in your environment.

## Investigation & Answers
Answer investigative questions directly with code citations; do NOT offload simple lookups to slow background research agents.

<!-- CODEGRAPH_START -->
## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->
