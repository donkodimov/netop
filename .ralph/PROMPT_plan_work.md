WORK SCOPE: {{WORK_SCOPE}}

0a. Study `specs/*.md` with up to 5 parallel subagents to learn what the application must do.
0b. Study @AGENTS.md to learn the project layout, how to build and test, and the codebase patterns.

1. Use up to 10 parallel subagents to study the existing source code and tests, and compare them against the parts of `specs/*.md` that belong to the WORK SCOPE above. Then ultrathink: decide what is missing, incomplete or wrong for that scope only, and REPLACE @IMPLEMENTATION_PLAN.md with a prioritized checklist for this scope.

Be conservative. Include a task only if it is clearly required for the WORK SCOPE. Leave out related improvements and nice-to-haves, and anything other specs describe. Each task must change the code; a task to verify, double-check or test only already-working behavior is never an implementation task. If an acceptance criterion is already met by the existing code, don't add a task for it. Record it under "## Discoveries" as `<criterion>: already met by <file/function>`.

2. Use exactly this format for @IMPLEMENTATION_PLAN.md:

```
# Implementation plan — {{WORK_SCOPE}}

## Tasks
- [ ] <short imperative title> — <why / which spec>. Done when: <observable check, ideally a named test that must pass>.
...

## Questions for human
- <spec contradictions, missing decisions, or anything you'd otherwise have to guess>

## Discoveries
- <facts about the code that the build loop needs: patterns, gotchas, related bugs>

## Done
```

Task rules:
- Highest priority first. Each task must fit in ONE iteration: one focused change plus its tests, one commit.
- Every task states how it is verified ("Done when: ..."). Derive the checks from the spec's acceptance criteria.
- If the project lacks the test infrastructure that a task's check needs, add a task for that infrastructure first.

IMPORTANT: Plan only. Do NOT implement anything and do NOT edit any file except @IMPLEMENTATION_PLAN.md.
IMPORTANT: Don't assume something is not implemented. Confirm with a code search before adding a task.
IMPORTANT: Do not invent requirements. When the spec is ambiguous or silent, add an item to "Questions for human" instead of guessing.

3. When done, commit only the plan: `git add IMPLEMENTATION_PLAN.md && git commit -m "plan: {{WORK_SCOPE}}"`. Do not push.
