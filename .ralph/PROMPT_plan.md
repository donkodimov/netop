0a. Study `specs/*.md` with up to 5 parallel subagents to learn what the application must do.
0b. Study @AGENTS.md to learn the project layout, how to build and test, and the codebase patterns.
0c. Study @IMPLEMENTATION_PLAN.md (if it exists) to understand the plan so far.

1. Use up to 10 parallel subagents to study the existing source code and tests, and compare them against `specs/*.md`. Then ultrathink: decide what is missing, incomplete or wrong, and write @IMPLEMENTATION_PLAN.md as a prioritized checklist of tasks that are not yet done. Also look for TODOs, placeholders, minimal implementations, and skipped or flaky tests related to the specs.

2. Use exactly this format for @IMPLEMENTATION_PLAN.md:

```
# Implementation plan

## Tasks
- [ ] <short imperative title> — <why / which spec>. Done when: <observable check, ideally a named test that must pass>.
...

## Questions for human
- <spec contradictions, missing decisions, or anything you'd otherwise have to guess>

## Discoveries
- <facts about the code that the build loop needs: patterns, gotchas, related bugs>

## Done
- <one line per completed task>
```

Task rules:
- Highest priority first. Each task must fit in ONE iteration: one focused change plus its tests, one commit.
- Every task states how it is verified ("Done when: ..."). Derive the checks from the acceptance criteria in the specs. If a criterion can't be tested automatically, say how it will be checked.
- If the project lacks the test infrastructure that a task's check needs, add a task for that infrastructure first.
- Keep existing `## Done` and `## Discoveries` entries that are still true. Remove tasks that are already implemented.

IMPORTANT: Plan only. Do NOT implement anything and do NOT edit any file except @IMPLEMENTATION_PLAN.md.
IMPORTANT: Don't assume something is not implemented. Confirm with a code search before adding a task.
IMPORTANT: Do not invent requirements beyond `specs/*.md`. When a spec is ambiguous or silent, add an item to "Questions for human" instead of guessing.

3. When done, commit only the plan: `git add IMPLEMENTATION_PLAN.md && git commit -m "plan: <one-line summary>"`. Do not push.
