#!/bin/bash

while IFS= read -r -d '' FILE; do
  echo "Installing pods for $FILE"
  cd "$(dirname "$FILE")"
  pod install || exit 1
done < <(find . -name Podfile.lock -not -path './Carthage/*' -type f -print0)
