#!/bin/sh

set -ex


rm -rf ./build
mkdir -p ./build
mkdir -p ./build/debug

build_plugin () {
    rojo sourcemap src/plugin.project.json > src/sourcemap.json

    rm -rf ./roblox-src

    if [ $1 = dev ]
    then
        export DARKLUA_DEV='dev_mode'
        output=$2
    else
        output=$1
    fi
    darklua process src roblox-src

    cp src/plugin.project.json roblox-src

    rojo build roblox-src/plugin.project.json -o $output
}


build_plugin build/crosswalk-plugin.rbxm
# build debug asset
build_plugin dev build/debug/crosswalk-plugin.rbxm
