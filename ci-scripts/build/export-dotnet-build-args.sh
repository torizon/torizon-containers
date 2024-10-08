#!/bin/bash

# Copyright (c) 2019-2024 Toradex AG
# SPDX-License-Identifier: MIT

set -x

apk update && apk add yq

yaml_file="$1"
key="$2"

DOTNET_RELEASE=$(yq e "explode(.).$key.release" "$yaml_file")
DOTNET_SEMVER=$(yq e "explode(.).$key.semver" "$yaml_file")
DOTNET_DEBUGGER_VER=$(yq e "explode(.).$key.debugger-version" "$yaml_file")

export DOTNET_RELEASE
export DOTNET_SEMVER
export DOTNET_DEBUGGER_VER
