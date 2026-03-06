#!/usr/bin/env bash
set -euo pipefail

failed=0

print_header() {
    if [ "$failed" -eq 0 ]; then
        echo "gitlocal: blocked commit of local-only files:"
        echo
    fi
}

# Find directories containing .gitlocal markers or *.gitlocal files
gitlocal_dirs=()
while IFS= read -r dir; do
    gitlocal_dirs+=("$dir")
done < <(find . \( -name .gitlocal -o -name '*.gitlocal' \) -not -path './.git/*' 2>/dev/null | xargs -I{} dirname {} | sort -u)

for dir in "${gitlocal_dirs[@]+"${gitlocal_dirs[@]}"}"; do
    dir="${dir#./}"
    staged=$(git diff --cached --name-only -- "$dir" 2>/dev/null || true)
    if [ -n "$staged" ]; then
        print_header
        while IFS= read -r file; do
            echo "  $file (marked by $dir/.gitlocal)"
        done <<< "$staged"
        failed=1
    fi
done

# Check staged files for a # gitlocal comment on the first line
while IFS= read -r file; do
    first_line=$(git show ":$file" 2>/dev/null | head -n 1 || true)
    if echo "$first_line" | grep -qi '# gitlocal' 2>/dev/null; then
        print_header
        echo "  $file (first line contains # gitlocal)"
        failed=1
    fi
done < <(git diff --cached --name-only 2>/dev/null)

if [ "$failed" -ne 0 ]; then
    echo
    echo "Remove these files from staging with: git reset HEAD <file>"
    exit 1
fi
