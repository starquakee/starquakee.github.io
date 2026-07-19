#!/usr/bin/env bash
# Ralph autonomous development loop.
# Usage:
#   scripts/ralph/ralph.sh [--tool codex|claude|amp] [--dry-run] [max_iterations]

set -euo pipefail

TOOL="codex"
MAX_ITERATIONS=10
DRY_RUN=0
CODEX_BIN="${RALPH_CODEX_BIN:-codex}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tool)
      TOOL="$2"
      shift 2
      ;;
    --tool=*)
      TOOL="${1#*=}"
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    *)
      if [[ "$1" =~ ^[0-9]+$ ]]; then
        MAX_ITERATIONS="$1"
      fi
      shift
      ;;
  esac
done

if [[ "$TOOL" != "codex" && "$TOOL" != "claude" && "$TOOL" != "amp" ]]; then
  echo "Error: invalid tool '$TOOL'. Use codex, claude, or amp." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"
PRD_FILE="$REPO_ROOT/prd.json"
PROGRESS_FILE="$REPO_ROOT/progress.txt"
ARCHIVE_DIR="$REPO_ROOT/archive"
LAST_BRANCH_FILE="$SCRIPT_DIR/.last-branch"

read_branch_name() {
  [[ -f "$PRD_FILE" ]] || return 0
  if command -v jq >/dev/null; then
    jq -r '.branchName // empty' "$PRD_FILE" 2>/dev/null || true
  elif command -v node >/dev/null; then
    node -e "const fs=require('fs'); try { const data=JSON.parse(fs.readFileSync(process.argv[1], 'utf8')); console.log(data.branchName || ''); } catch { process.exit(0); }" "$PRD_FILE"
  elif command -v python3 >/dev/null; then
    python3 -c "import json,sys; print((json.load(open(sys.argv[1])).get('branchName') or ''))" "$PRD_FILE" 2>/dev/null || true
  fi
}

has_json_reader() {
  command -v jq >/dev/null || command -v node >/dev/null || command -v python3 >/dev/null
}

tool_available() {
  case "$TOOL" in
    codex) command -v "$CODEX_BIN" >/dev/null || [[ -x "$CODEX_BIN" ]] ;;
    claude) command -v claude >/dev/null ;;
    amp) command -v amp >/dev/null ;;
  esac
}

CURRENT_BRANCH="$(read_branch_name)"

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "Ralph dry run"
  echo "  repo root: $REPO_ROOT"
  echo "  prd file: $PRD_FILE"
  echo "  progress file: $PROGRESS_FILE"
  echo "  archive dir: $ARCHIVE_DIR"
  echo "  branch: ${CURRENT_BRANCH:-<missing>}"
  echo "  tool: $TOOL"

  has_json_reader || { echo "Error: jq, node, or python3 is required to read prd.json" >&2; exit 1; }
  [[ -f "$PRD_FILE" ]] || { echo "Error: missing $PRD_FILE" >&2; exit 1; }
  [[ -n "$CURRENT_BRANCH" ]] || { echo "Error: prd.json branchName is missing" >&2; exit 1; }
  [[ -f "$PROGRESS_FILE" ]] || { echo "Error: missing $PROGRESS_FILE" >&2; exit 1; }
  [[ -d "$ARCHIVE_DIR" ]] || { echo "Error: missing $ARCHIVE_DIR" >&2; exit 1; }
  [[ -f "$SCRIPT_DIR/AGENTS.md" ]] || { echo "Error: missing $SCRIPT_DIR/AGENTS.md" >&2; exit 1; }
  tool_available || { echo "Error: tool '$TOOL' is unavailable" >&2; exit 1; }

  echo "Dry run OK"
  exit 0
fi

if [[ -f "$PRD_FILE" && -f "$LAST_BRANCH_FILE" ]]; then
  LAST_BRANCH="$(cat "$LAST_BRANCH_FILE" 2>/dev/null || true)"
  if [[ -n "$CURRENT_BRANCH" && -n "$LAST_BRANCH" && "$CURRENT_BRANCH" != "$LAST_BRANCH" ]]; then
    DATE="$(date +%Y-%m-%d)"
    FOLDER_NAME="$(echo "$LAST_BRANCH" | sed 's|^ralph/||')"
    ARCHIVE_FOLDER="$ARCHIVE_DIR/$DATE-$FOLDER_NAME"
    echo "Archiving previous run: $LAST_BRANCH"
    mkdir -p "$ARCHIVE_FOLDER"
    cp "$PRD_FILE" "$ARCHIVE_FOLDER/" 2>/dev/null || true
    cp "$PROGRESS_FILE" "$ARCHIVE_FOLDER/" 2>/dev/null || true
    {
      echo "# Ralph Progress Log"
      echo "Started: $(date)"
      echo "---"
    } > "$PROGRESS_FILE"
  fi
fi

if [[ -n "$CURRENT_BRANCH" ]]; then
  echo "$CURRENT_BRANCH" > "$LAST_BRANCH_FILE"
fi

if [[ ! -f "$PROGRESS_FILE" ]]; then
  {
    echo "# Ralph Progress Log"
    echo "Started: $(date)"
    echo "---"
  } > "$PROGRESS_FILE"
fi

echo "Starting Ralph - Tool: $TOOL - Max iterations: $MAX_ITERATIONS"

for i in $(seq 1 "$MAX_ITERATIONS"); do
  echo ""
  echo "==============================================================="
  echo "  Ralph Iteration $i of $MAX_ITERATIONS ($TOOL)"
  echo "==============================================================="

  if [[ "$TOOL" == "codex" ]]; then
    OUTPUT="$("$CODEX_BIN" exec --dangerously-bypass-approvals-and-sandbox - < "$SCRIPT_DIR/AGENTS.md" 2>&1)" || true
    echo "$OUTPUT"
    if echo "$OUTPUT" | grep -q "^assistant"; then
      OUTPUT="$(echo "$OUTPUT" | awk 'BEGIN{found=0} /^assistant/{found=1;next} {if(found) print}')"
    elif echo "$OUTPUT" | grep -q "^tokens used"; then
      OUTPUT="$(echo "$OUTPUT" | awk 'BEGIN{found=0} /^tokens used/{found=1} {if(found) print}')"
    fi
  elif [[ "$TOOL" == "claude" ]]; then
    OUTPUT="$(claude --dangerously-skip-permissions --print < "$SCRIPT_DIR/AGENTS.md" 2>&1)" || true
    echo "$OUTPUT"
  else
    OUTPUT="$(cat "$SCRIPT_DIR/AGENTS.md" | amp --dangerously-allow-all 2>&1)" || true
    echo "$OUTPUT"
  fi

  if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
    echo ""
    echo "Ralph completed all tasks!"
    echo "Completed at iteration $i of $MAX_ITERATIONS"
    exit 0
  fi

  echo "Iteration $i complete. Continuing..."
  sleep 2
done

echo ""
echo "Ralph reached max iterations ($MAX_ITERATIONS) without completing all tasks."
echo "Check $PROGRESS_FILE for status."
exit 1
