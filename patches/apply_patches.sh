#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(dirname "$script_dir")"

cd "$project_root"

# Apply patches in order
# Patches 1-4: submodule patches (need -p1 to strip the subdir prefix)
# Patch 5: root patch (uses a/ prefix, needs -p1)

echo "Applying patch 1: eglut - fix png_get_IHDR cast"
patch -d eglut -p1 < "$script_dir/0001-eglut-fix-png_get_IHDR-cast.patch"

echo "Applying patch 2: libc-shim - add SYS_getrandom fallback"
patch -d libc-shim -p1 < "$script_dir/0002-libc-shim-add-SYS_getrandom-fallback.patch"

echo "Applying patch 3: mcpelauncher-linker - fix __unused and format macros"
patch -d mcpelauncher-linker -p1 < "$script_dir/0003-linker-fix-__unused-and-format-macros.patch"

echo "Applying patch 4: mcpelauncher-client - OpenSSL 1.0.1 compat"
patch -d mcpelauncher-client -p1 < "$script_dir/0004-client-openssl-1.0.1-compat.patch"

echo "Applying patch 5: root - add global __STDC_FORMAT_MACROS"
patch -p1 < "$script_dir/0005-root-add-global-__STDC_FORMAT_MACROS.patch"

echo "All patches applied successfully."
