#!/usr/bin/env bash

set -eu

declare -r workdir="${PWD}"

declare -r apt="${CC/clang/apt}"

git clone https://github.com/minecraft-linux/mcpelauncher-manifest --recursive
cd mcpelauncher-manifest

patch --directory="${PWD}/eglut" --strip='1' --input="${workdir}/patches/0001-eglut-fix-png_get_IHDR-cast.patch"
patch --directory="${PWD}/libc-shim" --strip='1' --input="${workdir}/patches/0002-libc-shim-add-SYS_getrandom-fallback.patch"
#patch --directory="${PWD}/mcpelauncher-linker" --strip='1' --input="${workdir}/patches/0003-linker-fix-__unused-and-format-macros.patch"
patch --directory="${PWD}/mcpelauncher-client" --strip='1' --input="${workdir}/patches/0004-client-openssl-1.0.1-compat.patch"
patch --directory="${PWD}/libc-shim" --strip='1' --input="${workdir}/patches/0012-libc-shim-fixes.patch"

${apt} install -y libpng-dev libevdev-dev libudev-dev libx11-dev libegl1-mesa-dev libxi-dev libxcursor-dev libxrandr-dev libxss-dev libgl-dev libssl-dev

git clone https://github.com/LNSSPsd/arm64-mcpelauncher-server
cd arm64-mcpelauncher-server

#patch --directory="${PWD}/eglut" --strip='1' --input="${workdir}/patches/0001-eglut-fix-png_get_IHDR-cast.patch"
patch --directory="${PWD}" --strip='0' --input="${workdir}/patches/0002-libc-shim-add-SYS_getrandom-fallback.patch"
#patch --directory="${PWD}/mcpelauncher-linker" --strip='1' --input="${workdir}/patches/0003-linker-fix-__unused-and-format-macros.patch"
#patch --directory="${PWD}/mcpelauncher-client" --strip='1' --input="${workdir}/patches/0004-client-openssl-1.0.1-compat.patch"
patch --directory="${PWD}/libc-shim" --strip='1' --input="${workdir}/patches/0012-libc-shim-fixes.patch"

patch --directory="${PWD}/" --strip='1' --input="${workdir}/patches/0001-remove-stdlib-libcxx.patch"
patch --directory="${PWD}/" --strip='1' --input="${workdir}/patches/0003-fix-x86-64-asm-in-crash-handler.patch"
patch --directory="${PWD}/" --strip='1' --input="${workdir}/patches/0002-add-missing-includes-main-h.patch"

cmake -S . -B build -DBUILD_UI=OFF   -DBUILD_WEBVIEW=OFF   -DBUILD_CLIENT=ON   -DUSE_OWN_CURL=ON -DCMAKE_BUILD_TYPE='Release' -DCMAKE_INSTALL_PREFIX=/tmp/minecraft-linux
make -C build
make -C build install

