#!/bin/sh

# Copyright (c) 2019-2023 Toradex AG
# SPDX-License-Identifier: MIT

if [ $# -ne 3 ]; then
    echo "Usage: $0 <channel_id> <slack_token> <message>"
    exit 1
fi

channel_id="$1"
slack_token="$2"
message="$3"

curl -X POST \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $slack_token" \
-d "{\"channel\": \"$channel_id\", \"text\": \"$message\"}" \
https://slack.com/api/chat.postMessage

