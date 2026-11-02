0a. Study `specs/*.md` with up to 5 parallel subagents to learn what the application must do.
0b. Study @AGENTS.md: the project layout, the validation commands, and the codebase patterns.
0c. Study @IMPLEMENTATION_PLAN.md.

1. Choose the most important open `- [ ]` task in @IMPLEMENTATION_PLAN.md. Work on that ONE task only.
   Before changing code, search the codebase with subagents. Don't assume something is not implemented. If the task is already done, check it off with a note and go to step 5.

2. Implement the task completely. No placeholders, stubs or TODOs. Follow the existing patterns and reuse existing helpers instead of making near-duplicates. Write or extend the tests named in the task's "Done when". If they don't exist yet, create them. Tests must check observable behavior.

3. Run the validation commands from @AGENTS.md. Use only 1 subagent for build and test runs. If anything fails, including tests unrelated to your change, fix it before you continue. Add temporary logging if you need it to debug, and remove it before you commit.
   If you cannot make validation pass after a few serious attempts, revert your code changes (`git restore`/`git clean` on files you touched). Mark the task `- [!]`, and add the reason and what you tried under "## Questions for human". Then go to step 5.

4. Update @IMPLEMENTATION_PLAN.md: move the completed task to "## Done" as one line. Add anything future iterations need to know under "## Discoveries", including bugs you noticed but did not fix. Remove entries that are no longer true.

5. If you learned something operational, such as how to run, test or debug the project, add a short note to @AGENTS.md. Put only operational facts there; progress belongs in the plan.

6. Commit: `git add -A && git commit -m "<what changed and why>"`. Do not push. Then STOP. One task per iteration.

99. Capture the why: tests and code comments should explain intent where it isn't obvious.
999. One source of truth: no copies of logic, no compatibility shims, no parallel implementations.
9999. Never edit `specs/*.md`. If a spec is wrong, contradictory or silent on something you need, record it under "## Questions for human" and choose the most conservative option, or mark the task `- [!]`.
99999. Never weaken, skip or delete a test to make it pass unless the spec changed the behavior it checks. Say so in the commit message if you do.
999999. Respect everything in the "Never" section of @AGENTS.md. Never push, deploy, change CI configuration, or read or write secrets or `.env` files.
9999999. Keep @IMPLEMENTATION_PLAN.md short. Prune stale discoveries, and keep "## Done" to one line per task.
