# Writing specs for Ralph

Every file in `specs/` is something Ralph will try to build. Planning compares `specs/*.md` with the code and turns the gaps into tasks. Keep specs that aren't meant to be built yet somewhere else, such as `docs/`.

## Rules

1. **One topic per file.** Describe the topic in one sentence. If the sentence needs an "and" joining unrelated capabilities, split the file.
2. **Describe the target, not the current state.** Leave out "Current behavior" sections. Ralph works out the current state from the code, and those sections go stale after the first commit.
3. **Write decisions only.** Leave out "proposed", "maybe" and open questions. If something isn't decided, decide it before running the loop, or mark it out of scope.
4. **Make acceptance criteria observable.** Say what a test or a person can check, not how to implement it. Write "Save stays visible while editing the last product", not "use position: sticky".
5. **Keep it short.** Aim for 30–80 lines per spec. All specs together should stay well under ~5k tokens, because every iteration reads them.
6. **Make scope explicit.** A short "Out of scope" list stops Ralph from gold-plating.

## Template

```markdown
# <Topic>

<One or two sentences: who it is for and what outcome it gives them.>

## Requirements
- <decided behavior>
- <decided behavior>

## Constraints
- <tech, UX or brand rules the implementation must respect>

## Acceptance criteria
1. <observable check — will become a test>
2. <observable check>

## Out of scope
- <things Ralph must not add>
```

## Lifecycle

- **New work:** write the spec, create a `ralph/<topic>` branch, then run `plan-work "<topic>"` and `build N`.
- **Spec changed:** run planning again. The plan is disposable.
- **Work finished and merged:** keep the spec. It still describes the system, and later planning runs will confirm it's met.
- **Feature idea not ready yet:** keep it in `docs/`, not `specs/`.
