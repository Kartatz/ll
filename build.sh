#!/usr/bin/env bash

declare -r workdir="${PWD}"

declare -r apt="${CC/clang/apt}"

git clone https://github.com/minecraft-linux/mcpelauncher-manifest
cd mcpelauncher-manifest

$workdir/patches/apply_patches.sh

${apt} install -y libpng-dev libevdev-dev libudev-dev libx11-dev libegl1-mesa-dev libxi-dev libxcursor-dev libxrandr-dev libxss-dev libgl-dev libssl-dev

cmake -S . -B build -DCMAKE_INSTALL_PREFIX=/tmp/minecraft-linux
make -C build
make -C build install

