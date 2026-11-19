#!/bin/sh
# Audit Forge — scaffold a local audit workspace.
# Usage: sh scripts/audit-init.sh /path/to/repo-copy <commit>
# Creates <repo-copy>-audit/ with src/, test/, and a foundry.toml.
# No network access, no chain access. Work happens in the copy only.
set -e

if [ "$#" -ne 2 ]; then
  echo "usage: sh scripts/audit-init.sh /path/to/repo-copy <commit>" >&2
  exit 1
fi

REPO="$1"
COMMIT="$2"
WORK="${REPO}-audit"

if [ ! -d "$REPO" ]; then
  echo "not a directory: $REPO" >&2
  exit 1
fi

mkdir -p "$WORK/src" "$WORK/test" "$WORK/lib"

# Copy the contracts under review into the workspace. The original repo
# is never edited; the workspace is where PoCs live.
cp -r "$REPO"/* "$WORK/src/" 2>/dev/null || true

cat > "$WORK/foundry.toml" <<'EOF'
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc = "0.8.20"
EOF

cat > "$WORK/SCOPE.md" <<EOF
# Audit scope

- Repository copy: $REPO
- Commit: $COMMIT
- Workspace: $WORK
- In scope: (fill in — file paths, one per line)
- Out of scope: (fill in — file paths, one per line)
- Frozen on: $(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

echo "workspace ready: $WORK"
echo "scope file: $WORK/SCOPE.md (fill in in/out of scope, then start the first pass)"
echo "run PoCs with: cd $WORK && forge test"
