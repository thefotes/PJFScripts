#!/bin/bash

set -e

read -e -p "Enter path to Xcode project: " FILES

eval FILES=$FILES

find "$FILES" -type f \( -name "*.h" -or -name "*.m" \) | while read -r f;
do
	MYVAR=$(sed -n '/^#import/p' "$f" | sort | uniq -c | sed -n '/[2-9] #import/p' | sort -nr)
	if [ -n "$MYVAR" ]; then
		echo "$f"
		echo "$MYVAR"
	fi
done
