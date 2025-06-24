#!/bin/bash

PODFILE_LOCKS=()
POD_DIRS=()
while IFS= read -r -d '' FILE; do
  echo "Found Podfile.lock: $FILE"
  PODFILE_LOCKS+=("$FILE")
  POD_DIRS+=("$(dirname "$FILE")/Pods")
done < <(find . -name Podfile.lock -not -path './Carthage/*' -type f -print0)

printf -v var '%s,' "${PODFILE_LOCKS[@]}" && echo "PODFILE_LOCKS=${var%,}" >> $GITHUB_OUTPUT
printf -v var '%s,' "${POD_DIRS[@]}" && echo "POD_DIRS=${var%,}" >> $GITHUB_OUTPUT
