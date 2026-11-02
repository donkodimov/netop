#!/usr/bin/env bash
# Ralph loop — fresh agent context per iteration, state lives on disk.
#
#   .ralph/loop.sh plan [N]                  gap analysis specs/* vs code -> IMPLEMENTATION_PLAN.md   (default N=1)
#   .ralph/loop.sh plan-work "<scope>" [N]   same, but only tasks for one piece of work               (default N=1)
#   .ralph/loop.sh [build] [N]               one task per iteration: implement, test, commit           (default N=10)
#
# Env:
#   RALPH_MODEL_PLAN / RALPH_MODEL_BUILD   model alias or id (default: opus / sonnet; use RALPH_MODEL_BUILD=opus for logic-heavy specs)
#   RALPH_NO_PUSH=1                        don't push after each iteration
#   RALPH_ALLOW_MAIN=1                     allow running on main/master (don't)
#   RALPH_DRY_RUN=1                        print the prompt instead of calling claude
#   RALPH_MAX_IDLE=2                       stop after this many iterations in a row with no new commit
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"
HERE=".ralph"
PLAN_FILE="IMPLEMENTATION_PLAN.md"
LOG_DIR="$HERE/logs"
MODEL_PLAN="${RALPH_MODEL_PLAN:-opus}"
MODEL_BUILD="${RALPH_MODEL_BUILD:-sonnet}"
MAX_IDLE="${RALPH_MAX_IDLE:-2}"

die() { echo "ralph: $*" >&2; exit 1; }

# ---------------------------------------------------------------- args
mode=build; scope=""
case "${1:-}" in
  plan)      mode=plan; shift ;;
  plan-work) mode=plan-work; shift; scope="${1:-}"; [[ -n "$scope" ]] || die 'plan-work needs a scope: plan-work "add a sticky save bar"'; shift ;;
  build)     shift ;;
  -h|--help) sed -n '2,15p' "$0"; exit 0 ;;
esac
if [[ "${1:-}" =~ ^[0-9]+$ ]]; then max="$1"
elif [[ -n "${1:-}" ]]; then die "unknown argument: $1 (see --help)"
elif [[ $mode == build ]]; then max=10
else max=1; fi

# ---------------------------------------------------------------- guards
command -v claude >/dev/null || die "claude CLI not found"
[[ -f AGENTS.md ]] || die "AGENTS.md missing — fill it in first"
ls specs/*.md >/dev/null 2>&1 || die "no specs/*.md — write at least one spec first"

branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$branch" == main || "$branch" == master ]] && [[ "${RALPH_ALLOW_MAIN:-0}" != 1 ]]; then
  die "refusing to run on '$branch'. Create a work branch first:  git checkout -b ralph/<topic>"
fi
if [[ $mode == plan-work ]] && [[ -n "$(git status --porcelain -- "$PLAN_FILE")" ]]; then
  die "$PLAN_FILE has uncommitted changes; commit or discard them before re-planning"
fi
if [[ $mode == build ]] && [[ ! -f "$PLAN_FILE" ]]; then
  die "no $PLAN_FILE — run '.ralph/loop.sh plan' (or plan-work) first"
fi

case $mode in
  plan)      prompt_file="$HERE/PROMPT_plan.md";      model="$MODEL_PLAN" ;;
  plan-work) prompt_file="$HERE/PROMPT_plan_work.md"; model="$MODEL_PLAN" ;;
  build)     prompt_file="$HERE/PROMPT_build.md";     model="$MODEL_BUILD" ;;
esac
[[ -f "$prompt_file" ]] || die "missing $prompt_file"
prompt="$(cat "$prompt_file")"
prompt="${prompt//'{{WORK_SCOPE}}'/$scope}"

mkdir -p "$LOG_DIR"
has_remote=0; git remote get-url origin >/dev/null 2>&1 && has_remote=1

# grep -c prints 0 AND exits 1 on no match, hence "|| true" rather than "|| echo 0".
count_lines() { if [[ -f "$PLAN_FILE" ]]; then grep -cE "$1" "$PLAN_FILE" || true; else echo 0; fi; }
open_tasks()    { count_lines '^[[:space:]]*- \[ \]'; }
blocked_tasks() { count_lines '^[[:space:]]*- \[!\]'; }

# Live view of the stream-json log: assistant text + one line per tool call + result summary.
pretty() {
  if command -v jq >/dev/null; then
    jq -rj --unbuffered '
      if .type == "assistant" then
        (.message.content[]? |
          if .type == "text" then .text + "\n"
          elif .type == "tool_use" then "  → \(.name) \(.input | tostring | .[0:140])\n"
          else empty end)
      elif .type == "result" then
        "== \(.subtype)  turns=\(.num_turns)  cost=$\(.total_cost_usd // "?")\n"
      else empty end' 2>/dev/null || cat >/dev/null
  else
    echo "(install jq for live output; raw log is being written)"; cat >/dev/null
  fi
}

trap 'echo; echo "ralph: interrupted"; exit 130' INT

echo "ralph: mode=$mode model=$model branch=$branch max=$max${scope:+ scope=\"$scope\"}"
total_cost=0; idle=0

for ((i = 1; i <= max; i++)); do
  if [[ $mode == build ]] && [[ "$(open_tasks)" -eq 0 ]]; then
    echo "ralph: no open '- [ ]' tasks left in $PLAN_FILE ($(blocked_tasks) blocked). Done."
    break
  fi

  log="$LOG_DIR/$(date +%Y%m%d-%H%M%S)-$mode-$i.jsonl"
  echo; echo "━━━━━━━━ iteration $i/$max  ($mode)  log: $log"
  before="$(git rev-parse HEAD)"

  if [[ "${RALPH_DRY_RUN:-0}" == 1 ]]; then
    printf '%s\n' "$prompt"; break
  fi

  set +e
  printf '%s' "$prompt" | claude -p \
      --dangerously-skip-permissions \
      --model "$model" \
      --output-format stream-json \
      --verbose \
    | tee "$log" | pretty
  status=${PIPESTATUS[1]}
  set -e
  [[ $status -eq 0 ]] || die "claude exited with status $status — see $log"

  cost="$(jq -r 'select(.type=="result") | .total_cost_usd // 0' "$log" 2>/dev/null | tail -1)"
  total_cost="$(awk -v a="$total_cost" -v b="${cost:-0}" 'BEGIN{printf "%.2f", a+b}')"

  after="$(git rev-parse HEAD)"
  if [[ "$before" == "$after" ]]; then
    idle=$((idle + 1))
    echo "ralph: no new commit this iteration ($idle/$MAX_IDLE)"
    if [[ $idle -ge $MAX_IDLE ]]; then echo "ralph: stuck — stopping. Check the log and add a sign."; break; fi
  else
    idle=0
    git --no-pager log --oneline "$before..$after"
    if [[ $has_remote == 1 && "${RALPH_NO_PUSH:-0}" != 1 ]]; then
      git push -q -u origin "$branch" || echo "ralph: push failed (continuing)"
    fi
  fi
  if [[ -n "$(git status --porcelain)" ]]; then
    echo "ralph: warning — uncommitted changes left behind:"; git status --short | head -20
  fi
  echo "ralph: open=$(open_tasks) blocked=$(blocked_tasks) total_cost=\$$total_cost"
done

echo; echo "ralph: finished. total_cost=\$$total_cost  open=$(open_tasks) blocked=$(blocked_tasks)"
if [[ "$(blocked_tasks)" -gt 0 ]]; then echo "ralph: see '## Questions for human' in $PLAN_FILE"; fi
