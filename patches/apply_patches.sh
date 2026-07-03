#!/usr/bin/env bash
set -eu

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
manifest_dir="${1:-${PWD}/mcpelauncher-manifest}"

if [ ! -d "${manifest_dir}/.git" ]; then
    git clone https://github.com/minecraft-linux/mcpelauncher-manifest --recursive "${manifest_dir}"
fi

cd "${manifest_dir}"

# Patch -> target submodule directory
apply_patch() {
    local file="$1" dir="$2"
    printf 'Applying %s in %s ...\n' "$(basename "$file")" "$dir"
    patch --directory="$dir" --strip='1' --forward --input="$file"
}

# Order matters: later patches may depend on earlier ones having been applied
# to the same submodule.
apply_patch "${script_dir}/0001-eglut-fix-png_get_IHDR-cast.patch"              "${manifest_dir}/eglut"
apply_patch "${script_dir}/0002-libc-shim-add-SYS_getrandom-fallback.patch"     "${manifest_dir}/libc-shim"
apply_patch "${script_dir}/0003-linker-fix-__unused-and-format-macros.patch"    "${manifest_dir}/mcpelauncher-linker"
apply_patch "${script_dir}/0004-client-openssl-1.0.1-compat.patch"               "${manifest_dir}/mcpelauncher-client"
apply_patch "${script_dir}/0005-root-cxx-standard-23-and-format-macros.patch"   "${manifest_dir}"
apply_patch "${script_dir}/0006-linker-cxx-standard-23.patch"                    "${manifest_dir}/mcpelauncher-linker"
apply_patch "${script_dir}/0007-mcpelauncher-apkinfo-cxx-standard-23.patch"     "${manifest_dir}/mcpelauncher-apkinfo"
apply_patch "${script_dir}/0008-file-util-cxx-standard-23.patch"                 "${manifest_dir}/file-util"
apply_patch "${script_dir}/0009-axml-parser-cxx-standard-23.patch"              "${manifest_dir}/axml-parser"
apply_patch "${script_dir}/0010-simple-ipc-cxx-standard-23.patch"               "${manifest_dir}/simple-ipc"
apply_patch "${script_dir}/0011-libjnivm-cxx-standard-23.patch"                 "${manifest_dir}/libjnivm"
apply_patch "${script_dir}/0012-libc-shim-fixes.patch"                          "${manifest_dir}/libc-shim"
apply_patch "${script_dir}/0013-msa-daemon-client-json-fix.patch"               "${manifest_dir}/msa-daemon-client"

echo '=== All patches applied successfully ==='
