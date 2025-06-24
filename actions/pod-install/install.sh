#!/bin/bash

IFS=','; for FILE in "$PODFILE_LOCKS"; do
   echo "Installing pods for $FILE"
   cd "$(dirname "$FILE")"
   pod install || exit 1
done
