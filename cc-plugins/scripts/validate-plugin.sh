#!/usr/bin/env bash
set -euo pipefail

# Validate plugin.json and all SKILL.md files in the repo.
# Exit code 0 = all checks pass, non-zero = failures found.

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ERRORS=0

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

pass() { echo -e "  ${GREEN}✓${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }

# ============================================================
# 1. Validate plugin.json
# ============================================================
echo ""
echo "Validating plugin.json..."

PLUGIN_JSON="$REPO_ROOT/plugin.json"

if [ ! -f "$PLUGIN_JSON" ]; then
  fail "plugin.json not found at repo root"
else
  # Valid JSON?
  if ! python3 -c "import json, sys; json.load(open(sys.argv[1]))" "$PLUGIN_JSON" 2>/dev/null; then
    fail "plugin.json is not valid JSON"
  else
    pass "Valid JSON"

    # Required top-level fields
    for field in name description version skills; do
      if python3 -c "
import json, sys
d = json.load(open(sys.argv[1]))
assert '$field' in d
" "$PLUGIN_JSON" 2>/dev/null; then
        pass "Has required field: $field"
      else
        fail "Missing required field: $field"
      fi
    done

    # skills array validation
    python3 -c "
import json, sys, os

d = json.load(open(sys.argv[1]))
skills = d.get('skills', [])
if not isinstance(skills, list):
    print('FAIL:skills is not an array')
    sys.exit(0)

repo_root = sys.argv[2]
for i, skill in enumerate(skills):
    name = skill.get('name')
    path = skill.get('path')
    desc = skill.get('description')

    if not name:
        print(f'FAIL:skills[{i}] missing name')
    if not path:
        print(f'FAIL:skills[{i}] missing path')
    if not desc:
        print(f'FAIL:skills[{i}] missing description')

    # Check that the skill path exists
    if path:
        full_path = os.path.join(repo_root, path)
        if not os.path.isdir(full_path):
            print(f'FAIL:skills[{i}] path \"{path}\" does not exist')
        else:
            skill_md = os.path.join(full_path, 'SKILL.md')
            if not os.path.isfile(skill_md):
                print(f'FAIL:skills[{i}] no SKILL.md found at {path}/SKILL.md')
" "$PLUGIN_JSON" "$REPO_ROOT" | while IFS= read -r line; do
      if [[ "$line" == FAIL:* ]]; then
        fail "${line#FAIL:}"
      fi
    done

    pass "All skills in plugin.json reference valid paths"
  fi
fi

# ============================================================
# 2. Validate each SKILL.md
# ============================================================
echo ""
echo "Validating SKILL.md files..."

find "$REPO_ROOT/skills" -name "SKILL.md" 2>/dev/null | while IFS= read -r skill_file; do
  rel_path="${skill_file#$REPO_ROOT/}"
  echo ""
  echo "  Checking $rel_path..."

  # Has YAML frontmatter?
  first_line=$(head -1 "$skill_file")
  if [ "$first_line" != "---" ]; then
    fail "$rel_path: Missing YAML frontmatter (must start with ---)"
    continue
  fi

  # Extract frontmatter
  frontmatter=$(sed -n '1,/^---$/{ /^---$/d; p; }' "$skill_file" | tail -n +1)

  # Check for 'name' field
  if echo "$frontmatter" | grep -q "^name:"; then
    pass "$rel_path: Has 'name' in frontmatter"
  else
    fail "$rel_path: Missing 'name' in frontmatter"
  fi

  # Check for 'description' field
  if echo "$frontmatter" | grep -q "^description:"; then
    pass "$rel_path: Has 'description' in frontmatter"
  else
    fail "$rel_path: Missing 'description' in frontmatter"
  fi

  # Check description uses third person
  desc_line=$(echo "$frontmatter" | grep "^description:" | head -1)
  # For multiline descriptions, grab everything after description:
  if echo "$frontmatter" | grep -q "description: >"; then
    # Multiline — check second line of description block
    desc_content=$(sed -n '/^description:/,/^[a-z]/{ /^description:/d; /^[a-z]/d; p; }' "$skill_file" | head -3)
  else
    desc_content="$desc_line"
  fi

  if echo "$desc_content" | grep -qi "this skill should be used"; then
    pass "$rel_path: Description uses third person"
  else
    warn "$rel_path: Description should start with 'This skill should be used when...'"
  fi

  # Check body word count (rough estimate excluding frontmatter and code blocks)
  body=$(sed '1,/^---$/d' "$skill_file" | sed '/^```/,/^```/d')
  word_count=$(echo "$body" | wc -w | tr -d ' ')
  if [ "$word_count" -gt 5000 ]; then
    warn "$rel_path: Body is $word_count words (consider moving detail to references/)"
  else
    pass "$rel_path: Body word count OK ($word_count words)"
  fi
done

# ============================================================
# Summary
# ============================================================
echo ""
if [ "$ERRORS" -gt 0 ]; then
  echo -e "${RED}Validation failed with $ERRORS error(s)${NC}"
  exit 1
else
  echo -e "${GREEN}All validations passed${NC}"
  exit 0
fi
