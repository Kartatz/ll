#!/usr/bin/env bash

set -eu

declare -r prefix='/tmp/minecraft-linux'
declare -r workdir="${PWD}"
declare -r deps='libpng-dev libevdev-dev libudev-dev libx11-dev libegl1-mesa-dev libxi-dev libxcursor-dev libxrandr-dev libxss-dev libgl-dev libssl-dev'

git clone https://github.com/minecraft-linux/mcpelauncher-manifest --recursive
cd mcpelauncher-manifest

patch --directory="${PWD}/eglut" --strip='1' --input="${workdir}/patches/0001-eglut-fix-png_get_IHDR-cast.patch"
patch --directory="${PWD}/libc-shim" --strip='1' --input="${workdir}/patches/0002-libc-shim-add-SYS_getrandom-fallback.patch"
patch --directory="${PWD}/mcpelauncher-client" --strip='1' --input="${workdir}/patches/0004-client-openssl-1.0.1-compat.patch"
patch --directory="${PWD}/libc-shim" --strip='1' --input="${workdir}/patches/0012-libc-shim-fixes.patch"

"${APT}" install ${deps}

cmake \
	-S "${PWD}" \
	-B "${PWD}/build" \
	-DBUILD_UI=OFF \
	-DBUILD_WEBVIEW=OFF \
	-DBUILD_CLIENT=ON \
	-DUSE_OWN_CURL=ON \
	-DCMAKE_BUILD_TYPE='Release' \
	-DCMAKE_INSTALL_RPATH='$ORIGIN/../lib' \
	-DCMAKE_INSTALL_PREFIX="${prefix}"

cmake --build 'build' -- --jobs
cmake --install 'build' --strip

"${APT}" copylibs ${deps} --outputdir "${prefix}"
