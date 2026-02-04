#!/bin/sh

FILES="$(find . -type f -not -path '*/.*' -not -name '*.gz')"

echo "======== Files found ========"
printf "%s\n" "$FILES"
echo "============================="

ERROR=0

echo "=== Checking line endings ==="
for f in $FILES; do
  if file "$f" | grep -q CRLF; then
    echo "Error: $f has non-Unix line endings"
    ERROR=1
  fi
done
echo "============================="

exit $ERROR
