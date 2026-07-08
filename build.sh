#!/usr/bin/env bash

set -eu

declare -r workdir="${PWD}"
declare -r deps='libpng-dev libevdev-dev libudev-dev libx11-dev libegl1-mesa-dev libxi-dev libxcursor-dev libxrandr-dev libxss-dev libgl-dev libssl-dev'

declare -r APT="${CC/clang/apt}"

git clone https://github.com/minecraft-linux/mcpelauncher-manifest --recursive
cd mcpelauncher-manifest

patch --directory="${PWD}/eglut" --strip='1' --input="${workdir}/patches/0001-eglut-fix-png_get_IHDR-cast.patch"
patch --directory="${PWD}/libc-shim" --strip='1' --input="${workdir}/patches/0002-libc-shim-add-SYS_getrandom-fallback.patch"
#patch --directory="${PWD}/mcpelauncher-linker" --strip='1' --input="${workdir}/patches/0003-linker-fix-__unused-and-format-macros.patch"
patch --directory="${PWD}/mcpelauncher-client" --strip='1' --input="${workdir}/patches/0004-client-openssl-1.0.1-compat.patch"
patch --directory="${PWD}/libc-shim" --strip='1' --input="${workdir}/patches/0012-libc-shim-fixes.patch"

${APT} install -y ${deps}

cmake -S . -B build -DBUILD_UI=OFF   -DBUILD_WEBVIEW=OFF   -DBUILD_CLIENT=ON   -DUSE_OWN_CURL=ON -DCMAKE_BUILD_TYPE='Release' -DCMAKE_INSTALL_PREFIX=/tmp/minecraft-linux
make -C build
make -C build install

git clone https://github.com/LNSSPsd/arm64-mcpelauncher-server --recursive
cd arm64-mcpelauncher-server

#patch --directory="${PWD}/eglut" --strip='1' --input="${workdir}/patches/0001-eglut-fix-png_get_IHDR-cast.patch"
patch --directory="${PWD}" --strip='0' --input="${workdir}/patches/0002-libc-shim-add-SYS_getrandom-fallback.patch"
#patch --directory="${PWD}/mcpelauncher-linker" --strip='1' --input="${workdir}/patches/0003-linker-fix-__unused-and-format-macros.patch"
#patch --directory="${PWD}/mcpelauncher-client" --strip='1' --input="${workdir}/patches/0004-client-openssl-1.0.1-compat.patch"
patch --directory="${PWD}/libc-shim" --strip='1' --input="${workdir}/patches/0012-libc-shim-fixes.patch"

patch --directory="${PWD}/" --strip='1' --input="${workdir}/patches/0001-remove-stdlib-libcxx.patch"
patch --directory="${PWD}/" --strip='1' --input="${workdir}/patches/0001-Replace-inline-asm-with-__builtin_frame_address-__bu.patch"
patch --directory="${PWD}/" --strip='1' --input="${workdir}/patches/0002-add-missing-includes-main-h.patch"
patch --directory="${PWD}/" --strip='1' --input="${workdir}/patches/0001-Add-install-rules-for-binaries-and-libraries.patch"

cmake -S . -B build -DCMAKE_INSTALL_RPATH='$ORIGIN/../lib' -DCMAKE_BUILD_TYPE='Release' -DCMAKE_INSTALL_PREFIX=/tmp/minecraft-linux
make -C build
make -C build install

${APT} copy ${deps} --outputdir /tmp/minecraft-linux/lib
