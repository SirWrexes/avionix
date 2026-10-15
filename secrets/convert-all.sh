#! /usr/bin/env nix
#! nix shell github:ryantm/agenix nixpkgs#coreutils nixpkgs#fd nixpkgs#gnused --command bash

set -euo pipefail

ROOT="$(realpath $(dirname $0))"
export AGENIX_RULES="${AGENIX_RULES:-$ROOT/rules.nix}"

cd "$ROOT"
echo "Working from $ROOT."

# Add here the extensions that need to be kept in the resulting filename.
keep_extensions+=(prv)
keep_extensions+=(pub)
keep_extensions+=(mpq)

echo "These extensions won't be stripped from file names (case insensitive):"
for ext in "${keep_extensions[@]}"; do
  echo "  • $ext"
done

IFS='|'
  ext_pattern="(${keep_extensions[*],,})"
  export ext_pattern
unset IFS


fd  --type f \
    --unrestricted \
    --exclude ".gitignore" \
    --exclude "*.age" \
    --exclude "rules.nix" \
    --exclude "$(basename $0)" \
    -x bash -c '
      file="$1"
      ext="${file##*.}"
      base="$(basename "$file")"

      if [[ "$base" =~ ^\.[^.]*$ || "${ext,,}" =~ ^${ext_pattern}$ ]]; then
        target="${file}.age"
      else
        target="${file%.*}.age"
      fi

      echo "🔒 $(realpath "$file") -> $(realpath "$target")"
      EDITOR="cp $file" agenix -e "$target"
    ' _ {}
