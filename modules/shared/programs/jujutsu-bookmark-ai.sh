set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: jj bai [-r REVSET]

Create an alexey/<slug> bookmark at REVSET, with the slug generated from the
revision's descriptions and changed paths.
USAGE
}

sanitize_slug() {
  tr '[:upper:]' '[:lower:]' \
    | sed -E '
      s/^[[:space:]]+//;
      s/[[:space:]]+$//;
      s#^alexey/##;
      s/[^a-z0-9]+/-/g;
      s/^-+//;
      s/-+$//;
      s/-+/-/g;
    ' \
    | cut -c 1-50 \
    | sed -E 's/-+$//'
}

generate_with_codex() {
  if ! command -v codex >/dev/null 2>&1; then
    printf 'jj bai: codex command not found\n' >&2
    return 127
  fi

  local output
  output=$(mktemp)
  local codex_cwd
  codex_cwd=$(mktemp -d)

  local status=0
  timeout "${JJ_BAI_CODEX_TIMEOUT:-30s}" \
    codex exec \
      --ephemeral \
      --ignore-user-config \
      --ignore-rules \
      --skip-git-repo-check \
      --sandbox read-only \
      --color never \
      -m "${JJ_BAI_CODEX_MODEL:-gpt-5.4-mini}" \
      -c "model_reasoning_effort=\"${JJ_BAI_CODEX_REASONING:-low}\"" \
      -C "$codex_cwd" \
      --output-last-message "$output" \
      - <<PROMPT >/dev/null 2>/dev/null || status=$?
Generate a concise jj bookmark slug for the revision set below.

Rules:
- Output exactly one slug and nothing else.
- Use lowercase words separated by hyphens.
- Use 2 to 5 short words.
- Do not include a user prefix such as alexey/.
- Prefer the change intent over file names when the intent is clear.

Revision set:
$rev

Commit descriptions:
$log_context

Changed files:
$summary
PROMPT

  if [[ "$status" -ne 0 ]]; then
    rm -f "$output"
    rm -rf "$codex_cwd"
    return "$status"
  fi

  local candidate
  candidate=$(sed -n '/[[:alnum:]]/ { p; q; }' "$output")
  rm -f "$output"
  rm -rf "$codex_cwd"

  [[ -n "$candidate" ]] || return 1
  printf '%s\n' "$candidate"
}

bookmark_exists() {
  local name=$1
  jj bookmark list --all-remotes "$name" --template 'name ++ "\n"' 2>/dev/null \
    | grep -Fxq "$name"
}

rev="@"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h | --help)
      usage
      exit 0
      ;;
    -r | --revision | --to)
      if [[ $# -lt 2 ]]; then
        printf 'jj bai: %s requires a revision\n' "$1" >&2
        exit 2
      fi
      rev=$2
      shift 2
      ;;
    -r=* | --revision=* | --to=*)
      rev=${1#*=}
      shift
      ;;
    -r?*)
      rev=${1#-r}
      shift
      ;;
    *)
      printf 'jj bai: unsupported argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$rev" ]]; then
  printf 'jj bai: revision must not be empty\n' >&2
  exit 2
fi

if ! summary=$(jj --color never diff -r "$rev" --summary); then
  printf 'jj bai: failed to inspect revision: %s\n' "$rev" >&2
  exit 1
fi

log_context=$(jj --color never log -r "$rev" --no-graph -T 'description.first_line() ++ "\n"' | head -c 4000 || true)

slug=""
if ! candidate=$(generate_with_codex); then
  printf 'jj bai: failed to generate bookmark slug with Codex\n' >&2
  exit 1
fi
slug=$(printf '%s' "$candidate" | sanitize_slug)

if [[ -z "$slug" ]]; then
  printf 'jj bai: Codex did not produce a usable slug\n' >&2
  exit 1
fi

base_name="alexey/$slug"
name="$base_name"
suffix=2

while bookmark_exists "$name"; do
  name="$base_name-$suffix"
  suffix=$((suffix + 1))
done

jj bookmark create -r "$rev" "$name"
printf 'Created bookmark: %s\n' "$name"
