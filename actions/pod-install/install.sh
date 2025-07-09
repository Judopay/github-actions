#!/bin/bash

while IFS= read -r -d '' FILE; do
  CURR_DIR=$(pwd)
  echo "Installing pods for $FILE"
  cd "$(dirname "$FILE")"
  bundle exec pod install || exit 1
  cd "$CURR_DIR"
done < <(find . -name Podfile.lock -not -path './Carthage/*' -type f -print0)
