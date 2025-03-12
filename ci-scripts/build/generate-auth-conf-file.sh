#!/bin/sh

# Copyright (c) 2019-2025 Toradex AG
# SPDX-License-Identifier: MIT

set -e

if [ -z $QT_IO_USERNAME ]; then
  echo "QT_IO_USERNAME not defined"
  exit 1
elif [ -z $QT_IO_PASSWORD ]; then
  echo "QT_IO_PASSWORD not defined"
  exit 1
fi

printf "%s\n%s\n%s\n" "machine https://debian-packages.qt.io" \
  "login ${QT_IO_USERNAME}" \
  "password ${QT_IO_PASSWORD}" >support-files/qt6-enterprise/qt-feed-auth.conf

chmod 600 support-files/qt6-enterprise/qt-feed-auth.conf
