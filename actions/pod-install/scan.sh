#!/bin/bash

$PODFILE_LOCKS=""
$POD_DIRS=""
while IFS= read -r -d '' FILE; do
  echo "Found Podfile.lock: $FILE"
  PODFILE_LOCKS+="$FILE,"
  POD_DIRS+="$(dirname \"$FILE\")/Pods,"
done < <(find . -name Podfile.lock -not -path './Carthage/*' -type f -print0)

echo "PODFILE_LOCKS=blah" >> $GITHUB_OUTPUT
echo "POD_DIRS=blah" >> $GITHUB_OUTPUT
