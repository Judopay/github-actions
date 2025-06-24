#!/bin/bash

PODFILE_LOCKS=""
POD_DIRS=""
while IFS= read -r -d '' FILE; do
  echo "Found Podfile.lock: $FILE"
  PODFILE_LOCKS="${PODFILE_LOCKS}${PODFILE_LOCKS:+,}$FILE"
  POD_DIRS="${POD_DIRS}${POD_DIRS:+,}$(dirname \"$FILE\")/Pods"
  echo "$PODFILE_LOCKS"
  echo "$POD_DIRS"
done < <(find . -name Podfile.lock -not -path './Carthage/*' -type f -print0)

echo "PODFILE_LOCKS=$PODFILE_LOCKS" >> $GITHUB_OUTPUT
echo "POD_DIRS=$POD_DIRS" >> $GITHUB_OUTPUT
