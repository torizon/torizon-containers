#!/bin/bash

# Copyright (c) 2019-2023 Toradex AG
# SPDX-License-Identifier: MIT

set -x

apk update && apk add yq

yaml_file="$1"
key="$2"

export DOTNET_RELEASE=$(yq e "explode(.).$key.release" "$yaml_file")
export DOTNET_SEMVER=$(yq e "explode(.).$key.semver" "$yaml_file")
export DOTNET_DEBUGGER_VER=$(yq e "explode(.).$key.debugger-version" "$yaml_file")
